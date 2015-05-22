Mapper = require 'sqlite-orm'
Migration = Mapper.Migration
Q = require 'q'
require '../lib/db-info'
require '../lib/folder'
require '../lib/account'

mapper = null

beforeEach (done) ->
  unless mapper
    mapper = new Mapper require('path').resolve(__dirname, 'temp/test.db')
    mapper.sync().then -> done()
    .catch done
  else
    done()

# afterEach (done) ->
#   Q.all (Model.clear() for name, Model of Mapper.ModelBase.models)
#   .then -> done()
#   .catch done

module.exports = -> mapper
