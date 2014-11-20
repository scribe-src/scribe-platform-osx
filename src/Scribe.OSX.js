(function() {

var global = this;

Scribe.Window.instances = [];

Scribe.Window.prototype._isVisible = false;

Scribe.Window.prototype._createWindow = function(opts) {
  // Build the NSRect that will contain this window
  var height = OSX.NSScreen.mainScreen.frame.size.height;
  var frame    = {x: 0, y: 0, width: 800, height: 800};
  frame.y      = height - (opts.top || frame.y);
  frame.x      = opts.left   || frame.x;
  frame.width  = opts.width  || frame.width;
  frame.height = opts.height || frame.height;
  var rect = OSX.NSMakeRect(frame.x, frame.y, frame.width, frame.height);

  // apply some window-mask flags from options
  if (opts.chrome == null)     opts.chrome = true;
  if (opts.resizable == null)  opts.resizable = true;
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

  // tell the window about its parent context (this)
  this.nativeWindowObject.setParentEngine(Scribe.Engine._current);
  this.instanceIndex = Scribe.Window.instances.length;
  this.nativeWindowObject.setParentWindowIndex(this.instanceIndex);
  Scribe.Window.instances.push(this);

  // configure some settings in the ScribeWindow's WebView
  if (opts.sameOriginPolicy == null) opts.sameOriginPolicy = true;
  this.sameOriginPolicy = !!opts.sameOriginPolicy;

  // set up the titlebar if necessary
  if (opts.title != null) this.title = opts.title;

}

Scribe.Window.prototype._center = function() {
  this.nativeWindowObject.center;
}

Scribe.Window.prototype._show = function() {
  this.nativeWindowObject.makeKeyAndOrderFront({});
  OSX.NSApp.activateIgnoringOtherApps(true);
  this._isVisible = true;
}

Scribe.Window.prototype._hide = function() {
  this.nativeWindowObject.orderOut({});
  this._isVisible = false;
  this.trigger('blur');
}

Scribe.Window.prototype._close = function() {
  this.nativeWindowObject.close;
  this._nativeWindowObject = null;
  this._isVisible = false;
}

Scribe.Window.prototype._minimize = function() {
  this.nativeWindowObject.miniaturize(null);
}

Scribe.Window.prototype._deminimize = function() {
  this.nativeWindowObject.deminiaturize(null);
}

Scribe.Window.prototype._getVisible = function() {
  return this._isVisible;
}

Scribe.Window.prototype._navigateToURL = function(URL) {
  this.nativeWindowObject.navigateToURL(URL);
}

Scribe.Window.prototype._getNativeWindowObject = function() {
  if (!this._nativeWindowObject) {
    throw new Error("Method called on dead Scribe.Window");
  }
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
  var height = OSX.NSScreen.mainScreen.frame.size.height;
  return height - this.nativeWindowObject.frame.origin.y;
}

Scribe.Window.prototype._setTop = function(y) {
  var height = OSX.NSScreen.mainScreen.frame.size.height;
  y = height - y;
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
  return this.nativeWindowObject.webView.preferences.isWebSecurityEnabled;
}

Scribe.Window.prototype._setSameOriginPolicy = function(sop) {
  this.nativeWindowObject.webView.preferences.setWebSecurityEnabled(sop);
}

Scribe.Window.prototype._getTitle = function() {
  return this.nativeWindowObject.title.toString();
}

Scribe.Window.prototype._setTitle = function(title) {
  this.nativeWindowObject.setTitle(title);
}


// Assign the Scribe.Window.current static class variable
if (OSX.ScribeWindow.lastInstance) {
  Scribe.Window.current = new Scribe.Window({
    nativeWindowObject: OSX.ScribeWindow.lastInstance
  });
}


Scribe.Screen._getAll = function() {
  return [].slice.call(OSX.NSScreen.screens).map(function(screen) {
    return new Scribe.Screen({ nativeScreenObject: screen });
  });
};

Scribe.Screen.prototype._getWidth = function() {
  return this.nativeScreenObject.frame.size.width;
};

Scribe.Screen.prototype._getHeight = function() {
  return this.nativeScreenObject.frame.size.height;
};

Scribe.Screen.prototype._getNativeScreenObject = function() {
  return this._nativeScreenObject;
};

// Add a native hook to window.open():
(function() {

  function params(searchString) {
    var paramValue = '';
    var params = searchString.split('&');
    var retObject = {};
    for (i = 0; i < params.length; i++) {
      var paramPair = params[i];
      var eqlIndex = paramPair.indexOf('=');
      var paramName = paramPair.substring(0, eqlIndex);
      retObject[paramName] = unescape(paramPair.substring(eqlIndex+1));
    }
    return retObject;
  }

  var open = window.open;
  window.open = function ScribeOpen(url, name, opts) {
    name = name || '';
    opts = opts || {};
    // Ensure this is not a sibling reference like _self, _parent,
    // _opener, or _top
    if (name === '_self' || (name.charAt(0) === '_' &&
        window[name.slice(1)] instanceof Window)) {

      open.apply(window[name.slice(1)], arguments)
    } else {
      if (typeof opts === 'string') {
        opts = params(opts);
      }
      var win = new Scribe.Window(opts);
      win.show();
      return win;
    }
  }

})();

// Polyfill for alert()
this.alert = function $alert(msg) {
  // join all the args together
  msg = Array.prototype.slice.call(arguments).join(' ');
  var alert = OSX.NSAlert.new;
  alert.setMessageText(msg);
  alert.setAlertStyle(OSX.NSWarningAlertStyle)

  if (Scribe.Window.current) {
    alert['beginSheetModalForWindow:completionHandler:'](
      Scribe.Window.current.nativeWindowObject, null
    )
    while (Scribe.Window.current.nativeWindowObject.sheets.count > 0) {
      OSX.ScribeEngine.spin(1);
    }
  } else {
    alert.runModal;
  }

  alert.release;
}

// Polyfill for confirm()
this.confirm = function $confirm(msg) {
  // join all the args together
  msg = Array.prototype.slice.call(arguments).join(' ');
  var retVal = false;

  if (Scribe.Window.current) {
    retVal = !!Scribe.Window.current.nativeWindowObject.confirm(msg);
  } else {
    var alert = OSX.NSAlert[
      'alertWithMessageText:defaultButton:alternateButton:'+
      'otherButton:informativeTextWithFormat:'
    ](msg, 'OK', 'Cancel', null, '');
    retVal = (alert.runModal == OSX.NSAlertDefaultReturn);
    alert.release;
  }

  return retVal;  
}

// Polyfill for confirm()
this.prompt = function $prompt(msg) {
  // join all the args together
  msg = Array.prototype.slice.call(arguments).join(' ');
  var retVal = false;

  if (Scribe.Window.current) {
    retVal = Scribe.Window.current.nativeWindowObject.prompt(msg);
  } else {
    var input = OSX.NSTextField.alloc.initWithFrame(
      OSX.NSMakeRect(0, 0, 200, 24)
    );
    var alert = OSX.NSAlert[
      'alertWithMessageText:defaultButton:alternateButton:'+
      'otherButton:informativeTextWithFormat:'
    ](msg, 'OK', 'Cancel', null, '');
    alert.setAccessoryView(input);
    if (alert.runModal == OSX.NSAlertDefaultReturn) {
      input.validateEditing;
      retVal = input.stringValue;
    } else {
      retVal = null;
    }
    input.release;
  }

  return retVal;  
}

// Polyfill for debugger
Object.defineProperty(this, 'debugger', {
  get: function initDebugger() {
    OSX.triggerDebugger();
    return true;
  }
})

}).call(this);
