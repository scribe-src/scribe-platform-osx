 function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

UnitTest("Scribe.Screen.all returns an array", function() {
  AssertEqual(Scribe.Screen.all.constructor, Array);
});

UnitTest("Scribe.Screen.all returns a non-empty array", function() {
  Assert(Scribe.Screen.all.length > 0);
});

UnitTest("Scribe.Screen.all[0] is a Scribe.Screen instance", function() {
  AssertEqual(Scribe.Screen.all[0].constructor, Scribe.Screen);
});


UnitTest("Scribe.Screen.all[0].width returns a number", function() {
  Assert(isNumber(Scribe.Screen.all[0].width));
});

UnitTest("Scribe.Screen.all[0].height returns a number", function() {
  Assert(isNumber(Scribe.Screen.all[0].height));
});
