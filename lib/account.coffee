common = require 'xmail-model-common'
Mapper = require 'sqlite-orm'
{Emitter} = require 'event-kit'
Folder = require './folder'
EWSClient = require 'viewpoint'
Q = require 'q'

ModelBase = Mapper.ModelBase

module.exports =
class ExchangeAccount
  ModelBase.includeInto this

  @initAssos: ->
    @belongsTo Folder, {through: 'rootFolderId', as: 'rootFolder'}
    @hasMany Folder, {through: 'accountId', as: 'folders'}

  constructor: (params, httpOpts) ->
    @initModel params
    @client = new EWSClient(@username, @password, @url, httpOpts)
    @emitter = new Emitter

  onDidAddFolders: (callback) ->
    @emitter.on 'did-add-folders', callback

  onWillRemoveFolders: (callback) ->
    @emitter.on 'will-remove-folders', callback

  onDidRenameFolder: (callback) ->
    @emitter.on 'did-rename-folder', callback

  createFolder: (name, parentFolder) ->
    parent = parentFolder.folderId if parentFolder
    newFolder = new Folder {name: name, account: this, parent}
    newFolder.save().then =>
      @client.createFolders name, {parent: parentFolder?.folderId}
    .then =>
      @emitter.emit 'did-add-folders', [newFolder]
      newFolder

  removeFolder: (folder) ->
    @client.deleteFolders folder.folderId
    .then =>
      @emitter.emit 'will-remove-folders', [folder]
      folder.destroy()

  renameFolder: (folder, name) ->
    @client.updateFolder folder.folderId, {displayName: name}
    .then ->
      folder.displayName = name
      folder.save()
    .then => @emitter.emit 'did-rename-folder', folder

  ROOT_FOLDER_ID = 'msgfolderroot'

  pullRootFolder: ->
    @client.getFolder {id: ROOT_FOLDER_ID, type: 'distinguished'}
    .then (xmlFolder) => Folder._createFromXmlFolder(this, xmlFolder, null, 0)
    .then (rootFolder) =>
      this.rootFolder = rootFolder
      this.save()

  pullKnownFolders: ->
    @pullFoldersByName Folder.DISTINGUISH_MAP

  pullFoldersByName: (nameFlags) ->
    folderIds = for name, flag of nameFlags
      {id: name, type: 'distinguished', flag}
    @client.getFolders(folderIds).then (folders) =>
      Folder.getMapper().scopeTransaction =>
        promises = for xmlFolder, i in folders
          flag = folderIds[i].flag
          Folder._createFromXmlFolder(this, xmlFolder, @rootFolder, flag)
        Q.all promises
    .then (folders) =>
      @emitter.emit 'did-add-folders', folders
      folders

  _createFoldersByXmlFolders: (xmlFolders) ->
    createPromises = for xmlFolder in xmlFolders
      Folder.updateFromXmlFolder(this, xmlFolder)
    Q.all(createPromises).then (folders) =>
      @emitter.emit 'did-add-folders', folders

  _deleteFoldersByXmlFoldera: (xmlFolders) ->
    return Q() if xmlFolders.length is 0
    promises = for xmlFolder in xmlFolders
      Folder.getByFolderId(xmlFolder.folderId())
    Q.all(promises).then (folders) =>
      folders = folders.filter (folder) -> folder?
      @emitter.emit 'will-remove-folders', folders if folders.length > 0
      Q.all (folder.destroy() for folder in folders)

  pullFolders: ->
    @client.syncFoldersWithParent(@folderSyncState).then (res) =>
      @folderSyncState = res.syncState()
      Folder.getMapper().scopeTransaction =>
        Q.all([
          @_createFoldersByXmlFolders(res.creates()),
          @_deleteFoldersByXmlFoldera(res.deletes())
        ]).then => @save()
