#import "UnitTest.h"
#import "TestHelpers.h"
#import "ScribeWindow.h"
#import "ScribeEngine.h"
#import <JavascriptCore/JavascriptCore.h>

NSMutableArray *jsTests = nil;
extern int osxStart __asm("section$start$__DATA$__osxjs");

void runJSTest() {
  NSString *path = [jsTests lastObject];
  path = [NSString stringWithFormat: @"./test/%@", path];

  NSString *js = [NSString
    stringWithContentsOfFile: path
                    encoding: NSUTF8StringEncoding
                       error: nil];

  [jsTests removeLastObject];

  JSVirtualMachine *vm = [[JSVirtualMachine new] autorelease];
  JSContext *context = [[[JSContext alloc] initWithVirtualMachine: vm] autorelease];
  
  ScribeEngine *scribeEngine = [ScribeEngine inject: context];

  if (osxStart) {
    NSString *jsOSX = [NSString stringWithCString: (char*)&osxStart encoding: NSUTF8StringEncoding];
    [scribeEngine.jsCocoa evalJSString: jsOSX];
  }

  NSString *helpersjs = [NSString
    stringWithContentsOfFile: @"./test/support/TestHelpers.js"
                    encoding: NSUTF8StringEncoding
                       error: nil];
  [scribeEngine.jsCocoa evalJSString: helpersjs];

  js = [NSString stringWithFormat: @"try{%@}catch(e){this.ERROR=e}", js];
  [scribeEngine.jsCocoa evalJSString: js];
  JSValue *err = context[@"ERROR"];
  if (!([err isUndefined] || [err isNull])) {
    [NSException raise: @"Error loading JS file" format:@"%@\n%@",
      [err[@"message"] toString], [err[@"stack"] toString]];
  }

  BOOL passed = true;
  while ([context[@"UnitTest"][@"hasNext"] toBool]) {
    NSString *specName = [context[@"UnitTest"][@"nextName"] toString];

    int keepRunning = true;
    __block int* intPtr = &keepRunning;
    int timer = 0;

    [context[@"UnitTest"][@"runTest"] callWithArguments: @[^() {
      *intPtr = false;
    }]];
    
    // wait for the done callback to finish
    int end = (int)time(NULL) + 5;
    BOOL timeExpired = NO;
    while (keepRunning && (timeExpired = (int)time(NULL) < end));

    if (timeExpired) {
      ReportSpecFailure(specName, @"Time expired while running spec.");
    } else {
      JSValue *err = context[@"ERROR"];
      if ([err isUndefined] || [err isNull]) {
        ReportSpecSuccess(specName);
      } else {
        passed = false;
        NSString *errStr = [NSString stringWithFormat: @"%@\n%@",
          [err[@"message"] toString], [err[@"stack"] toString]];
        ReportSpecFailure(specName, errStr);
      }
    }
  }

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
