#import "AppDelegate.h"
#import "ScribeEngine.h"


@implementation AppDelegate

@synthesize infoPlist, mainContext;

// This method is called on the delegate by NSApplicationMain() when
// initialization is complete (when the Dock icon stops bouncing).
// It is a part of the <NSApplicationDelegate> protocol.
- (void) applicationDidFinishLaunching: (NSNotification *) n {
  @try {
    [self buildJSContext];
    [self readInfoPlist];
    [self loadMainJS];
  } @catch (NSException *e) {
    NSLog(@"Error occurred during initialization: %@", e);
    exit(1);
  }
}

// populates the {mainContext} ivar with a valid JS runtime context
- (void) buildJSContext {
  // build the vm and context
  JSVirtualMachine *vm = [[JSVirtualMachine new] autorelease];
  self.mainContext = [[[JSContext alloc] initWithVirtualMachine: vm] autorelease];

  // inject the window.scribe global into the JavaScriptCore runtime
  [ScribeEngine inject: self.mainContext];
}

// Attempts to populate the {infoPlist} ivar with the dictionary
// in the Info.plist contained in either the bundle or the current
// working directory.
//
// Raises an NSException when the plist cannot be found or parsed.
- (void) readInfoPlist {
  self.infoPlist = [[NSBundle mainBundle] infoDictionary];

#ifdef TEST_ENV

  // None of the below code is really necessary anymore (since I
  // remmebered I could call -infoDictionary and get the Hash),
  // but I keep it around since it is useful for test stubbing
  // and debugging

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
#endif
}

// Executes the main.js Javascript execution entrypoint.
// Raises an NSException when the main.js file is not valid, is missing, or
// when an exception is thrown during synchronous execution of the file.
- (void) loadMainJS {
  NSString *jsPath = [self mainJSPath];
  NSError  *err  = nil;

  NSString *js = [NSString stringWithContentsOfFile: jsPath
                                           encoding: NSUTF8StringEncoding
                                              error: &err];
  if (!err && js) {

    // wrap the JS with a try{}catch{} so we can report errors
    js = [NSString stringWithFormat:
      @"var err;try{(function(){%@})();}catch(e){err = e};err;", js];

    JSValue *jsErr = [self.mainContext evaluateScript: js];

    // Check and bubble any JS errors as objc Exceptions
    if (![jsErr isUndefined]) {
      [NSException raise: @"MainJS Runtime Exception" format:
        @"An error occurred trying to execute the MainJS File: %@\n\n%@",
        jsPath, jsErr
      ];
    }
  } else {

    [NSException raise: @"Invalid MainJS File" format:
      @"An error occurred trying to read the MainJS File: %@\n\n%@",
      jsPath, err
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
  NSString *finalPath = nil;

  if (bundle) {
    finalPath = [bundle pathForResource: filename ofType: type];
  }

  if (!finalPath) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cwd = [fileManager currentDirectoryPath];
    NSString *file = [NSString stringWithFormat: @"%@.%@", filename, type];
    finalPath = [cwd stringByAppendingPathComponent: file];
  }

  return finalPath;
}

- (NSString *)resourcesDir {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *cwd = [fileManager currentDirectoryPath];
  NSString *app = [cwd stringByDeletingLastPathComponent];
  return [app stringByAppendingPathComponent: @"Resources"];
}

// The baseURL for webView SOP (defaults to file:// path)
- (NSURL *)baseURL {
  return [NSURL URLWithString:
    [NSString stringWithFormat: @"file://%@/Resources/", [self resourcesDir]]
  ];
}

@end
