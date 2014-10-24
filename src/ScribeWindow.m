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
  // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];

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

// Add injection hook for injecting ScribeEngine scribe global
- (void)webView: (WebView *) webView
        didCreateJavaScriptContext: (JSContext *) context
        forFrame: (WebFrame *) frame {
  ScribeEngine *engine = [ScribeEngine inject: context];
  if (frame == [webView mainFrame]) {
    self.scribeEngine = engine;
  }
}

// - (void)webView: (WebView *) sender
//         didClearWindowObject: (WebScriptObject *) windowObject
//         forFrame: (WebFrame *) frame {
//   ScribeEngine *engine = [ScribeEngine inject: mainFrame];
//   if (frame == [webView mainFrame]) {
//     self.scribeEngine = engine;
//   }
// }

@end


