{Emitter} = require 'event-kit'

class Folder
  # get all of the folders hierarchy
  @syncFolders: ->

  @load: ->

  @folderFlags =
    INBOX: 0
    TRASH: 1

  constructor: ->
    @children = []
    @flag = 0
    @emitter = new Emitter

  setName: (@name) ->
  getName: -> @name

  setFlag: (flag) -> @flag |= flag
  hasFlag: (flag) -> @flag & flag

  getChildren: -> @children

  addChild: (childFolder) ->
    @children.push childFolder
    @emitter.emit 'did-add-child', childFolder

  onDidAddChild: (callback) ->
    @emitter.on 'did-add-child', callback

  onDidRemoveChild: (callback) ->
    @emitter.on 'did-remove-child', callback

  save: ->
