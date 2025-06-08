.data 
inputBuffer:    .space 10
inputCursor:    .space 8
outputBuffer:   .space 10
outputCursor:   .space 8
bufferSize: .quad 10


.text
.global inImage
.global getInt
.global getText
.global getInPos
.global setInPos
.global outImage
.global putInt
.global putText
.global putChar
.global getOutPos
.global setOutPos

inImage:

    push %rbp
    mov %rsp, %rbp

    # fgets(inputBuffer, 256, stdin)

    lea inputBuffer(%rip), %rdi     # arg1: pekare till buffer
    mov $10, %rsi                  # arg2: antal tecken att läsa (inkl NULL)
    mov stdin(%rip), %rdx           # arg3: FILE* stdin
    call fgets                      # anropa fgets(buffer, size, stdin)

    # inputCursor = 0
    movq $0, inputCursor(%rip)

    pop %rbp
    ret


getInt:
    movq $0, %rax
    movq $0, %r11                # negativ-flagga
    lea inputBuffer(%rip), %rdi
    mov inputCursor(%rip), %rsi
    cmpq bufferSize(%rip), %rsi
    jb skip_call_inImage        # om rsi < bufferSize → hoppa över inläsning

call_inImage:
    call inImage
    lea inputBuffer(%rip), %rdi
    mov inputCursor(%rip), %rsi

skip_call_inImage:
    add %rsi, %rdi


check_blanc:
    cmpb $' ', (%rdi)
    jne check_nullTerminator
    incq %rdi
    jmp check_blanc

check_nullTerminator:
    cmpb $'\n', (%rdi) # 0 is asci for null
    je call_inImage

check_plus: 
    cmpb $'+', (%rdi)
    jne check_minus
    incq %rdi
    jmp while
check_minus:
    cmpb $'-', (%rdi)
    jne while
    incq %rdi
    movq $1, %r11 

while: 
    cmpb $'0', (%rdi)
    jl end_while
    cmpb $'9', (%rdi)
    jg end_while
    movzbq (%rdi), %r10
    subq $'0', %r10 
    imul $10, %rax
    addq %r10, %rax

    incq %rdi 
    jmp while
end_while:
    cmpq $1, %r11
    jne end
    negq %rax
end:
    ret

getText:
    pushq	$0

getInPos:
    pushq	$0

setInPos:
    pushq	$0

outImage:
    pushq	$0

putInt:
    pushq	$0

putText:
    pushq	$0

putChar:
    pushq	$0

getOutPos:
    pushq	$0

setOutPos:
    pushq	$0
