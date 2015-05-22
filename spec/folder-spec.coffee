Q = require 'q'
mapper = require './spec-prepare'

describe 'ExchangeFolder', ->
  it 'folder can has children and parent', (done) ->
    Folder = require '../lib/folder'
    folders = for i in [0..2]
      Folder.new(name: "folder#{i}")

    Q.all (folder.save() for folder in folders)
    .then ->
      folders[0].children.splice(0, 0, folders[1], folders[2])
    .then ->
      folders[1].parent.should.equal folders[0]
      folders[2].parent.should.equal folders[0]
      Q.all (folder.save() for folder in folders)
    .then -> done()
    .catch done

  it 'test createFromXmlFolder', (done) ->
    Folder = require '../lib/folder'
    xmlFolder =
      folderId: -> {id: 'folderId', changeKey: 'changeKey'}
      displayName: -> 'NAME'

    Folder._createFromXmlFolder(null, xmlFolder, null)
    .then (folder) ->
      Folder.getByFolderId(xmlFolder.folderId())
    .then (folder) ->
      folder.id.should.equal 1
      Folder.removeByXmlFolder(null, xmlFolder)
    .then ->
      Folder.findAll()
    .then (folders) ->
      folders.length.should.equal 0
      done()
    .catch done
