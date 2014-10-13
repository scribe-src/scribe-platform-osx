CC=clang

# Where the 
ENGINE_NAME=scribe-engine-jsc
ENGINE_DIR=../$(ENGINE_NAME)
ENGINE_LIB=$(ENGINE_DIR)/build/$(ENGINE_NAME).dylib
ENGINE_SRC=$(ENGINE_DIR)/src

# The files to compile
SRC_DIR=src
SRC_FILES=$(SRC_DIR)/**.m $(ENGINE_SRC)/**.m

# Properties of the output build files
OUT_DIR=build
OUT_FILE=Scribe

# Needed for linking
FRAMEWORKS=-framework Cocoa -framework WebKit

# Ensure that the `test` and `clean` targets always get run
.PHONY: clean

all:
	mkdir -p $(OUT_DIR)
	$(CC) $(FRAMEWORKS) -lobjc -I ../$(ENGINE_NAME)/src \
		-flat_namespace $(SRC_FILES) -o $(OUT_DIR)/$(OUT_FILE)
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_FILE)\n"

clean:
	rm -rf $(OUT_DIR)/
