should = require 'should'
Sequelize = require 'sequelize'
path = require 'path'
common = require 'xmail-model-common'

describe 'create sequelize', ->
  it 'define', (done) ->
    dbPath = path.resolve(__dirname, 'temp/test.db')
    common.setupDB(dbPath, 'testdb')
    Account = require '../lib/account'

    common.getDB().sync()
    .then ->
      account = Account.create
        username: 'user'
        password: 'password'
        url: 'url'
        email: 'xx@xx'
      done()
    .catch (err) -> done(err)
      # .then ->

      # .then ->
      #   Account.findOne().then (account) ->
      #     console.log account.email
      #     done()
