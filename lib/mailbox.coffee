{ModelBase} = require 'sqlite-orm'

module.exports =
class Mailbox
  ModelBase.includeInto this

  constructor: (params) ->
    @initModel params
