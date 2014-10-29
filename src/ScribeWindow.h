#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "ScribeEngine.h"

@interface ScribeWindow: NSWindow <NSWindowDelegate> {
  WebView *webView;
  ScribeEngine *scribeEngine;
  JSValueRef jsWrapperObject;
}

@property (nonatomic, retain) WebView *webView;
@property (nonatomic, retain) ScribeEngine *scribeEngine;
@property (nonatomic, assign) JSValueRef jsWrapperObject;

- (id) init;
- (id) initWithFrame: (CGRect) frame;
- (void) buildWebView;
- (void) navigateToURL: (NSString *) url;
- (void) triggerEvent: (NSString *)event;
+ (id) lastInstance;

@end
