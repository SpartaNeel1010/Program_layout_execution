/**
 * Factorial Calculation with Recursion
 * 
 * This program demonstrates recursion through a simple factorial calculation.
 * The factorial function calls itself recursively until it reaches the base case.
 * 
 * Example: factorial(5) = 5 * 4 * 3 * 2 * 1 = 120
 */

#include <stdio.h>
#include <stdint.h>

/**
 * Recursive factorial function
 * 
 * @param n - The number to calculate factorial for
 * @return The factorial of n
 * 
 * Base case: factorial(0) = 1, factorial(1) = 1
 * Recursive case: factorial(n) = n * factorial(n-1)
 */
uint8_t factorial(uint8_t n) {
    // Base case: 0! = 1 and 1! = 1
    if (n <= 1) {
        return 1;
    }
    
    // Recursive case: n! = n * (n-1)!
    return n * factorial(n - 1);
}

/**
 * Main program - Driver function
 * 
 * Tests the factorial function with various inputs
 */
int main() {
    printf("Factorial Calculator\n");
    printf("====================\n\n");
    
    // Test cases - limited to small values due to 8-bit arithmetic
    uint8_t test_values[] = {0, 1, 2, 3, 4, 5};
    int num_tests = sizeof(test_values) / sizeof(test_values[0]);
    
    for (int i = 0; i < num_tests; i++) {
        uint8_t n = test_values[i];
        uint8_t result = factorial(n);
        printf("factorial(%d) = %d\n", n, result);
    }
    
    printf("\nNote: Values beyond 5! exceed 8-bit range (max 255)\n");
    
    return 0;
}

