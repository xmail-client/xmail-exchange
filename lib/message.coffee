{ModelBase} = require 'sqlite-orm'
Mailbox = require './mailbox'
FileBuffer = require './file-buffer'

module.exports =
class ExchangeMessage
  ModelBase.includeInto this

  @initAssos: ->
    # @belongsTo Mailbox, {through: 'from', as: 'from'}
    @belongsTo FileBuffer, {through: 'body', as: 'body'}
    # @hasManyBelongsTo Mailbox,
    #   midTableName: 'ExchangeToMailBox', sourceThrough: 'messageId', as: 'to'

  constructor: (params) ->
    @initModel params

  @createFromXmlMsg: (xmlMsg) ->
    promises = []
    model = new ExchangeMessage

    itemId = xmlMsg.itemId()
    model.itemId = itemId.id
    model.changeKey = itemId.changeKey
    model.subject = xmlMsg.subject()

    body = xmlMsg.body()
    @bodyType = body.bodyType
    promises.push model._writeBody(body.content)

    model.sentTime = new Date(xmlMsg.dateTimeSent())

    promises.push @_createMailbox(xmlMsg.from()).then (mailbox) ->
      model.from = mailbox

    for toXml in xmlMsg.toRecipients()
      promises.push @_createMailbox(toXml).then (mailbox) ->
        model.to.push mailbox
    model.isRead = xmlMsg.isRead()

    Q.all(promises).then ->
      model.save()
      model

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
