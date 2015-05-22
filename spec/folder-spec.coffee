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
      Q.delay(0)
    .then ->
      folders[1].parent.should.equal folders[0]
      folders[2].parent.should.equal folders[0]
      Q.all (folder.save() for folder in folders)
    .then -> done()
    .catch done
