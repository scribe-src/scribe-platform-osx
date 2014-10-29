#import "ScribeWindow.h"
#import "ScribeEngine.h"

@interface AppDelegate: NSObject <NSApplicationDelegate, NSWindowDelegate> {
  NSDictionary *infoPlist;
  ScribeEngine *engine;
}

- (void) buildJSContext;

// Attempts to populate the {infoPlist} ivar with the dictionary
// in the Info.plist contained in either the bundle or the current
// working directory.
//
// Raises an NSException when the plist cannot be found or parsed.
- (void) readInfoPlist;

// Executes the main.js Javascript execution entrypoint.
// Raises an NSException when the main.js file is not valid or is missing.
- (void) loadMainJS;

// Returns the path to the Info.plist file for this application or exe.
- (NSString *) plistPath;

// Returns the path to the main.js file that is the program entrypoint.
// This can be specified in Info.plist under the {MainJS} key.
// Defaults to "main.js" in the Bundle or current working directory.
- (NSString *) mainJSPath;

// Looks for +filename+ in either the bundle or the current working dir.
- (NSString *) pathForResource: (NSString *)filename
                        ofType: (NSString *)type;

// The baseURL for webView SOP (defaults to file:// path)
- (NSURL *)baseURL;

// The plist configuration hash in this application's bundle
@property (nonatomic, retain) NSDictionary *infoPlist;

// The Javascript runtime for running the MainJS js entrypoint
@property (nonatomic, retain) ScribeEngine *engine;

@end
