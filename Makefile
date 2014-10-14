CC=clang

# Where the JSC engine lib lives
ENGINE_NAME=scribe-engine-jsc
ENGINE_DIR=../$(ENGINE_NAME)
ENGINE_LIB=$(ENGINE_DIR)/build/$(ENGINE_NAME).dylib
ENGINE_SRC=$(ENGINE_DIR)/src

# The files to compile
SRC_DIR=src
SRC_FILES=$(SRC_DIR)/**.m $(ENGINE_SRC)/**.m

# Files needed for building tests
TEST_DIR=test
TEST_FILES=$(TEST_DIR)/**.m $(TEST_DIR)/support/**.m

# Properties of the output build files
OUT_DIR=build
OUT_FILE=$(OUT_DIR)/Scribe
OUT_TEST=$(OUT_DIR)/run-tests

# Needed for linking
FRAMEWORKS=-framework Cocoa -framework WebKit -framework JavaScriptCore

# Ensure that the `test` and `clean` targets always get run
.PHONY: test clean

all:
	mkdir -p $(OUT_DIR)
	$(CC) $(FRAMEWORKS) -lobjc -I ../$(ENGINE_NAME)/src \
		-flat_namespace $(SRC_FILES) -o $(OUT_FILE)
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_FILE)\n"

clean:
	rm -rf $(OUT_DIR)/

test:   all
	$(CC) -g $(FRAMEWORKS) -lobjc $(TEST_FILES) \
	  -I$(SRC_DIR) -I$(TEST_DIR)/support -o $(OUT_TEST)
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_TEST)\n"
	$(OUT_TEST)

