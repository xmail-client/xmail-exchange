common = require 'xmail-model-common'
Mapper = require 'sqlite-orm'
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

  syncFolders: ->
    @client.syncFoldersWithParent(@folderSyncState).then (res) =>
      @folderSyncState = res.syncState()
      Folder.getMapper().scopeTransaction =>
        promises = []
        for xmlFolder in res.creates()
          promises.push Folder.updateFromXmlFolder(this, xmlFolder)
        for xmlFolder in res.deletes()
          promises.push Folder.removeByXmlFolder(this, xmlFolder)
        Q.all promises
