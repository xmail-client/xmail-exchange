Q = require 'q'
mapper = require '../spec-prepare'
Server = require 'exchange-test-server'
Account = require '../../lib/account'
http = require 'http'
sinon = require 'sinon'

describe 'integration', ->
  [server, account] = []
  beforeEach (done) ->
    dbPath = require('path').resolve(__dirname, '../temp/server.db')
    server = new Server()
    server.start dbPath: dbPath, done

  afterEach (done) ->
    server.dbInfo.destroyTables().then ->
      server.close done
    .catch done

  describe 'account test', ->
    config = url: 'http://127.0.0.1:3000/EWS/Exchange.asmx'
    beforeEach (done) ->
      opts =
        rejectUnauthorized: false
        agent: http.globalAgent
        # proxy: {host: 'localhost', port: 8888}
        # agent: new require('http').Agent({keepAlive: true})

      account = new Account(config, opts)
      account.save().then -> done()

    it 'createRootFolder should get root Folder', (done) ->
      account.createRootFolder()
      .then -> account.rootFolder.folderId.should.ok
      .then -> done()
      .catch done

    it 'createKnownFolders should get folders', (done) ->
      callback = sinon.spy()
      account.onDidAddFolders callback
      account.createKnownFolders()
      .then ->
        callback.calledOnce.should.true
        account.folders.length.should.greaterThan 0
      .then -> done()
      .catch done

    it 'syncFolders should get folders', (done) ->
      account.
      account.syncFolders()
      .then ->
        account.folderSyncState.should.ok
      .then -> done()
      .catch done

  describe.skip 'Folder', ->
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
