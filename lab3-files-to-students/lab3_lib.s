.data 
inputBuffer:    .space 256
inputCursor:    .space 8
outputBuffer:   .space 256
outputCursor:   .space 8
bufferSize: .quad 256


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
    mov $256, %rsi                  # arg2: antal tecken att läsa (inkl NULL)
    mov stdin(%rip), %rdx           # arg3: FILE* stdin
    call fgets                      # anropa fgets(buffer, size, stdin)

    # inputCursor = 0
    movq $0, inputCursor(%rip)

    pop %rbp
    ret

# -----------------------------------------------
getInt:
    lea inputBuffer(%rip), %rdi
    mov inputCursor(%rip), %rsi
    cmpq bufferSize(%rip), %rsi
    jb skip_call_inImage        # om rsi < bufferSize → hoppa över inläsning

call_inImage:
    call inImage
    lea inputBuffer(%rip), %rdi
    mov inputCursor(%rip), %rsi

skip_call_inImage:
    movq $0, %rax
    movq $0, %r11                # negativ-flagga
    add %rsi, %rdi


check_blanc:
    cmpb $' ', (%rdi)
    jne check_nullTerminator
    incq %rdi
    jmp check_blanc

check_nullTerminator:
    cmpb $'\n', (%rdi) 
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
    lea inputBuffer(%rip), %r10
    subq %r10, %rdi
    movq %rdi, inputCursor(%rip) 
    ret
# --------------------------------------------------------------------------
getText:
    push   %rbp
    mov    %rsp, %rbp

    # spara rbx (cursor) och r12 (basadress)
    push   %rbx
    lea    inputBuffer(%rip), %r12    # r12 = &inputBuffer

    # arguments: %rdi = buf, %rsi = n
    mov    %rdi, %r13    # r13 = dest‐pekare
    mov    %rsi, %r14    # r14 = max antal tecken

    # kolla refill
    movq   inputCursor(%rip), %rbx
    cmpq   bufferSize(%rip), %rbx
    jae    .Lrefill

    jmp    .Lcopy

.Lrefill:
    call   inImage
    xorq   %rbx, %rbx

.Lcopy:
    xorq   %rax, %rax    # count = 0

.Lloop:
    cmpq   %r14, %rax    # om count == n → färdig
    je     .Ldone
    movb   (%r12,%rbx,1), %dl
    cmpb   $0, %dl       # null‐terminator?
    je     .Ldone
    movb   %dl, (%r13)
    incq   %r13          # dest++
    incq   %rax          # count++
    incq   %rbx          # cursor++
    jmp    .Lloop

.Ldone:
    movb   $0, (%r13)    # null‐terminera
    movq   %rbx, inputCursor(%rip)
    
    pop    %rbx
    pop    %rbp
    ret
# ------------------------------------
getInPos:
    movq inputCursor(%rip), %rax
    ret

# --------------------------------------------
setInPos:
    movq    %rdi, %rax                   # RAX = n

    cmpq    $0, %rax
    jl      .Lset_zero                   # om n < 0 → hoppa till 0

    cmpq    bufferSize(%rip), %rax
    jle     .Lstore                      # om n ≤ MAXPOS → lagra n
    movq    bufferSize(%rip), %rax       # annars: clamp till MAXPOS

.Lstore:
    movq    %rax, inputCursor(%rip)      # skriv tillbaka
    ret

.Lset_zero:
    xorq    %rax, %rax                   # RAX = 0
    jmp     .Lstore

# ------------------------------------------
outImage:
    push %rbp
    # -–– ladda adressen till vår output-buffert som argument till puts
    lea    outputBuffer(%rip), %rdi

    # -–– anropa puts(outputBuffer)
    call   puts

    # -–– återställ cursor så bufferten blir "tom" igen
    movq   $0, outputCursor(%rip)

    # -–– retur
    pop %rbp
    ret
# ---------------------------------------
putInt:
    movq %rdi, %rax
    lea outputBuffer(%rip), %rdi
    mov outputCursor(%rip), %rsi
    mov bufferSize(%rip), %r11
    add %rsi, %rdi

    cmpq $0, %rax
    jge convert_digits

    movb $'-', (%rdi)
    incq %rdi
    decq %r11
    negq %rax

convert_digits:
    pushq $0
    movq $10, %r10

next_digit: 
    cqto
    divq %r10
    addq $'0', %rdx
    pushq %rdx
    cmpq $0, %rax
    jne next_digit


write_digits: 
    popq %rax
    cmpq $0, %rax
    je done
    movb %al, (%rdi)
    incq %rdi
    decq %r11
    jmp write_digits

done:
    lea outputBuffer(%rip), %r10
    subq %r10, %rdi
    movq %rdi, outputCursor(%rip) 
    ret
#-------------------------
putText:
    movq %rdi, %rcx
    movq $0, %rdx

putTezt_loop:
    movb (%rcx, %rdx), %dil
    cmpb $0, %dil
    jz end_putTezt
    call putChar
    incq %rdx
    jmp putTezt_loop

end_putTezt:
    ret

# -----------------------
putChar:
    pushq %rcx 
    movq %rdi, %rcx # flytta input till rax
    lea outputBuffer(%rip), %rdi # ladda in basaddress
    mov outputCursor(%rip), %rsi # ladda in cursor index
    mov bufferSize(%rip), %r11 # ladda in buffersize
    add %rsi, %rdi #räkna ut cursor address

    movq %rcx, (%rdi) # flytta 
    incq %rdi

    lea outputBuffer(%rip), %r10
    subq %r10, %rdi
    movq %rdi, outputCursor(%rip) 
    pop %rcx
    ret

# ----------------
getOutPos:
     movq outputCursor(%rip), %rax
    ret
#------------------
setOutPos:
    movq    %rdi, %rax                   # RAX = n

    cmpq    $0, %rax
    jl      .Lset_zeroout                   # om n < 0 → hoppa till 0

    cmpq    bufferSize(%rip), %rax
    jle     .Lstoreout                      # om n ≤ MAXPOS → lagra n
    movq    bufferSize(%rip), %rax       # annars: clamp till MAXPOS

.Lstoreout:
    movq    %rax, outputCursor(%rip)      # skriv tillbaka
    ret

.Lset_zeroout:
    xorq    %rax, %rax                   # RAX = 0
    jmp     .Lstoreout

