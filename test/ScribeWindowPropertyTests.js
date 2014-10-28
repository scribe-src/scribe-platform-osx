// TODO:
// This should have been written in Jasmine, so that I can
// reuse them across projects without having to re-port the
// test harness.

function buildWindow(opts) {
  var defaults = {
    center: true,
    width: 800,
    height: 900,
    top: 2,
    left: 1,
    chrome: false
  };
  opts = opts || {};
  for (var key in opts) {
    defaults[key] = opts[key];
  }
  return Scribe.Window.create(defaults);
}

function spy(retVal) {
  var called = 0;
  var me = function() { called++; return retVal }
  me.called = function() { return called; };
  return me;
}

UnitTest("width getter returns the width", function(){
  var win = buildWindow();
  var width = win.width;
  win.close();
  AssertEqual(width, 800);
});

UnitTest("height getter returns the height", function(){
  var win = buildWindow();
  var height = win.height;
  win.close();
  AssertEqual(height, 900);
});

UnitTest("left getter returns the X position", function(){
  var win = buildWindow();
  var left = win.left;
  win.close();
  AssertEqual(left, 1);
});

UnitTest("top getter returns the Y position", function(){
  var win = buildWindow();
  var top = win.top;
  win.close();
  AssertEqual(top, 2);
});

UnitTest("title constructor property sets the title", function(){
  var win = buildWindow({title: 'joe'});
  var title = win.title;
  win.close();
  AssertEqual(title, 'joe');
});

UnitTest("title setter sets the title", function(){
  var win = buildWindow();
  win.title = 'joe';
  var title = win.title;
  win.close();
  AssertEqual(title, 'joe');
});

UnitTest("(top, left) changes after calling center():", function(){
  var win = buildWindow();
  var top = win.top;
  var left = win.left;
  win.center();
  AssertNotEqual(win.left, left);
  AssertNotEqual(win.top, top);
  win.close();
});

UnitTest("nativeWindowObject is defined", function(){
  var win = buildWindow();
  var obj = win.nativeWindowObject;
  win.close(); win = null;
  AssertDefined(obj);
});

UnitTest("width setter sets the width", function(){
  var win = buildWindow();
  win.width = 400;
  var width = win.width;
  win.close();
  AssertEqual(width, 400);
});

UnitTest("height setter sets the width", function(){
  var win = buildWindow();
  win.height = 400;
  var height = win.height;
  win.close();
  AssertEqual(height, 400);
});

UnitTest("top setter sets the top", function(){
  var win = buildWindow();
  win.top = 100;
  var top = win.top;
  win.close();
  AssertEqual(top, 100);
});

UnitTest("left setter sets the left", function(){
  var win = buildWindow();
  win.left = 100;
  var left = win.left;
  win.close();
  AssertEqual(left, 100);
});

UnitTest("visible is false initially", function(){
  var win = buildWindow();
  var visible = win.visible;
  win.close();
  AssertFalse(visible);
});

UnitTest("visible is true after calling show()", function(){
  var win = buildWindow();
  win.show();
  var visible = win.visible;
  win.close();
  Assert(visible);
});

UnitTest("visible is false after calling show() then close()", function(){
  var win = buildWindow();
  win.show();
  win.close();
  var visible = win.visible;
  AssertFalse(visible);
});

UnitTest("visible is false after calling show() then hide()", function(){
  var win = buildWindow();
  win.show();
  win.hide();
  var visible = win.visible;
  win.close();
  AssertFalse(visible);
});

UnitTest("visible is true after calling show() then hide() then show()", function(){
  var win = buildWindow();
  win.show();
  win.hide();
  win.show();
  var visible = win.visible;
  win.close();
  Assert(visible);
});

UnitTest("visible is true after calling show() then hide() then show()", function(){
  var win = buildWindow();
  win.show();
  win.hide();
  win.show();
  var visible = win.visible;
  win.close();
  Assert(visible);
});

// the following test will cause annoying window rearrangement in OSX:
// UnitTest("fullscreen is true after setting win.fullscreen=true;", function(){
//   var win = buildWindow({fullscreen: false});
//   var width = win.width;
//   var height = win.height;
//   win.show();
//   // win.fullscreen = true;
//   // var fullscreen = win.fullscreen;
//   // win.close();
//   // PENDING: must tick run loop for the animation to finish here
//   // AssertNotEqual(win.width, width);
//   // AssertNotEqual(win.height, height);
//   Assert(fullscreen);
// });

UnitTest("fullscreen is false after setting win.fullscreen=true;", function(){
  var win = buildWindow({fullscreen: false});
  // that ashould be true ^ but otherwise it shifts the screen on spec run
  var width = win.width;
  var height = win.height;
  win.show();
  win.fullscreen = false;
  var fullscreen = win.fullscreen;
  win.close();
  AssertFalse(fullscreen);
  
});

UnitTest("resizable is true after setting win.resizable=true;", function(){
  var win = buildWindow({resizable: false});
  win.show();
  win.resizable = true;
  var resizable = win.resizable;
  win.close();
  Assert(resizable);
});

UnitTest("resizable is false after setting win.resizable=false;", function(){
  var win = buildWindow({resizable: true});
  win.show();
  win.resizable = false;
  var resizable = win.resizable;
  win.close();
  AssertFalse(resizable);
});

UnitTest("closable is true after setting win.closable=true;", function(){
  var win = buildWindow({closable: false});
  win.show();
  win.closable = true;
  var closable = win.closable;
  win.close();
  Assert(closable);
});

UnitTest("closable is false after setting win.closable=false;", function(){
  var win = buildWindow({closable: true});
  win.show();
  win.closable = false;
  var closable = win.closable;
  win.close();
  AssertFalse(closable);
});

UnitTest("sameOriginPolicy is true when specified in the constructor;", function(){
  var win = buildWindow({sameOriginPolicy: true});
  win.show();
  var sameOriginPolicy = win.sameOriginPolicy;
  win.close();
  Assert(sameOriginPolicy);
});

UnitTest("sameOriginPolicy is false when specified in the constructor;", function(){
  var win = buildWindow({sameOriginPolicy: false});
  win.show();
  var sameOriginPolicy = win.sameOriginPolicy;
  win.close();
  AssertFalse(sameOriginPolicy);
});

UnitTest("setting sameOriginPolicy to true works as expected", function(){
  var win = buildWindow({sameOriginPolicy: false});
  win.show();
  win.sameOriginPolicy = true;
  var sop = win.sameOriginPolicy;
  win.close();
  Assert(sop);
});
