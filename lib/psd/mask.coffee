# Each layer/group in the PSD document can have a mask, which is
# represented by this class. The mask describes which parts of the
# layer are visible and which are hidden.
module.exports = class Mask
  constructor: (@file, @channelsInfo) ->
    @top = 0
    @right = 0
    @bottom = 0
    @left = 0
    @realUserMask = null

  parse: ->
    # If there is no mask, then this section will have a size of zero
    # and we can move on to the next.
    @size = @file.readInt()
    return @ if @size is 0

    maskEnd = @file.tell() + @size

    # First, we parse the coordinates of the mask.
    @top = @file.readInt()
    @left = @file.readInt()
    @bottom = @file.readInt()
    @right = @file.readInt()

    @defaultColor = @file.readByte()
    @flags = @file.readByte()

    # We can then easily derive the dimensions from the box coordinates.
    @width = @right - @left
    @height = @bottom - @top

    # Each mask defines a couple of flags that are used as extra metadata.
    @relative = (@flags & 0x01) > 0
    @disabled = (@flags & (0x01 << 1)) > 0
    @invert = (@flags & (0x01 << 2)) > 0

    if @flags & 0x10
      @parseRealUserMask()

    @file.seek maskEnd
    return @
  
  parseRealUserMask: ->
    exist = false
    for chan in @channelsInfo
      exist = if chan.id == -3 then true else false
      break if exist
    return if !exist
    @realUserMask = {}
    # flag
    @file.seek 1, true
    # color
    @realUserMask.color = @file.readByte()
    @realUserMask.top = @file.readInt()
    @realUserMask.left = @file.readInt()
    @realUserMask.height = @file.readInt() - @realUserMask.top
    @realUserMask.width = @file.readInt() - @realUserMask.left

  export: ->
    return {} if @size is 0

    top: @top
    left: @left
    bottom: @bottom
    right: @right
    width: @width
    height: @height
    defaultColor: @defaultColor
    relative: @relative
    disabled: @disabled
    invert: @invert
    realUserMask: @realUserMask
