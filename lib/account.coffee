common = require 'xmail-model-common'
{ModelBase} = require 'sqlite-orm'
Folder = require './folder'
EWSClient = require 'viewpoint'

module.exports =
class ExchangeAccount
  ModelBase.includeInto this

  @initAssos: ->
    @belongsTo Folder, {through: 'rootFolderId', as: 'rootFolder'}
    @hasMany Folder, as: 'folders'

  constructor: (params, httpOpts) ->
    @initModel params
    @client = new EWSClient(@username, @password, @url, httpOpts)

  syncFolders: ->
    for name, flag of Folder.DISTINGUISH_MAP
      @client.getFolder({id: name, type: 'distinguished'})
    @client.syncFolders()
