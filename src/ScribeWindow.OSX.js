Scribe.Window.prototype._isVisible = false;

Scribe.Window.prototype._createWindow = function(opts) {
  // Build the NSRect that will contain this window
  var frame = {x: 0, y: 0, width: 800, height: 800};
  frame.x = opts.left || frame.x;
  frame.y = opts.top || frame.y;
  frame.width = opts.width || frame.width;
  frame.height = opts.height || frame.height;
  var rect = OSX.NSMakeRect(frame.x, frame.y, frame.width, frame.height);

  // apply some window-mask flags from options
  if (opts.chrome == null)   opts.chrome = true;
  if (opts.resizable == null) opts.resizable = true;
  if (opts.fullscreen == null) opts.fullscreen = false;

  var styleMask = 0;
  if (opts.chrome)     styleMask |= OSX.NSTitledWindowMask;
  if (opts.resizable)  styleMask |= OSX.NSResizableWindowMask;
  if (opts.closable)   styleMask |= OSX.NSClosableWindowMask;
  if (opts.fullscreen) styleMask |= OSX.NSFullScreenWindowMask;

  // create the nativeWindowObject
  this._nativeWindowObject = OSX.ScribeWindow.alloc['initWithContentRect:styleMask:backing:defer:'](
    rect,
    styleMask,
    OSX.NSBackingStoreBuffered,
    false
  );

  if (opts.sameOriginPolicy == null) opts.sameOriginPolicy = true;
  this.nativeWindowObject.webView.preferences.setWebSecurityEnabled(
    opts.sameOriginPolicy
  );
}

Scribe.Window.prototype._center = function() {
  this.nativeWindowObject.center;
}

Scribe.Window.prototype._show = function() {
  this.nativeWindowObject.makeKeyAndOrderFront(null);
  this._isVisible = true;
}

Scribe.Window.prototype._hide = function() {
  this.nativeWindowObject.hide;
  this._isVisible = false;
}

Scribe.Window.prototype._close = function() {
  this.nativeWindowObject.close;
  this._isVisible = false;
}

Scribe.Window.prototype._getVisible = function() {
  return this._isVisible;
}

Scribe.Window.prototype._navigateToURL = function(URL) {
  this.nativeWindowObject.navigateToURL(URL);
}

Scribe.Window.prototype._getNativeWindowObject = function() {
  return this._nativeWindowObject;
}

Scribe.Window.prototype._getLeft = function() {
  return this.nativeWindowObject.frame.origin.x;
}

Scribe.Window.prototype._setLeft = function(x) {
  var frame = this.nativeWindowObject.frame;
  var rect = OSX.NSMakeRect(
    x,
    frame.origin.y,
    frame.size.width,
    frame.size.height
  );

  this.nativeWindowObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getTop = function() {
  return this.nativeWindowObject.frame.origin.y;
}

Scribe.Window.prototype._setTop = function(y) {
  var frame = this.nativeWindowObject.frame;
  var rect = OSX.NSMakeRect(
    frame.origin.x,
    y,
    frame.size.width,
    frame.size.height
  );

  this.nativeWindowObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getWidth = function() {
  return this.nativeWindowObject.frame.size.width;
}

Scribe.Window.prototype._setWidth = function(width) {
  var frame = this.nativeWindowObject.frame;
  var rect = OSX.NSMakeRect(
    frame.origin.x,
    frame.origin.y,
    width,
    frame.size.height
  );

  this.nativeWindowObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getHeight = function() {
  return this.nativeWindowObject.frame.size.height;
}

Scribe.Window.prototype._setHeight = function(height) {
  var frame = this.nativeWindowObject.frame;
  var rect = OSX.NSMakeRect(
    frame.origin.x,
    frame.origin.y,
    frame.size.width,
    height
  );

  this.nativeWindowObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getFullscreen = function() {
  return ((this.nativeWindowObject.styleMask & OSX.NSFullScreenWindowMask) != 0);
}

Scribe.Window.prototype._setFullscreen = function(fullscreen) {
  this.nativeWindowObject.setCollectionBehavior(OSX.NSWindowCollectionBehaviorFullScreenPrimary);
  if (this.fullscreen != fullscreen) {
    this.nativeWindowObject.toggleFullScreen(this.nativeWindowObject);
  }
}

Scribe.Window.prototype._getResizable = function() {
  return ((this.nativeWindowObject.styleMask & OSX.NSResizableWindowMask) != 0);
}

Scribe.Window.prototype._setResizable = function(resizable) {
  var newMask;
  if (resizable){
    var newMask = this.nativeWindowObject.styleMask | OSX.NSResizableWindowMask;
  } else {
    var newMask = this.nativeWindowObject.styleMask & ~OSX.NSResizableWindowMask;
  }
  this.nativeWindowObject.setStyleMask(newMask);
}

Scribe.Window.prototype._getClosable = function() {
  return ((this.nativeWindowObject.styleMask & OSX.NSClosableWindowMask) != 0);
}

Scribe.Window.prototype._setClosable = function(closable) {
  var newMask;
  if (closable){
    var newMask = this.nativeWindowObject.styleMask | OSX.NSClosableWindowMask;
  } else {
    var newMask = this.nativeWindowObject.styleMask & ~OSX.NSClosableWindowMask;
  }
  this.nativeWindowObject.setStyleMask(newMask);
}

Scribe.Window.prototype._getSameOriginPolicy = function() {
  return this.nativeWindowObject.webView.preferences.webSecurityEnabled;
}

Scribe.Window.prototype._setSameOriginPolicy = function(sop) {
  throw new Error("Cannot set the sameOriginPolicy property.");
}

