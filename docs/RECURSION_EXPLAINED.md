# Recursion in SC8 CPU

## What is Recursion?

**Recursion** is a programming technique where a function calls itself to solve a problem by breaking it down into smaller, similar subproblems. Each recursive call works on a simpler version of the original problem until reaching a **base case** that can be solved directly.

## Core Concepts

### 1. Base Case
The condition that stops the recursion. Without a base case, recursion continues infinitely.

### 2. Recursive Case
The part where the function calls itself with a modified parameter, moving toward the base case.

### 3. Stack Unwinding
After reaching the base case, the function calls return in reverse order (LIFO - Last In, First Out), building up the final result.

## Mathematical Example: Factorial

### Definition
```
factorial(n) = n! = n × (n-1) × (n-2) × ... × 2 × 1

Recursive definition:
  factorial(0) = 1              (base case)
  factorial(1) = 1              (base case)
  factorial(n) = n × factorial(n-1)  (recursive case)
```

### Example: factorial(5)
```
factorial(5) = 5 × factorial(4)
             = 5 × (4 × factorial(3))
             = 5 × (4 × (3 × factorial(2)))
             = 5 × (4 × (3 × (2 × factorial(1))))
             = 5 × (4 × (3 × (2 × 1)))
             = 5 × (4 × (3 × 2))
             = 5 × (4 × 6)
             = 5 × 24
             = 120
```

## Recursion in C

### Factorial Implementation
```c
uint8_t factorial(uint8_t n) {
    // Base case
    if (n <= 1) {
        return 1;
    }
    
    // Recursive case
    return n * factorial(n - 1);
}
```

### Call Sequence for factorial(4)
```
main() calls factorial(4)
  factorial(4) calls factorial(3)
    factorial(3) calls factorial(2)
      factorial(2) calls factorial(1)
        factorial(1) returns 1         ← Base case reached
      factorial(2) returns 2 * 1 = 2
    factorial(3) returns 3 * 2 = 6
  factorial(4) returns 4 * 6 = 24
main() receives 24
```

## Recursion in SC8 Assembly

### Implementation Strategy

For the SC8 CPU, implementing recursion requires:
1. **Saving parameters** before recursive call
2. **Modifying parameters** for the recursive call
3. **Making the recursive call** using CALL
4. **Restoring parameters** after the call
5. **Computing result** using saved and returned values
6. **Returning** the result via RET

### factorial(n) in SC8 Assembly

```assembly
; Input: R0 = n
; Output: R0 = n!
factorial:
    ; Check base case: if n <= 1, return 1
    CMPI R0, 2            ; Compare n with 2
    JC base_case          ; If n < 2, go to base case
    
    ; Recursive case: n * factorial(n-1)
    PUSH R0               ; Save n on stack
    
    DEC R0                ; R0 = n-1
    CALL factorial        ; Recursive call: R0 = factorial(n-1)
    
    POP R1                ; R1 = n (restore from stack)
    
    ; Multiply: R0 = n * factorial(n-1)
    ; Using repeated addition since no MUL stores full result
    PUSH R0               ; Save factorial(n-1)
    LOADI R0, 0           ; R0 = accumulator
    POP R2                ; R2 = factorial(n-1)
    
multiply_loop:
    CMPI R1, 0
    JZ multiply_done
    ADD R0, R0, R2        ; R0 += factorial(n-1)
    DEC R1
    JMP multiply_loop
    
multiply_done:
    RET                   ; Return with result in R0

base_case:
    LOADI R0, 1           ; Return 1
    RET
```

## Detailed Execution Trace: factorial(3)

Let's trace `factorial(3)` step by step to understand how recursion works at the machine level.

### Initial State
```
PC: 0x0100
SP: 0xFEFF (stack empty)
R0: 3
Call: factorial(3)
```

### Recursion Level 1: factorial(3)

**Entry:**
```
PC: 0x0150 (factorial function)
SP: 0xFEFD (return address on stack)
R0: 3
Stack:
  0xFEFE: [return_addr_low]
  0xFEFD: [return_addr_high] <- SP
```

**Base case check:**
```
CMPI R0, 2        ; Compare 3 with 2
                  ; Result: 3 >= 2, carry flag = 0
JC base_case      ; Not taken (carry = 0)
```

**Save n and prepare recursive call:**
```
PUSH R0           ; Save n=3

Stack:
  0xFEFE: [return_addr_low]
  0xFEFD: [return_addr_high]
  0xFEFC: [3]     <- SP (saved n)

DEC R0            ; R0 = 2
CALL factorial    ; Call factorial(2)
```

### Recursion Level 2: factorial(2)

**Entry:**
```
PC: 0x0150
SP: 0xFEFA (new return address on stack)
R0: 2
Stack:
  0xFEFE: [ret_addr_low level 1]
  0xFEFD: [ret_addr_high level 1]
  0xFEFC: [3]     (saved n from level 1)
  0xFEFB: [ret_addr_low level 2]
  0xFEFA: [ret_addr_high level 2] <- SP
```

**Base case check:**
```
CMPI R0, 2        ; Compare 2 with 2
                  ; Result: 2 >= 2, but edge case
JC base_case      ; Not taken
```

**Save n and prepare recursive call:**
```
PUSH R0           ; Save n=2

Stack:
  0xFEFE: [ret_addr_low level 1]
  0xFEFD: [ret_addr_high level 1]
  0xFEFC: [3]
  0xFEFB: [ret_addr_low level 2]
  0xFEFA: [ret_addr_high level 2]
  0xFEF9: [2]     <- SP (saved n)

DEC R0            ; R0 = 1
CALL factorial    ; Call factorial(1)
```

### Recursion Level 3: factorial(1) - BASE CASE

**Entry:**
```
PC: 0x0150
SP: 0xFEF7
R0: 1
Stack:
  0xFEFE: [ret_addr_low level 1]
  0xFEFD: [ret_addr_high level 1]
  0xFEFC: [3]
  0xFEFB: [ret_addr_low level 2]
  0xFEFA: [ret_addr_high level 2]
  0xFEF9: [2]
  0xFEF8: [ret_addr_low level 3]
  0xFEF7: [ret_addr_high level 3] <- SP
```

**Base case check:**
```
CMPI R0, 2        ; Compare 1 with 2
                  ; Result: 1 < 2, carry flag = 1
JC base_case      ; JUMP TAKEN! 🎯
```

**Base case execution:**
```
base_case:
  LOADI R0, 1     ; R0 = 1
  RET             ; Return to level 2
```

**After RET:**
```
PC: [return address to level 2]
SP: 0xFEF9 (return address popped)
R0: 1 (return value)
Stack:
  0xFEFE: [ret_addr_low level 1]
  0xFEFD: [ret_addr_high level 1]
  0xFEFC: [3]
  0xFEFB: [ret_addr_low level 2]
  0xFEFA: [ret_addr_high level 2]
  0xFEF9: [2]     <- SP
```

### Returning to Level 2: Complete factorial(2)

**Continue after recursive call:**
```
POP R1            ; R1 = 2 (restore n)

SP: 0xFEFA
R0: 1 (factorial(1))
R1: 2 (n)
```

**Multiply: 2 × factorial(1) = 2 × 1:**
```
PUSH R0           ; Save factorial(1) = 1
LOADI R0, 0       ; R0 = 0 (accumulator)
POP R2            ; R2 = 1 (factorial(1))

multiply_loop:
  Iteration 1: R0 = 0 + 1 = 1, R1 = 1
  Iteration 2: R0 = 1 + 1 = 2, R1 = 0
  
multiply_done:
  R0 = 2

RET               ; Return to level 1
```

**After RET:**
```
PC: [return address to level 1]
SP: 0xFEFC
R0: 2 (factorial(2) = 2)
Stack:
  0xFEFE: [ret_addr_low level 1]
  0xFEFD: [ret_addr_high level 1]
  0xFEFC: [3]     <- SP
```

### Returning to Level 1: Complete factorial(3)

**Continue after recursive call:**
```
POP R1            ; R1 = 3 (restore n)

SP: 0xFEFD
R0: 2 (factorial(2))
R1: 3 (n)
```

**Multiply: 3 × factorial(2) = 3 × 2:**
```
PUSH R0           ; Save factorial(2) = 2
LOADI R0, 0       ; R0 = 0 (accumulator)
POP R2            ; R2 = 2 (factorial(2))

multiply_loop:
  Iteration 1: R0 = 0 + 2 = 2, R1 = 2
  Iteration 2: R0 = 2 + 2 = 4, R1 = 1
  Iteration 3: R0 = 4 + 2 = 6, R1 = 0
  
multiply_done:
  R0 = 6

RET               ; Return to main
```

**Final State:**
```
PC: [return address in main]
SP: 0xFEFF (stack fully unwound)
R0: 6 (factorial(3) = 6) ✅
```

## Visualization: Call Stack Evolution

```
Time →

Initial:
Stack: [Empty]
Call: factorial(3)

Level 1:
Stack: [ret1_low, ret1_high]
       [n=3]
Call: factorial(2)

Level 2:
Stack: [ret1_low, ret1_high]
       [n=3]
       [ret2_low, ret2_high]
       [n=2]
Call: factorial(1)

Level 3 (Maximum Depth):
Stack: [ret1_low, ret1_high]
       [n=3]
       [ret2_low, ret2_high]
       [n=2]
       [ret3_low, ret3_high]
Exec: BASE CASE → return 1

Unwind Level 2:
Stack: [ret1_low, ret1_high]
       [n=3]
       [ret2_low, ret2_high]
Calc: 2 × 1 = 2 → return 2

Unwind Level 1:
Stack: [ret1_low, ret1_high]
Calc: 3 × 2 = 6 → return 6

Complete:
Stack: [Empty]
Result: 6
```

## Another Example: Recursive Multiplication

### Definition
```
multiply(a, 0) = 0                    (base case)
multiply(a, b) = a + multiply(a, b-1) (recursive case)
```

### Implementation in SC8 Assembly
```assembly
; Input: R0 = a, R1 = b
; Output: R0 = a * b
multiply:
    ; Base case: if b == 0, return 0
    CMPI R1, 0
    JZ mult_base_case
    
    ; Recursive case: a + multiply(a, b-1)
    PUSH R0               ; Save a
    PUSH R1               ; Save b
    
    DEC R1                ; R1 = b-1
    CALL multiply         ; R0 = multiply(a, b-1)
    
    POP R1                ; R1 = b (discard)
    POP R1                ; R1 = a
    ADD R0, R0, R1        ; R0 = a + multiply(a, b-1)
    
    RET

mult_base_case:
    LOADI R0, 0           ; Return 0
    RET
```

### Execution: multiply(4, 3)

```
multiply(4, 3) = 4 + multiply(4, 2)
               = 4 + (4 + multiply(4, 1))
               = 4 + (4 + (4 + multiply(4, 0)))
               = 4 + (4 + (4 + 0))
               = 4 + (4 + 4)
               = 4 + 8
               = 12
```

**Stack at Maximum Depth:**
```
Level 1: multiply(4, 3)
  Stack: [ret1][a=4][b=3]

Level 2: multiply(4, 2)
  Stack: [ret1][a=4][b=3][ret2][a=4][b=2]

Level 3: multiply(4, 1)
  Stack: [ret1][a=4][b=3][ret2][a=4][b=2][ret3][a=4][b=1]

Level 4: multiply(4, 0) - BASE CASE
  Stack: [ret1][a=4][b=3][ret2][a=4][b=2][ret3][a=4][b=1][ret4]
  Returns: 0
```

**Unwinding:**
```
Level 3 returns: 4 + 0 = 4
Level 2 returns: 4 + 4 = 8
Level 1 returns: 4 + 8 = 12
```

## Stack Space Requirements

### Formula
For a recursive function with depth D:
```
Stack_Space = D × (2 + S)

Where:
  D = maximum recursion depth
  2 = bytes for return address
  S = bytes saved per call (parameters, local vars)
```

### Examples

**factorial(n):**
- Maximum depth: n
- Bytes per level: 2 (ret addr) + 1 (saved n) = 3
- Total: 3n bytes

**multiply(a, b):**
- Maximum depth: b
- Bytes per level: 2 (ret addr) + 2 (saved a, b) = 4
- Total: 4b bytes

**For SC8 with ~60KB stack:**
- Max factorial: n ≈ 20,000 (practically limited to 255 by 8-bit)
- Max multiply: b ≈ 15,000 (practically limited to 255)

## Recursion vs. Iteration

### Advantages of Recursion
✅ **Simplicity**: Elegant solution for naturally recursive problems
✅ **Readability**: Mirrors mathematical definitions
✅ **Correctness**: Easier to prove correct
✅ **Natural fit**: Tree traversal, divide-and-conquer algorithms

### Disadvantages of Recursion
❌ **Stack overhead**: Each call uses stack space
❌ **Performance**: Function call overhead (CALL/RET)
❌ **Stack overflow risk**: Deep recursion can crash

### When to Use Recursion
- Problem has recursive structure (trees, graphs)
- Depth is guaranteed to be small
- Clarity is more important than performance
- Tail call optimization is available

### When to Use Iteration
- Large/unknown depth
- Performance is critical
- Stack space is limited
- Simple loop suffices

## Iterative Equivalent

### Factorial (Iterative)
```assembly
; Input: R0 = n
; Output: R0 = n!
factorial_iter:
    CMPI R0, 1
    JC base_case_iter
    
    LOADI R1, 1           ; R1 = result accumulator
    LOADI R2, 1           ; R2 = counter
    
loop:
    CMP R2, R0
    JZ done
    INC R2                ; counter++
    ; Multiply R1 by R2 (result *= counter)
    PUSH R0
    PUSH R2
    LOADI R0, 0
    LOADI R3, 0
mult:
    CMP R3, R1
    JZ mult_done
    ADD R0, R0, R2
    INC R3
    JMP mult
mult_done:
    LOADI R1, 0
    ADD R1, R1, R0
    POP R2
    POP R0
    JMP loop
    
done:
    LOADI R0, 0
    ADD R0, R0, R1        ; Move result to R0
    RET

base_case_iter:
    LOADI R0, 1
    RET
```

**Comparison:**
| Metric | Recursive | Iterative |
|--------|-----------|-----------|
| Code Size | Smaller | Larger |
| Stack Usage | O(n) | O(1) |
| Speed | Slower (calls) | Faster |
| Clarity | Higher | Lower |

## Tail Recursion

A special form where the recursive call is the last operation.

### Example: Tail Recursive Factorial
```c
uint8_t factorial_tail(uint8_t n, uint8_t accumulator) {
    if (n <= 1) {
        return accumulator;
    }
    return factorial_tail(n - 1, n * accumulator);
}

// Call: factorial_tail(5, 1)
```

### Optimization Opportunity
Tail recursion can be converted to iteration automatically:
```assembly
factorial_tail:
    CMPI R0, 1
    JC return_accum
    
    ; Instead of CALL, use JMP
    MUL R1, R0, R1        ; accumulator *= n (if MUL available)
    DEC R0                ; n--
    JMP factorial_tail    ; Loop instead of call!
    
return_accum:
    LOADI R0, 0
    ADD R0, R0, R1        ; Return accumulator
    RET
```

**Benefits:**
- No stack growth
- Same performance as iteration
- Maintains recursive style

## Common Recursion Patterns

### 1. Linear Recursion
One recursive call per invocation.
```
factorial(n) → factorial(n-1)
```

### 2. Binary Recursion
Two recursive calls per invocation.
```
fibonacci(n) → fibonacci(n-1) + fibonacci(n-2)
```

### 3. Tail Recursion
Recursive call is the last operation.
```
count_down(n) → count_down(n-1)  (no operation after)
```

### 4. Mutual Recursion
Functions call each other.
```
is_even(n) → is_odd(n-1)
is_odd(n) → is_even(n-1)
```

## Summary

Recursion in SC8:
- ✅ **Implemented** using CALL/RET and stack
- ✅ **Requires** base case to terminate
- ✅ **Uses** stack to store return addresses and intermediate values
- ✅ **Supports** nested and multiple recursive calls
- ✅ **Limited** by stack space (~60KB)
- ✅ **Trade-off**: Clarity vs. performance
- ✅ **Alternative**: Iterative solutions for better performance

The stack-based architecture of SC8 naturally supports recursion, making it possible to implement elegant recursive solutions to complex problems, while understanding the underlying mechanism helps write efficient recursive code.

