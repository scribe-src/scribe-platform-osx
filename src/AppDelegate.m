#import "AppDelegate.h"
#import "JSDebugConsole.h"
#import "FileSystem.h"

extern int osxStart __asm("section$start$__DATA$__osxjs");

@implementation AppDelegate

@synthesize infoPlist, engine;

// This method is called on the delegate by NSApplicationMain() when
// initialization is complete (when the Dock icon stops bouncing).
// It is a part of the <NSApplicationDelegate> protocol.
- (void) applicationDidFinishLaunching: (NSNotification *) n {

  // this line prevents an error: Error (1000) creating CGSWindow
  [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular];

  @try {
    [self buildJSContext];
    [self readInfoPlist];

    if ([[NSProcessInfo processInfo].arguments count] > 1 &&
      [[[NSProcessInfo processInfo].arguments objectAtIndex: 1]
      isEqual: @"console"]) {

      JSDebugConsole *console = [[JSDebugConsole alloc] initWithJSCocoa: engine.jsc];
      [console start];
      [console release];
    }

    [self loadMainJS];
  } @catch (NSException *e) {
    NSLog(@"Error occurred during initialization: %@", e);
    exit(1);
  }
}

- (void) applicationDidChangeScreenParameters: (NSNotification *) aNotification {
  // TODO: send to all ScribeEngines: 'Scribe.Screen.trigger("change")'
}

- (void) buildJSContext {
  // inject the window.scribe global into the JavaScriptCore runtime
  self.engine = [[ScribeEngine new] autorelease];

  if (osxStart) {
    NSString *js = [NSString stringWithCString: (char*)&osxStart encoding: NSUTF8StringEncoding];
    [engine.jsc evalJSString: js];
  }
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
  NSString *js   = nil;

  js = [NSString stringWithContentsOfFile: jsPath
                               encoding: NSUTF8StringEncoding
                                  error: &err];

  if (err || !js) {
    NSData *data = [[FileSystem shared] fileAtPath: @"main.js"];
    SCRIBELOG(@"Loaded main.js data: %d", [data length]);
    if (data && data.length > 0) {
      js = [NSString stringWithUTF8String: [data bytes]];
    }
    if (js) {
      err = nil;
    }
  }

  if (!err && js) {
    // wrap the JS with a try{}catch{} so we can report errors
    js = [NSString stringWithFormat:
      @"var err;try{(function(){%@})();}catch(e){err = e};err;", js];

    JSValueRef jsErr = [engine.jsc evalJSString: js];

    // Check and bubble any JS errors as objc Exceptions
    if (!JSValueIsUndefined(self.engine.context, jsErr)) {
      [NSException raise: @"MainJS Runtime Exception" format:
        @"An error occurred trying to execute the MainJS File: %@\n\n%@\n\n%@",
        jsPath, [self.engine.jsc toString: jsErr], js
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

- (NSString *) resourcesDir {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *cwd = [fileManager currentDirectoryPath];
  NSString *app = [cwd stringByDeletingLastPathComponent];
  return [app stringByAppendingPathComponent: @"Resources"];
}

// The baseURL for webView SOP (defaults to file:// path)
- (NSURL *) baseURL {
  return [NSURL URLWithString:
    [self pathForResource: @"index" ofType: @"html"]
  ];
}

- (void) dealloc {
  [engine release], engine = nil;
  [super dealloc];
}

@end
