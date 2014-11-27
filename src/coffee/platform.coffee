Scribe.Platform::_getName = ->
  'osx'

Scribe.Platform::_getVersion = ->
  OSX.NSProcessInfo
    .processInfo
    .operatingSystemVersionString
    .toString()
    .match(/Version ([\d\.]+)/)[1]

Scribe.Platform.current = new Scribe.Platform
