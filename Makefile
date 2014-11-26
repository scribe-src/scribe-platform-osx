CC=clang
TMP_DIR=/tmp

JSCOCOA_DIR=./deps/jscocoa/JSCocoa
FASTZIP_DIR=./deps/fast-zip
FASTZIP_SRC_FILES=$(wildcard $(FASTZIP_DIR)/src/**.m $(FASTZIP_DIR)/deps/minizip/**.c)
FASTZIP_FILTERED=$(FASTZIP_DIR)/deps/minizip/iowin32.c $(FASTZIP_DIR)/deps/minizip/minizip.c $(FASTZIP_DIR)/deps/minizip/miniunz.c
FASTZIP_FILES=$(filter-out $(FASTZIP_FILTERED), $(FASTZIP_SRC_FILES))

# The files to compile
SRC_DIR=src
SRC_FILES=$(SRC_DIR)/**.m $(JSCOCOA_DIR)/**.m $(FASTZIP_FILES)

INCLUDES=-I$(JSCOCOA_DIR) -I$(SRC_DIR) -I$(FASTZIP_DIR)/src -I$(FASTZIP_DIR)/deps/minizip

# Files needed for building tests
TEST_DIR=test
TEST_LIB_DIR=./deps/objc-unit/src
TEST_FILES=$(TEST_DIR)/**.m $(TEST_DIR)/support/**.m \
	$(TEST_LIB_DIR)/**.m
TEST_INC=-I$(TEST_DIR)/support -I$(TEST_LIB_DIR)

# Properties of the output build files
RES_DIR=res
APP_DIR=build/Scribe.app
RSRC_DIR=$(APP_DIR)/Contents/Resources
OUT_DIR=$(APP_DIR)/Contents/MacOS
OUT_FILE=$(OUT_DIR)/Scribe
OUT_TEST=build/run-tests

SCRIBE_API_DIR=./deps/scribe-api
APIJS=$(SCRIBE_API_DIR)/dist/dist.js
ENGINE_JS=./src/engine.js
OSXJS=./src/coffee/*.coffee
APIJS_TMP=$(TMP_DIR)/APITMP.js
OSXJS_TMP=$(TMP_DIR)/OSXTMP.js
DEBUG_FLAG=-g

# Uncomment the below line for verbose output in tests:
# DEBUG_FLAG=-g -DDEBUG

# Needed for linking
ADD_DATA = -sectcreate __DATA __scribejs $(APIJS_TMP) \
  -sectcreate __DATA __osxjs $(OSXJS_TMP)

FRAMEWORKS=-framework Cocoa -framework WebKit \
           -framework JavaScriptCore -framework AppKit

# Include all src files except src/main.m in the test suite
M_FILES = $(wildcard src/*.m)
SRC_FOR_TEST = $(filter-out src/main.m, $(M_FILES)) $(JSCOCOA_DIR)/**.m
CFLAGS=-lobjc -lffi $(FRAMEWORKS) -fPIE $(ADD_DATA) \
  -mmacosx-version-min=10.5 -DOS_OBJECT_USE_OBJC=0 -ledit -ltermcap \
  -lpthread -lz
TRAVISFLAGS=-lobjc -lffi $(FRAMEWORKS) -fPIE $(DEBUG_FLAG) \
	$(ADD_DATA) -DOS_OBJECT_USE_OBJC=0 -ledit -ltermcap -lpthread -lz

# Ensure that the `test` and `clean` targets always get run
.PHONY: test clean init open run debug test-run test-travis bump-deps

all: init
	mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -flat_namespace  -arch x86_64 \
		$(SRC_FILES) -o $(OUT_FILE).x64
	$(CC) $(CFLAGS) $(INCLUDES) -flat_namespace  -arch i386 \
		$(SRC_FILES) -o $(OUT_FILE).x86
	lipo -create $(OUT_FILE).x64 $(OUT_FILE).x86 -output $(OUT_FILE)
	rm -f $(OUT_FILE).x64 $(OUT_FILE).x86
	cp -R $(RES_DIR)/ $(APP_DIR)/
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_FILE)\n"

# Updates the dependencies in ./deps to the latest on master
bump-deps:
	cd ./deps/scribe-api && git pull --ff origin master
	cd ./deps/jscocoa && git pull --ff origin master
	cd ./deps/objc-unit && git pull --ff origin master

init:
	# Prepare some data for inserting into an macho segment
	make -C $(SCRIBE_API_DIR) dist
	mkdir -p $(OUT_DIR)
	cp $(APIJS) $(APIJS_TMP)
	cat $(ENGINE_JS) >> $(APIJS_TMP)
	npm i
	cat $(OSXJS) | ./node_modules/.bin/coffee --compile --stdio > $(OSXJS_TMP)
	# cat $(OSXJS) >> $(OSXJSSXJS_TMP)
	# clang doesn't add the NULL byte for you
	printf "\x00" >> $(APIJS_TMP)
	printf "\x00" >> $(OSXJS_TMP)

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
	$(CC) -g $(CFLAGS) $(DEBUG_FLAG) $(TEST_FILES) $(SRC_FOR_TEST) \
	  $(INCLUDES) $(TEST_INC) -o $(OUT_TEST) \
	  -D TEST_ENV
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_TEST)\n"
	export NSZombieEnabled=YES
	$(OUT_TEST)

test-travis: init
	$(CC) -g $(TRAVISFLAGS) $(TEST_FILES) $(SRC_FOR_TEST) \
	  $(INCLUDES) $(TEST_INC) -o $(OUT_TEST) \
	  -D TEST_ENV
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_TEST)\n"
	export NSZombieEnabled=YES
	$(OUT_TEST)

test-run:
	export NSZombieEnabled=YES
	$(OUT_TEST)
