UnitTest("Width setter sets the width", function(){
  var win = Scribe.Window.create({
    center: true,
    width: 800,
    height: 900,
    chrome: false
  });
  AssertEqual(win.width, 800);
});

UnitTest("Height getter returns the height", function(){
  var win = Scribe.Window.create({
    center: true,
    width: 800,
    height: 900,
    chrome: false
  });
  AssertEqual(win.height, 900);
});
