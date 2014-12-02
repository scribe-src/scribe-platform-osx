#import "ScribeEngine+SetTimeout.h"
#import "Callback.h"

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
  dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  if (timer) {
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
    dispatch_source_set_event_handler(timer, block);
    dispatch_resume(timer);
  }
  return timer;
}

@implementation ScribeEngine (SetTimeout)


// Used to implement setTimeout() and setInterval()
- (int) runFunction: (JSValueRefAndContextRef) fn
         afterDelay: (JSValueRefAndContextRef) timeout
            repeats: (BOOL) repeats {

  JSObjectRef __block obj = JSValueToObject(fn.ctx, fn.value, NULL);
  // JSValueProtect(fn.ctx, fn.value);
  int index = [_timers count];

  Callback *c = [Callback new];
  c.function = fn;
  SCRIBELOG(@"setTimeout called.");
  c.timer = CreateDispatchTimer(
    [self.jsc toDouble: timeout.value]/1000.0f,
    dispatch_get_main_queue(), ^{

    SCRIBELOG(@"Running setTimeout callback");
    [self.jsc callJSFunction: obj withArguments: @[]];

    if (!repeats) {
      [_timers replaceObjectAtIndex: index withObject: [NSNull null]];
    }
  });

  [_timers addObject: c];
  [c release];

  return index+1;
}

// Used to implement clearTimeout() and clearInterval()
- (void) cancelFunction: (int) key {
  key--;

  if (key < [_timers count] && key > -1) {
    Callback *c = [_timers objectAtIndex: key];
    if (c != (Callback *)[NSNull null]) {
      [_timers replaceObjectAtIndex: key withObject: [NSNull null]];
    }
  }
}


@end
