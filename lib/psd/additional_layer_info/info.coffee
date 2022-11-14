Util = require '../util.coffee'

INFOS = {
  pattern: require './pattern.coffee'
}

module.exports =
  parse: (file) ->
    # sig
    file.seek 4, true # sig
    key = file.readString(4)
    console.log key
    file.seek 20, true # sig
    key = file.readString(4)
    console.log key
    length = Util.pad2 file.readInt()
    file.seek 12, true
    file.seek 4, true
    id = file.read(4)
    console.log length, file.readUnicodeString(15)
    # while file.tell() < infoLen
    #   for own name, klass of INFOS
    #     continue unless klass.shouldParse(key)
    #     i = new klass(file, length)


