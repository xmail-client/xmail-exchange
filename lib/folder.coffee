{Emitter} = require 'event-kit'
{ModelBase} = require 'sqlite-orm'

module.exports =
class ExchangeFolder
  ModelBase.includeInto this

  @initAssos: ->
    Account = require './account'
    @belongsTo this, {through: 'parentId', as: 'parent'}
    @hasMany this, {through: 'parentId', as: 'children'}
    @belongsTo Account, {through: 'accountId', as: 'account'}

  constructor: (params) ->
    @initModel params
    @flags = 0
    @emitter = new Emitter

  @syncMessages: ->

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

  @updateFromXmlFolder: (account, xmlFolder) ->
    @getByFolderId(xmlFolder.folderId()).then (folder) =>
      if folder then folder else @createFromXmlFolder(account, xmlFolder)

  @createFromXmlFolder: (account, xmlFolder) ->
    @getByFolderId(xmlFolder.parentFolderId()).then (parentFolder) =>
      @_createFromXmlFolder(account, xmlFolder, parentFolder, 0)

  @_createFromXmlFolder: (account, xmlFolder, parentFolder, flag) ->
    newFolder = new ExchangeFolder
      folderId: xmlFolder.folderId().id
      name: xmlFolder.displayName()
      flags: flag ? 0
      account: account
      parent: parentFolder
    newFolder.save().then -> newFolder

  @removeByXmlFolder: (account, xmlFolder) ->
    @getByFolderId(xmlFolder.folderId()).then (folder) ->
      folder.destroy() if folder

  @getByFolderId: (folderId) ->
    @find({folderId: folderId.id})

  @getByFlag: (flag) ->

  @FLAGS =
    INBOX: 0x1, DRAFTS: 0x2, SENT_MAIL: 0x4, TRASH: 0x8, JUNK: 0x10

  @DISTINGUISH_MAP =
    inbox: @FLAGS.INBOX
    drafts: @FLAGS.DRAFTS
    sentitems: @FLAGS.SENT_MAIL
    deleteditems: @FLAGS.TRASH
    junkemail: @FLAGS.JUNK
