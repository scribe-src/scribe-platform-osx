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

#define TEST_SUITE(name) @interface name: UnitTest\
                         @end\
                         @implementation name

#define END_TEST_SUITE @end

#define TEST(name) + (void) name {

#define END_TEST }

#define FORK_TESTS 1

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

@interface UnitTest: NSObject
@end
