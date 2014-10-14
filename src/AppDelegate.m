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

- (NSString *) plistPath {
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *plistPath = nil;

  if (bundle) {
    plistPath = [bundle pathForResource: @"Info" ofType: @"plist"];
  }

  if (!plistPath) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cwd = [fileManager currentDirectoryPath];
    plistPath = [cwd stringByAppendingString: @"/Info.plist"];
  }

  return plistPath;
}

- (void) dealloc {
  [infoPlist release];
  [super dealloc];
}

@end
