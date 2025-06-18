# Macros
.set A 1103515245
.set C 12345

.section .text
# void vgsrand(void): seeds rng based on system clock
.globl vgsrand
.type vgsrand, @function
vgsrand:
    movq $288, %rax                          # syscall clock_gettime
    movq $0, %rdi                            # CLOCK_REALTIME
    lea seed_buf(%rip), %rsi
    syscall
    ret
.size vgsrand, . - vgsrand    

# int vgrand(int): generates a random integer between 0 and arg0
.globl vgrand
.type vgrand, @function
vgrand:
    movl seed_buf+4(%rip), %eax             # Uses the lower 4 bytes of tv_sec as the seed
    imull $A, %eax, %eax
    addl $C, %eax
    movl %eax, seed_buf+4(%rip)             # updates seed
    xorl %edx, %edx
    divl %edi
    movl %edx, %eax
    ret
.size vgrand, . - vgrand

# double vgrandsd(): generates a random double between 0 and 1, stores in xmm0
.globl vgrandsd
.type vgrandsd, @function
vgrandsd:
    movl $0xFFFFFFFF, %edi
    call vgrand
    cvtsi2sd %eax, %xmm0
    divsd lmaxsd(%rip), %xmm0
    ret
.size vgrandsd, . - vgrandsd

# long vgstrlen(char*): returns length of string literal
.globl vgstrlen
.type vgstrlen, @function
vgstrlen:
    xorq %rax, %rax
    .Lvgrstrlen.loop:
        movb (%rdi,%rax,1), %sil
        test %sil, %sil 
        jz .Lvgrstrlen.end                  # If sil == 0, goto .Lvgrstrlen.end
        incq %rax
        jmp .Lvgrstrlen.loop
    .Lvgrstrlen.end:
    ret
.size vgstrlen, . - vgstrlen

# long vgprint(char*): prints a string literal to console
.globl vgprint
.type vgprint, @function
vgprint:
    push %rdi                               # Store char pointer in stack, as it is volatile
    call vgstrlen
    pop %rsi                                # pop char pointer to stack and store in rsi (expected by syscall ABI)                         
    movq %rax, %rdx                         # move strlen to rdx (expected by syscall ABI)
    push %rdx                               # store strlen so we can return it
    movq $1, %rax                           # syscall write (1)
    movq $1, %rdi                           # file descriptor stdout (1)
    syscall
    pop %rax
    ret
.size vgprint, . - vgprint


.section .rodata
lmaxsd: .double 4294967295.0
newline: .ascii "\n\0"

.section .bss
.lcomm seed_buf, 16                         # POSIX timespec struct. tv_sec: 0-7, tv_nsec: 8-15