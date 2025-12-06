; =====================================================================
; FACTORIAL CALCULATION WITH RECURSION - SC8 CPU
; =====================================================================
; This program demonstrates recursive function calls on the SC8 CPU
; 
; Function: factorial(n)
; Returns: n! (factorial of n)
; 
; Base case: if n <= 1, return 1
; Recursive case: return n * factorial(n-1)
;
; Memory Layout:
; 0x0100-0x01FF: Code segment (program)
; 0x0200-0x0FFF: Data segment
; 0x1000-0xFEFF: Stack (grows downward from 0xFEFF)
; 0xFF00-0xFFFF: Memory-mapped I/O
;
; Stack Frame Structure for factorial(n):
; [SP+0]: Return address (low byte)
; [SP+1]: Return address (high byte)
; [SP+2]: Parameter n
; [SP+3]: Saved R1 (temp storage)
; =====================================================================

start:
    ; Initialize Stack Pointer to top of stack area
    LOADI R7, 0xFF        ; SP high byte
    LOADI R6, 0xFE        ; SP low byte (SP = 0xFEFF)
    ; Note: R7 is used as SP in this CPU

    ; Print header message
    CALL print_header
    
    ; Test factorial(0)
    LOADI R0, 0
    CALL test_factorial
    
    ; Test factorial(1)
    LOADI R0, 1
    CALL test_factorial
    
    ; Test factorial(2)
    LOADI R0, 2
    CALL test_factorial
    
    ; Test factorial(3)
    LOADI R0, 3
    CALL test_factorial
    
    ; Test factorial(4)
    LOADI R0, 4
    CALL test_factorial
    
    ; Test factorial(5)
    LOADI R0, 5
    CALL test_factorial
    
    ; Print done message
    CALL print_done
    
    ; Halt the CPU
    HALT

; =====================================================================
; test_factorial: Wrapper to test and display factorial calculation
; Input: R0 = n
; Output: Prints "factorial(n) = result"
; Modifies: R0, R1, R2, R3, R4, R5
; =====================================================================
test_factorial:
    ; Save return address (automatically pushed by CALL)
    PUSH R0               ; Save input n
    PUSH R1               ; Save R1
    
    ; Store n for later display
    LOADI R4, 0
    ADD R4, R4, R0        ; R4 = n (for display later)
    
    ; Print "factorial("
    LOADI R5, 102         ; 'f'
    STORE R5, [0xFF01]
    LOADI R5, 97          ; 'a'
    STORE R5, [0xFF01]
    LOADI R5, 99          ; 'c'
    STORE R5, [0xFF01]
    LOADI R5, 116         ; 't'
    STORE R5, [0xFF01]
    LOADI R5, 111         ; 'o'
    STORE R5, [0xFF01]
    LOADI R5, 114         ; 'r'
    STORE R5, [0xFF01]
    LOADI R5, 105         ; 'i'
    STORE R5, [0xFF01]
    LOADI R5, 97          ; 'a'
    STORE R5, [0xFF01]
    LOADI R5, 108         ; 'l'
    STORE R5, [0xFF01]
    LOADI R5, 40          ; '('
    STORE R5, [0xFF01]
    
    ; Print n as digit
    LOADI R5, 48
    ADD R5, R5, R4        ; R5 = '0' + n
    STORE R5, [0xFF01]
    
    ; Print ") = "
    LOADI R5, 41          ; ')'
    STORE R5, [0xFF01]
    LOADI R5, 32          ; ' '
    STORE R5, [0xFF01]
    LOADI R5, 61          ; '='
    STORE R5, [0xFF01]
    LOADI R5, 32          ; ' '
    STORE R5, [0xFF01]
    
    ; Restore n and call factorial
    POP R1                ; Restore R1
    POP R0                ; Restore n
    PUSH R0               ; Save again for cleanup
    
    ; Call factorial function
    CALL factorial        ; Result in R0
    
    ; R0 now contains factorial result
    ; Print result - handle up to 3 digits (max 255)
    CMPI R0, 10
    JC print_single_digit
    
    ; Check if 3-digit number (>= 100)
    CMPI R0, 100
    JC print_two_digits
    
    ; For three-digit numbers, extract hundreds first
    LOADI R1, 100
    LOADI R5, 0
divide_hundreds:
    CMP R0, R1
    JC print_hundreds_digit
    SUB R0, R0, R1
    INC R5
    JMP divide_hundreds
    
print_hundreds_digit:
    LOADI R3, 48
    ADD R5, R5, R3        ; Convert to ASCII
    STORE R5, [0xFF01]
    ; Fall through to print tens
    
print_two_digits:
    ; For two-digit numbers, print tens then ones
    LOADI R1, 10
    LOADI R5, 0
divide_tens:
    CMP R0, R1
    JC print_tens_digit
    SUB R0, R0, R1
    INC R5
    JMP divide_tens
    
print_tens_digit:
    LOADI R3, 48
    ADD R5, R5, R3        ; Convert to ASCII
    STORE R5, [0xFF01]
    ; R0 now has remainder (ones digit)
    JMP print_ones

print_single_digit:
    LOADI R5, 48
    ADD R5, R5, R0        ; R5 = '0' + result
    STORE R5, [0xFF01]
    JMP print_newline

print_ones:
    LOADI R5, 48
    ADD R5, R5, R0        ; R5 = '0' + ones
    STORE R5, [0xFF01]

print_newline:
    ; Print newline
    LOADI R5, 10          ; '\n'
    STORE R5, [0xFF01]
    
    POP R0                ; Cleanup stack
    RET

; =====================================================================
; factorial: Recursive factorial function
; Input: R0 = n
; Output: R0 = n!
; 
; This function demonstrates:
; 1. Parameter passing via registers
; 2. Stack-based recursion
; 3. Return value in R0
; 4. Preservation of registers across calls
; =====================================================================
factorial:
    ; Check base case: if n <= 1, return 1
    CMPI R0, 2            ; Compare n with 2
    JC base_case          ; If n < 2, go to base case
    
    ; Recursive case: n * factorial(n-1)
    ; Need to save n before recursive call
    PUSH R0               ; Save n on stack
    
    ; Calculate n-1
    DEC R0                ; R0 = n-1
    
    ; Recursive call: factorial(n-1)
    CALL factorial        ; Result will be in R0
    
    ; Now R0 contains factorial(n-1)
    ; Pop original n
    POP R1                ; R1 = n
    
    ; Multiply: R0 = n * factorial(n-1)
    ; Since we don't have direct multiply, use loop
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
    ; Return 1 for n <= 1
    LOADI R0, 1
    RET

; =====================================================================
; print_header: Print program header
; =====================================================================
print_header:
    ; Print "Factorial Calculator\n"
    LOADI R5, 70          ; 'F'
    STORE R5, [0xFF01]
    LOADI R5, 97          ; 'a'
    STORE R5, [0xFF01]
    LOADI R5, 99          ; 'c'
    STORE R5, [0xFF01]
    LOADI R5, 116         ; 't'
    STORE R5, [0xFF01]
    LOADI R5, 111         ; 'o'
    STORE R5, [0xFF01]
    LOADI R5, 114         ; 'r'
    STORE R5, [0xFF01]
    LOADI R5, 105         ; 'i'
    STORE R5, [0xFF01]
    LOADI R5, 97          ; 'a'
    STORE R5, [0xFF01]
    LOADI R5, 108         ; 'l'
    STORE R5, [0xFF01]
    LOADI R5, 10          ; '\n'
    STORE R5, [0xFF01]
    LOADI R5, 10          ; '\n'
    STORE R5, [0xFF01]
    RET

; =====================================================================
; print_done: Print completion message
; =====================================================================
print_done:
    ; Print "\nDone!\n"
    LOADI R5, 10          ; '\n'
    STORE R5, [0xFF01]
    LOADI R5, 68          ; 'D'
    STORE R5, [0xFF01]
    LOADI R5, 111         ; 'o'
    STORE R5, [0xFF01]
    LOADI R5, 110         ; 'n'
    STORE R5, [0xFF01]
    LOADI R5, 101         ; 'e'
    STORE R5, [0xFF01]
    LOADI R5, 33          ; '!'
    STORE R5, [0xFF01]
    LOADI R5, 10          ; '\n'
    STORE R5, [0xFF01]
    RET

