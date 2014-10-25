#import "ScribeWindow.h"

@implementation ScribeWindow

@synthesize webView, scribeEngine;

- (id)initWithContentRect: (NSRect) contentRect
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
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];

  WebPreferences* prefs = [webView preferences];
  [prefs _setLocalStorageDatabasePath: @"~/Library/Application Support/MyApp"];
  [prefs setLocalStorageEnabled:YES];

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

-(NSArray *) webView: (WebView *) sender
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
}

- (void) windowDidResize: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('resize');"
  ];
}

- (void) windowDidMove: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('move');"
  ];
}

- (void) windowDidEnterFullScreen: (NSNotification *) notification {
  [scribeEngine.context evaluateScript: 
    @"Scribe.Window.currentWindow().trigger('fullscreen');"
  ];
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
  [super dealloc];
}

@end
