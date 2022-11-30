PSD = require '../'
path = require 'path'
should = require 'should'


describe "mask", ->
  it "layer mask", () ->
    psdPath = path.resolve(__dirname, "../", "examples/mask/layer_mask.psd")
    PSD
    .open(psdPath)
    .then (psd) ->
      { image } = psd.layers[0]
      png = image.maskToPng()
      png.width.should.eql(200)
      png.height.should.eql(200)


  it "real user mask", () ->
    psdPath = path.resolve(__dirname, "../", "examples/mask/user_vector_mask.psd")
    PSD
    .open(psdPath)
    .then (psd) ->
      { image } = psd.layers[0]
      png = image.realUserMaskToPng()
      png.width.should.eql(225)
      png.height.should.eql(163)
