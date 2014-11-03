UnitTest("Scribe.log() function runs", function(){
  Scribe.log('abc');
  Assert(true);
});

UnitTest("Scribe.log() function accepts multiple args", function(){
  Scribe.log('abc', 'def');
  Assert(true);
});
