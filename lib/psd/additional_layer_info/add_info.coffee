Util = require '../util.coffee'
LazyExecute = require '../lazy_execute.coffee'

ADD_INFOS = {
  pattern: require './pattern.coffee'
}

module.exports =
  parse: (file, infos, remaining_size) ->
    end_pos = file.tell() + remaining_size
    while file.tell() < end_pos
      keyParseable = false
      # sig
      file.seek 4, true
      # key
      key = file.readString(4)
      # content length
      length = Util.pad2 file.readInt()
      for own name, klass of ADD_INFOS
        continue unless klass.shouldParse(key)
        keyParseable = true
        inst = new klass(file, length)
        infos[name] = new LazyExecute(inst, file)
          .now('skip')
          .later('parse')
          .get()
        break
      file.seek length, true if keyParseable
