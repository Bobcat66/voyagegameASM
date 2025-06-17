# Macros
.set A 1103515245
.set C 12345
.extern printf                              # from the C standard library

.section .text

# void srand(void): seeds rng based on system clock
.type srand, @function
srand:
    mov $288, %rax                          # syscall clock_gettime
    mov $0, %rdi                            # CLOCK_REALTIME
    lea seed_buf(%rip) %rdi
    syscall
    ret
.size srand, . - srand    

# int rand(int): generates a random integer between 0 and arg0
.type rand, @function
rand:
    movl seed_buf+4(%rip), %eax             # Uses the lower 4 bytes of tv_sec as the seed
    imull $A, %eax, %eax,
    addl $C, %eax
    xor %edx, %edx
    idivl %edi
    movl %edx %eax
    ret
.size rand, . - rand

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
    movl %eax, ship_max_mateys(%rip)

    ret
.size updateMax, . - updateMax

# 
.type voyage, @function
voyage:
    movl %18, voyage_weeks_left(%rip)
    movl %0, voyage_current_week(%rip)
    movl %3, voyage_resupply_time(%rip)
    .Lgameloop:
        lea str1(%rip), %rdi
        movl voyage_current_week(%rip), %rsi
        call printf

        lea str2(%rip), %rdi
        movl voyage_weeks_left(%rip), %rsi
        call printf

        lea str3(%rip), %rdi
        movl ship_level(%rip), %rsi
        call printf

        lea str4(%rip), %rdi
        movl ship_limes(%rip), %rsi
        movl ship_max_limes(%rip), %rdx
        call printf

        lea str5(%rip), %rdi
        movl ship_mateys(%rip), %rsi
        movl ship_max_mateys(%rip), %rdx
        call printf

        lea str6(%rip), %rdi
        movl ship_booty(%rip), %rsi
        call printf

        lea str7(%rip), %rdi
        movl ship_health(%rip), %rsi
        movl ship_max_heath(%rip), %rdx
        call printf

        lea str8(%rip), %rdi
        movl ship_dubloons(%rip), %rsi
        call printf

        lea str9(%rip), %rdi
        movl ship_cannons(%rip), %rsi
        movl ship_max_cannons(%rip), %rdx
        call printf

        lea str10(%rip), %rdi
        movl voyage_resupply_time(%rip), %rsi
        call printf


.size voyage, . - voyage


# The main entry point is called 'main' and not '_start' because this program is designed to run inside the C runtime
.globl main
.type main, @function
main:
    call srand                              # Seed RNG
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
str5: "Mateys: %d/%d\n\0"
str6: "Booty: %d/%d\n\0"
str7: "Ship health: %d/%d\n\0"
str8: "Dubloons: %d\n\0"
str9: "Cannons: %d/%d\n\0"
str10: "Weeks until resupply: %d\n\0"

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
.lcomm ship_max_heath, 4





