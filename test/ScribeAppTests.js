UnitTest("Scribe.App is defined", function(){
  AssertDefined(Scribe.App);
});

UnitTest("Scribe.app is defined", function(){
  AssertDefined(Scribe.app);
});

UnitTest("Scribe.app equals Scribe.App.current", function(){
  AssertEqual(Scribe.app, Scribe.App.current);
});

UnitTest("Scribe.app.getEnv('USER') is defined", function(){
  AssertDefined(Scribe.app.getEnv('USER'));
});

UnitTest("Scribe.app.setEnv('BLAH') does not fail", function(){
  AssertDefined(Scribe.app.setEnv('BLAH', 'A'));
});

UnitTest("Scribe.app.getEnv('BLAH') returns '1' after Scribe.app.setEnv('BLAH', '1')", function(){
  Scribe.app.setEnv('BLAH', '1');
  AssertEqual(Scribe.app.getEnv('BLAH'), '1');
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

UnitTest("Scribe.app.arguments returns an Array", function(){
  AssertEqual(Scribe.app.arguments.constructor, Array);
});

UnitTest("Scribe.app.identifier returns null", function(){
  AssertNull(Scribe.app.identifier);
});