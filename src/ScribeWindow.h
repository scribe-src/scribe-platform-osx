#import <WebKit/WebKit.h>

@interface ScribeWindow: NSWindow {
  WebView *webView;
}

@property (nonatomic, retain) WebView *webView;

- (id) initWithFrame: (CGRect) frame;

- (void) buildWebView;

@end
