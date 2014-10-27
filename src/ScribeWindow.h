#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "ScribeEngine.h"

@interface ScribeWindow: NSWindow <NSWindowDelegate> {
  WebView *webView;
  ScribeEngine *scribeEngine;
  JSValue *jsWrapperObject;
}

@property (nonatomic, retain) WebView *webView;
@property (nonatomic, retain) ScribeEngine *scribeEngine;
@property (nonatomic, retain) JSValue *jsWrapperObject;

- (id) init;
- (id) initWithFrame: (CGRect) frame;
- (void) buildWebView;
- (void) navigateToURL: (NSString *) url;
+ (id) lastInstance;

@end
