{Emitter} = require 'event-kit'
{ModelBase} = require 'sqlite-orm'

class Folder
  ModelBase.includeInto this

  @belongsTo Folder, {through: 'parentId', as: 'parent'}
  @hasMany Folder, {as: 'children'}

  constructor: (params) ->
    @initModel params

  # get all of the folders hierarchy
  @syncFolders: ->

  @syncMessages: ->

  constructor: (sequelize) ->
    @flags = 0
    @emitter = new Emitter

  setFlag: (flag) -> @flags |= flag
  hasFlag: (flag) -> @flags & flag

  getChildren: -> @children

  addChild: (childFolder) ->
    @children.push childFolder
    @emitter.emit 'did-add-child', childFolder

  onDidAddChild: (callback) ->
    @emitter.on 'did-add-child', callback

  onDidRemoveChild: (callback) ->
    @emitter.on 'did-remove-child', callback
