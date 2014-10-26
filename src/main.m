#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "ScribeWindow.h"

int main(int argc, char * argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  [app setActivationPolicy: NSApplicationActivationPolicyRegular];

  AppDelegate *appDelegate =  [[AppDelegate new] autorelease];
  [app setDelegate: appDelegate];

  [app run];

  [pool drain];

  return EXIT_SUCCESS;
}
