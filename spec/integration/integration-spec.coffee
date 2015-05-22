Q = require 'q'
mapper = require '../spec-prepare'

describe 'integration', ->
  config = require './config.json'
  Account = require '../../lib/account'
  account = null

  beforeEach (done) ->
    opts =
      rejectUnauthorized: false
      proxy: {host: 'localhost', port: 8888}
      agent: new require('http').Agent({keepAlive: true})

    account = new Account(config, opts)
    account.save().then -> done()

  it 'createRootFolder should get root Folder', (done) ->
    account.createRootFolder()
    .then -> account.rootFolder.folderId.should.ok
    .then -> done()
    .catch done

  it 'createKnownFolders should get folders', (done) ->
    account.createKnownFolders()
    .then -> account.folders.length.should.greaterThan 0
    .then -> done()
    .catch done

  it.only 'syncFolders should get folders', (done) ->
    account.syncFolders()
    .then -> account.folderSyncState.should.ok
    .then -> done()
    .catch done
