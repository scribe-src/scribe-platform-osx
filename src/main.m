#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "ScribeWindow.h"

int main(int argc, char * argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];

  AppDelegate *appDelegate =  [[AppDelegate new] autorelease];
  [app setDelegate:appDelegate];

  // the MainMenu is stored in a NIB file
  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
  NSString *mainNibName = [infoDictionary objectForKey:@"NSMainNibFile"];
  NSNib *mainNib = [[NSNib alloc] initWithNibNamed: mainNibName
                                  bundle: [NSBundle mainBundle]];
  [mainNib instantiateNibWithOwner: app topLevelObjects: nil];

  [app run];

  [pool drain];

  return EXIT_SUCCESS;
}
