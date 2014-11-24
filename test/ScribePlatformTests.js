UnitTest("Scribe.Platform is truthy", function(){
  Assert(Scribe.Platform);
});

UnitTest("Scribe.platform is truthy", function(){
  Assert(Scribe.platform);
});

UnitTest("Scribe.platform.is('windows') is false", function(){
  Assert(!Scribe.platform.is('windows'));
});

UnitTest("Scribe.platform.is('osx') is true", function(){
  Assert(Scribe.platform.is('osx'));
});

UnitTest("Scribe.platform.name is 'osx'", function(){
  AssertEqual(Scribe.platform.name, 'osx');
});

UnitTest("Scribe.platform.version returns a String", function(){
  AssertEqual(typeof Scribe.platform.version, 'string');
});

UnitTest("Scribe.platform.version returns a non-empty String", function(){
  Assert(Scribe.platform.version.length > 0);
});

UnitTest("Scribe.Platform.SUPPORTED is truthy", function(){
  Assert(Scribe.Platform.SUPPORTED);
});

UnitTest("Scribe.Platform.SUPPORTED contains 'osx'", function(){
  Assert(Scribe.Platform.SUPPORTED.indexOf('osx') > -1);
});
