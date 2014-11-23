UnitTest("Scribe.App is defined", function(){
  AssertDefined(Scribe.App);
});

UnitTest("Scribe.app is defined", function(){
  AssertDefined(Scribe.app);
});

UnitTest("Scribe.app equals Scribe.App.current", function(){
  AssertEqual(Scribe.app, Scribe.App.current);
});

UnitTest("Scribe.app.env returns an object", function(){
  Assert(typeof Scribe.app.env == 'object');
});

UnitTest("Scribe.app.env['USER'] is defined", function(){
  AssertDefined(Scribe.app.env['USER']);
});

UnitTest("Scribe.app.cwd returns a String", function(){
  Assert(typeof Scribe.app.cwd == 'string');
});

UnitTest("Scribe.app.exePath returns a String", function(){
  Assert(typeof Scribe.app.exePath == 'string');
});

UnitTest("Scribe.app.name returns null", function(){
  AssertNull(Scribe.app.name);
});

UnitTest("Scribe.app.identifier returns null", function(){
  AssertNull(Scribe.app.identifier);
});