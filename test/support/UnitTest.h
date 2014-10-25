//
// UnitTest.h - a tiny ObjC unit testing library
// @author admin@scribe.io
// @copyright 2014 Scribe.io
// @license BSD 3-Clause
//
// Sample test: MyObjectTests.m
//
// #import "UnitTest.h"
// #import "MyObject.h"
//
// TEST_SUITE(MyObjectTests)
//
// TEST(EmptyConstructor)
//    AssertNotNil([MyObject new])
// END_TEST
//
// END_TEST_SUITE
//

#include <objc/objc.h>
#include <objc/runtime.h>
#include <execinfo.h>
#import <Foundation/Foundation.h>

//
// Test definition macros
//

// We disable forking during the tests, since the NSBundle API
// does not seem to like it when you fork and then try to access
// [[NSBundle mainBundle] pathForResource:ofType:];

// #define FORK_TESTS 1

#define TEST_SUITE(name) @interface name: TestSuite\
                         @end\
                         @implementation name

#define END_TEST_SUITE @end

#define TEST(name) + (void) name {

#define END_TEST }

#define SUITE_INIT - (void) suiteInitialize {

#define END_SUITE_INIT }

#define FORK(SHOULD) - (BOOL) shouldFork { return SHOULD; }

//
// Test assertion helpers. These throw a helpful exception
// if the asserted condition fails.
//

void Assert(int conditional);
void AssertFalse(int conditional);
void AssertNull(void* obj);
void AssertNotNull(void* ptr);
void AssertNil(void* obj);
void AssertNotNil(void* obj);
void AssertEqual(void* a, void* b);
void AssertIntEqual(int a, int b);
void AssertStrEqual(char* a, char* b);
void AssertObjEqual(id a, id b);
void AssertNotEqual(void* a, void* b);
void AssertIntNotEqual(int a, int b);
void AssertStrNotEqual(void* a, void* b);
void AssertObjNotEqual(id a, id b);
void AssertInstanceOfClass(id instance, Class klass);

void PrintGood(NSString *msg);
void PrintBold(NSString *msg);
void PrintBad(NSString *msg);
void Print(NSString *msg);

void ReportSpecSuccess(NSString *name);
void ReportSpecFailure(NSString *name, NSString *details);

@interface TestSuite: NSObject
- (void) suiteInitialize;
- (BOOL) shouldFork;
@end
