#
# Implements the OSX-specific portions of the Scribe.App API.
#

Scribe.App::_getName = ->

Scribe.App::_getIdentifier = ->

Scribe.App::_getExePath = ->

Scribe.App::_getCwd = ->

Scribe.App::_getArguments = ->

Scribe.App::_getEnv = (varName) ->
  if varName?
    OSX.NSProcessInfo.processInfo.environment[varName]
  else
    OSX.NSProcessInfo.processInfo.environment

Scribe.App::_exit = (status) ->
  OSX.NSApp.terminate(null)

Scribe.App.current = new Scribe.App()
