#import "ScribeEngine.h"

@interface ScribeEngine (SetTimeout)

// Used to implement setTimeout() and setInterval()
- (int) runFunction: (JSValueRefAndContextRef) fn
         afterDelay: (JSValueRefAndContextRef) timeout
            repeats: (BOOL) repeats;

// Used to implement clearTimeout() and clearInterval()
- (void) cancelFunction: (int) key;

@end