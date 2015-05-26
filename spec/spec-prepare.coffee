Mapper = require 'sqlite-orm'
Migration = Mapper.Migration
Q = require 'q'
require '../lib/db-info'
require '../lib/folder'
require '../lib/account'
FileBuffer = require '../lib/file-buffer'
require '../lib/mailbox'
require '../lib/message'

mapper = null

beforeEach (done) ->
  unless mapper
    path = require('path')
    mapper = new Mapper path.resolve(__dirname, 'temp/test.db')
    mapper.sync().then ->
      FileBuffer.initFile path.resolve(__dirname, 'temp/test.bin')
    .then -> done()
    .catch done
  else
    done()

afterEach (done) ->
  Q.all (Model.clear() for name, Model of Mapper.ModelBase.models)
  .then -> done()
  .catch done

module.exports = -> mapper
