gulp            = require 'gulp'
gutil           = require 'gulp-util'
mocha           = require 'gulp-spawn-mocha'
stylus          = require 'gulp-stylus'
uglify          = require('gulp-uglify-es').default
streamify       = require 'gulp-streamify'
CSSmin          = require 'gulp-minify-css'

rimraf          = require 'rimraf'
source          = require 'vinyl-source-stream'
coffeeify       = require 'coffeeify'
browserify      = require 'browserify'

production      = process.env.NODE_ENV is 'production'
browserSync     = require('browser-sync').create()

# to make browser-sync catch all the routes and redirect them to index.html,
# kind of SPA mode.
# see:
# https://github.com/BrowserSync/browser-sync/issues/204#issuecomment-60410751
historyFallback = require 'connect-history-api-fallback'

openApp         = yes
globalBundler   = null

paths           =
  scripts       :
    watch       : './app/src/*.coffee'
    source      : './app/src/app.coffee'
    destination : './dist/js/'
    filename    : './app.js'
    vendor      : './vendor.js'
  styles        :
    source      : './app/styl/app.styl'
    watch       : './app/styl/*.styl'
    destination : './dist/css/'
  entryPoint    :
    source      : './app/index.html'
    watch       : './app/index.html'
    destination : './dist/'
  images        :
    source      : './app/images/*'
    destination : './dist/images/'
  test          :
    app         : './dist/**/*'
    cases       : './test/*.coffee'


handleError = (err) ->
  err = err.message  if err.message?
  gutil.log err
  gutil.beep()
  this.emit 'end'


getBrowserifiedBundler = ->

  return globalBundler  if globalBundler

  globalBundler  = browserify
    cache        : {}
    packageCache : {}
    fullPaths    : no
    entries      : [ paths.scripts.source ]
    extensions   : [ '.coffee' ]
    transform    : [ 'coffeeify' ]
    debug        : !production

  globalBundler.external 'kd.js'

  return globalBundler


gulp.task 'compile-vendors', ->

  vendorBundler = browserify
    cache        : {}
    packageCache : {}
    fullPaths    : no
    require      : 'kd.js'
    debug        : !production

  bundle = vendorBundler.bundle()
    .on 'error', handleError
    .pipe source paths.scripts.vendor

  bundle.pipe streamify uglify()  if production
  bundle
    .pipe gulp.dest paths.scripts.destination
    .pipe browserSync.reload stream: yes


gulp.task 'compile-scripts', ->

  bundle = getBrowserifiedBundler().bundle()
    .on 'error', handleError
    .pipe source paths.scripts.filename

  bundle.pipe streamify uglify()  if production
  bundle
    .pipe gulp.dest paths.scripts.destination
    .pipe browserSync.reload stream: yes


gulp.task 'watch', ->

  gulp.watch paths.styles.watch, [ 'styles' ]
  gulp.watch paths.scripts.watch, [ 'compile-scripts' ]


gulp.task 'styles', ->

  styles = gulp
    .src paths.styles.source
    .pipe stylus set: ['include css']
    .on 'error', handleError

  styles = styles.pipe CSSmin()  if production

  styles
    .pipe gulp.dest paths.styles.destination
    .pipe browserSync.reload stream: yes


gulp.task 'server', [ 'compile' ], ->

  gulp.start [ 'run-server' ]


gulp.task 'run-server', ->

  browserSync.init
    notify       : no
    open         : openApp
    port         : 9000
    server       :
      baseDir    : './dist'
      middleware : [ historyFallback() ]


gulp.task 'entry-point', ->

  gulp
    .src  paths.entryPoint.source
    .pipe gulp.dest paths.entryPoint.destination


gulp.task 'images', ->

  gulp
    .src  paths.images.source
    .pipe gulp.dest paths.images.destination


gulp.task 'export-kd', ->

  # Just copy kd.css to dist
  gulp
    .src            './node_modules/kd.js/dist/kd.css'
    .pipe gulp.dest './dist/css/'


gulp.task 'clean', (cb) -> rimraf './dist', cb

gulp.task 'enable-test-watch', [ 'default' ], ->

  gulp.watch paths.test.app,   [ 'single-test' ]
  gulp.watch paths.test.cases, [ 'single-test' ]

  gulp.start 'single-test'

gulp.task 'enable-prod', -> production = yes

gulp.task 'disable-open', -> openApp = no

gulp.task 'prod-build', [ 'enable-prod', 'serve-only', 'test' ]

gulp.task 'production', [ 'prod-build' ], ->

  gutil.log 'Building for production is completed,
             you can now deploy ./dist folder'

gulp.task 'test', [ 'disable-open', 'serve-only' ], (done) ->

  gulp
    .src ['./test/*.coffee'], read: no
    .pipe mocha
      reporter: 'list'
      require: 'coffeescript/register'

    .on 'end', ->
      browserSync.exit()

    .once 'error', ->
      @emit 'end'

gulp.task 'single-test', ->

  gulp
    .src ['./test/*.coffee'], read: no
    .pipe mocha
      reporter: 'list'
      require: 'coffeescript/register'

    .once 'error', ->
      @emit 'end'


gulp.task 'test-watch', [ 'enable-test-watch' ]

gulp.task 'compile', [ 'compile-vendors', 'compile-scripts' ]

gulp.task 'build',   [
  'compile', 'styles', 'entry-point', 'export-kd', 'images'
]

gulp.task 'serve-only', [
  'build', 'server'
]

gulp.task 'default', [
  'build', 'watch', 'server'
]
