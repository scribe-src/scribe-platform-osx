#import "ScribeWindow.h"
#import "ScribeEngine.h"

@implementation ScribeWindow

@synthesize webView;

- (id) initWithFrame: (CGRect) frame {
  if (self = [super initWithContentRect: frame
                              styleMask: NSTitledWindowMask
                                backing: NSBackingStoreBuffered
                                  defer: NO]) {
    [self buildWebView];
  }
  return self;
}

- (id) init {
  return [self initWithFrame: CGRectMake(0, 0, 800, 800)];
}

- (void) buildWebView {
  webView = [[WebView alloc] initWithFrame: self.frame
                                 frameName: @"scribe"
                                 groupName: nil];
  webView.frameLoadDelegate = self;

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

- (void)webView: (WebView *) webView
        didCreateJavaScriptContext: (JSContext *) context
        forFrame: (WebFrame *) frame {
  [ScribeEngine inject: context];
}

@end


