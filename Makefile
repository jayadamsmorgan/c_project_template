SRC_DIR = src
INC_DIR = include
TESTS_DIR = tests

BUILD_DIR = .build
BUILD_SRC_DIR = $(BUILD_DIR)/$(SRC_DIR)
BUILD_TESTS_DIR = $(BUILD_DIR)/$(TESTS_DIR)

CFLAGS ?= -O3 -I$(INC_DIR) $(EXTRA_CFLAGS)
CC ?= gcc

SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_SRC_DIR)/%.o,$(SOURCES))
HEADERS = $(wildcard $(INC_DIR)/*.h)

TEST_SOURCES = $(wildcard $(TESTS_DIR)/*.c)
TEST_OBJECTS = $(patsubst $(TESTS_DIR)/%.c,$(BUILD_TESTS_DIR)/%.o,$(TEST_SOURCES))
TEST_EXECUTABLES = $(patsubst $(BUILD_TESTS_DIR)/%.o,$(BUILD_TESTS_DIR)/%,$(TEST_OBJECTS))
OBJECTS_NO_MAIN = $(filter-out $(BUILD_SRC_DIR)/main.o, $(OBJECTS))

all: build

build: $(BUILD_DIR)/main

$(BUILD_DIR)/main: $(BUILD_SRC_DIR) $(OBJECTS)
	$(CC) $(OBJECTS) -o $(BUILD_DIR)/main

run: build
	@$(BUILD_DIR)/main

build_tests: $(BUILD_TESTS_DIR) $(BUILD_SRC_DIR) $(TEST_EXECUTABLES)

test: build_tests
	@for test in $(TEST_EXECUTABLES); do \
		echo "\n\033[32mRunning $$test...\033[0m\n"; \
		$$test; \
		if [ $$? -ne 0 ]; then \
			echo "\n\033[31mTest $$test failed.\033[0m\n"; \
			exit 1; \
		fi; \
		echo "\n\033[32mTest $$test passed.\033[0m\n"; \
	done
	@echo "\n\033[32mAll tests passed.\033[0m\n"

$(BUILD_SRC_DIR):
	@mkdir -p $(BUILD_SRC_DIR)

$(BUILD_TESTS_DIR):
	@mkdir -p $(BUILD_TESTS_DIR)

$(BUILD_SRC_DIR)/%.o: $(SRC_DIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_TESTS_DIR)/%.o: $(TESTS_DIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_TESTS_DIR)/%: $(BUILD_TESTS_DIR)/%.o $(OBJECTS_NO_MAIN)
	$(CC) $< $(OBJECTS_NO_MAIN) -o $@

clean:
	@rm -rf $(BUILD_DIR)
	@rm -f compile_commands.json

compile_commands: clean
	bear -- make build_tests build

.PHONY: clean all
