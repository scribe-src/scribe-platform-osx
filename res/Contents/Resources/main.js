// Create a window to contain our application
var win = Scribe.Window.create({
  top: 100,
  left: 100,
  width: 500,
  height: 500,
  chrome: true,
  closable: false,
  resizable: false
});

win.show();
win.center();
win.navigateToURL('index.html');
