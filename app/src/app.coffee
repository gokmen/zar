kd = require 'kd.js'

class Zar extends kd.View

  @N = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅']
  @getRandom = ->
    @N[Math.floor Math.random() * 6]

  constructor: (options = {}, data = Zar.getRandom()) ->
    options.cssClass = 'zar'
    super options, data

  pistachio: -> '{{#(0)}}'

  roll: ->
    @setClass 'rolling'
    @setData Zar.getRandom()
    kd.utils.wait 500, @lazyBound 'unsetClass', 'rolling'

class Zarlar extends kd.View

  constructor: (options = {}, data) ->
    options.cssClass = 'zarlar'
    super options, data

    @zarlar = [
      (@addSubView new Zar)
      (@addSubView new Zar)
    ]

  click: ->
    @zarlar.forEach (zar) -> zar.roll()

do ->

  zarlar = new Zarlar
  zarlar.appendToDomBody()
