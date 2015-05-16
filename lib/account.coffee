{Emitter} = require 'event-kit'
PropertyAccessors = require 'property-accessors'
common = require 'xmail-model-common'
{ModelBase} = require 'sqlite-orm'

defAccountModel = ->

module.exports =
class ExchangeAccount
  PropertyAccessors.includeInto this
  ModelBase.includeInto this

  constructor: (params) ->
    @initModel params
