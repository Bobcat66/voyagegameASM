# Macros
.set A, 1103515245
.set C, 12345

.section .text
# void vgsrand(void): seeds rng based on system clock
.globl vgsrand
.type vgsrand, @function
vgsrand:
    movq $228, %rax                          # syscall clock_gettime
    movq $1, %rdi                            # CLOCK_MONOTONIC
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

.section .rodata
lmaxsd: .double 4294967295.0
newline: .ascii "\n\0"

.section .bss
.lcomm seed_buf, 16                         # POSIX timespec struct. tv_sec: 0-7, tv_nsec: 8-15