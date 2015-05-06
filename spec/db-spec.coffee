should = require 'should'
Sequelize = require 'sequelize'
path = require 'path'

describe 'create sequelize', ->
  it 'define', (done) ->
    dbPath = path.resolve(__dirname, 'temp/test.db')
    sequelize = new Sequelize 'testdb', null, null,
      storage: dbPath, dialect: 'sqlite'

    userDefine =
      firstName: Sequelize.STRING
      lastName: Sequelize.STRING
    User = sequelize.define 'user', userDefine, timestamps: false

    sequelize.sync {force: true}
    .then ->
      User.create {firstName: 'John', lastName: 'Coco'}
    .then -> done()
