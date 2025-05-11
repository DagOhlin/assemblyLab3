#include <stdio.h>

// Declaration of the external assembly function
extern long myFunction(long);

int main() {
    long input;
    printf("Enter a number: ");
    scanf("%ld", &input);

    long result = myFunction(input);
    printf("The result from assembly function: %ld\n", result);

    return 0;
}
