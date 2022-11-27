zlib = require('zlib')
{jspack} = require 'jspack'

module.exports =
  parseZip: ->
    length = @chan.length
    compressed = @file.read(length)
    buf = new Uint8Array(compressed)
    decompressed = zlib.deflateSync(buf)
    @channelData.set decompressed
    return if @compression == 2
    # with prediction
    else
      decoded = @decode_zip_prediction(decompressed)
      @channelData.set decoded

  decode_zip_prediction: (decompressed)->
    if @depth == 8
      arr = new Uint8Array(decompressed)
      delta_decode(arr, @read8, @_width, @_height)
    else if @depth == 16
      arr = new Uint16Array(decompressed)
      delta_decode(arr, @read16, @_width, @_height)
    else if @depth == 32
      arr = new Uint32Array(decompressed)
      delta_decode(arr, @read32, @_width, @_height)
    else throw new Error('Invalid depth. Got #{ depth } .')

  read8: (num) -> num

  read16: (num) ->
    arr = []
    arr[0] = num >> 8
    arr[1] = num & 0xff
    jspack.Unpack '>h', arr
  
  read32: (num) ->
    arr = []
    arr[0] = num >> 24
    arr[1] = (num >> 16) & 0xff
    arr[2] = (num >> 8) & 0xff
    arr[3] = num & 0xff
    jspack.Unpack '>I', arr

  # see: https://github.com/psd-tools/psd-tools/blob/4ff198368eebcda7c8bf385a3129e7481fbae8ab/src/psd_tools/compression/__init__.py#L145
  delta_decode: (arr, readNum, w, h) ->
    for y in [0...h]
      offset = y * w
      for x in [0...(w - 1)]
        pos = offset + x
        nextValue = readNum((arr[pos + 1]) + readNum(arr[pos]))
        arr[pos + 1] = nextValue