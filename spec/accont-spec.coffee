should = require 'should'
path = require 'path'
Q = require 'q'
Mapper = require 'sqlite-orm'
Account = require '../lib/account'
Folder = require '../lib/folder'
Migration = Mapper.Migration
require '../lib/db-info'

describe 'ExchangeAccount', ->
  mapper = null

  beforeEach (done) ->
    mapper = new Mapper path.resolve(__dirname, 'temp/test.db')
    mapper.sync().then -> done()
    .catch done

  afterEach (done) ->
    mapper.dropAllTables()
    .then ->
      Migration.clear()
      mapper.close()
      done()
    .catch done

  it 'account has many folders', (done) ->
    params = {username: 'u', password: 'p', url: 'l', email: 'x'}
    account = Account.new(params)
    folder = Folder.new(name: 'f')

    Q.all [account.save(), folder.save()]
    .then ->
      account.folders.push folder
      Q.delay(0)
    .then ->
      account.folders.length.should.equal(1)
      account.folders[0].should.equal folder
      console.log folder.account
      # folder.account.should.equal account
      done()
    .catch done
