Q = require 'q'
path = require 'path'
fs = require 'fs'
mapper = require './spec-prepare'
FileBuffer = require '../lib/file-buffer'

describe 'FileBuffer', ->
  it 'newBuffer', (done) ->
    filePath = path.resolve(__dirname, 'temp/test.txt')
    if fs.existsSync (filePath)
      fs.unlinkSync(filePath)
    writtenStr = ''
    FileBuffer.initFile(filePath).then ->
      promises = [1..2].map (i) ->
        FileBuffer.newBuffer().then (stream) ->
          writtenStr += (buf = "HELLO WORLD#{i}")
          stream.end(buf)
          defer = Q.defer()
          stream.on 'model-finish', (model) ->
            defer.resolve()
          defer.promise
      Q.all promises
    .then ->
      Q.ninvoke(fs, 'readFile', filePath, {encoding: 'utf8'}).then (str) ->
        str.should.equal writtenStr
    .then -> Q.all [FileBuffer.getById(1), FileBuffer.getById(2)]
    .then ([model1, model2]) ->
      model1.offset.should.equal 0
      model2.offset.should.equal model1.offset + model1.length
    .then -> done()
    .catch done
