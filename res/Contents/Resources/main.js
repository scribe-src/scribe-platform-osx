// Create a window to contain our application
var win = Scribe.Window.create({
  top: 100,
  left: 100,
  width: 500,
  height: 500,
  chrome: true,
  closable: false,
  resizable: false
});

win.show();
win.center();
win.navigateToURL('index.html');

// Set up the menubar
var menubar = OSX.NSMenu.new.autorelease;
var appMenuItem = OSX.NSMenuItem.new.autorelease;
menubar.addItem(appMenuItem);
OSX.NSApp.setMainMenu(menubar);

var appMenu = OSX.NSMenu.new.autorelease;
var appName = OSX.NSProcessInfo.processInfo.processName;
var quitTitle = OSX.NSString.stringWithFormat("Quit %@", appName);
var quitMenuItem = OSX.NSMenuItem.alloc['initWithTitle:action:keyEquivalent:'](
  quitTitle,
  'terminate:',
  'q'
).autorelease;
appMenu.addItem(quitMenuItem);
appMenuItem.setSubmenu(appMenu);
