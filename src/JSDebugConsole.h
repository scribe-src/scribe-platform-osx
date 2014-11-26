#import <JavaScriptCore/JavaScriptCore.h>
#import "ScribeEngine.h"

@interface JSDebugConsole: NSObject {
  JSCocoaController *jsc;
  BOOL done;
  BOOL _killed;
}

@property (nonatomic, retain) JSCocoaController *jsc;
@property BOOL done;

+ (id) activeConsole;

- (id) initWithJSCocoa: (JSCocoaController *) jsc;
- (void) start;
- (void) kill;
- (BOOL) done;

@end
