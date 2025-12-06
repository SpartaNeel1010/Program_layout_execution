# Function Calls in SC8 CPU

## Overview

Function calls are a fundamental mechanism in computer architecture that allow code reuse, modularity, and recursion. The SC8 CPU implements function calls using a **stack-based calling convention** with dedicated `CALL` and `RET` instructions.

## Basic Function Call Mechanism

### Components Required for Function Calls

1. **Program Counter (PC)**: Tracks current instruction address
2. **Stack Pointer (SP)**: Points to top of stack (register R7)
3. **Stack Memory**: Stores return addresses and local data
4. **CALL Instruction**: Initiates function call
5. **RET Instruction**: Returns from function

### CALL Instruction

The `CALL` instruction performs the following operations:

```
CALL address:
  1. Push current PC (low byte) onto stack
  2. Push current PC (high byte) onto stack
  3. Set PC = address (jump to function)
```

**Binary Encoding** (3 bytes):
```
Byte 0: [0x1D << 3 | condition] = 0xE8
Byte 1: address_low
Byte 2: address_high
```

**Example**:
```assembly
    LOADI R0, 5
    CALL multiply_by_2    ; Call function at label
    ; Execution continues here after RET
    HALT

multiply_by_2:
    ADD R0, R0, R0        ; R0 = R0 * 2
    RET                   ; Return to caller
```

### RET Instruction

The `RET` instruction reverses the CALL operation:

```
RET:
  1. Pop PC (high byte) from stack
  2. Pop PC (low byte) from stack
  3. Continue execution at restored PC
```

**Binary Encoding** (1 byte):
```
Byte 0: 0xF0 (opcode for RET)
```

## Function Call Convention

### Parameter Passing

The SC8 uses **register-based parameter passing**:

| Parameter | Register | Notes |
|-----------|----------|-------|
| 1st param | R0 | Primary parameter/return value |
| 2nd param | R1 | Secondary parameter |
| 3rd param | R2 | Third parameter |
| Additional | Stack | If more than 3 parameters |

### Return Value

- **Primary return value**: Register R0
- **Additional returns**: R1, R2, or memory locations

### Register Usage Convention

| Register | Purpose | Saved By |
|----------|---------|----------|
| R0-R2 | Parameters/Return | Caller |
| R3-R6 | Temporary/Local | Callee |
| R7 (SP) | Stack Pointer | Hardware |

**Caller-saved**: Caller must save these registers before CALL if needed
**Callee-saved**: Function must save/restore these registers if used

## Step-by-Step Function Call Example

### Example Code
```assembly
main:
    LOADI R0, 5           ; Parameter: n = 5
    CALL double_value     ; Call function
    ; R0 now contains 10
    HALT

double_value:
    ADD R0, R0, R0        ; R0 = R0 * 2
    RET
```

### Execution Trace

**Initial State**:
```
PC: 0x0100
SP: 0xFEFF
R0: 0
Memory[0x0100]: LOADI R0, 5
Memory[0x0102]: CALL 0x0108
Memory[0x0108]: ADD R0, R0, R0
Memory[0x010A]: RET
```

**Step 1**: Execute `LOADI R0, 5`
```
PC: 0x0102 (advanced by 2)
R0: 5
SP: 0xFEFF (unchanged)
```

**Step 2**: Execute `CALL 0x0108`
```
Actions:
  1. Push PC_low (0x05 from 0x0105) to stack
  2. Push PC_high (0x01) to stack
  3. Set PC = 0x0108

Result:
PC: 0x0108
SP: 0xFEFD (decremented by 2)
Stack[0xFEFD]: 0x01 (PC high)
Stack[0xFEFE]: 0x05 (PC low)
```

**Step 3**: Execute `ADD R0, R0, R0`
```
PC: 0x010A
R0: 10 (5 + 5)
SP: 0xFEFD
```

**Step 4**: Execute `RET`
```
Actions:
  1. Pop PC_high from stack (0x01)
  2. Pop PC_low from stack (0x05)
  3. Set PC = 0x0105

Result:
PC: 0x0105 (back to instruction after CALL)
SP: 0xFEFF (restored)
R0: 10 (return value preserved)
```

**Step 5**: Execute `HALT`
```
CPU halts with R0 = 10
```

## Nested Function Calls

Functions can call other functions, creating a **call chain**.

### Example: Three-Level Call Chain
```assembly
main:
    LOADI R0, 3
    CALL func_a           ; Level 1
    HALT

func_a:
    PUSH R0               ; Save parameter
    CALL func_b           ; Level 2
    POP R0                ; Restore
    RET

func_b:
    PUSH R0               ; Save parameter
    CALL func_c           ; Level 3
    POP R0                ; Restore
    RET

func_c:
    INC R0                ; R0 = R0 + 1
    RET
```

### Stack State at Maximum Depth

```
Address    Content                      Call Level
─────────────────────────────────────────────────
0xFEFF                                  (initial)
0xFEFE     [PC_low after CALL func_a]   main -> func_a
0xFEFD     [PC_high]
0xFEFC     [saved R0 = 3]               func_a saved
0xFEFB     [PC_low after CALL func_b]   func_a -> func_b
0xFEFA     [PC_high]
0xFEF9     [saved R0 = 3]               func_b saved
0xFEF8     [PC_low after CALL func_c]   func_b -> func_c
0xFEF7     [PC_high]                    <- SP (deepest)
```

## Advanced Function Call Patterns

### Pattern 1: Function with Multiple Parameters

```assembly
; Calculate: R0 = (a * b) + c
; Parameters: R0=a, R1=b, R2=c
calculate:
    PUSH R2               ; Save c
    ; Multiply a * b
    LOADI R3, 0           ; Accumulator
multiply_loop:
    CMPI R1, 0
    JZ multiply_done
    ADD R3, R3, R0        ; R3 += a
    DEC R1                ; b--
    JMP multiply_loop
multiply_done:
    ; R3 now has a * b
    POP R2                ; Restore c
    ADD R0, R3, R2        ; R0 = (a*b) + c
    RET
```

### Pattern 2: Function with Local Variables

```assembly
; Function uses local variables on stack
process_data:
    ; Function prologue: allocate stack space
    PUSH R3               ; Save R3
    PUSH R4               ; Save R4
    ; Now we have 2 bytes for local variables
    
    ; Function body
    LOADI R3, 10          ; Local var 1
    LOADI R4, 20          ; Local var 2
    ADD R0, R3, R4        ; R0 = local1 + local2
    
    ; Function epilogue: restore and cleanup
    POP R4                ; Restore R4
    POP R3                ; Restore R3
    RET
```

### Pattern 3: Function with Stack Parameters

When more than 3 parameters are needed:

```assembly
; Call function with 5 parameters
main:
    LOADI R0, 1           ; Param 1 (in register)
    LOADI R1, 2           ; Param 2 (in register)
    LOADI R2, 3           ; Param 3 (in register)
    LOADI R3, 4
    PUSH R3               ; Param 4 (on stack)
    LOADI R3, 5
    PUSH R3               ; Param 5 (on stack)
    CALL sum_five
    ; Clean up stack
    POP R3                ; Remove param 5
    POP R3                ; Remove param 4
    HALT

sum_five:
    ; Access stack parameters
    ; Stack: [ret_high][ret_low][param5][param4]
    ; SP points to ret_low
    ; param4 is at SP+2, param5 is at SP+3
    
    ; Sum: R0 + R1 + R2 + param4 + param5
    ADD R0, R0, R1        ; R0 = p1 + p2
    ADD R0, R0, R2        ; R0 = p1 + p2 + p3
    
    ; Access param 4 (would need LOAD with SP offset)
    ; This requires storing SP address and using LOAD
    ; For simplicity, this is conceptual
    
    RET
```

## Function Call Overhead

### Time Overhead
Each function call incurs:
- **CALL instruction**: 3 cycles (fetch + 2 stack writes + jump)
- **RET instruction**: 3 cycles (2 stack reads + jump)
- **Total**: 6 cycles minimum

### Space Overhead
- **Return address**: 2 bytes per call
- **Saved registers**: N bytes (depends on function)
- **Local variables**: M bytes (depends on function)
- **Total per call**: 2 + N + M bytes

### Example Overhead Analysis

For `factorial(5)`:
```
Number of calls: 5 (n=5,4,3,2,1)
Stack per call: 2 (ret addr) + 1 (saved n) = 3 bytes
Total stack: 5 * 3 = 15 bytes
Total cycles: 5 * (6 + function body cycles)
```

## Optimization Techniques

### 1. Inline Small Functions
Instead of calling a simple function:
```assembly
; Instead of:
CALL double
; Use inline:
ADD R0, R0, R0
```

### 2. Leaf Function Optimization
Functions that don't call others can avoid saving return address in register:
```assembly
; Leaf function - doesn't call other functions
simple_add:
    ADD R0, R0, R1        ; Just do the work
    RET                   ; Return address already on stack
```

### 3. Tail Call Optimization
Last call in a function can reuse current stack frame:
```assembly
func_a:
    ; ... some code ...
    ; Instead of:
    ; CALL func_b
    ; RET
    ; Use:
    JMP func_b            ; Jump instead of call
                          ; func_b will RET to our caller
```

## Common Pitfalls

### 1. Stack Overflow
```assembly
; WRONG: Calling without enough stack space
infinite_recursion:
    CALL infinite_recursion    ; Will overflow stack!
    RET
```

### 2. Mismatched PUSH/POP
```assembly
; WRONG: Unbalanced stack operations
function:
    PUSH R0
    PUSH R1
    ; ... code ...
    POP R0                ; Wrong! Should pop R1 first
    RET                   ; Returns to wrong address!
```

### 3. Not Preserving Registers
```assembly
; WRONG: Caller expects R3 unchanged
main:
    LOADI R3, 100         ; Important value
    CALL bad_function
    ; R3 is now corrupted!

bad_function:
    LOADI R3, 0           ; Overwrites caller's R3
    RET
```

**CORRECT VERSION**:
```assembly
good_function:
    PUSH R3               ; Save R3
    LOADI R3, 0           ; Use R3
    ; ... use R3 ...
    POP R3                ; Restore R3
    RET
```

## Function Call State Machine

```
┌─────────────────┐
│   EXECUTING     │
│   (Normal code) │
└────────┬────────┘
         │ CALL instruction
         ▼
┌─────────────────┐
│   CALLING       │
│ 1. Push PC      │
│ 2. Jump to addr │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   IN FUNCTION   │
│ (Execute body)  │
└────────┬────────┘
         │ RET instruction
         ▼
┌─────────────────┐
│   RETURNING     │
│ 1. Pop PC       │
│ 2. Jump to PC   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   EXECUTING     │
│ (After call)    │
└─────────────────┘
```

## Comparison with Other Architectures

| Feature | SC8 | x86 | ARM | MIPS |
|---------|-----|-----|-----|------|
| Call Instruction | CALL | CALL | BL | JAL |
| Return | RET | RET | BX LR | JR RA |
| Return Address | Stack | Stack | Register (LR) | Register (RA) |
| Parameters | Registers | Stack/Reg | Registers | Registers |
| Stack Growth | Downward | Downward | Downward | Downward |
| Frame Pointer | Optional | EBP | FP (R11) | FP (S8) |

## Summary

Function calls in the SC8 CPU:
- ✅ Use stack for return addresses
- ✅ Pass parameters via registers (R0, R1, R2)
- ✅ Return values in R0
- ✅ Support nested and recursive calls
- ✅ Follow caller-saved and callee-saved conventions
- ✅ Require careful stack management
- ✅ Have predictable overhead (6+ cycles, 2+ bytes)

The CALL/RET mechanism provides a clean, efficient way to structure programs with reusable functions while maintaining execution context through the stack.

