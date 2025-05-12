.global myFunction

myFunction:
    pushq %rbp        # Save the base pointer
    movq %rsp, %rbp   # Set the base pointer

    movq %rdi, %rax   # Move the input from rdi to rax
    addq %rax, %rax   # Multiply the input by 2

    popq %rbp         # Restore the base pointer
    ret
