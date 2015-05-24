{ModelBase} = require 'sqlite-orm'
fs = require 'fs'
Q = require 'q'

module.exports =
class FileBuffer
  ModelBase.includeInto this

  constructor: (params) ->
    @initModel params
    @requests = []

  @initFile: (@path) ->
    Q.ninvoke(fs, 'open', @path, 'a+').then (@fd) ->
      Q.ninvoke fs, 'fstat', @fd
    .then ({size}) => @fileSize = size

  @close: ->
    Q.ninvoke fs, 'close', @fd if @fd

  createReadStream: (opts={}) ->
    opts.start = @offset
    opts.end = @offset + @length - 1
    fs.createReadStream(FileBuffer.path, opts)

  @_createNewRequest: ->
    offset = @fileSize
    stream = fs.createWriteStream null, {flags: 'a', fd: @fd}
    stream.on 'finish', =>
      @fileSize += bytesWritten
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
