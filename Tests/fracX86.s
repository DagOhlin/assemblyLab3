.data
resMsg: .asciz "fak=%d\n"   # Format string for factorial result
buf: .asciz "xxxxxxxxx"      # Buffer for input
endMsg: .asciz "slut\n"      # End message

.text
.global main
main:
    pushq $0                # Stack should be 16 bytes aligned
    movq $5, %rdi           # Calculate factorial of 5
    call fac
    movq %rax, %rsi         # Move the return value to the argument register (arg2)
    movq $resMsg, %rdi      # Print "fak=<result>", address of format string in arg1
    call printf

    # Read with fgets(buf, 5, stdin)
    movq $buf, %rdi         # Address of buffer in arg1
    movq $5, %rsi           # Maximum 5-1=4 characters, arg2
    movq stdin, %rdx        # From standard input, arg3
    call fgets
    movq $buf, %rdi         # Address of the string in arg1
    call printf             # Print the buffer
    movq $endMsg, %rdi      # Followed by the end message
    call printf
    popq %rax
    ret                     # End the program

# Recursive factorial function: fac = n!
fac:
    cmpq $1, %rdi           # If n > 1
    jle lBase
    pushq %rdi              # Push the argument value onto the stack
    decq %rdi               # Decrement the value by 1
    call fac                # Recursive call: fac(n-1)
    popq %rdi               # Retrieve the value from the stack
    imul %rdi, %rax         # Multiply n * temp (result from recursive call)
    ret                     # Return result

lBase:
    movq $1, %rax           # Base case: return 1
    ret                     # Return
