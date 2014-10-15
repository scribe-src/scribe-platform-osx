#import "UnitTest.h"
#import "TestHelpers.h"
#import "AppDelegate.h"

TEST_SUITE(AppDelegateTests)

TEST(MissingPlistFile)
  @try {
    AppDelegate *del = [[AppDelegate new] autorelease];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: [del plistPath] error: nil];
    [del readInfoPlist];
    Assert(false);
  } @catch (NSException *e) {
    AssertObjEqual([e name], @"Missing Info.plist");
  }
END_TEST

TEST(PlistPathDefaultValueIsInfoDotPlist)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  AssertObjEqual([[appDelegate plistPath] lastPathComponent], @"Info.plist");
END_TEST

TEST(InvalidPlistFile)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
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
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  NSString *plistPath = [appDelegate plistPath];
  NSDictionary *dict = @{ @"a": @"b" };
  [dict writeToFile: plistPath atomically: YES];
  [appDelegate readInfoPlist];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: plistPath error: nil];
  AssertObjEqual(appDelegate.infoPlist, dict);
END_TEST

TEST(MainJSPathDefaultValueIsMainDotJS)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  AssertObjEqual([[appDelegate mainJSPath] lastPathComponent], @"main.js");
END_TEST

TEST(MainJSIsRun)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  NSString *plistPath = [appDelegate plistPath];
  NSString *mainJSPath = [appDelegate mainJSPath];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: plistPath error: nil];
  [fileManager removeItemAtPath: mainJSPath error: nil];

  NSDictionary *dict = @{ @"MainJS": @"main.js" };
  [dict writeToFile: plistPath atomically: YES];
  NSString *mainjs = @"x = 1;";
  [mainjs writeToFile: mainJSPath atomically: YES encoding: NSUTF8StringEncoding error: nil];
  [appDelegate applicationDidFinishLaunching: nil];
  
  [fileManager removeItemAtPath: plistPath error: nil];
  [fileManager removeItemAtPath: mainJSPath error: nil];
  AssertFalse([[appDelegate mainContext][@"x"] isUndefined]);
END_TEST

TEST(MissingMainJSKeyRaiseException)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  @try {
    [appDelegate loadMainJS];
    Assert(false);
  } @catch (NSException *e) {
    AssertObjEqual([e name], @"Invalid MainJS File");
  }
END_TEST

TEST(InvalidMainJSKeyRaiseException)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  NSString *jsPath = [appDelegate mainJSPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *err = nil;

  [fileManager createDirectoryAtPath: jsPath
         withIntermediateDirectories: YES
                          attributes: nil
                               error: &err];

  if (err) {
    [NSException raise: @"Test Setup Failed" format: @"Dir error: %@", err];
  }

  @try {
    [appDelegate loadMainJS];
    Assert(false);
  } @catch (NSException *e) {    
    [fileManager removeItemAtPath: jsPath error: nil];
    AssertObjEqual([e name], @"Invalid MainJS File");
  }
END_TEST

TEST(RuntimeErrorInMainJSFileRaisesException)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  NSString *mainJSPath = [appDelegate mainJSPath];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: mainJSPath error: nil];

  NSString *mainjs = @"ijsdaalskj();";
  [mainjs writeToFile: mainJSPath atomically: YES encoding: NSUTF8StringEncoding error: nil];
  
  @try {
    [appDelegate loadMainJS];
    Assert(false);
  } @catch (NSException *e) {
    [fileManager removeItemAtPath: mainJSPath error: nil];
    AssertObjEqual([e name], @"MainJS Runtime Exception"); 
  }
END_TEST

TEST(ScribeGlobalIsAvailableToJSEnvironment)
  AppDelegate *appDelegate = [[AppDelegate new] autorelease];
  NSString *plistPath = [appDelegate plistPath];
  NSString *mainJSPath = [appDelegate mainJSPath];
  NSDictionary *dict = @{ @"MainJS": @"main.js" };
  [dict writeToFile: plistPath atomically: YES];
  NSString *mainjs = @"";
  [mainjs writeToFile: mainJSPath atomically: YES encoding: NSUTF8StringEncoding error: nil];
  [appDelegate applicationDidFinishLaunching: nil];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath: plistPath error: nil];
  [fileManager removeItemAtPath: mainJSPath error: nil];
  AssertFalse([[appDelegate mainContext][@"scribe"] isUndefined]);
END_TEST

END_TEST_SUITE
