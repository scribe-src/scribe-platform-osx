#import "ScribeEngine.h"
#import "ScribeEngine+SetTimeout.h"
#import "JSDebugConsole.h"

#include <dlfcn.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>

// Abuse the Darwin linker to get a handle to the START of the
// windowjs linker section. This way we can shove data in with `ld`
extern int apiStart __asm("section$start$__DATA$__scribejs");

@implementation ScribeEngine

//
// Instance Methods
//

@synthesize context = _context, jsc = _jsc;

- (id) init {
  JSGlobalContextRef ctx = JSGlobalContextCreate(NULL);
  [self initWithContext: ctx];
  JSGlobalContextRelease(ctx);
  return self;
}

- (id) initWithContext: (JSGlobalContextRef) ctx {
  if (self = [super init]) {
    _timers = [NSMutableArray new];

    // save the context ptr for later
    self.context = ctx;
    JSGlobalContextRetain(self.context);

    // inject the JSCocoa runtime
    self.jsc = [[JSCocoa alloc] initWithGlobalContext: self.context];
    [self.jsc release];
    self.jsc.delegate = self;

    // Inject a weak reference to the current engine into Javascript
    [self.jsc setObject: self withName: @"_currentEngine"];

    // Run any js that has been stuffed into a linker section
    NSString *js = [NSString stringWithCString: (char*)&apiStart encoding: NSUTF8StringEncoding];
    [self.jsc evalJSString: js];
  }

  return self;
}

// Ensure any errors get logged
- (void) JSCocoa: (JSCocoaController*) controller
        hadError: (NSString *) error
    onLineNumber: (NSInteger) lineNumber
     atSourceURL: (id) url {
  // NSLog(@"Error encountered: %@\nOn %@:%d", error, url, (int)lineNumber);
}

- (void) repl {
  JSDebugConsole *console = [[JSDebugConsole alloc] initWithJSCocoa: self.jsc];
  [console start];
  while (!console.done) [ScribeEngine spin: 1];
  [console release];
}

- (JSValueRef) eval: (NSString *) js {
  JSValueRef __block out;
  if ([NSThread isMainThread]) {
    out = [self.jsc evalJSString: js];
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      out = [self.jsc evalJSString: js];
    }); 
  }
  return out;
}

- (void) dealloc {
  [_timers release], _timers = nil;

  [self.jsc unlinkAllReferences];
  [self.jsc garbageCollect];
  [self.jsc release], self.jsc = nil;

  JSGarbageCollect(self.context);
  JSGlobalContextRelease(self.context);
  self.context = nil;

  [super dealloc];
}


//
// Class Methods
//

// Creates a new ScribeEngine instance and injects some of its
// instance methods into.
//
// Returns an allocated ScribeEngine instance that must be released.
+ (ScribeEngine *) inject: (JSGlobalContextRef)context {
  if (!context) return nil;

  // create a new instance of ScribeEngine with our context
  ScribeEngine *instance =
    [[self alloc] initWithContext: context];

  return instance;
}

// Spins the main UI thread for given number of ticks (at 0.01s
// per tick). This is useful for implementing synchronous APIs
// like alert(), prompt(), and confirm().
+ (void) spin: (int) ticks {
  for (int i = 0; i < ticks; i++) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // spin the Cocoa run loop while the test executes
    // this works really well,wtf
    NSEvent *event =
        [[NSApplication sharedApplication]
            nextEventMatchingMask: NSAnyEventMask
            untilDate: [[NSDate date] dateByAddingTimeInterval: 0.001]
            inMode: NSDefaultRunLoopMode
            dequeue: YES];
    [[NSApplication sharedApplication] sendEvent: event];
    [[NSApplication sharedApplication] updateWindows];

    [pool release];
  }
}

// Convenience/safety wrapper for logging from Javascript
+ (void) log: (NSString *) msg {
  NSLog(@"%@", msg);
}

// Convenience function for setting an env variable
+ (BOOL) setEnvVar: (NSString *) var toValue: (NSString *) val {
  return (setenv(var.UTF8String, val.UTF8String, 1) == 0);
}

@end
