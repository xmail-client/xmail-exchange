Q = require 'q'
mapper = require '../spec-prepare'

describe.skip 'integration', ->
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

  describe 'Account', ->
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

    it 'syncFolders should get folders', (done) ->
      account.syncFolders()
      .then -> account.folderSyncState.should.ok
      .then -> done()
      .catch done

  describe 'Folder', ->
    Folder = require '../../lib/folder'
    folder = null
    beforeEach (done) ->
      account.createFolderByDistinguishId('inbox').then (newFolder) ->
        folder = newFolder
        done()
      .catch done

    it 'syncMessages should get Message', (done) ->
      folder._syncMessages(10).then (isEnd) ->
        done()
      .catch done
