UnitTest("Scribe.App is defined", function(){
  Assert(Scribe.App != null);
});

UnitTest("Scribe.app is defined", function(){
  Assert(Scribe.app != null);
});

UnitTest("Scribe.app equals Scribe.App.current", function(){
  Assert(Scribe.app === Scribe.App.current);
});

UnitTest("Scribe.app.env returns an object", function(){
  Assert(typeof Scribe.app.env == 'object');
});

UnitTest("Scribe.app.env['USER'] is defined", function(){
  Assert(Scribe.app.env['USER'] != null);
});

UnitTest("Scribe.app.cwd returns a String", function(){
  Assert(typeof Scribe.app.cwd == 'string');
});

UnitTest("Scribe.app.exePath returns a String", function(){
  Assert(typeof Scribe.app.exePath == 'string');
});

UnitTest("Scribe.app.name returns a String", function(){
  Assert(typeof Scribe.app.name == 'string');
});

UnitTest("Scribe.app.identifier returns a String", function(){
  Assert(typeof Scribe.app.identifier == 'string');
});