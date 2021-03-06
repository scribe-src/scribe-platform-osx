#import "ScribeWindow.h"
#import "JSCocoa.h"

// Abuse the Darwin linker to get a handle to the START of the
// osx linker section. This way we can shove data in with `ld`.
extern int osxStart __asm("section$start$__DATA$__osxjs");

// Keep the last instance around!
ScribeWindow *lastInstance;

@implementation ScribeWindow

@synthesize webView = _webView,
            scribeEngine = _scribeEngine,
            parentEngine = _parentEngine;

+ (id) lastInstance { return lastInstance; }

- (id) initWithContentRect: (NSRect) contentRect
                 styleMask: (NSUInteger) windowStyle
                   backing: (NSBackingStoreType) bufferingType
                     defer: (BOOL) deferCreation {

  if (self = [super initWithContentRect: contentRect
                              styleMask: windowStyle
                                backing: bufferingType
                                  defer: deferCreation]) {
    self.delegate = self;
    lastInstance = self;
    _parentWindowIndex = -1;

    [self buildWebView];
  }

  return self;
}

- (id) initWithFrame: (NSRect) frame {
  return [self initWithContentRect: frame
                         styleMask: NSTitledWindowMask
                           backing: NSBackingStoreBuffered
                             defer: NO];
}

- (id) init {
  return [self initWithFrame: NSMakeRect(0, 0, 800, 800)];
}

- (void) buildWebView {
  _webView = [[WebView alloc] initWithFrame: self.frame
                                  frameName: @"scribe"
                                  groupName: nil];
  self.webView.frameLoadDelegate = self;
  self.webView.UIDelegate = self;

  NSString *app = [[[NSBundle mainBundle] localizedInfoDictionary]
    objectForKey: @"CFBundleName"];

  if (!app) app = @"Scribe";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
  WebPreferences *prefs = [self.webView preferences];
  [prefs setAutosaves:YES];

  static const unsigned long long defaultTotalQuota = 1024 * 1024 * 1024 * 10; // 10GB
  static const unsigned long long defaultOriginQuota = 1024 * 1024 * 1024 * 10; // 10GB

  [prefs setApplicationCacheTotalQuota: defaultTotalQuota];
  [prefs setApplicationCacheDefaultOriginQuota: defaultOriginQuota];

  [prefs setWebGLEnabled: YES];
  [prefs setWebAudioEnabled: YES];
  [prefs setOfflineWebApplicationCacheEnabled: YES];
  [prefs setAVFoundationEnabled: YES];
  [prefs setDatabasesEnabled: YES];
  [prefs setDeveloperExtrasEnabled: YES];
  [prefs setWebSecurityEnabled: NO];
  [prefs setJavaScriptCanAccessClipboard: YES];
  [prefs setNotificationsEnabled: YES];
  [prefs setLocalStorageEnabled: YES];
  [prefs _setLocalStorageDatabasePath:
    [NSString stringWithFormat: @"~/Library/Application Support/%@", app]];
#pragma clang diagnostic pop

  [self setContentView: self.webView];
}

- (void) navigateToURL: (NSString *) url {
  NSURL *resolvedURL = [NSURL URLWithString: url
                      relativeToURL: [[NSApp delegate] baseURL]];
  NSURLRequest *request = [NSURLRequest requestWithURL: resolvedURL];
  [[self.webView mainFrame] loadRequest: request];
}

//
// WebUIDelegate methods
//

- (NSArray *) webView: (WebView *) sender
    contextMenuItemsForElement: (NSDictionary *) element
    defaultMenuItems: (NSArray *) defaultMenuItems {

    SCRIBELOG(@"%@", element);
    if ([defaultMenuItems count] == 1) {
      // remove the default "Reload option"
      return nil;
    } else {
      // keep the debug menu available
      return @[[defaultMenuItems lastObject]];
    }
}

//
// WebFrameDelegate methods
//

// Add injection hook for injecting ScribeEngine scribe global
- (void) webView: (WebView *) wv
         didCreateJavaScriptContext: (JSContext *) context
         forFrame: (WebFrame *) frame {

  // Inject JSCocoa runtime into the WebView's JS context, along
  // with the universal bits of the Scribe.* namespace.
  ScribeEngine *engine = [ScribeEngine inject: [frame globalContext]];

  // add a reference to yourself!
  [engine.jsc setObject: self withName: @"Scribe.Window._current"];

  // Inject the OSX-specific bits of the Scribe.* APIs, that get
  // compiled into a header.
  if (osxStart) {
    NSString *js = [NSString stringWithCString: (char*)&osxStart encoding: NSUTF8StringEncoding];
    [engine.jsc evalJSString: js];
  }

  // save the ScribeEngine in an ivar if this is the top frame
  if (frame == [self.webView mainFrame]) {
    [self.scribeEngine release];
    self.scribeEngine = engine;
  }

  [engine release];
}

//
// NSWindowDelegate methods
//

- (void) windowDidMiniaturize: (NSNotification *) notification {
  [self triggerEvent: @"minimize"];
}

- (void) windowDidDeminiaturize: (NSNotification *) notification {
  [self triggerEvent: @"deminimize"];
}

- (void) windowDidResize: (NSNotification *) notification {
  [self triggerEvent: @"resize"];
}

- (void) windowDidMove: (NSNotification *) notification {
  [self triggerEvent: @"move"];
}

- (void) windowDidEnterFullScreen: (NSNotification *) notification {
  [self triggerEvent: @"fullscreen"];
}

- (void) windowDidExitFullScreen: (NSNotification *) notification {
  [self triggerEvent: @"fullscreen"];
}

- (void) windowWillClose: (NSNotification *) notification {
  [self triggerEvent: @"close"];
}

- (void) windowDidBecomeKey: (NSNotification *) notification {
  [self triggerEvent: @"focus"];
}

- (void) windowDidResignKey: (NSNotification *) notification {
  [self triggerEvent: @"blur"];
}

- (BOOL) canBecomeKeyWindow {
  return YES;
}

- (void) triggerEvent: (NSString *)event {
  if (self.scribeEngine) {
    [self.scribeEngine retain];
    void (^selfTrigger)() = ^{
      [self.scribeEngine.jsc evalJSString: [NSString stringWithFormat:
        @"setTimeout(function(){Scribe.Window.current.trigger('%@');},0)", event
      ]];
      [self.scribeEngine release];
    };

    dispatch_async(dispatch_get_main_queue(), selfTrigger);
  }

  if (self.parentEngine && _parentWindowIndex != -1) {
    SCRIBELOG(@"%ld", (long)_parentWindowIndex);
    SCRIBELOG(@"Trigger Event: %@", event);
    [self.parentEngine retain];
    void (^refTrigger)() = ^{
      [self.parentEngine.jsc evalJSString: [NSString stringWithFormat:
        @"setTimeout(function(){Scribe.Window.instances[%ld] && Scribe.Window.instances[\
          %ld].trigger('%@');},0)", (long)_parentWindowIndex, (long)_parentWindowIndex, event
      ]];
      [self.parentEngine release];
    };

    dispatch_async(dispatch_get_main_queue(), refTrigger);
  }
}

- (void) setParentWindowIndex: (NSInteger) idx {
  _parentWindowIndex = idx;
}

- (BOOL) confirm: (NSString *) msg {
  NSAlert *alert = [NSAlert 
    alertWithMessageText: msg
    defaultButton: @"OK"
    alternateButton: @"Cancel"
    otherButton: nil
    informativeTextWithFormat: @""
  ];

  NSModalResponse __block rCode = 0x0;
  BOOL __block done = NO;

  if (![NSThread isMainThread]) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      [alert beginSheetModalForWindow: self completionHandler: ^(NSModalResponse code) {
        rCode = code;
        done = YES;
      }];
    });
  } else {
    [alert beginSheetModalForWindow: self completionHandler: ^(NSModalResponse code) {
        rCode = code;
        done = YES;
      }];
    while (!done) [ScribeEngine spin: 1];
  }
  return !!rCode;
}

- (NSString *) prompt: (NSString *) msg {
  NSTextField *input = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 200, 24)];
  NSAlert __block *alert = [NSAlert 
    alertWithMessageText: msg
    defaultButton: @"OK"
    alternateButton: @"Cancel"
    otherButton: nil
    informativeTextWithFormat: @""
  ];
  [alert setAccessoryView: input];

  NSModalResponse __block rCode = 0x0;
  BOOL __block done = NO;
  if (![NSThread isMainThread]) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      [alert beginSheetModalForWindow: self completionHandler: ^(NSModalResponse code) {
        rCode = code;
        done = YES;
      }];
    });
  } else {
    [alert beginSheetModalForWindow: self completionHandler: ^(NSModalResponse code) {
      rCode = code;
      done = YES;
    }];
    while (!done) [ScribeEngine spin: 1];
  }

  [input validateEditing];
  NSString *ret = [input stringValue];
  [input release];

  if (rCode) {
    return ret;
  } else {
    return nil;    
  }
}

// - (void)webView: (WebView *) sender
//         didClearWindowObject: (WebScriptObject *) windowObject
//         forFrame: (WebFrame *) frame {
//   ScribeEngine *engine = [ScribeEngine inject: [frame globalContext]];
//   if (frame == [webView mainFrame]) {
//     self.scribeEngine = engine;
//   }
// }

- (void) dealloc {

  SCRIBELOG(@"Deallocating Window.");
  self.delegate = nil;
  if (lastInstance == self) lastInstance = NULL;

  if (_parentWindowIndex != -1 && self.parentEngine) {
    NSString *key = [NSString stringWithFormat:
      @"Scribe.Window.instances[%ld]._nativeObject=null;",
      (long)_parentWindowIndex
    ];
    // Note: evalJSString: fails here during GC sweep, use setObject: instead.
    [self.scribeEngine.jsc setObject: nil withName: key];
  }
  
  [self.parentEngine release], _parentEngine = nil;

  [self.webView removeFromSuperview];
  [self.webView release], _webView = nil;
  [self.scribeEngine release], _scribeEngine = nil;
  [super dealloc];
}

@end
