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

APIJS=../scribe-api/dist/dist.js
OSXJS=./src/ScribeWindow.OSX.js
APIJS_TMP=/tmp/APITMP.js
OSXJS_TMP=/tmp/OSXTMP.js

# Needed for linking
ADD_DATA = -sectcreate __DATA __scribejs $(APIJS_TMP) \
  -sectcreate __DATA __osxjs $(OSXJS_TMP)

FRAMEWORKS=-framework Cocoa -framework WebKit \
           -framework JavaScriptCore -framework AppKit

# Include all src files except src/main.m in the test suite
M_FILES = $(wildcard src/*.m)
SRC_FOR_TEST = $(filter-out src/main.m, $(M_FILES)) $(ENGINE_SRC)/**.m
CFLAGS=-O1 -lobjc -lffi -arch x86_64 $(FRAMEWORKS) -fPIE $(ADD_DATA) \
  -mmacosx-version-min=10.5

# Ensure that the `test` and `clean` targets always get run
.PHONY: test clean init

init:
	# Prepare some data for inserting into an macho segment
	rm -f $(APIJS_TMP)
	rm -f $(OSXJS_TMP)
	cp $(APIJS) $(APIJS_TMP)
	cp $(OSXJS) $(OSXJS_TMP)
	# Append a null byte to the data
	printf "\x00" >> $(APIJS_TMP)
	printf "\x00" >> $(OSXJS_TMP)

all: init
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

test: init
	NSZombieEnabled=1 $(CC) $(CFLAGS) $(TEST_FILES) $(SRC_FOR_TEST) \
	  -I$(SRC_DIR) -I$(ENGINE_SRC) -I$(TEST_INC) -o $(OUT_TEST) \
	  -D TEST_ENV
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_TEST)\n"

test-run:
	NSZombieEnabled=1 $(OUT_TEST)
