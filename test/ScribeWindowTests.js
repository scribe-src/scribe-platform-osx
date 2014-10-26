UnitTest("Width setter sets the width", function(){
  var win = Scribe.Window.create({
    center: true,
    width: 800,
    height: 900,
    chrome: false
  });
  var width = win.width;
  win.destroy(); win = null;
  AssertEqual(width, 800);
});

UnitTest("Height getter returns the height", function(){
  var win = Scribe.Window.create({
    center: true,
    width: 800,
    height: 900,
    chrome: false
  });
  var height = win.height;
  win.destroy(); win = null;
  AssertEqual(height, 900);
});

UnitTest("nativeWindowObject is defined", function(){
  var win = Scribe.Window.create({
    center: true,
    width: 800,
    height: 900,
    chrome: false
  });
  var obj = win.nativeWindowObject;
  win.destroy(); win = null;
  AssertDefined(obj);
});
