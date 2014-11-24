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

UnitTest("Scribe.platform.version is truthy", function(){
  Assert(Scribe.platform.version);
});

UnitTest("Scribe.Platform.SUPPORTED is truthy", function(){
  Assert(Scribe.Platform.SUPPORTED);
});

UnitTest("Scribe.Platform.SUPPORTED contains 'osx'", function(){
  Assert(Scribe.Platform.SUPPORTED.indexOf('osx') > -1);
});
