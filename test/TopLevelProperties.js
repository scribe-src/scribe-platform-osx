UnitTest("Scribe.window should be null", function(){
  // The test suite does not have a "current window", so it should be null
  AssertNull(Scribe.window);
});

UnitTest("Scribe.app should be truthy", function(){
  Assert(Scribe.app);
});

UnitTest("Scribe.engine should be truthy", function(){
  Assert(Scribe.engine);
});

UnitTest("Scribe.platform should be truthy", function(){
  Assert(Scribe.platform);
});

UnitTest("Scribe.debugger should be a function", function(){
  Assert(typeof Scribe.debugger == 'function');
});
