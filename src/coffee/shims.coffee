#
# Implements a few polyfills for when a Window is not available
#

global = @

# Polyfill for debugger
# Object.defineProperty(this, 'debugger', {
#   get: function initDebugger() {
#     Scribe.debugger();
#     return true;
#   }
# })

# keep a helper inside our closure
params = (searchString) ->
  paramValue = ""
  params = searchString.split("&")
  retObject = {}
  i = 0
  while i < params.length
    paramPair = params[i]
    eqlIndex = paramPair.indexOf("=")
    paramName = paramPair.substring(0, eqlIndex)
    retObject[paramName] = unescape(paramPair.substring(eqlIndex + 1))
    i++
  retObject

# hold a reference to the native window.open() function:
openOriginal = global.open

# shim the global window.open() function:
global.open ?= (url, name='', opts={}) ->
  # Ensure this is not a sibling reference like _self, _parent,
  # _opener, or _top
  if (Scribe.Window.current and (name is "_self" or
       (name.charAt(0) is "_" and window[name.slice(1)] instanceof Window)))
    # run the original open() method on any arguments passed
    openOriginal.apply global, arguments
  else
    opts = params(opts)  if typeof opts is "string"
    win = new Scribe.Window(opts)
    win.show()


# Polyfill for alert()
global.alert ?= (msg) ->
  
  # join all the args together
  msg = Array::slice.call(arguments).join(" ")
  alert = OSX.NSAlert.new
  alert.setMessageText msg
  alert.setAlertStyle OSX.NSWarningAlertStyle
  if Scribe.Window.current
    alert["beginSheetModalForWindow:completionHandler:"] Scribe.Window.current.nativeObject, null
    OSX.ScribeEngine.spin 1  while Scribe.Window.current.nativeObject.sheets.count > 0
  else
    alert.runModal
  alert.release


# Polyfill for confirm()
global.confirm ?= (msg) ->
  
  # join all the args together
  msg = Array::slice.call(arguments).join(" ")
  retVal = false
  if Scribe.Window.current
    retVal = !!Scribe.Window.current.nativeObject.confirm(msg)
  else
    fnName = "alertWithMessageText:defaultButton:alternateButton:" +
             "otherButton:informativeTextWithFormat:"
    alert = OSX.NSAlert[fnName](msg, "OK", "Cancel", null, "")
    retVal = (alert.runModal is OSX.NSAlertDefaultReturn)
    alert.release
  retVal


# Polyfill for prompt()
global.prompt ||= (msg) ->
  
  # join all the args together
  msg = Array::slice.call(arguments).join(" ")
  retVal = false
  if Scribe.Window.current
    retVal = Scribe.Window.current.nativeObject.prompt(msg)
  else
    input = OSX.NSTextField.alloc.initWithFrame(OSX.NSMakeRect(0, 0, 200, 24))
    fnName =  "alertWithMessageText:defaultButton:alternateButton:" +
              "otherButton:informativeTextWithFormat:"
    alert = OSX.NSAlert[fnName](msg, "OK", "Cancel", null, "")

    alert.setAccessoryView input
    if alert.runModal is OSX.NSAlertDefaultReturn
      input.validateEditing
      retVal = input.stringValue
    else
      retVal = null
    input.release
  retVal


# Add some convenience methods if they are missing
domFallbacks = [
  'setTimeout', 'setInterval',
  'clearTimeout', 'clearInterval'
]

# Install each fallback into global scope if it doesn't exist yet
domFallbacks.forEach (fallback) ->
  global[fallback] ?= ->
    args = Array::slice.call(arguments)
    Scribe.engine[fallback].apply(Scribe.engine, args)
