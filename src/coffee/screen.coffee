#
# Implements the OSX-specific portions of the Scribe.Screen API.
#

Scribe.Screen._getAll = ->
  Array::slice.call(OSX.NSScreen.screens).map (screen) ->
    new Scribe.Screen({ nativeObject: screen })

Scribe.Screen::_getWidth = ->
  @nativeObject.frame.size.width

Scribe.Screen::_getHeight = ->
  @nativeObject.frame.size.height

Scribe.Screen::_getNativeObject = ->
  @_nativeObject;
