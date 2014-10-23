var win = ScribeWindow.alloc.init;
win.makeKeyAndOrderFront(null);
win.title = 'joes favorite window';

var menubar = NSMenu.new.autorelease;
var appMenuItem = NSMenuItem.new.autorelease;
menubar.addItem(appMenuItem);
NSApp.setMainMenu(menubar);

var appMenu = NSMenu.new.autorelease;
var appName = NSProcessInfo.processInfo.processName;
var quitTitle = NSString.stringWithFormat("Quit %@", appName);
var quitMenuItem = NSMenuItem.alloc['initWithTitle:action:keyEquivalent:'](
  quitTitle,
  'terminate:',
  'q'
).autorelease;
appMenu.addItem(quitMenuItem);
appMenuItem.setSubmenu(appMenu);

win.center;
win.navigateToURL('index.html')