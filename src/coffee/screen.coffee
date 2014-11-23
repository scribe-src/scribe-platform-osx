Scribe.Screen._getAll = ->
  [].slice.call(OSX.NSScreen.screens).map (screen) ->
    new Scribe.Screen({ nativeObject: screen })

Scribe.Screen::_getWidth = ->
  @nativeObject.frame.size.width

Scribe.Screen::_getHeight = ->
  @nativeObject.frame.size.height

Scribe.Screen::_getNativeObject = ->
  @_nativeObject;
