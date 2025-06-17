# Macros
.set A 1103515245
.set C 12345
.extern printf                              # from the C standard library

.section .text

# void vgsrand(void): seeds rng based on system clock
.type vgsrand, @function
vgsrand:
    movq $288, %rax                          # syscall clock_gettime
    movq $0, %rdi                            # CLOCK_REALTIME
    lea seed_buf(%rip), %rdi
    syscall
    ret
.size vgsrand, . - vgsrand    

# int vgrand(int): generates a random integer between 0 and arg0
.type vgrand, @function
vgrand:
    movl seed_buf+4(%rip), %eax             # Uses the lower 4 bytes of tv_sec as the seed
    imull $A, %eax, %eax
    addl $C, %eax
    movl %eax, seed_buf+4(%rip)             # updates seed
    xorl %edx, %edx
    idivl %edi
    movl %edx, %eax
    ret
.size vgrand, . - vgrand

# long vgstrlen(char*): returns length of string literal
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
size vgstrlen, . - vgstrlen

# long vgprint(char*): prints a string literal to console
.type vgprint, @function
vgprint:
    push %rdi                               # Store char pointer in stack, as it is volatile
    callq vgstrlen
    pop %rsi                                # pop char pointer to stack and stor in rsi (expected by syscall ABI)                         
    movq %rax, %rdx                         # move strlen to rdx (expected by syscall ABI)
    push %rdx                               # store strlen so we can return it
    movq $1, %rax                           # syscall write (1)
    movq $1, %rdi                           # file descriptor stdout (1)
    syscall
    popq %rax
    ret
size vgprint, . - vgprint


# void updateMax(void): updates maximums based on level
.type updateMax, @function
updateMax:
    # update max limes
    movl ship_level(%rip), %eax
    imull $50, %eax, %eax
    addl $250, %eax
    movl %eax, ship_max_limes(%rip)

    # update max limes
    movl ship_level(%rip), %eax
    imul $15, %eax, %eax
    addl $165, %eax
    movl %eax, ship_max_mateys(%rip)

    # update max booty
    movl ship_level(%rip), %eax
    imul $500, %eax, %eax
    addl $2500, %eax
    movl %eax, ship_max_booty(%rip)

    # update max cannons
    movl ship_level(%rip), %eax
    imul $5, %eax, %eax
    addl $18, %eax
    movl %eax, ship_max_cannons(%rip)

    # update max health
    movl ship_level(%rip), %eax
    imul $30, %eax, %eax
    addl $70, %eax
    movl %eax, ship_max_health(%rip)

    ret
.size updateMax, . - updateMax

# int updateStat(int* stat, int delta): returns a copy of the updated stat's value. Stat will be set at zero if adding the delta would make it negative
.type updateStat, @function
updateStat:
    movl (%rdi), %eax
    addl %esi, %eax
    cmpl $1, %eax
    jge .LupdateStat.exit                   # Jumps to exit if result is positive
    movl $0, %eax                           # Otherwise, sets stat to zero
    .LupdateStat.exit:
    movl %eax, (%rdi)
    ret
.size updateStat, . - updateStat

# 
.type voyage, @function
voyage:

    # Sets up local stack frame
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp                          # Allocates 64 bytes of stack space. Todo: figure out how much space to allocate        

    pushq %rbx                              # Saves nonvolatile register

    movl %18, voyage_weeks_left(%rip)
    movl %0, voyage_current_week(%rip)
    movl %3, voyage_resupply_time(%rip)
    .Lvoyage.loop:
        # Prints game data for player
        leaq str1(%rip), %rdi
        movl voyage_current_week(%rip), %esi
        call printf

        leaq str2(%rip), %rdi
        movl voyage_weeks_left(%rip), %esi
        call printf

        leaq str3(%rip), %rdi
        movl ship_level(%rip), %esi
        call printf

        leaq str4(%rip), %rdi
        movl ship_limes(%rip), %esi
        movl ship_max_limes(%rip), %edx
        call printf

        leaq str5(%rip), %rdi
        movl ship_mateys(%rip), %esi
        movl ship_max_mateys(%rip), %edx
        call printf

        leaq str6(%rip), %rdi
        movl ship_booty(%rip), %esi
        call printf

        leaq str7(%rip), %rdi
        movl ship_health(%rip), %esi
        movl ship_max_health(%rip), %edx
        call printf

        leaq str8(%rip), %rdi
        movl ship_dubloons(%rip), %esi
        call printf

        leaq str9(%rip), %rdi
        movl ship_cannons(%rip), %esi
        movl ship_max_cannons(%rip), %edx
        call printf

        leaq str10(%rip), %rdi
        movl voyage_resupply_time(%rip), %esi
        call printf

        # Calls RNG function to get random number between 0 and 8 (inclusive), stores result in ebx
        movl $9, %edi
        call vgrand
        movl %eax, %ebx

        # Compares RNG result and jumps
        cmpl %0, %ebx 
        je .Lvoyage.becalmed

        cmpl %1, %ebx 
        je .Lvoyage.becalmed

        cmpl %2, %ebx 
        je .Lvoyage.storm

        cmpl %3, %ebx 
        je .Lvoyage.manowar

        cmpl %4, %ebx 
        je .Lvoyage.merchantman

        cmpl %5, %ebx 
        je .Lvoyage.merchantman

        jmp .Lvoyage.noincident             # default

        .Lvoyage.becalmed:
            incl voyage_weeks_left(%rip)
            incl voyage_resupply_time(%rip)
            leaq str11(%rip), %rdi
            call vgprint
            jmp .Lvoyage.loop.end
        .Lvoyage.storm:
            movl $50, %edi
            call vgrand
            movl %eax, -4(%rbp)             # Mateys killed

            movl %eax, %esi
            leaq ship_mateys(%rip), %rdi
            call updateStat                 # Update mateys

            movl $50, %edi
            call vgrand
            movl %eax, -8(%rbp)             # Ship damage

            movl %eax, %esi
            leaq ship_health(%rip), %rdi
            call updateStat                 # Update health

            movl $100, %edi
            call vgrand
            movl %eax, -12(%rbp)            # Booty lost

            movl %eax, %esi
            leaq ship_booty(%rip), %rdi
            call updateStat                 # Update booty

            # If vgrand returns 0, or the ship damage is greater than the ship's health, the ship sinks
            movl $100, %edi
            call vgrand
            test %eax, %eax
            jz 1f
            movl ship_health(%rip), %eax    # Retrieve damage
            test %eax, %eax
            jz 1f
            jmp 2f
            1:
                leaq str12(%rip), %rdi
                call vgprint
                movq $1, %rax
                jmp .Lvoyage.exit
            2:
                leaq str13(%rip), %rdi
                call vgprint

                leaq str14(%rip), %rdi
                movl -4(%rbp), %esi
                call printf

                leaq str15(%rip), %rdi
                movl -8(%rbp), %esi
                call printf

                leaq str16(%rip), %rdi
                movl -12(%rbp), %esi
                call printf

                jmp .Lvoyage.loop.end


        .Lvoyage.manowar:

        .Lvoyage.merchantman:

        .Lvoyage.noincident:

        .Lvoyage.loop.end:
        jmp .Lvoyage.loop
    .Lvoyage.exit:
    popq %rbx

    # Tear down local stack frame
    movq %rbp, %rsp
    popq %rbp

    ret



.size voyage, . - voyage


# The main entry point is called 'main' and not '_start' because this program is designed to run inside the C runtime environment
.globl main
.type main, @function
main:
    call vgsrand                            # Seed RNG
    .Lmain.loop:
        # Begin game
        movl $300, ship_limes(%rip)
        movl $180, ship_mateys(%rip)
        movl $0, ship_booty(%rip)
        movl $23, ship_cannons(%rip)
        movl $100, ship_health(%rip)
        movl $300, ship_dubloons(%rip)
        movl $1, ship_level(%rip)
        call updateMax
        call voyage
        
    .Lmain.exit:
    mov $0 %rax                             # return 0
    ret
.size main, . - main

.section .rodata
str0: .ascii "You are Captain John Birdman, pirate captain of the HMS Pirate Ship\n\0"

str1: .ascii "----------Week %d----------\n\0"
str2: .ascii "Weeks left: %d\n\0"
str3: .ascii "Ship level: %d\n\0"
str4: .ascii "Limes: %d/%d\n\0"
str5: .ascii "Mateys: %d/%d\n\0"
str6: .ascii "Booty: %d/%d\n\0"
str7: .ascii "Ship health: %d/%d\n\0"
str8: .ascii "Dubloons: %d\n\0"
str9: .ascii "Cannons: %d/%d\n\0"
str10: .ascii "Weeks until resupply: %d\n\0"

str11: .ascii "The HMS Pirate Ship has been becalmed!\n\0"

str12: .ascii "The HMS Pirate Ship was destroyed in a storm!\n\0"

str13: .ascii "The HMS Pirate Ship caught in a storm!\n\0"
str14: .ascii "Mateys killed: %d\n\0"
str15: .ascii "Ship damage: %d\n\0"
str16: .ascii "Booty lost: %d\n\0"

.section .data

game_state: .byte 0                         # 0 means game is active, 1 means game not active, 2 means error
return_voyage: .byte 1                      # whether or not the game is on a return voyage

.section .bss
.lcomm seed_buf, 16                         # POSIX timespec struct. tv_sec: 0-7, tv_nsec: 8-15
.lcomm voyage_weeks_left, 4                   
.lcomm voyage_current_week, 4
.lcomm voyage_resupply_time, 4

.lcomm ship_limes, 4
.lcomm ship_mateys, 4
.lcomm ship_booty, 4
.lcomm ship_cannons, 4
.lcomm ship_health, 4
.lcomm ship_dubloons, 4
.lcomm ship_level, 4

.lcomm ship_max_limes, 4
.lcomm ship_max_mateys, 4
.lcomm ship_max_booty, 4
.lcomm ship_max_cannons, 4
.lcomm ship_max_health, 4





