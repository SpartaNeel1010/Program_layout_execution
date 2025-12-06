/**
 * Recursive Multiplication
 * 
 * This program demonstrates recursion through multiplication using addition.
 * Instead of using the * operator, we implement multiplication as repeated addition
 * using recursion.
 * 
 * Example: multiply(5, 3) = 5 + 5 + 5 = 15
 */

#include <stdio.h>
#include <stdint.h>

/**
 * Recursive multiplication function
 * Implements multiplication as repeated addition
 * 
 * @param a - First number (multiplicand)
 * @param b - Second number (multiplier)
 * @return The product of a and b
 * 
 * Base case: multiply(a, 0) = 0
 * Recursive case: multiply(a, b) = a + multiply(a, b-1)
 */
uint8_t multiply(uint8_t a, uint8_t b) {
    // Base case: anything multiplied by 0 is 0
    if (b == 0) {
        return 0;
    }
    
    // Recursive case: a * b = a + (a * (b-1))
    return a + multiply(a, b - 1);
}

/**
 * Main program - Driver function
 * 
 * Tests the multiplication function with various inputs
 */
int main() {
    printf("Recursive Multiplication Calculator\n");
    printf("====================================\n\n");
    
    // Test cases
    struct {
        uint8_t a;
        uint8_t b;
    } tests[] = {
        {0, 5},   // 0 * 5 = 0
        {5, 0},   // 5 * 0 = 0
        {1, 7},   // 1 * 7 = 7
        {3, 4},   // 3 * 4 = 12
        {5, 6},   // 5 * 6 = 30
        {7, 8},   // 7 * 8 = 56
        {10, 10}  // 10 * 10 = 100
    };
    
    int num_tests = sizeof(tests) / sizeof(tests[0]);
    
    for (int i = 0; i < num_tests; i++) {
        uint8_t a = tests[i].a;
        uint8_t b = tests[i].b;
        uint8_t result = multiply(a, b);
        printf("multiply(%d, %d) = %d\n", a, b, result);
    }
    
    printf("\nNote: Results are limited to 8-bit range (max 255)\n");
    
    return 0;
}

