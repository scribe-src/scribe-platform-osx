[![Build Status](https://travis-ci.org/scribe-src/scribe-platform-osx.svg)](https://travis-ci.org/scribe-src/scribe-platform-osx)

### scribe-platform-osx

The `scribe-platform-osx` module contains a template Mac OS X application that runs a Javascript file and provides a standard Window and Menu API as well as Objective-C and C bridges that allow native libraries to be described and called.

The project uses the `scribe-engine-jsc` project, which injects hooks into the JavaScriptCore engine. We piece together a basic templated executable using a Makefile. The .app bundle is created by then `scribe-cli-osx` package at runtime.

#### Setup

Dependencies are tracked as git submodules, you can initialize and fetch them with:

    $ git submodule update --init --recursive

#### Build and run the .app

    $ make all run

#### Tests

    $ make test test-run
