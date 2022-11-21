{Module}    = require 'coffeescript-module'
{jspack}    = require 'jspack'
ImageFormat = require '../image_format.coffee'

module.exports = class Pattern extends Module
  @includes ImageFormat.RAW
  @includes ImageFormat.RLE

  constructor: (@file, @length) ->
    @data = []
    @section_end = @file.tell() + @length
    @channelData = null
    @length = 0
    @channelDataHeight = 0

  @shouldParse: (key) -> key in ['Patt', 'Pat2', 'Pat3']

  skip: -> @file.seek @section_end

  parse: ->
    while @file.tell() < @section_end
      parsed = {}
      # length of this pattern
      patternLength = @file.readInt()
      # start position
      start = @file.tell()
      # end position
      end = start + patternLength
      # version
      @file.seek 4, true
      # the image mode of the file
      mode = @file.readInt()
      # point
      @file.seek 4, true
      # name => unicode string
      nameLen = @file.readInt()
      name = @file.readUnicodeString(nameLen)
      parsed.name = name
      # id => pascal string
      idLen = @file.readByte() & 255
      id = @file.readString(idLen)
      parsed.id = id
      if mode == 2
        @file.seek 3 * 256 + 4
      @parseVmArrayList(parsed)
      @data.push parsed
      remainder = patternLength % 4
      if remainder != 0
        patternLength += 4 - remainder;
      @file.seek (start + patternLength - @file.tell()), true
    return
  
  parseVmArrayList: (parsed)->
    # version
    version = @file.readInt()
    # length
    @file.seek 4, true
    # rect
    @file.seek 16, true
    # channels
    channelsCount = @file.readInt()
    channelDatas = []
    # The following is a virtual memory array, repeated for the number of channels + one for a user mask + one for a sheet mask.
    for i in [0...channelsCount + 2]
      # Boolean indicating whether array is written, skip following data if 0.
      written = @file.readInt()
      continue unless written != 0
      dataLen = @file.readInt()
      continue unless dataLen != 0
      # Pixel depth
      @file.seek 4, true
      # Rectangle
      # top
      top = @file.readInt()
      # left
      left = @file.readInt()
      # bottom
      bottom = @file.readInt()
      # right
      right = @file.readInt()
      # width
      width = right - left
      # height
      height = bottom - top
      # Pixel depth
      depth = @file.readShort()
      # comspression mode
      compression = @file.readByte() & 255
      @decompress compression, depth, width, height
      channelDatas.push @channelData
      @channelData = null
    parsed.channelDatas = channelDatas

  channels: -> 1

  height: -> @channelDataHeight

  decompress: (compression, depth, width, height) ->
    depth = Math.max 1, (Math.floor depth / 8)
    switch compression
      when 0
        @length = width * height * depth
        @channelDataHeight = height
        @channelData = new Uint8Array(@length)
        @parseRaw()
      when 1
        @length = width * height * depth
        @channelDataHeight = height
        @channelData = new Uint8Array(@length)
        @parseRLE()
