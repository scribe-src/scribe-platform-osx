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

TEST(InvalidPlistFile)
  AppDelegate *appDelegate = [AppDelegate new];
  NSString *plistPath = [appDelegate plistPath];
  NSString *invalidStr = @"INVALID";
  [invalidStr writeToFile: plistPath
               atomically: YES
                 encoding: NSUTF8StringEncoding
                    error: nil];
  @try {
    [appDelegate readInfoPlist];
    Assert(false);
  } @catch (NSException *e) {
    AssertObjEqual([e name], @"Invalid Info.plist");
  }
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: plistPath error: nil];
END_TEST

TEST(ValidPlistFile)
  AppDelegate *appDelegate = [AppDelegate new];
  NSString *plistPath = [appDelegate plistPath];
  NSDictionary *dict = @{ @"a": @"b" };
  [dict writeToFile: plistPath atomically: YES];
  @try {
    [appDelegate readInfoPlist];
    AssertObjEqual(appDelegate.infoPlist, dict);
  } @catch (NSException *e) {
    Assert(false);
  }
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: plistPath error: nil];
END_TEST

END_TEST_SUITE
