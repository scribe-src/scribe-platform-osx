// Create a window to contain our application
with (OSX) {
  var win = ScribeWindow.alloc['initWithContentRect:styleMask:backing:defer:'](
    CGRectMake(0,0,800,500),
    NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask,
    NSBackingStoreBuffered,
    false
  );
  win.makeKeyAndOrderFront(null);
  win.title = 'Scribe Engine';

  // Load our HTML into the new Window
  win.center;
  win.navigateToURL('index.html');

  // Set up the menubar
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
}
