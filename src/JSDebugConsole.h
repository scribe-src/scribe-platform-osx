#import <JavaScriptCore/JavaScriptCore.h>
#import "ScribeEngine.h"

@interface JSDebugConsole: NSObject {
  JSCocoaController *jsc;
  BOOL done;
  BOOL _killed;
}

@property (atomic, retain) JSCocoaController *jsc;
@property (atomic) BOOL done;

+ (id) activeConsole;

- (id) initWithJSCocoa: (JSCocoaController *) jsc;
- (void) start;
- (void) kill;
- (BOOL) done;

@end
