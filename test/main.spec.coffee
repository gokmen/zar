describe 'zar test', ->

  page = null

  before ->
    page = await browser.newPage()
    await page.goto 'http://localhost:9000'

  after ->
    await page.close()

  it 'should have zar in page title', ->
    expect(await page.title()).to.eql 'zar'

  it 'should have the zarlar in it', ->
    SELECTOR = '.zarlar > div'

    await page.waitFor SELECTOR
