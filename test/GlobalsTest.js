if (!scribe) {
  throw new Error("scribe global is not defined.");
}

if (!scribe.engine) {
  throw new Error("scribe.engine global is not defined.");
}

if (!OSX.ScribeWindoW) {
  throw new Error("ScribeWindow global is not defined.");
}
