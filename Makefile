CC=clang

# The files to compile
SRC_DIR=src
SRC_FILES=$(SRC_DIR)/**.m

# Properties of the output build files
OUT_DIR=build
OUT_FILE=Scribe

# Needed for linking
FRAMEWORKS=-framework Foundation -framework JavaScriptCore

# Ensure that the `test` and `clean` targets always get run
.PHONY: clean

all:
	mkdir -p $(OUT_DIR)
	$(CC) $(FRAMEWORKS) -lobjc -undefined suppress -dynamiclib \
	  -flat_namespace $(SRC_FILES) -o $(OUT_DIR)/$(OUT_FILE)
	@printf "\033[0;32;40mCompiled successfully\033[0m: $(OUT_FILE)\n"

clean:
	rm -rf $(OUT_DIR)/
