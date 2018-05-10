puppeteer = require 'puppeteer'
{ expect } = require 'chai'
_ = require 'lodash'
globalVariables = _.pick global, ['browser', 'expect']

opts =
  headless: yes
  timeout: 10000


before ->

  global.expect = expect
  global.browser = await puppeteer.launch opts


after ->

  global.browser.close()

  global.browser = globalVariables.browser
  global.expect = globalVariables.expect
