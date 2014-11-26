#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCocoa.h"
#include "common.h"

// An Engine is a single instance of the Javascript runtime
@interface ScribeEngine: NSObject {
  JSGlobalContextRef context;
  JSCocoaController *jsc;
  NSMutableArray *_timers;
}

//
// Instance Methods
//

// Each engine instance belongs to a single JS context
@property (nonatomic, assign) JSGlobalContextRef context;
@property (nonatomic, retain) JSCocoaController *jsc;

- (id) initWithContext: (JSGlobalContextRef) ctx;

// Spawns a JS REPL on stdin in a new thread and spins the event
// loop until the user runs `exit()`
- (void) repl;

// Evaluates the code in `js` and returns a reference to the result
- (JSValueRef) eval: (NSString *) js;

//
// Class methods
//

// Creates a new ScribeEngine instance and injects some of its
// instance methods into.
//
// Returns the autoreleasedScribeEngine instance
+ (ScribeEngine *) inject: (JSGlobalContextRef)context;

// Spins the main UI thread for given number of ticks (at 0.01s
// per tick). This is useful for implementing synchronous APIs
// like alert(), prompt(), and confirm().
+ (void) spin: (int) ticks;

// Convenience/safety wrapper for logging from Javascript
+ (void) log: (NSString *) msg;

// Convenience function for setting an env variable
+ (void) setEnvVar: (NSString *) var toValue: (NSString *) val;

@end
