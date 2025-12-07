# Makefile for Function Calls and Recursion Project
# CMPE220 - Computer Architecture

# Directories
C_SOURCE_DIR = c_source
ASM_DIR = assembly
CPU_DIR_NAME = CPU(project 1)
CPU_BIN = $(CPU_DIR_NAME)/bin
CPU_SRC_ASM = $(CPU_DIR_NAME)/src/assembler
CPU_SRC_EMU = $(CPU_DIR_NAME)/src/emulator
SC8_PROJECT = ../CMPE220_project
SC8_BIN = $(SC8_PROJECT)/bin
SC8_ASSEMBLER = $(SC8_BIN)/assembler
SC8_EMULATOR = $(SC8_BIN)/emulator

# C Compiler
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2

# C++ Compiler for CPU
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O2
CPU_INCLUDE = -I"$(CPU_SRC_EMU)" -I"$(CPU_SRC_ASM)"

# C Programs
C_PROGRAMS = $(C_SOURCE_DIR)/factorial $(C_SOURCE_DIR)/multiply

# Assembly Programs
ASM_SOURCES = $(ASM_DIR)/factorial.asm $(ASM_DIR)/multiply.asm
ASM_BINARIES = $(ASM_DIR)/factorial.bin $(ASM_DIR)/multiply.bin

# Default target
.PHONY: all
all: check-cpu c-programs asm-programs
	@echo "✓ All programs built successfully!"

# Build CPU (SC8 emulator and assembler)
.PHONY: cpu
cpu:
	@echo "Building SC8 CPU in $(CPU_DIR_NAME)..."
	@mkdir -p "$(CPU_BIN)"
	@echo "Building assembler..."
	@$(CXX) $(CXXFLAGS) $(CPU_INCLUDE) \
		"$(CPU_SRC_ASM)/main.cpp" \
		"$(CPU_SRC_ASM)/assembler.cpp" \
		"$(CPU_SRC_ASM)/lexer.cpp" \
		"$(CPU_SRC_ASM)/parser.cpp" \
		"$(CPU_SRC_ASM)/symbol_table.cpp" \
		-o "$(CPU_BIN)/assembler"
	@echo "✓ Assembler built: $(CPU_BIN)/assembler"
	@echo "Building emulator..."
	@$(CXX) $(CXXFLAGS) $(CPU_INCLUDE) \
		"$(CPU_SRC_EMU)/main.cpp" \
		"$(CPU_SRC_EMU)/cpu.cpp" \
		"$(CPU_SRC_EMU)/alu.cpp" \
		"$(CPU_SRC_EMU)/memory.cpp" \
		"$(CPU_SRC_EMU)/bus.cpp" \
		-o "$(CPU_BIN)/emulator"
	@echo "✓ Emulator built: $(CPU_BIN)/emulator"
	@echo "✓ SC8 CPU tools built successfully!"

.PHONY: build-cpu-help
build-cpu-help:
	@echo "To build the SC8 CPU:"
	@echo "  cd 'CPU(project 1)/src'"  
	@echo "  Run the appropriate build commands for your CPU implementation"
	@echo ""
	@echo "Or copy pre-built binaries to: $(CPU_BIN)/"

# Build C programs
.PHONY: c-programs
c-programs: $(C_PROGRAMS)

$(C_SOURCE_DIR)/factorial: $(C_SOURCE_DIR)/factorial.c
	@echo "Compiling factorial.c..."
	$(CC) $(CFLAGS) -o $@ $<
	@echo "✓ factorial compiled"

$(C_SOURCE_DIR)/multiply: $(C_SOURCE_DIR)/multiply.c
	@echo "Compiling multiply.c..."
	$(CC) $(CFLAGS) -o $@ $<
	@echo "✓ multiply compiled"

# Build assembly programs
.PHONY: asm-programs
asm-programs: check-cpu $(ASM_BINARIES)

.PHONY: check-cpu
check-cpu:
	@if [ ! -f "$(CPU_BIN)/assembler" ] || [ ! -f "$(CPU_BIN)/emulator" ]; then \
		echo "Error: SC8 CPU tools not found."; \
		echo "Building them now with 'make cpu'..."; \
		$(MAKE) cpu; \
	fi

$(ASM_DIR)/factorial.bin: $(ASM_DIR)/factorial.asm
	@echo "Assembling factorial.asm..."
	@"$(CPU_BIN)/assembler" "$<" "$@"
	@echo "✓ factorial.asm assembled"

$(ASM_DIR)/multiply.bin: $(ASM_DIR)/multiply.asm
	@echo "Assembling multiply.asm..."
	@"$(CPU_BIN)/assembler" "$<" "$@"
	@echo "✓ multiply.asm assembled"

# Run C programs
.PHONY: run-c
run-c: c-programs
	@echo "==================================="
	@echo "Running C factorial program:"
	@echo "==================================="
	@$(C_SOURCE_DIR)/factorial
	@echo ""
	@echo "==================================="
	@echo "Running C multiply program:"
	@echo "==================================="
	@$(C_SOURCE_DIR)/multiply

.PHONY: run-c-factorial
run-c-factorial: $(C_SOURCE_DIR)/factorial
	@echo "Running C factorial program:"
	@$(C_SOURCE_DIR)/factorial

.PHONY: run-c-multiply
run-c-multiply: $(C_SOURCE_DIR)/multiply
	@echo "Running C multiply program:"
	@$(C_SOURCE_DIR)/multiply

# Run assembly programs
.PHONY: run-asm
run-asm: asm-programs
	@echo "==================================="
	@echo "Running SC8 factorial program:"
	@echo "==================================="
	@"$(CPU_BIN)/emulator" $(ASM_DIR)/factorial.bin
	@echo ""
	@echo "==================================="
	@echo "Running SC8 multiply program:"
	@echo "==================================="
	@"$(CPU_BIN)/emulator" $(ASM_DIR)/multiply.bin

.PHONY: run-asm-factorial
run-asm-factorial: $(ASM_DIR)/factorial.bin
	@echo "Running SC8 factorial program:"
	@"$(CPU_BIN)/emulator" $(ASM_DIR)/factorial.bin

.PHONY: run-asm-multiply
run-asm-multiply: $(ASM_DIR)/multiply.bin
	@echo "Running SC8 multiply program:"
	@"$(CPU_BIN)/emulator" $(ASM_DIR)/multiply.bin

# Debug assembly programs
.PHONY: debug-factorial
debug-factorial: $(ASM_DIR)/factorial.bin
	@echo "Debugging SC8 factorial program (step mode):"
	@"$(CPU_BIN)/emulator" -d $(ASM_DIR)/factorial.bin

.PHONY: debug-multiply
debug-multiply: $(ASM_DIR)/multiply.bin
	@echo "Debugging SC8 multiply program (step mode):"
	@"$(CPU_BIN)/emulator" -d $(ASM_DIR)/multiply.bin

# Run all tests
.PHONY: test
test: run-c run-asm
	@echo ""
	@echo "==================================="
	@echo "All tests completed!"
	@echo "==================================="

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(C_PROGRAMS)
	@rm -f $(ASM_BINARIES)
	@rm -f $(C_SOURCE_DIR)/*.o
	@rm -rf "$(CPU_BIN)"
	@echo "✓ Clean complete"

# Help target
.PHONY: help
help:
	@echo "Recursion Project Makefile"
	@echo "=========================="
	@echo ""
	@echo "Available targets:"
	@echo "  make all              - Build CPU, C programs, and assemble SC8 programs"
	@echo "  make cpu              - Build SC8 CPU (emulator and assembler)"
	@echo "  make c-programs       - Build C programs only"
	@echo "  make asm-programs     - Assemble SC8 programs only"
	@echo ""
	@echo "  make run-c            - Run all C programs"
	@echo "  make run-c-factorial  - Run C factorial program"
	@echo "  make run-c-multiply   - Run C multiply program"
	@echo ""
	@echo "  make run-asm          - Run all SC8 assembly programs"
	@echo "  make run-asm-factorial - Run SC8 factorial program"
	@echo "  make run-asm-multiply  - Run SC8 multiply program"
	@echo ""
	@echo "  make debug-factorial  - Debug factorial in step mode"
	@echo "  make debug-multiply   - Debug multiply in step mode"
	@echo ""
	@echo "  make test             - Run all programs (C and assembly)"
	@echo "  make clean            - Remove all build artifacts"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - GCC compiler for C programs"
	@echo "  - G++ compiler for SC8 CPU"
	@echo "  - SC8 CPU will be built automatically from CPU(project 1)/"

# Verify all programs work correctly
.PHONY: verify
verify: all
	@echo "Verifying C programs..."
	@$(C_SOURCE_DIR)/factorial > /tmp/c_factorial_out.txt 2>&1 && echo "✓ C factorial works"
	@$(C_SOURCE_DIR)/multiply > /tmp/c_multiply_out.txt 2>&1 && echo "✓ C multiply works"
	@echo "Verifying assembly programs..."
	@"$(CPU_BIN)/emulator" $(ASM_DIR)/factorial.bin > /tmp/asm_factorial_out.txt 2>&1 && echo "✓ ASM factorial works"
	@"$(CPU_BIN)/emulator" $(ASM_DIR)/multiply.bin > /tmp/asm_multiply_out.txt 2>&1 && echo "✓ ASM multiply works"
	@echo "✓ All programs verified successfully!"

.DEFAULT_GOAL := all

