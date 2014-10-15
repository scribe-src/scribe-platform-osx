#import "AppDelegate.h"

@implementation AppDelegate

@synthesize infoPlist, mainContext;

- (void) applicationDidFinishLaunching: (NSNotification *) n {
  [self buildJSContext];
  [self processInfoPlist];
}

// populates the {mainContext} ivar with a valid JS runtime context
- (void) buildJSContext {
  JSVirtualMachine *vm = [[JSVirtualMachine new] autorelease];
  mainContext = [[JSContext alloc] initWithVirtualMachine: vm];
}

// Reads and acts on the contents of the Info.plist conf file
// To be called during initialization. Exits on error.
- (void) processInfoPlist {
  @try {
    [self readInfoPlist];
  } @catch (NSException *e) {
    NSLog(@"%@", e);
    exit(1);
  }
}

// Attempts to populate the {infoPlist} ivar with the dictionary
// in the Info.plist contained in either the bundle or the current
// working directory.
//
// Raises an NSException when the plist cannot be found or parsed.
- (void) readInfoPlist {
  BOOL isDir;
  NSString *plistPath = [self plistPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath: plistPath isDirectory: &isDir]
       && !isDir) {

    self.infoPlist = [NSDictionary dictionaryWithContentsOfFile: plistPath];

  } else {
    [NSException raise: @"Missing Info.plist" format:
      @"Info.plist file at %@ could not be found.", plistPath, nil
    ];
  }

  if (!self.infoPlist) {
    [NSException raise: @"Invalid Info.plist" format:
      @"Info.plist file at %@ could not be parsed.", plistPath, nil
    ];
  }
}

// Returns the path to the Info.plist file for this application or exe
- (NSString *) plistPath {
  return [self pathForResource: @"Info" ofType: @"plist"];
}

// Returns the path to the main.js file that is the program entrypoint.
// This can be specified in Info.plist under the {MainJS} key.
// Defaults to "main.js" in the Bundle or current working directory.
- (NSString *) mainJSPath {
  NSString *fname = nil;
  NSString *ftype = nil;

  if (self.infoPlist) {
    fname = [self.infoPlist objectForKey: @"MainJS"];
    if (fname) {
      ftype = [fname pathExtension];
      fname = [[fname lastPathComponent] stringByDeletingPathExtension];
    }
  }

  if (!fname) fname = @"main";
  if (!ftype) ftype = @"js";

  return [self pathForResource: fname ofType: ftype];
}
// Looks for +filename+ in either the bundle or the current working dir.
- (NSString *) pathForResource: (NSString *)filename
                        ofType: (NSString *)type {
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *plistPath = nil;

  if (bundle) {
    plistPath = [bundle pathForResource: filename ofType: type];
  }

  if (!plistPath) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cwd = [fileManager currentDirectoryPath];
    NSMutableString *cwdMutable = [NSMutableString stringWithString: cwd];
    
    if (![cwdMutable hasSuffix: @"/"]) {
      [cwdMutable appendString: @"/"];
    }

    [cwdMutable appendFormat: @"%@.%@", filename, type];
    plistPath = cwdMutable;
  }

  return plistPath;
}

- (void) dealloc {
  [infoPlist release];
  [super dealloc];
}

@end
