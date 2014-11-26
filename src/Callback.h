#import <Foundation/Foundation.h>
#import "JSCocoa.h"
#import "common.h"

// Callback is a small wrapper class we maintain for storing
// a Javascript function, its context, and a tag identifier
@interface Callback: NSObject {
  JSValueRefAndContextRef function;
  int tag;
  dispatch_source_t timer;
}

@property int tag;
@property JSValueRefAndContextRef function;
@property dispatch_source_t timer;

@end

@implementation Callback

@synthesize function, tag, timer;

- (void) dealloc {
  SCRIBELOG(@"Cancelling callback..");
  dispatch_source_cancel(timer);
  dispatch_release(timer);
  // this crashes for whatever reason:
  // JSValueUnprotect(function.ctx, function.value);
  [super dealloc];
}

@end
