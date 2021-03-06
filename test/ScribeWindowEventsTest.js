UnitTest("after calling on('x'), trigger('x') fires the callback", function(){
  var win = buildWindow();
  var agent = spy();
  win.on('x', agent);
  win.trigger('x');
  Assert(agent.called());
});

UnitTest("after calling on('x'), trigger('y') does not fire the callback", function(){
  var win = buildWindow();
  var agent = spy();
  win.on('x', agent);
  win.trigger('y');
  AssertFalse(agent.called());
});

UnitTest("after calling on('x'), off('x'), trigger('x') does not fire the callback", function(){
  var win = buildWindow();
  var agent = spy();
  win.on('x', agent);
  win.off('x');
  win.trigger('x');
  AssertFalse(agent.called());
});

UnitTest("after calling on('x',fn), off('x',fn), trigger('x') does not fire the callback", function(){
  var win = buildWindow();
  var agent = spy();
  win.on('x', agent);
  win.off('x', agent);
  win.trigger('x');
  AssertFalse(agent.called());
});

UnitTest("the 'close' event is fired on close", function(cb) {
  var win = buildWindow();
  win.show();
  win.on('close', cb);
  win.close();
});

UnitTest("the 'move' event is fired on move", function(cb){
  var win = buildWindow();
  win.show();
  win.on('move', function() { win.close(); cb(); });
  win.center();
});

UnitTest("the 'resize' event is fired on resize", function(cb){
  var win = buildWindow();
  win.show();
  win.on('resize', function() { win.close(); cb(); });
  win.height = 300;
});

UnitTest("the 'minimize' event is fired on minimize", function(cb){
  var win = buildWindow();
  win.on('minimize', function() { win.close(); cb(); });
  win.minimize();
});

UnitTest("the 'deminimize' event is fired on deminimize", function(cb){
  var win = buildWindow();
  win.on('minimize', function() { win.deminimize(); });
  win.on('deminimize', function() { win.close(); cb(); });
  win.minimize();
});

UnitTest("the 'focus' event is fired on show()", function(cb){
  var win = buildWindow({chrome: true});
  win.on('focus', function() { win.close(); cb(); });
  win.show();
});

UnitTest("the 'blur' event is fired on hide()", function(cb){
  var win = buildWindow({chrome: true});
  win.on('focus', function() { setTimeout(function(){win.hide();},100); });
  win.on('blur', function() { setTimeout(function(){ win.close(); cb(); },100); });
  win.show();
});
