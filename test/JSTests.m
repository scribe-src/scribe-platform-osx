#import "UnitTest.h"
#import "TestHelpers.h"
#import "ScribeWindow.h"
#import "ScribeEngine.h"
#import <JavascriptCore/JavascriptCore.h>

NSMutableArray *jsTests = nil;

void runJSTest() {
  NSString *path = [jsTests lastObject];
  path = [NSString stringWithFormat: @"./test/%@", path];

  NSString *js = [NSString
    stringWithContentsOfFile: path
                    encoding: NSUTF8StringEncoding
                       error: nil];

  js = [NSString stringWithFormat: @"try { %@ } catch(e){this.ERROR=e}", js];
  [jsTests removeLastObject];

  JSVirtualMachine *vm = [[JSVirtualMachine new] autorelease];
  JSContext *context = [[[JSContext alloc] initWithVirtualMachine: vm] autorelease];
  
  ScribeEngine *scribeEngine = [ScribeEngine inject: context];

  // [context evaluateScript: @"window.ERROR=1;"];
  [scribeEngine.jsCocoa evalJSString: js];
  JSValue *err = context[@"ERROR"];

  if ([err isUndefined] || [err isNull]) {
    JSValue *asserted = context[@"ASSERT"];
    if ([asserted isTrue]) {
      Assert(true);
    } else {
      [NSException raise: @"JS assertion failed" format: @"Error raised in JS.", nil];
    }
  } else {
    [NSException raise: @"False Assertion" format: @"%@\n%@", [err[@"message"] toString], [err[@"stack"] toString], nil];
  }

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
