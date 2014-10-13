#import "ScribeWindow.h"

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

- (void) buildWebView {
  webView = [[WebView alloc] initWithFrame: self.frame
                                 frameName: @"scribe"
                                 groupName: nil];
  NSURL *url = [NSURL URLWithString: @"http://example.com"];
  NSURLRequest *request = [NSURLRequest requestWithURL: url];
  [[webView mainFrame] loadRequest: request];
  [self setContentView: webView];
}

@end
