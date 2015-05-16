should = require 'should'
path = require 'path'
common = require 'xmail-model-common'

describe 'create sequelize', ->
  it 'define', ->
    # dbPath = path.resolve(__dirname, 'temp/test.db')
    # common.setupDB(dbPath, 'testdb')
    # Account = require '../lib/account'
    #
    # common.getDB().sync()
    # .then ->
    #   account = Account.create
    #     username: 'user'
    #     password: 'password'
    #     url: 'url'
    #     email: 'xx@xx'
    #   done()
    # .catch (err) -> done(err)
      # .then ->

      # .then ->
      #   Account.findOne().then (account) ->
      #     console.log account.email
      #     done()
