#import "AppDelegate.h"

@implementation AppDelegate

- (id) init {
  if (self = [super init]) {
    window = [[ScribeWindow alloc] initWithFrame: CGRectMake(0, 0, 800, 800)];
  }
  return self;
}

- (void) applicationWillFinishLaunching: (NSNotification *) n {
  [window makeKeyAndOrderFront: self];
}

- (void) dealloc {
  [window release];
  [super dealloc];
}

@end
