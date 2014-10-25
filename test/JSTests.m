#import "UnitTest.h"
#import "TestHelpers.h"
#import "ScribeWindow.h"

NSMutableArray *jsTests = nil;

void runJSTest() {
  Assert(true);
}

TEST_SUITE(JSTests)

// Dynamically adds class methods per JS file discovered
SUITE_INIT
  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *dirContents = [fm contentsOfDirectoryAtPath: @"/Users/scribe/dev/scribe-platform-osx/test/" error: nil];
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
