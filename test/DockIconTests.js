UnitTest("Scribe.app.dockIcon is a Scribe.DockIcon", function(){
  Assert(Scribe.app.dockIcon instanceof Scribe.DockIcon);
});

UnitTest("Scribe.app.dockIcon.badge can be set to 'a'", function(){
  Scribe.app.dockIcon.badge = 'a';
  Assert(Scribe.app.dockIcon.badge === 'a');
});

UnitTest("Scribe.app.dockIcon.bounce() does not throw an exception", function(){
  Scribe.app.dockIcon.bounce();
  Assert(true);
});
