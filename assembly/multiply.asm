; =====================================================================
; RECURSIVE MULTIPLICATION - SC8 CPU
; =====================================================================
; This program demonstrates recursive function calls through multiplication
; implemented as repeated addition.
;
; Function: multiply(a, b)
; Returns: a * b (product of a and b)
;
; Base case: if b == 0, return 0
; Recursive case: return a + multiply(a, b-1)
;
; Memory Layout:
; 0x0100-0x01FF: Code segment (program)
; 0x0200-0x0FFF: Data segment
; 0x1000-0xFEFF: Stack (grows downward from 0xFEFF)
; 0xFF00-0xFFFF: Memory-mapped I/O
;
; Stack Frame Structure for multiply(a, b):
; [SP+0]: Return address (low byte)
; [SP+1]: Return address (high byte)
; [SP+2]: Parameter a
; [SP+3]: Parameter b
; =====================================================================

start:
    ; Initialize Stack Pointer
    LOADI R7, 0xFF        ; SP high byte
    LOADI R6, 0xFE        ; SP low byte (SP = 0xFEFF)

    ; Print header
    CALL print_header
    
    ; Test multiply(3, 4) = 12
    LOADI R0, 3           ; a = 3
    LOADI R1, 4           ; b = 4
    CALL test_multiply
    
    ; Test multiply(5, 6) = 30
    LOADI R0, 5
    LOADI R1, 6
    CALL test_multiply
    
    ; Test multiply(7, 8) = 56
    LOADI R0, 7
    LOADI R1, 8
    CALL test_multiply
    
    ; Test multiply(0, 5) = 0
    LOADI R0, 0
    LOADI R1, 5
    CALL test_multiply
    
    ; Test multiply(5, 0) = 0
    LOADI R0, 5
    LOADI R1, 0
    CALL test_multiply
    
    ; Print done message
    CALL print_done
    
    HALT

; =====================================================================
; test_multiply: Test and display multiplication
; Input: R0 = a, R1 = b
; Output: Prints "multiply(a, b) = result"
; =====================================================================
test_multiply:
    PUSH R0               ; Save a
    PUSH R1               ; Save b
    PUSH R2
    
    ; Save parameters for display
    POP R2
    POP R4                ; R4 = b
    POP R3                ; R3 = a
    PUSH R3               ; Restore stack
    PUSH R4
    PUSH R2
    
    ; Print "multiply("
    LOADI R5, 109         ; 'm'
    STORE R5, [0xFF01]
    LOADI R5, 117         ; 'u'
    STORE R5, [0xFF01]
    LOADI R5, 108         ; 'l'
    STORE R5, [0xFF01]
    LOADI R5, 116         ; 't'
    STORE R5, [0xFF01]
    LOADI R5, 105         ; 'i'
    STORE R5, [0xFF01]
    LOADI R5, 112         ; 'p'
    STORE R5, [0xFF01]
    LOADI R5, 108         ; 'l'
    STORE R5, [0xFF01]
    LOADI R5, 121         ; 'y'
    STORE R5, [0xFF01]
    LOADI R5, 40          ; '('
    STORE R5, [0xFF01]
    
    ; Print a
    LOADI R5, 48
    ADD R5, R5, R3
    STORE R5, [0xFF01]
    
    ; Print ", "
    LOADI R5, 44          ; ','
    STORE R5, [0xFF01]
    LOADI R5, 32          ; ' '
    STORE R5, [0xFF01]
    
    ; Print b
    LOADI R5, 48
    ADD R5, R5, R4
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
    
    ; Restore parameters and call multiply
    POP R2
    POP R1                ; b
    POP R0                ; a
    PUSH R0               ; Save for cleanup
    PUSH R1
    
    CALL multiply         ; Result in R0
    
    ; Print result
    ; Handle two-digit numbers
    CMPI R0, 10
    JC print_single
    
    ; Two or three digit number
    CMPI R0, 100
    JC print_two_digit
    
    ; Three digit number (100+)
    LOADI R5, 49          ; '1'
    STORE R5, [0xFF01]
    LOADI R2, 100
    SUB R0, R0, R2        ; R0 = R0 - 100
    
print_two_digit:
    ; Get tens digit
    LOADI R1, 10
    LOADI R2, 0           ; Counter
count_tens:
    CMPI R0, 10
    JC print_tens
    LOADI R3, 10
    SUB R0, R0, R3        ; R0 = R0 - 10
    INC R2
    JMP count_tens
    
print_tens:
    CMPI R2, 0            ; Skip if no tens
    JZ print_ones
    LOADI R5, 48
    ADD R5, R5, R2
    STORE R5, [0xFF01]
    JMP print_ones

print_single:
    LOADI R5, 48
    ADD R5, R5, R0
    STORE R5, [0xFF01]
    JMP cleanup_multiply

print_ones:
    LOADI R5, 48
    ADD R5, R5, R0
    STORE R5, [0xFF01]

cleanup_multiply:
    ; Print newline
    LOADI R5, 10
    STORE R5, [0xFF01]
    
    POP R1                ; Cleanup
    POP R0
    RET

; =====================================================================
; multiply: Recursive multiplication function
; Input: R0 = a, R1 = b
; Output: R0 = a * b
;
; Implements: multiply(a, b) = a + multiply(a, b-1)
; Base case: if b == 0, return 0
; =====================================================================
multiply:
    ; Check base case: if b == 0, return 0
    CMPI R1, 0
    JZ mult_base_case
    
    ; Recursive case: a + multiply(a, b-1)
    PUSH R0               ; Save a (will need it for addition)
    PUSH R1               ; Save b
    
    ; Calculate b-1
    DEC R1                ; R1 = b-1
    
    ; Recursive call: multiply(a, b-1)
    ; R0 already has a
    CALL multiply         ; Result in R0 = multiply(a, b-1)
    
    ; R0 now contains multiply(a, b-1)
    ; Add a to get final result
    POP R1                ; Restore b (not needed but clean stack)
    POP R1                ; R1 = a
    ADD R0, R0, R1        ; R0 = a + multiply(a, b-1)
    
    RET

mult_base_case:
    ; Return 0
    LOADI R0, 0
    RET

; =====================================================================
; print_header: Print program header
; =====================================================================
print_header:
    ; Print "Recursive Multiplication\n\n"
    LOADI R5, 77          ; 'M'
    STORE R5, [0xFF01]
    LOADI R5, 117         ; 'u'
    STORE R5, [0xFF01]
    LOADI R5, 108         ; 'l'
    STORE R5, [0xFF01]
    LOADI R5, 116         ; 't'
    STORE R5, [0xFF01]
    LOADI R5, 105         ; 'i'
    STORE R5, [0xFF01]
    LOADI R5, 112         ; 'p'
    STORE R5, [0xFF01]
    LOADI R5, 108         ; 'l'
    STORE R5, [0xFF01]
    LOADI R5, 121         ; 'y'
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

