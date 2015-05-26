Q = require 'q'
mapper = require './spec-prepare'

describe 'ExchangeMessage', ->
  it 'association', (done) ->
    Message = require '../lib/message'
    Mailbox = require '../lib/mailbox'
    FileBuffer = require '../lib/file-buffer'

    console.log Message.prototype.to
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
