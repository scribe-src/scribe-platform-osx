UnitTest("Scribe.app.icon is a Scribe.DockIcon", function(){
  Assert(Scribe.app.icon instanceof Scribe.DockIcon);
});

UnitTest("Scribe.app.icon.badge can be set to 'a'", function(){
  Scribe.app.icon.badge = 'a';
  Assert(Scribe.app.icon.badge === 'a');
});

UnitTest("Scribe.app.icon.bounce() does not throw an exception", function(){
  Scribe.app.icon.bounce();
  Assert(true);
});
