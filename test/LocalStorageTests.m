#import "UnitTest.h"
#import "TestHelpers.h"
#import "ScribeWindow.h"

TEST_SUITE(LocalStorageTests)

FORK(NO)

TEST(LocalStorageIsPersisted)
  // NSApplication *app = [NSApplication sharedApplication];

  // ScribeWindow *win = [ScribeWindow new];
  // [win makeKeyAndOrderFront: nil];
  // WebScriptObject *script = [win.webView windowScriptObject];
  // [script evaluateWebScript: @"window.localStorage.x = '1';"];
  // [win release];
  // win = nil;

  // win = [ScribeWindow new];
  // script = [win.webView windowScriptObject];
  // id one = [script evaluateWebScript: @"window.localStorage.x == '1'"];

  // [win release];
  // win = nil;

  // AssertObjEqual([one toNumber], [NSNumber numberWithInt: 1]);
END_TEST

END_TEST_SUITE
