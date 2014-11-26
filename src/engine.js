;(function(){

// Install some shims for asynchronous browser primitives
// like setTimeout and setInterval().
this.setTimeout = this.setTimeout || function setTimeout(fn, d) {
  return Scribe.engine.nativeObject[
    'runFunction:afterDelay:repeats:'
  ](fn, d, false);
};

this.setInterval = this.setInterval || function setInterval(fn, d) {
  return Scribe.engine.nativeObject[
    'runFunction:afterDelay:repeats:'
  ](fn, d, true);
};

this.clearTimeout = this.clearTimeout || function clearTimeout(d) {
  return Scribe.engine.nativeObject.cancelFunction(d);
};

this.clearInterval = this.clearInterval || function clearInterval(d) {
  return clearTimeout(d);
};

// Add some log helpers
this.console = this.console || {};
this.Scribe.log = function consoleLog() {
  OSX.ScribeEngine.log(Array.prototype.slice.call(arguments).join(' '));
};
this.console.log = this.console.log || this.Scribe.log;

Scribe.Engine.prototype._repl = function _repl() {
  this.nativeObject.repl();
};

Scribe.Engine.prototype._getNativeObject = function _getNativeObject() {
  return this._nativeObject;
}

Scribe.Engine.current = new Scribe.Engine({ nativeObject: _currentEngine });

})();
