{ModelBase} = require 'sqlite-orm'
fs = require 'fs'
Q = require 'q'

module.exports =
class FileBuffer
  ModelBase.includeInto this

  constructor: (params) ->
    @initModel params

  @initFile: (@path) ->
    @requests = []
    Q.ninvoke(fs, 'open', @path, 'w+')
    .then (fd) -> Q.ninvoke(fs, 'fstat', fd)
    .then ({size}) => @fileSize = size

  createReadStream: (opts={}) ->
    opts.start = @offset
    opts.end = @offset + @length - 1
    fs.createReadStream(FileBuffer.path, opts)

  @_createNewRequest: ->
    offset = @fileSize
    stream = fs.createWriteStream @path, {flags: 'a'}
    stream.on 'finish', =>
      @fileSize += stream.bytesWritten
      @create({offset: offset, length: stream.bytesWritten}).then (model) =>
        @isBusy = false
        @_schedule()
        stream.emit 'model-finish', model
    stream

  @_schedule: ->
    if not @isBusy and @requests.length > 0
      defer = @requests.shift()
      defer.resolve @_createNewRequest()
      @isBusy = true

  @newBuffer: ->
    defer = Q.defer()
    @requests.push defer
    @_schedule()
    defer.promise
