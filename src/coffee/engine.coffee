#
# Implements the OSX-specific parts of Scribe.Engine
#
Scribe.Engine::setTimeout = (fn, d) ->
  @nativeObject['runFunction:afterDelay:repeats:'](fn, d, false)

Scribe.Engine::setInterval = (fn, d) ->
  @nativeObject['runFunction:afterDelay:repeats:'](fn, d, true)

Scribe.Engine::clearTimeout = (d) ->
  @nativeObject.cancelFunction(d)

Scribe.Engine::clearInterval = (d) ->
  @clearTimeout(d)

Scribe.Engine::_repl = ->
  @nativeObject.repl()

Scribe.Engine::_getNativeObject = ->
  @_nativeObject

do ->
  global = @

  # Ensure the current engine reference has been injected
  throw new Error('_currentEngine global not found') unless @_currentEngine?

  # Hook up the Scribe.Engine.current reference
  Scribe.Engine.current = new Scribe.Engine(nativeObject: global._currentEngine);

  # Add some convenience methods if they are missing
  fallbacks = [
    'setTimeout', 'setInterval',
    'clearTimeout', 'clearInterval'
  ]

  # Install each fallback into global scope if it doesn't exist yet
  for fallback in fallbacks
    global[fallback] ?= Scribe.engine[fallback].bind(Scribe.engine)

  # Add a log method to scope
  Scribe.log = ->
    OSX.ScribeEngine.log(Array.prototype.slice.call(arguments).join(' '))
  global.console ?= {}
  global.console.log ?= Scribe.log

