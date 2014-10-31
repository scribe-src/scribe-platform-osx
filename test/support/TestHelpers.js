function O2S(obj) {
  if (obj === null) {
    return "null";
  }
  if (obj === undefined) {
    return "undefined";
  }
  if (obj && obj.toString) {
    return obj.toString();
  }
  if (obj === true) {
    return "true";
  }
  if (obj === false) {
    return "false";
  }

  return String(obj);
}

function Assert(x) {
  if (!x) {
    throw new Error("Expected " + O2S(x) + " to be truthy.");
  }
}

function AssertLooseEqual(x, y) {
  if (x != y) {
    throw new Error("Expected " + O2S(x) + " to == " + O2S(y) + ".");
  }
}

function AssertEqual(x, y) {
  if (x !== y) {
    throw new Error("Expected " + O2S(x) + " to === " + O2S(y) + ".");
  }
}

function AssertFalse(x) {
  if (x) {
    throw new Error("Expected " + O2S(x) + " to be falsey.");
  }
}

function AssertLooseNotEqual(x, y) {
  if (x == y) {
    throw new Error("Expected " + O2S(x) + " to != " + O2S(y) + ".");
  }
}

function AssertNotEqual(x, y) {
  if (x === y) {
    throw new Error("Expected " + O2S(x) + " to !== " + O2S(y) + ".");
  }
}

function AssertDefined(x) {
  if (x === undefined) {
    throw new Error("Expected " + O2S(x) + " to be defined.");
  }
}

function AssertUndefined(x) {
  if (x !== undefined) {
    throw new Error("Expected " + O2S(x) + " to be undefined.");
  }
}

// From: http://www.mattsnider.com/parsing-javascript-function-argument-names/
function getParamNames(fn) {
  var funStr = fn.toString();
  return funStr.slice(funStr.indexOf('(') + 1, funStr.indexOf(')')).match(/([^\s,]+)/g);
}

// Implement a tiny DSL for adding multiple tests in one file
var global = this;
global.tests = [];
var currTestIdx = 0;
var defaultTimeout = 5.0;
function UnitTest(name, fn) {
  var params = getParamNames(fn);
  global.tests.push({ name: name, fn: fn, async: !!params });
  UnitTest.nextName = UnitTest.testName();
  UnitTest.hasNext = (UnitTest.nextName !== null);
}
UnitTest.hasNext = false;
UnitTest.nextName = null;
UnitTest.timeout = defaultTimeout;
UnitTest.testName = function () {
  if (currTestIdx < global.tests.length) {
    return global.tests[currTestIdx].name;
  }
  return null;
};
UnitTest.runTest = function (cb) {
  UnitTest.next();
  UnitTest.timeout = defaultTimeout;
  UnitTest.nextName = UnitTest.testName();
  UnitTest.hasNext = (UnitTest.nextName !== null);

  var cb = function() { global.killed = true; };
  var test = global.tests[currTestIdx - 1];
  if (currTestIdx - 1 < global.tests.length) {
    try {
      test.fn.call({
        timeout: function (tm) { UnitTest.timeout = tm; }
      }, cb);
      if (!test.async) cb();
    } catch (e) {
      global.ERROR = e;
      cb();
      return false;
    }
  } else {
    cb();
    return null;
  }
};
UnitTest.next = function () {
  currTestIdx++;
};
RUN = UnitTest.runTest;
