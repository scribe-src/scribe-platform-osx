if (!scribe) {
  throw new Error("scribe global is not defined.");
}

if (!scribe.engine) {
  throw new Error("scribe.engine global is not defined.");
}

if (!OSX) {
  throw new Error("OSX global is not defined.");
}
