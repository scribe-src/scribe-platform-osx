#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "ScribeEngine.h"

@interface ScribeWindow: NSWindow <NSWindowDelegate> {
  WebView *webView;
  ScribeEngine *scribeEngine;
}

@property (nonatomic, retain) WebView *webView;
@property (nonatomic, retain) ScribeEngine *scribeEngine;

- (id) init;
- (id) initWithFrame: (CGRect) frame;
- (void) buildWebView;
- (void) navigateToURL: (NSString *) url;

@end
