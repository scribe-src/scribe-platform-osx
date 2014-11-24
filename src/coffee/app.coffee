#
# Implements the OSX-specific portions of the Scribe.App API.
#

Scribe.App::_getName = ->
  lookup = (name) ->
    OSX.NSBundle.mainBundle.objectForInfoDictionaryKey(name)?.toString()
  lookup('CFBundleDisplayName') ? lookup('CFBundleName') ? null

Scribe.App::_getIdentifier = ->
  OSX.NSBundle.mainBundle.bundleIdentifier?.toString() ? null

Scribe.App::_getExePath = ->
  OSX.NSProcessInfo.processInfo.arguments[0].toString()

Scribe.App::_getCwd = ->
  OSX.NSFileManager.defaultManager.currentDirectoryPath.toString()

Scribe.App::_getArguments = ->
  [].slice.call(OSX.NSProcessInfo.processInfo.arguments, 1)

Scribe.App::_getEnv = (varName) ->
  OSX.NSProcessInfo.processInfo.environment[varName]?.toString() ? null

Scribe.App::_setEnv = (varName, value) ->
  OSX.ScribeEngine['setEnvVar:toValue:'](varName, value)

Scribe.App::_setBadge = (label) ->
  OSX.NSApp.dockTile.setBadgeLabel(label)

Scribe.App::_getBadge = ->
  OSX.NSApp.dockTile.badgeLabel?.toString()

Scribe.App::_bounce = ->
  OSX.NSApp.requestUserAttention(OSX.NSCriticalRequest)

Scribe.App::_exit = (status) ->
  OSX.NSApp.terminate(null)

Scribe.App.current = new Scribe.App()
