    .global myFunction

myFunction:
    movq %rdi, %rax   # Move the input from rdi to rax (return value register)
    addq %rax, %rax    # Multiply the input by 2
    ret
