{ModelBase} = require 'sqlite-orm'
Mailbox = require './mailbox'
FileBuffer = require './file-buffer'

module.exports =
class ExchangeMessage
  ModelBase.includeInto this

  @initAssos: ->
    @belongsTo Mailbox, {through: 'to', as: 'to'}
    @belongsTo Mailbox, {through: 'from', as: 'from'}
    @belongsTo FileBuffer, {through: 'body', as: 'body'}

  constructor: (params) ->
    @initModel params

  @createFromXmlMsg: (xmlMsg) ->
    model = new ExchangeMessage

    itemId = xmlMsg.itemId()
    model.itemId = itemId.id
    model.changeKey = itemId.changeKey
    model.subject = xmlMsg.subject()

    body = xmlMsg.body()
    @bodyType = body.bodyType
    FileBuffer.newBuffer().then (stream) ->
      stream.end(body.content)
      stream.on 'model-finish', (buf) -> model.body = buf

    model.sentTime = new Date(xmlMsg.dateTimeSent())
    model.to = Mailbox.create()
    model.isRead = xmlMsg.isRead()

  @removeByMsgId: (msgId) ->
