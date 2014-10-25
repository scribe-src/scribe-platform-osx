function O2S(obj) {
  if (obj === null)
    return "null";
  if (obj === undefined)
    return "undefined";
  if (obj && obj.toString)
    return obj.toString();
  if (obj === true)
    return "true";
  if (obj === false)
    return "false";
  if (obj)
    return "[Object truthy]";

  return "[Object falsey]";
}

function Assert(x) {
  if (!x)
    throw new Error("Expected "+O2S(str)+" to be truthy.")
}

function AssertLooseEqual(x, y) {
  if (x != y)
    throw new Error("Expected "+O2S(x)+" to == "+O2S(y)+".");
}

function AssertEqual(x, y) {
  if (x !== y)
    throw new Error("Expected "+O2S(x)+" to === "+O2S(y)+".");
}

function AssertFalse(x) {
  if (x)
    throw new Error("Expected "+O2S(str)+" to be falsey.")
}

function AssertLooseNotEqual(x, y) {
  if (x == y)
    throw new Error("Expected "+O2S(x)+" to != "+O2S(y)+".");
}

function AssertNotEqual(x, y) {
  if (x === y)
    throw new Error("Expected "+O2S(x)+" to !== "+O2S(y)+".");
}

// Implement a tiny DSL for adding multiple tests in one file
var global = this;
global.tests = [];
var currTestIdx = 0;
function UnitTest(name, fn) {
  global.tests.push({ name: name, fn: fn });
  UnitTest.nextName = UnitTest.testName();
  UnitTest.hasNext = (UnitTest.nextName != null);
}
UnitTest.hasNext = false;
UnitTest.nextName = null;
UnitTest.testName = function() {
  if (currTestIdx < global.tests.length) {
    return global.tests[currTestIdx].name;
  } else {
    return null;
  }
};
UnitTest.runTest = function() {
  UnitTest.next();
  UnitTest.nextName = UnitTest.testName();
  UnitTest.hasNext = (UnitTest.nextName != null);

  if (currTestIdx-1 < global.tests.length) {
    var fn = global.tests[currTestIdx-1].fn;
    try {
      fn();
      delete global.ERROR;
      return true;
    } catch (e) {
      global.ERROR = e;
      return false;
    }
  } else {
    return null;
  }
};
UnitTest.next = function() {
  currTestIdx++;
};