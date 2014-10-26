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

UnitTest("(width, height) changes after setting fullscreen=true:", function(){
  var win = buildWindow({chrome: true});
  var width = win.width;
  var height = win.height;
  win.show();
  win.nativeWindowObject.toggleFullScreen(win.nativeWindowObject);
  win.fullscreen = true;
  AssertNotEqual(win.width, width);
  AssertNotEqual(win.height, height);
  Assert(win.fullscreen);
  win.close();
});
