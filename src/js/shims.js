(function() {

// Polyfill for debugger
// Object.defineProperty(this, 'debugger', {
//   get: function initDebugger() {
//     Scribe.debugger();
//     return true;
//   }
// })

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
  if (Scribe.Window.current && (name === '_self' || (name.charAt(0) === '_' &&
      window[name.slice(1)] instanceof Window))) {
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

})();