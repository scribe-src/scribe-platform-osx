(function() {

Scribe.Screen._getAll = function() {
  return [].slice.call(OSX.NSScreen.screens).map(function(screen) {
    return new Scribe.Screen({ nativeObject: screen });
  });
};

Scribe.Screen.prototype._getWidth = function() {
  return this.nativeObject.frame.size.width;
};

Scribe.Screen.prototype._getHeight = function() {
  return this.nativeObject.frame.size.height;
};

Scribe.Screen.prototype._getNativeObject = function() {
  return this._nativeObject;
};

})();
