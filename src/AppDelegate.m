#import "AppDelegate.h"

@implementation AppDelegate

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

- (void) applicationWillFinishLaunching: (NSNotification *) notification {
  [window makeKeyAndOrderFront:self];
}

- (void) dealloc {
  [window release];
  [super dealloc];
}

@end