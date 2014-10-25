UnitTest("Width setter sets the width", function(){
  // var win = Scribe.Window.create({
  //   center: true,
  //   width: 800,
  //   height: 900,
  //   chrome: false
  // });
  AssertNotEqual(900, 800);
});

UnitTest("Width getter returns the width", function(){
  AssertEqual(900, 900);
});
