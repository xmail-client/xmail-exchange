Mapper = require 'sqlite-orm'
Migration = Mapper.Migration
require '../lib/db-info'

exports.mapper = mapper = null

beforeEach (done) ->
  mapper = new Mapper require('path').resolve(__dirname, 'temp/test.db')
  mapper.sync().then -> done()
  .catch done

afterEach (done) ->
  mapper.dropAllTables()
  .then ->
    Migration.clear()
    mapper.close()
    done()
  .catch done
