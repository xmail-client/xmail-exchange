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

  ROOT_FOLDER_ID = 'msgfolderroot'

  createRootFolder: ->
    @client.getFolder {id: ROOT_FOLDER_ID, type: 'distinguished'}
    .then (xmlFolder) => Folder._createFromXmlFolder(this, xmlFolder, null, 0)
    .then (rootFolder) =>
      this.rootFolder = rootFolder
      this.save()

  createFolderByDistinguishId: (name, flag) ->
    folderId = {id: name, type: 'distinguished'}
    @client.getFolder(folderId).then (xmlFolder) =>
      Folder._createFromXmlFolder(this, xmlFolder, @rootFolder, flag)

  createKnownFolders: ->
    folderIds = for name, flag of Folder.DISTINGUISH_MAP
      {id: name, type: 'distinguished', flag}
    @client.getFolders(folderIds).then (folders) =>
      Folder.getMapper().scopeTransaction =>
        promises = for xmlFolder, i in folders
          flag = folderIds[i].flag
          Folder._createFromXmlFolder(this, xmlFolder, @rootFolder, flag)
        Q.all promises
    .then (folders) =>
      @emitter.emit 'did-add-folders', folders

  _createFolders: (xmlFolders) ->
    createPromises = for xmlFolder in xmlFolders
      Folder.updateFromXmlFolder(this, xmlFolder)
    Q.all(createPromises).then (folders) =>
      @emitter.emit 'did-add-folders', folders

  _deleteFolders: (xmlFolders) ->
    promises = for xmlFolder in xmlFolders
      Folder.getByFolderId(xmlFolder.folderId())
    promises.then (folders) =>
      folders = folders.filter (folder) -> folder?
      @emitter.emit 'will-remove-folders', folders
      Q.all (folder.destroy() for folder in folders)

  syncFolders: ->
    @client.syncFoldersWithParent(@folderSyncState).then (res) =>
      @folderSyncState = res.syncState()
      Folder.getMapper().scopeTransaction =>
        Q.all [
          @_createFolders(res.creates()),
          @_deleteFolders(res.deletes())
        ]
