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

  // create the nativeObject
  this._nativeObject = OSX.ScribeWindow.alloc['initWithContentRect:styleMask:backing:defer:'](
    rect,
    styleMask,
    OSX.NSBackingStoreBuffered,
    false
  );

  // tell the window about its parent context (this)
  this.nativeObject.setParentEngine(Scribe.Engine._current);
  this.instanceIndex = Scribe.Window.instances.length;
  this.nativeObject.setParentWindowIndex(this.instanceIndex);
  Scribe.Window.instances.push(this);

  // configure some settings in the ScribeWindow's WebView
  if (opts.sameOriginPolicy == null) opts.sameOriginPolicy = true;
  this.sameOriginPolicy = !!opts.sameOriginPolicy;

  // set up the titlebar if necessary
  if (opts.title != null) this.title = opts.title;

}

Scribe.Window.prototype._center = function() {
  this.nativeObject.center;
}

Scribe.Window.prototype._show = function() {
  this.nativeObject.makeKeyAndOrderFront({});
  OSX.NSApp.activateIgnoringOtherApps(true);
  this._isVisible = true;
}

Scribe.Window.prototype._hide = function() {
  this.nativeObject.orderOut({});
  this._isVisible = false;
  this.trigger('blur');
}

Scribe.Window.prototype._close = function() {
  this.nativeObject.close;
  this._nativeObject = null;
  this._isVisible = false;
}

Scribe.Window.prototype._minimize = function() {
  this.nativeObject.miniaturize(null);
}

Scribe.Window.prototype._deminimize = function() {
  this.nativeObject.deminiaturize(null);
}

Scribe.Window.prototype._getVisible = function() {
  return this._isVisible;
}

Scribe.Window.prototype._navigateToURL = function(URL) {
  this.nativeObject.navigateToURL(URL);
}

Scribe.Window.prototype._getNativeObject = function() {
  if (!this._nativeObject) {
    throw new Error("Method called on dead Scribe.Window");
  }
  return this._nativeObject;
}

Scribe.Window.prototype._getLeft = function() {
  return this.nativeObject.frame.origin.x;
}

Scribe.Window.prototype._setLeft = function(x) {
  var frame = this.nativeObject.frame;
  var rect = OSX.NSMakeRect(
    x,
    frame.origin.y,
    frame.size.width,
    frame.size.height
  );

  this.nativeObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getTop = function() {
  var height = OSX.NSScreen.mainScreen.frame.size.height;
  return height - this.nativeObject.frame.origin.y;
}

Scribe.Window.prototype._setTop = function(y) {
  var height = OSX.NSScreen.mainScreen.frame.size.height;
  y = height - y;
  var frame = this.nativeObject.frame;
  var rect = OSX.NSMakeRect(
    frame.origin.x,
    y,
    frame.size.width,
    frame.size.height
  );

  this.nativeObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getWidth = function() {
  return this.nativeObject.frame.size.width;
}

Scribe.Window.prototype._setWidth = function(width) {
  var frame = this.nativeObject.frame;
  var rect = OSX.NSMakeRect(
    frame.origin.x,
    frame.origin.y,
    width,
    frame.size.height
  );

  this.nativeObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getHeight = function() {
  return this.nativeObject.frame.size.height;
}

Scribe.Window.prototype._setHeight = function(height) {
  var frame = this.nativeObject.frame;
  var rect = OSX.NSMakeRect(
    frame.origin.x,
    frame.origin.y,
    frame.size.width,
    height
  );

  this.nativeObject['setFrame:display:'](rect, true);
}

Scribe.Window.prototype._getFullscreen = function() {
  return ((this.nativeObject.styleMask & OSX.NSFullScreenWindowMask) != 0);
}

Scribe.Window.prototype._setFullscreen = function(fullscreen) {
  this.nativeObject.setCollectionBehavior(OSX.NSWindowCollectionBehaviorFullScreenPrimary);
  if (this.fullscreen != fullscreen) {
    this.nativeObject.toggleFullScreen(this.nativeObject);
  }
}

Scribe.Window.prototype._getResizable = function() {
  return ((this.nativeObject.styleMask & OSX.NSResizableWindowMask) != 0);
}

Scribe.Window.prototype._setResizable = function(resizable) {
  var newMask;
  if (resizable){
    var newMask = this.nativeObject.styleMask | OSX.NSResizableWindowMask;
  } else {
    var newMask = this.nativeObject.styleMask & ~OSX.NSResizableWindowMask;
  }
  this.nativeObject.setStyleMask(newMask);
}

Scribe.Window.prototype._getClosable = function() {
  return ((this.nativeObject.styleMask & OSX.NSClosableWindowMask) != 0);
}

Scribe.Window.prototype._setClosable = function(closable) {
  var newMask;
  if (closable){
    var newMask = this.nativeObject.styleMask | OSX.NSClosableWindowMask;
  } else {
    var newMask = this.nativeObject.styleMask & ~OSX.NSClosableWindowMask;
  }
  this.nativeObject.setStyleMask(newMask);
}

Scribe.Window.prototype._getSameOriginPolicy = function() {
  return this.nativeObject.webView.preferences.isWebSecurityEnabled;
}

Scribe.Window.prototype._setSameOriginPolicy = function(sop) {
  this.nativeObject.webView.preferences.setWebSecurityEnabled(sop);
}

Scribe.Window.prototype._getTitle = function() {
  return this.nativeObject.title.toString();
}

Scribe.Window.prototype._setTitle = function(title) {
  this.nativeObject.setTitle(title);
}


// Assign the Scribe.Window.current static class variable
if (OSX.ScribeWindow.lastInstance) {
  Scribe.Window.current = new Scribe.Window({
    nativeObject: OSX.ScribeWindow.lastInstance
  });
}


Scribe.Screen._getAll = function() {
  return [].slice.call(OSX.NSScreen.screens).map(function(screen) {
    return new Scribe.Screen({ nativeObject: screen });
  });
};

Scribe.Screen.prototype._getWidth = function() {
  return this.nativeObject.frame.size.width;
};

Scribe.Screen.prototype._getHeight = function() {
  return this.nativeObject.frame.size.height;
};

Scribe.Screen.prototype._getNativeObject = function() {
  return this._nativeObject;
};

// Add a native hook to window.open():
(function() {

  // keep a helper inside our closure
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

  // hold a reference to the native window.open() function:
  var openOriginal = window.open;

  // shim the global window.open() function:
  window.open = function ScribeWindowOpen(url, name, opts) {
    name = name || '';
    opts = opts || {};
    // Ensure this is not a sibling reference like _self, _parent,
    // _opener, or _top
    if (name === '_self' || (name.charAt(0) === '_' &&
        window[name.slice(1)] instanceof Window)) {
      // run the original open() method on any arguments passed
      openOriginal.apply(window, arguments)
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
      Scribe.Window.current.nativeObject, null
    )
    while (Scribe.Window.current.nativeObject.sheets.count > 0) {
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
    retVal = !!Scribe.Window.current.nativeObject.confirm(msg);
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
    retVal = Scribe.Window.current.nativeObject.prompt(msg);
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
