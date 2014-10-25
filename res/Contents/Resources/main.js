// Create a window to contain our application
var win = OSX.ScribeWindow.alloc['initWithContentRect:styleMask:backing:defer:'](
  OSX.CGRectMake(0, 0, 800, 500),
  OSX.NSTitledWindowMask | OSX.NSClosableWindowMask | OSX.NSResizableWindowMask,
  OSX.NSBackingStoreBuffered,
  false
);
win.makeKeyAndOrderFront(null);
win.title = 'My Window';

// Load our HTML into the new Window
win.center;
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
