{ModelBase} = require 'sqlite-orm'

module.exports =
class ExchangeMessage
  ModelBase.includeInto this

  @initAssos: ->
    Folder = require './folder'
    @belongsTo Folder, {through: 'folderId', as: 'folder'}
