UnitTest("calling close() twice should throw a JS error", function(){
  var win = new Scribe.Window();
  win.show();
  win.close();
  try {
    win.close();
  } catch (e) {
    Assert(e.message.match(/called on dead Scribe\.Window/))
  }
});
