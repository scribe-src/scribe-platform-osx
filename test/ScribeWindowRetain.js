
function buildWindow(opts) {
  OSX.NSApplication.sharedApplication.setActivationPolicy(
    OSX.NSApplicationActivationPolicyRegular
  );
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

UnitTest("calling close() twice should throw a JS error", function(){
  var win = buildWindow();
  win.show();
  win.close();
  try {
    win.close();
  } catch (e) {
    Assert(e.message.match(/called on dead Scribe\.Window/))
  }
});
