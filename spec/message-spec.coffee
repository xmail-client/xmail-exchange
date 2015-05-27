Q = require 'q'
mapper = require './spec-prepare'

describe 'ExchangeMessage', ->
  it 'association', (done) ->
    Message = require '../lib/message'
    Mailbox = require '../lib/mailbox'
    FileBuffer = require '../lib/file-buffer'

    Q.all [
      Message.create({itemId: 'id', changeKey: 'key'}),
      Mailbox.create({name: 'mailbox'}),
      FileBuffer.create({offset: 0, length: 100}),
    ]
    .then (params) ->
      [msg, mailbox, fileBuf] = params
      msg.from = mailbox
      msg.body = fileBuf
      msg.to.push(mailbox)
      msg.fromId.should.equal mailbox.id
      msg.bodyId.should.equal fileBuf.id
      done()
    .catch done

  it 'createFromXmlMsg', (done) ->
    genMailbox = (obj) ->
      name: -> obj.name
      emailAddress: -> obj.emailAddress

    nowDate = new Date
    xmlMsg =
      itemId: -> {id: 'id', changeKey: 'key'}
      subject: -> 'subject'
      body: -> {content: 'HELLO', bodyType: 'text'}
      dateTimeSent: -> nowDate.toISOString()
      from: -> genMailbox {name: 'from', emailAddress: 'from'}
      toRecipients: -> [genMailbox({name: 'to', emailAddress: 'to'})]
      isRead: -> true

    readBody = (msg) ->
      defer = Q.defer()
      stream = msg.body.createReadStream()
      res = []
      stream.on 'data', (chunk) ->
        res.push chunk
      stream.on 'end', ->
        defer.resolve(Buffer.concat(res).toString())
      defer.promise

    Message = require '../lib/message'
    Message.createFromXmlMsg(xmlMsg).then (msg) ->
      msg.parseBody(xmlMsg).then -> msg
    .then (msg) ->
      msg.itemId.should.equal 'id'
      msg.changeKey.should.equal 'key'
      msg.bodyType.should.equal 'text'
      msg.sentTime.getTime().should.equal nowDate.getTime()
      msg.isRead.should.ok
      msg.from.name.should.equal 'from'
      # msg.to.length.should.equal 1
      # msg.to.get(0).name.should.equal 'to'
      readBody(msg)
    .then (body) ->
      body.should.equal 'HELLO'
      done()
    .catch done
