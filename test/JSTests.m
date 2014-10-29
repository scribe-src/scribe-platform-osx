#import "UnitTest.h"
#import "TestHelpers.h"
#import "ScribeWindow.h"
#import "ScribeEngine.h"
#import <JavascriptCore/JavascriptCore.h>

NSMutableArray *jsTests = nil;
int* intPtr = NULL;
@interface Killer: NSObject {}
- (void)kill;
@end
@implementation Killer
- (void)kill{ *intPtr = 0; }
@end

extern int osxStart __asm("section$start$__DATA$__osxjs");

BOOL hasError(ScribeEngine *engine) {
  return !![engine.jsCocoa objectWithName: @"ERROR"];
}

void runJSTest() {
  NSString *path = [jsTests lastObject];
  path = [NSString stringWithFormat: @"./test/%@", path];

  NSString *js = [NSString
    stringWithContentsOfFile: path
                    encoding: NSUTF8StringEncoding
                       error: nil];

  [jsTests removeLastObject];
  
  // context[@"setTimeout"] = ^(JSValue* function, JSValue* timeout) {
  //   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([timeout toInt32] * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
  //       [function callWithArguments:@[]];
  //   });
  // };

  ScribeEngine *scribeEngine = [ScribeEngine new];

  if (osxStart) {
    NSString *jsOSX = [NSString stringWithCString: (char*)&osxStart encoding: NSUTF8StringEncoding];
    [scribeEngine.jsCocoa evalJSString: jsOSX];
  }

  NSString *helpersjs = [NSString
    stringWithContentsOfFile: @"./test/support/TestHelpers.js"
                    encoding: NSUTF8StringEncoding
                       error: nil];
  [scribeEngine.jsCocoa evalJSString: helpersjs];

  js = [NSString stringWithFormat: @"this.ERROR=null;try{%@}catch(e){this.ERROR=e}", js];
  [scribeEngine.jsCocoa evalJSString: js];
  if (hasError(scribeEngine)) {
    JSValueRef err = [scribeEngine.jsCocoa evalJSString: @"this.ERROR"];
    NSString *errStr = [scribeEngine.jsCocoa toString: err];   
    [NSException raise: @"Error loading JS file" format:@"%@", errStr];
  }


  BOOL passed = true;
  while (JSValueToBoolean(scribeEngine.context,
    [scribeEngine.jsCocoa evalJSString: @"UnitTest.hasNext"])) {

    NSString *specName = [scribeEngine.jsCocoa objectWithName: @"UnitTest.nextName"];

    int keepRunning = true;
    intPtr = &keepRunning;
    int timer = 0;

    [scribeEngine.jsCocoa callJSFunctionNamed: @"RUN" withArgumentsArray: @[
      [Killer new]
    ]];
    
    // wait for the done callback to finish
    double timeout = JSValueToNumber(scribeEngine.context, 
      [scribeEngine.jsCocoa evalJSString: @"UnitTest.timeout"], NULL
    );

    double end = ((double)(int)time(NULL)) + timeout;
    BOOL timeExpired = NO;
    while (keepRunning && !timeExpired) {
      NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

      // spin the Cocoa run loop while the test executes
      // this works really well,wtf
      NSEvent *event =
          [NSApp
              nextEventMatchingMask:NSAnyEventMask
              untilDate: [[NSDate date] dateByAddingTimeInterval: 1]
              inMode:NSDefaultRunLoopMode
              dequeue:YES];

      [NSApp sendEvent:event];
      [NSApp updateWindows];

      [pool release];
      timeExpired = ((double)(int)time(NULL) > end);
    }

    if (timeExpired) {
      ReportSpecFailure(specName, [NSString stringWithFormat:
        @"Time expired (%.1f seconds) while running spec.", timeout
      ]);
    } else {
      if (hasError(scribeEngine)) {
        JSValueRef err = [scribeEngine.jsCocoa evalJSString: @"this.ERROR"];
        passed = false;
        NSString *errStr = [scribeEngine.jsCocoa toString: err];
        ReportSpecFailure(specName, errStr);
      } else {
        ReportSpecSuccess(specName);
      }
    }
  }

  [scribeEngine release];

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
    NSString *safeName = [[testName componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    Class ourClass = object_getClass([JSTests class]);
    class_addMethod(ourClass, NSSelectorFromString(safeName), (IMP)runJSTest, "v@:");
  }
END_SUITE_INIT

END_TEST_SUITE
