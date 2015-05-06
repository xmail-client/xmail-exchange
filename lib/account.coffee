{Emitter} = require 'event-kit'
PropertyAccessors = require 'property-accessors'

class Account
  PropertyAccessors.includeInto this

  @::accessor 'email',
    get: -> @email
    set: (@email) ->

  @::accessor 'username',
    get: -> @username
    set: (@username) ->

  @::accessor 'password',
    get: -> @password
    set: (@password) ->

  @::accessor 'url',
    get: -> @url
    set: (@url) ->
