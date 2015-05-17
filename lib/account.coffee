common = require 'xmail-model-common'
{ModelBase} = require 'sqlite-orm'
EWSClient = require 'viewpoint'

module.exports =
class ExchangeAccount
  ModelBase.includeInto this

  @initAssos: ->
    Folder = require './folder'
    # @belongsTo Folder, {through: 'rootFolderId', as: 'rootFolder'}
    @hasMany Folder, as: 'folders'

  constructor: (params, httpOpts) ->
    @initModel params
    @client = new EWSClient(@username, @password, @url, httpOpts)

  syncFolders: ->
    @client.syncFolders()
