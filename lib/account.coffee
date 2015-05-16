common = require 'xmail-model-common'
{ModelBase} = require 'sqlite-orm'
EWSClient = require 'viewpoint'
Folder = require './folder'

module.exports =
class ExchangeAccount
  ModelBase.includeInto this
  @belongsTo Folder, {through: 'rootFolderId', as: 'rootFolder'}
  @hasMany Folder

  constructor: (params, httpOpts) ->
    @initModel params
    @client = new EWSClient(@username, @password, @url, httpOpts)

  syncFolders: ->
    @client.syncFolders()
