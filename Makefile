CC=clang

# Where the JSC engine lib lives
ENGINE_NAME=scribe-engine-jsc
ENGINE_DIR=../$(ENGINE_NAME)
ENGINE_SRC=$(ENGINE_DIR)/src

# The files to compile
SRC_DIR=src
SRC_FILES=$(SRC_DIR)/**.m $(ENGINE_SRC)/**.m

# Files needed for building tests
TEST_DIR=test
TEST_FILES=$(TEST_DIR)/**.m $(TEST_DIR)/support/**.m
TEST_INC=$(TEST_DIR)/support

# Properties of the output build files
RES_DIR=res
APP_DIR=build/Scribe.app
RSRC_DIR=$(APP_DIR)/Contents/Resources
OUT_DIR=$(APP_DIR)/Contents/MacOS
OUT_FILE=$(OUT_DIR)/Scribe
OUT_TEST=build/run-tests

# Needed for linking
ADD_DATA = -sectcreate __DATA __windowjs ../scribe-api/dist/dist.js \
  -sectcreate __DATA __osxjs ./src/ScribeWindow.OSX.js

FRAMEWORKS=-framework Cocoa -framework WebKit \
           -framework JavaScriptCore -framework AppKit

# Include all src files except src/main.m in the test suite
M_FILES = $(wildcard src/*.m)
SRC_FOR_TEST = $(filter-out src/main.m, $(M_FILES)) $(ENGINE_SRC)/**.m
CFLAGS=-O1 -lobjc -lffi -arch x86_64 $(FRAMEWORKS) -fPIE $(ADD_DATA)

# Ensure that the `test` and `clean` targets always get run
.PHONY: test clean

all:
	mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) -I$(ENGINE_SRC) -flat_namespace \
		$(SRC_FILES) -o $(OUT_FILE)
	cp -R $(RES_DIR)/ $(APP_DIR)/
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_FILE)\n"

clean:
	rm -rf build/
	mkdir -p build/

open:
	open $(APP_DIR)

run:
	$(OUT_FILE)

debug:
	gdb $(OUT_FILE)

test:
	$(CC) $(CFLAGS) $(TEST_FILES) $(SRC_FOR_TEST) \
	  -I$(SRC_DIR) -I$(ENGINE_SRC) -I$(TEST_INC) -o $(OUT_TEST) \
	  -D TEST_ENV
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_TEST)\n"

test-run:
	$(OUT_TEST)
