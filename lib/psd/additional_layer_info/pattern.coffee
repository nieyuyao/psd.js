module.exports = class Pattern
  @shouldParse: (key) -> key in ['Patt', 'Pat2', 'Pat3']

  parse: ->
    console.log 'todo pattern'
