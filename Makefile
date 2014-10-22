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
APP_DIR=build/Scribe.app
RSRC_DIR=$(APP_DIR)/Contents/Resources
OUT_DIR=$(APP_DIR)/Contents/MacOS
OUT_FILE=$(OUT_DIR)/Scribe
OUT_TEST=build/run-tests

# Needed for linking
FRAMEWORKS=-framework Cocoa -framework WebKit \
           -framework JavaScriptCore

# Include all src files except src/main.m in the test suite
M_FILES = $(wildcard src/*.m)
SRC_FOR_TEST = $(filter-out src/main.m, $(M_FILES)) $(ENGINE_SRC)/**.m
CFLAGS=-lobjc -lffi -arch x86_64 $(FRAMEWORKS)

# Ensure that the `test` and `clean` targets always get run
.PHONY: test clean

all:
	mkdir -p $(OUT_DIR)
	mkdir -p $(RSRC_DIR)
	$(CC) $(CFLAGS) -I$(ENGINE_SRC) -flat_namespace \
		$(SRC_FILES) -o $(OUT_FILE)
	cp $(SRC_DIR)/Info.plist $(APP_DIR)/Contents/Info.plist
	cp $(SRC_DIR)/main.js $(RSRC_DIR)/main.js
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_FILE)\n"

clean:
	rm -rf $(OUT_DIR)/

test:   all
	$(CC) $(CFLAGS) $(TEST_FILES) $(SRC_FOR_TEST) \
	  -I$(SRC_DIR) -I$(ENGINE_SRC) -I$(TEST_INC) -o $(OUT_TEST) \
	  -D TEST_ENV
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_TEST)\n"
	$(OUT_TEST)
