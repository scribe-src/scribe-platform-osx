#import "ScribeWindow.h"


// Abuse the Darwin linker to get a handle to the START of the
// windowjs linker section. This way we can shove data in with `ld`
extern int osxStart __asm("section$start$__DATA$__osxjs");
ScribeWindow *lastInstance;

@implementation ScribeWindow

@synthesize webView, scribeEngine, jsWrapperObject;

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
    [self buildWebView];
  }

  lastInstance = self;

  return self;
}

- (id) initWithFrame: (CGRect) frame {
  return [self initWithContentRect: frame
                         styleMask: NSTitledWindowMask
                           backing: NSBackingStoreBuffered
                             defer: NO];
}

- (id) init {
  return [self initWithFrame: CGRectMake(0, 0, 800, 800)];
}

- (void) buildWebView {
  webView = [[WebView alloc] initWithFrame: self.frame
                                 frameName: @"scribe"
                                 groupName: nil];
  webView.frameLoadDelegate = self;
  webView.UIDelegate = self;

  WebPreferences *prefs = [webView preferences];
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

  NSString *app = [[[NSBundle mainBundle] localizedInfoDictionary]
    objectForKey:@"CFBundleName"];

  if (!app) app = @"Scribe";

  [prefs setLocalStorageEnabled: YES];
  [prefs _setLocalStorageDatabasePath:
    [NSString stringWithFormat: @"~/Library/Application Support/%@", app]];

  [self setContentView: webView];
}

- (void) navigateToURL: (NSString *) url {
  NSURL *resolvedURL = [NSURL URLWithString: url
                      relativeToURL: [[NSApp delegate] baseURL]];
  NSURLRequest *request = [NSURLRequest requestWithURL: resolvedURL];
  [[webView mainFrame] loadRequest: request];
}

//
// WebUIDelegate methods
//

- (NSArray *) webView: (WebView *) sender
    contextMenuItemsForElement: (NSDictionary *) element
    defaultMenuItems: (NSArray *) defaultMenuItems {

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
- (void) webView: (WebView *) webView
         didCreateJavaScriptContext: (JSContext *) context
         forFrame: (WebFrame *) frame {

  // Inject JSCocoa runtime into the WebView's JS context, along
  // with the universal bits of the Scribe.* namespace.
  ScribeEngine *engine = [ScribeEngine inject: context];

  // ensure the code running in this window gets the correct result
  // from Scribe.Window.currentWindow();
  context[@"Scribe"][@"_currentNativeWindow"] = self;

  if (osxStart) {
    NSString *js = [NSString stringWithCString: (char*)&osxStart encoding: NSUTF8StringEncoding];
    [engine.jsCocoa evalJSString: js];
  }

  // Inject the OSX-specific bits of the Scribe.* APIs

  // save the ScribeEngine in an ivar if this is the top frame
  if (frame == [webView mainFrame]) {
    self.scribeEngine = engine;
  }
}

//
// NSWindowDelegate methods
//

- (void) windowDidMiniaturize: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('minimize');"
  ];
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"minimize"]];
}

- (void) windowDidDeminiaturize: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('deminimize');"
  ];
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"deminimize"]];
}

- (void) windowDidResize: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('resize');"
  ];
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"resize"]];
}

- (void) windowDidMove: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('move');"
  ];
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"move"]];
}

- (void) windowDidEnterFullScreen: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('fullscreen');"
  ];
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"fullscreen"]];
}

- (void) windowDidExitFullScreen: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('fullscreen');"
  ];
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"fullscreen"]];
}

- (void) windowWillClose: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"setTimeout(function(){Scribe.Window.currentWindow().trigger('close');},5);"
  ];
  
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"close"]];
}

- (void) windowDidBecomeKey: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('focus');"
  ];
  
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"focus"]];
}

- (void) windowDidResignKey: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('blur');"
  ];
  
  [jsWrapperObject[@"trigger"] callWithArguments: @[@"blur"]];
}

- (BOOL) canBecomeKeyWindow {
  return YES;
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
  [webView release], webView = nil;
  [scribeEngine release], scribeEngine = nil;
  [jsWrapperObject release], jsWrapperObject = nil;
  [super dealloc];
}

@end
