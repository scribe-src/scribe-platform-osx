#import "UnitTest.h"
#import "TestHelpers.h"
#import "ScribeWindow.h"
#import "ScribeEngine.h"
#import <JavascriptCore/JavascriptCore.h>

NSMutableArray *jsTests = nil;
extern NSString *$currentTest;

extern int osxStart __asm("section$start$__DATA$__osxjs");

BOOL hasError(ScribeEngine *engine) {
  return !![engine.jsc objectWithName: @"ERROR"];
}

void runJSTest() {
  NSAutoreleasePool *bigPool = [[NSAutoreleasePool alloc] init];

  // this line prevents an error: Error (1000) creating CGSWindow
  [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular];

  int idx = 0;
  for (; idx < [jsTests count]; idx++) {
    if ([[[jsTests objectAtIndex: idx] stringByDeletingPathExtension] isEqual: $currentTest]) break;
  }
  if (idx >= [jsTests count]) {
    NSLog(@"Error: runJSTest called for %@, not found in jsTests global.", $currentTest);
    return;
  }

  NSString *path = [jsTests objectAtIndex: idx];
  path = [NSString stringWithFormat: @"./test/%@", path];

  NSString *js = [NSString
    stringWithContentsOfFile: path
                    encoding: NSUTF8StringEncoding
                       error: nil];

  [jsTests removeObjectAtIndex: idx];

  ScribeEngine *scribeEngine = [ScribeEngine new];

  if (osxStart) {
    NSString *jsOSX = [NSString stringWithCString: (char*)&osxStart encoding: NSUTF8StringEncoding];

    NSString *myErr;
    if (![scribeEngine.jsc isSyntaxValid: jsOSX error: &myErr]) {
      [NSException raise: @"Syntax error in JS:" format:@"%@", myErr];
    }

    jsOSX = [NSString stringWithFormat: @"this.ERROR=null;try{%@}catch(e){this.ERROR=e}", jsOSX];
    [scribeEngine.jsc evalJSString: jsOSX];
    if (hasError(scribeEngine)) {
      JSValueRef err = [scribeEngine.jsc evalJSString: @"this.ERROR"];
      NSString *errStr = [scribeEngine.jsc toString: err];   
      [NSException raise: @"Error loading JS file" format:@"%@", errStr];
    }
    [scribeEngine.jsc evalJSString: @"delete this.ERROR"];
  } else {
    [NSException raise: @"+osxStart+ macho segment not found, exiting." format:@""];
  }

  NSString *helpersjs = [NSString
    stringWithContentsOfFile: @"./test/support/TestHelpers.js"
                    encoding: NSUTF8StringEncoding
                       error: nil];
  [scribeEngine.jsc evalJSString: helpersjs];

  js = [NSString stringWithFormat: @"this.ERROR=null;try{%@}catch(e){this.ERROR=e}", js];
  [scribeEngine.jsc evalJSString: js];

  if (hasError(scribeEngine)) {
    JSValueRef err = [scribeEngine.jsc evalJSString: @"this.ERROR"];
    NSString *errStr = [scribeEngine.jsc toString: err];   
    [NSException raise: @"Error loading JS file" format:@"%@", errStr];
  }

  [scribeEngine.jsc evalJSString: @"delete this.ERROR"];

  while ([scribeEngine.jsc toBool:
    [scribeEngine.jsc evalJSString: @"UnitTest.hasNext"]]) {


    [scribeEngine.jsc evalJSString: @"this.killed=false;"];
    NSString *specName = [scribeEngine.jsc objectWithName: @"UnitTest.nextName"];

    [scribeEngine.jsc callFunction: @"RUN"];
    
    // wait for the done callback to finish
    double timeout = JSValueToNumber(scribeEngine.context, 
      [scribeEngine.jsc evalJSString: @"UnitTest.timeout"], NULL
    );

    double end = ((double)(int)time(NULL)) + timeout;
    BOOL timeExpired = NO;
    while (![scribeEngine.jsc toBool:
      [scribeEngine.jsc evalJSString: @"this.killed"]] && !timeExpired) {
      [ScribeEngine spin: 1000];
      timeExpired = ((double)(int)time(NULL) > end);
    }
    if (timeExpired) {
      ReportSpecFailure(specName, [NSString stringWithFormat:
        @"Time expired (%.1f seconds) while running spec.", timeout
      ]);
    } else {
      if (hasError(scribeEngine)) {
        JSValueRef err = [scribeEngine.jsc evalJSString: @"this.ERROR"];
        [scribeEngine.jsc evalJSString: @"delete this.ERROR"];
        NSString *errStr = [scribeEngine.jsc toString: err];
        ReportSpecFailure(specName, errStr);
      } else {
        ReportSpecSuccess(specName);
      }
    }

  }

  [scribeEngine release];
  [bigPool drain];

  Assert(true);
}


TEST_SUITE(JSTests)

FORK(NO)

// Dynamically adds class methods per JS file discovered
SUITE_INIT
  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *dirContents = [fm contentsOfDirectoryAtPath: @"./test/" error: nil];
  NSPredicate *predicate = [NSPredicate predicateWithFormat: @"pathExtension == 'js'"];
  jsTests = [[dirContents filteredArrayUsingPredicate: predicate] mutableCopy];
  for (NSString *testName in jsTests) {
    testName = [testName stringByDeletingPathExtension];
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *safeName = [[testName componentsSeparatedByCharactersInSet: charactersToRemove] componentsJoinedByString: @""];
    class_addMethod(object_getClass([JSTests class]), NSSelectorFromString(safeName), (IMP)runJSTest, "v@:");
  }
END_SUITE_INIT

END_TEST_SUITE
