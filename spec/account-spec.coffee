Q = require 'q'
Account = require '../lib/account'
Folder = require '../lib/folder'

describe 'ExchangeAccount', ->
  it 'account has many folders', (done) ->
    params = {username: 'u', password: 'p', url: 'l', email: 'x'}
    account = Account.new(params)
    folder = Folder.new(name: 'f')

    Q.all [account.save(), folder.save()]
    .then ->
      account.folders.push folder
      account.rootFolder = folder
      Q.delay(0)
    .then ->
      account.folders.length.should.equal(1)
      account.folders[0].should.equal folder
      account.rootFolder.should.equal folder
      folder.account.should.equal account
      done()
    .catch done
