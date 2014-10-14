#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ScribeWindow.h"

@interface AppDelegate: NSObject <NSApplicationDelegate, NSWindowDelegate> {
  NSDictionary *infoPlist;
  JSContext    *mainContext;
}

// populates the {mainContext} ivar with a valid JS runtime context
- (void) buildJSContext;

// Reads and acts on the contents of the Info.plist conf file
- (void) processInfoPlist;

// Attempts to populate the {infoPlist} ivar with the dictionary
// in the Info.plist contained in either the bundle or the current
// working directory.
//
// Raises an NSException when the plist cannot be found or parsed.
- (void) readInfoPlist;

@property (nonatomic, assign) NSDictionary *infoPlist;
@property (nonatomic, assign) JSContext    *mainContext;

@end
