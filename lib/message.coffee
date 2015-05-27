{ModelBase} = require 'sqlite-orm'
Mailbox = require './mailbox'
FileBuffer = require './file-buffer'
Q = require 'q'

module.exports =
class ExchangeMessage
  ModelBase.includeInto this

  @initAssos: ->
    @belongsTo Mailbox, {through: 'fromId', as: 'from'}
    @belongsTo FileBuffer, {through: 'bodyId', as: 'body'}
    @belongsTo 'ExchangeFolder', {through: 'folderId', as: 'folder'}
    @hasManyBelongsTo Mailbox,
      midTableName: 'ExchangeToMailBox', sourceThrough: 'messageId', as: 'to'

  constructor: (params) ->
    @initModel params

  @createFromXmlMsg: (xmlMsg, folder) ->
    model = new ExchangeMessage
    model.folder = folder if folder
    itemId = xmlMsg.itemId()
    model.itemId = itemId.id
    model.changeKey = itemId.changeKey
    model.subject = xmlMsg.subject()

    model.sentTime = new Date(xmlMsg.dateTimeSent())
    model.isRead = xmlMsg.isRead()

    model.save().then =>
      promises = []
      promises.push @_createMailbox(xmlMsg.from()).then (mailbox) ->
        model.from = mailbox
      # for toXml in xmlMsg.toRecipients()
      #   promises.push @_createMailbox(toXml).then (mailbox) ->
      #     model.to.push mailbox
      Q.all promises
    .then -> model.save()
    .then -> model

  parseBody: (xmlMsg) ->
    body = xmlMsg.body()
    @bodyType = body.bodyType
    @_writeBody(body.content)

  _writeBody: (content) ->
    self = this
    defer = Q.defer()
    FileBuffer.newBuffer().then (stream) ->
      stream.end(content)
      stream.on 'model-finish', (buf) ->
        self.body = buf
        defer.resolve()
    defer.promise

  @_createMailbox: (xmlMailbox) ->
    Mailbox.create {name: xmlMailbox.name(), email: xmlMailbox.emailAddress()}

  @removeByMsgId: (msgId) ->
