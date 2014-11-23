#
# Implements the OSX-specific portions of the Scribe.App API.
#

Scribe.App::_getName = ->
  "LOLZ!"

Scribe.App::_getIdentifier = ->
  "LOLZ"

Scribe.App::_getExePath = ->
  OSX.NSProcessInfo.processInfo.arguments[0].toString()

Scribe.App::_getCwd = ->
  OSX.NSFileManager.defaultManager.currentDirectoryPath.toString()

Scribe.App::_getArguments = ->
  [].slice.call(OSX.NSProcessInfo.processInfo.arguments, 1)

Scribe.App::_getEnv = ->
  OSX.NSProcessInfo.processInfo.environment

Scribe.App::_exit = (status) ->
  OSX.NSApp.terminate(null)

Scribe.App.current = new Scribe.App()
