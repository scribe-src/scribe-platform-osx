#import "UnitTest.h"
#import "TestHelpers.h"
#import "AppDelegate.h"

TEST_SUITE(AppDelegateTests)

TEST(MissingPlistFile)
  @try {
    AppDelegate *del = [AppDelegate new];
    [del readInfoPlist];
    Assert(false);
  } @catch (NSException *e) {
    AssertObjEqual([e name], @"Missing Info.plist");
  }
END_TEST

TEST(ValidPlistFile)
  AppDelegate *del = [AppDelegate new];
  NSDictionary *dict = @{ @"a": @"b" };
  [dict writeToFile: [del plistPath] atomically: YES];
  @try {
    [del readInfoPlist];
    AssertObjEqual(del.infoPlist, dict);
  } @catch (NSException *e) {
    Assert(false);
  }
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: [del plistPath] error: nil];
END_TEST

END_TEST_SUITE
