# Function Calls and Recursion on SC8 CPU

## Video Demonstration

See [Video](https://drive.google.com/file/d/1CZ3KRU2UfkXIH5kmQxYV_XEV2ksE1ZGC/view?usp=sharing) for video.

## Project Overview

**Note**: This project includes the SC8 CPU (Simple CPU 8-bit) made in the project 1. The CPU will be built automatically when you run `make all`.

This project demonstrates function calls and recursion on the SC8 processor. It includes:
- C implementations of recursive functions
- Assembly implementations for the SC8 CPU
- Complete SC8 CPU (assembler and emulator)
- Comprehensive documentation on memory layout and execution
- Detailed explanations of function call mechanisms and recursion

## Team Members

- **Neel Asheshbhai Shah**
- **Vedant Tushar Mehta**
- **Aarav Pranav Shah**
- **Harshavardhan Kuruvella**

## Project Structure

```
Program_Layout_Execution/
├── assembly/                    # Assembly implementations
│   ├── factorial.asm           # Recursive factorial in SC8 assembly
│   ├── multiply.asm            # Recursive multiplication in SC8 assembly
│
├── c_source/                    # C implementations
│   ├── factorial.c             # Recursive factorial in C
│   └── multiply.c              # Recursive multiplication in C
│
├── CPU(project 1)/              # SC8 CPU from Project 1
│   └── src/
│       ├── assembler/          # Assembler source code
│       └── emulator/           # Emulator source code
├── docs/                        # Documentation
│   ├── FUNCTION_CALLS.md       # Function call mechanism explained
│   ├── MEMORY_LAYOUT.md        # Memory organization details
│   └── RECURSION_EXPLAINED.md  # Recursion implementation guide
│
├── report/                      # Project report
│   └── PROJECT_REPORT.pdf      # PDF report
│
├── Makefile                     # Build automation
└── README.md                    # This file
```

## Quick Start

### Prerequisites

1. **GCC**: For compiling C programs
2. **G++**: For building the SC8 CPU
3. **Make**: Build automation tool

The SC8 CPU is included in this project and will be built automatically.

### Build Everything

```bash
# Build CPU, C programs, and assemble assembly programs
make all
```


### Using the SC8 CPU

```bash
# The CPU is built automatically with 'make all'
# Or build it separately
make cpu

# Run assembly programs
make run-asm-factorial
make run-asm-multiply

# Debug mode (step-by-step execution)
make debug-factorial
make debug-multiply
```

## Programs Included

### About the SC8 CPU

The assembly programs run on the **SC8 (Simple CPU 8-bit)**, a custom-designed educational CPU included in this project. The SC8 features:

- **8-bit data path** with **16-bit addressing** (64KB memory)
- **8 general-purpose registers** (R0-R7)
- **Stack-based function calls** with CALL/RET instructions
- **Hardware stack support** (PUSH/POP)
- **Memory-mapped I/O** for console output
- **Rich instruction set** including arithmetic, logic, memory, and control flow
- **Debug mode** for step-by-step execution

**Key Components:**
- **Assembler** (`CPU(project 1)/bin/assembler`): Converts `.asm` to binary
- **Emulator** (`CPU(project 1)/bin/emulator`): Executes binary programs

The CPU is perfect for demonstrating recursion because:
1. Hardware stack automatically manages return addresses
2. CALL/RET instructions handle function calls
3. PUSH/POP preserve values across recursive calls
4. Registers enable efficient parameter passing
5. Debug mode shows stack evolution

See the [SC8 CPU Architecture section](#sc8-cpu-architecture) below for details.

### 1. Factorial (factorial.c / factorial.asm)

**C Implementation:**
```c
uint8_t factorial(uint8_t n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}
```

**Features:**
- Classic example of recursion
- Demonstrates base case and recursive case
- Tests values from 0 to 5
- Shows stack-based recursion in assembly

**Expected Output:**
```
Factorial Calculator
====================

factorial(0) = 1
factorial(1) = 1
factorial(2) = 2
factorial(3) = 6
factorial(4) = 24
factorial(5) = 120
```

### 2. Recursive Multiplication (multiply.c / multiply.asm)

**C Implementation:**
```c
uint8_t multiply(uint8_t a, uint8_t b) {
    if (b == 0) {
        return 0;
    }
    return a + multiply(a, b - 1);
}
```

**Features:**
- Implements multiplication as repeated addition
- Demonstrates recursion with multiple parameters
- Shows parameter passing via registers
- Illustrates stack unwinding

**Expected Output:**
```
Recursive Multiplication Calculator
====================================

multiply(0, 5) = 0
multiply(5, 0) = 0
multiply(1, 7) = 7
multiply(3, 4) = 12
multiply(5, 6) = 30
multiply(7, 8) = 56
multiply(10, 10) = 100
```

## Key Concepts Demonstrated

### 1. Memory Layout

The project shows how programs are organized in memory:
- **Code Segment** (0x0100-0x01FF): Program instructions
- **Data Segment** (0x0200-0x0FFF): Variables and constants
- **Stack** (0x1000-0xFEFF): Function calls and local data
- **I/O Region** (0xFF00-0xFFFF): Memory-mapped devices

See [MEMORY_LAYOUT.md](docs/MEMORY_LAYOUT.md) for details.

### 2. Function Call Mechanism

Function calls use the stack-based calling convention:
1. **CALL** instruction pushes return address and jumps
2. Parameters passed via registers (R0, R1, R2)
3. Function executes with saved context
4. **RET** instruction pops return address and returns
5. Return value in R0

See [FUNCTION_CALLS.md](docs/FUNCTION_CALLS.md) for details.

### 3. Recursion Implementation

Recursion requires:
1. **Base case**: Condition to stop recursion
2. **Recursive case**: Function calls itself with modified parameters
3. **Stack frames**: Each call gets its own stack space
4. **Stack unwinding**: Returns happen in reverse order (LIFO)

See [RECURSION_EXPLAINED.md](docs/RECURSION_EXPLAINED.md) for details.



## Technical Details

### SC8 CPU Features Used

- **CALL/RET**: Function call instructions
- **PUSH/POP**: Stack operations
- **CMPI/JC/JZ**: Conditional branching
- **ADD/SUB/DEC/INC**: Arithmetic operations
- **LOADI**: Load immediate values
- **STORE/LOAD**: Memory access

### Register Usage

| Register | Purpose | Preserved By |
|----------|---------|--------------|
| R0 | First parameter, return value | Caller |
| R1 | Second parameter | Caller |
| R2 | Third parameter | Caller |
| R3-R6 | Temporary/Local variables | Callee |
| R7 (SP) | Stack pointer | Hardware |

### Stack Space Analysis

**Factorial:**
- Recursion depth: n
- Stack per call: 3 bytes (2 ret addr + 1 saved n)
- Total: 3n bytes
- Max depth on SC8: ~20,000 (practical limit: 255)

**Multiply:**
- Recursion depth: b
- Stack per call: 4 bytes (2 ret addr + 2 saved params)
- Total: 4b bytes
- Max depth on SC8: ~15,000 (practical limit: 255)

