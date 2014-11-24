#
# Implements the OSX-specific portions of the Scribe.Window API.
#

global = @

Scribe.Window.instances = []

Scribe.Window::_isVisible = false

Scribe.Window::_createWindow = (opts) ->
  # Build the NSRect that will contain this window
  height       = OSX.NSScreen.mainScreen.frame.size.height
  frame        = { x: 0, y: 0, width: 800, height: 800 }
  frame.y      = height - (opts.top || frame.y)
  frame.x      = opts.left ? frame.x
  frame.width  = opts.width  ? frame.width
  frame.height = opts.height ? frame.height
  rect = OSX.NSMakeRect(frame.x, frame.y, frame.width, frame.height)

  # apply some window-mask flags from options
  opts.chrome = true      unless opts.chrome?
  opts.resizable = true   unless opts.resizable?
  opts.fullscreen = false unless opts.fullscreen?

  styleMask = 0
  styleMask |= OSX.NSTitledWindowMask     if opts.chrome
  styleMask |= OSX.NSResizableWindowMask  if opts.resizable
  styleMask |= OSX.NSClosableWindowMask   if opts.closable
  styleMask |= OSX.NSFullScreenWindowMask if opts.fullscreen

  # create the nativeObject
  @_nativeObject = OSX.ScribeWindow.alloc['initWithContentRect:styleMask:backing:defer:'](
    rect,
    styleMask,
    OSX.NSBackingStoreBuffered,
    false
  )

  # tell the window about its parent context (this)
  @nativeObject.setParentEngine(Scribe.Engine.current.nativeObject)
  @instanceIndex = Scribe.Window.instances.length
  @nativeObject.setParentWindowIndex(@instanceIndex)
  Scribe.Window.instances.push(@)

  # configure some settings in the ScribeWindow's WebView
  opts.sameOriginPolicy = true unless opts.sameOriginPolicy?
  @sameOriginPolicy = !!opts.sameOriginPolicy

  # set up the titlebar if necessary
  @title = opts.title if opts.title?

Scribe.Window::_center = ->
  @nativeObject.center

Scribe.Window::_show = ->
  @nativeObject.makeKeyAndOrderFront({})
  OSX.NSApp.activateIgnoringOtherApps(true)
  @_isVisible = true

Scribe.Window::_hide = ->
  @nativeObject.orderOut({})
  @_isVisible = false
  @trigger('blur')

Scribe.Window::_close = ->
  @nativeObject.close
  @_nativeObject = null
  @_isVisible = false

Scribe.Window::_minimize = ->
  @nativeObject.miniaturize(null)

Scribe.Window::_deminimize = ->
  @nativeObject.deminiaturize(null)

Scribe.Window::_getVisible = ->
  @_isVisible

Scribe.Window::_navigateToURL = (URL) ->
  @nativeObject.navigateToURL(URL)

Scribe.Window::_getNativeObject = ->
  unless @_nativeObject?
    throw new Error("Method called on dead Scribe.Window")
  @_nativeObject

Scribe.Window::_getLeft = ->
  @nativeObject.frame.origin.x

Scribe.Window::_setLeft = (x) ->
  frame = @nativeObject.frame
  rect = OSX.NSMakeRect(
    x,
    frame.origin.y,
    frame.size.width,
    frame.size.height
  )
  @nativeObject['setFrame:display:'](rect, true)

Scribe.Window::_getTop = ->
  height = OSX.NSScreen.mainScreen.frame.size.height
  height - @nativeObject.frame.origin.y

Scribe.Window::_setTop = (y) ->
  height = OSX.NSScreen.mainScreen.frame.size.height
  y = height - y
  frame = @nativeObject.frame
  rect = OSX.NSMakeRect(frame.origin.x, y, frame.size.width, frame.size.height)
  @nativeObject['setFrame:display:'](rect, true)

Scribe.Window::_getWidth = ->
  @nativeObject.frame.size.width

Scribe.Window::_setWidth = (width) ->
  frame = @nativeObject.frame
  rect = OSX.NSMakeRect(frame.origin.x, frame.origin.y, width, frame.size.height)
  @nativeObject['setFrame:display:'](rect, true)

Scribe.Window::_getHeight = ->
  @nativeObject.frame.size.height

Scribe.Window::_setHeight = (height) ->
  frame = @nativeObject.frame
  rect = OSX.NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, height)
  @nativeObject['setFrame:display:'](rect, true)

Scribe.Window::_getFullscreen = ->
  ((@nativeObject.styleMask & OSX.NSFullScreenWindowMask) != 0)

Scribe.Window::_setFullscreen = (fullscreen) ->
  @nativeObject.setCollectionBehavior(OSX.NSWindowCollectionBehaviorFullScreenPrimary)
  if (@fullscreen != fullscreen)
    @nativeObject.toggleFullScreen(@nativeObject)

Scribe.Window::_getResizable = ->
  ((@nativeObject.styleMask & OSX.NSResizableWindowMask) != 0)

Scribe.Window::_setResizable = (resizable) ->
  newMask = if resizable
    @nativeObject.styleMask | OSX.NSResizableWindowMask
  else
    @nativeObject.styleMask & ~OSX.NSResizableWindowMask
  @nativeObject.setStyleMask(newMask)

Scribe.Window::_getClosable = ->
  (@nativeObject.styleMask & OSX.NSClosableWindowMask) != 0

Scribe.Window::_setClosable = (closable) ->
  newMask = if closable
    @nativeObject.styleMask | OSX.NSClosableWindowMask
  else
    @nativeObject.styleMask & ~OSX.NSClosableWindowMask
  @nativeObject.setStyleMask(newMask)

Scribe.Window::_getSameOriginPolicy = ->
  @nativeObject.webView.preferences.isWebSecurityEnabled

Scribe.Window::_setSameOriginPolicy = (sop) ->
  @nativeObject.webView.preferences.setWebSecurityEnabled(sop)

Scribe.Window::_getTitle = ->
  @nativeObject.title?.toString?() ? null

Scribe.Window::_setTitle = (title) ->
  @nativeObject.setTitle(title?.toString?() ? '')

Scribe.Window::_getEngine = ->
  new Scribe.Engine(nativeObject: @nativeObject.scribeEngine)

# Assign the Scribe.Window.current static class variable
if (OSX.ScribeWindow.lastInstance)
  Scribe.Window.current = new Scribe.Window
    nativeObject: OSX.ScribeWindow.lastInstance
