.extern printf                              # from the C standard library
.extern scanf                               # from the C standard library
.extern vgsrand
.extern vgrand
.extern vgrandsd
.extern vgstrlen
.extern vgprint
.section .text

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
    subq $64, %rsp                          # Allocates 64 bytes of stack space    

    lea str0(%rip), %rdi
    call vgprint

    movl %18, voyage_weeks_left(%rip)
    movl %0, voyage_current_week(%rip)
    movl %3, voyage_resupply_time(%rip)
    .Lvoyage.loop:
        # Prints game data for player
        lea fstr0(%rip), %rdi
        movl voyage_current_week(%rip), %esi
        xorq %rax, %rax
        call printf

        lea fstr1(%rip), %rdi
        movl voyage_weeks_left(%rip), %esi
        xorq %rax, %rax
        call printf

        lea fstr2(%rip), %rdi
        movl ship_level(%rip), %esi
        xorq %rax, %rax
        call printf

        lea fstr3(%rip), %rdi
        movl ship_limes(%rip), %esi
        movl ship_max_limes(%rip), %edx
        xorq %rax, %rax
        call printf

        lea fstr4(%rip), %rdi
        movl ship_mateys(%rip), %esi
        movl ship_max_mateys(%rip), %edx
        xorq %rax, %rax
        call printf

        lea fstr5(%rip), %rdi
        movl ship_booty(%rip), %esi
        xorq %rax, %rax
        call printf

        lea fstr6(%rip), %rdi
        movl ship_health(%rip), %esi
        movl ship_max_health(%rip), %edx
        xorq %rax, %rax
        call printf

        lea fstr7(%rip), %rdi
        movl ship_dubloons(%rip), %esi
        xorq %rax, %rax
        call printf

        lea fstr8(%rip), %rdi
        movl ship_cannons(%rip), %esi
        movl ship_max_cannons(%rip), %edx
        xorq %rax, %rax
        call printf

        lea fstr9(%rip), %rdi
        movl voyage_resupply_time(%rip), %esi
        xorq %rax, %rax
        call printf

        # Calls RNG function to get random number between 0 and 8 (inclusive), stores result in eax
        movl $9, %edi
        call vgrand

        # Compares RNG result and jumps
        cmpl %0, %eax 
        je .Lvoyage.becalmed

        cmpl %1, %eax 
        je .Lvoyage.becalmed

        cmpl %2, %eax 
        je .Lvoyage.storm

        cmpl %3, %eax 
        je .Lvoyage.warship

        cmpl %4, %eax 
        je .Lvoyage.merchantman

        cmpl %5, %eax 
        je .Lvoyage.merchantman

        jmp .Lvoyage.noincident             # default

        # ebx no longer needs to be preserved after this point
        .Lvoyage.becalmed:
            incl voyage_weeks_left(%rip)
            incl voyage_resupply_time(%rip)
            lea str1(%rip), %rdi
            call vgprint
            jmp .Lvoyage.loop.end
        .Lvoyage.storm:
            movl $50, %edi
            call vgrand
            movl %eax, -4(%rbp)             # Mateys killed

            movl %eax, %esi
            lea ship_mateys(%rip), %rdi
            call updateStat                 # Update mateys

            movl $50, %edi
            call vgrand
            movl %eax, -8(%rbp)             # Ship damage

            movl %eax, %esi
            lea ship_health(%rip), %rdi
            call updateStat                 # Update health

            movl $100, %edi
            call vgrand
            movl %eax, -12(%rbp)            # Booty lost

            movl %eax, %esi
            lea ship_booty(%rip), %rdi
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
                lea str12(%rip), %rdi
                call vgprint
                movq $1, %rax               # 1 denotes that the game is over
                jmp .Lvoyage.exit
            2:
                lea str13(%rip), %rdi
                call vgprint

                lea str14(%rip), %rdi
                movl -4(%rbp), %esi
                xorq %rax, %rax
                call printf

                lea str15(%rip), %rdi
                movl -8(%rbp), %esi
                xorq %rax, %rax
                call printf

                lea str16(%rip), %rdi
                movl -12(%rbp), %esi
                xorq %rax, %rax
                call printf

                jmp .Lvoyage.loop.end


        .Lvoyage.warship:
            movl $2, %edi
            call vgrand
            test %eax, %eax
            jz .Lvoyage.warship.manowar
            jnz .Lvoyage.warship.manowar

            .Lvoyage.warship.manowar:
                lea manowarName(%rip), %rdi
                movq %rdi, -8(%rbp)         # Warship Name: "Man-o-War"
                movl $30000, -12(%rbp)      # Warship reward: 30000 dubloons
                movsd $0.02, %xmm1          # Warship win factor: 0.02
                jmp .Lvoyage.warship.event

            .Lvoyage.warship.frigate:
                lea manowarName(%rip), %rdi
                movq %rdi, -8(%rbp)         # Warship Name: "Frigate"
                movl $5000, -12(%rbp)       # Warship reward: 5000 dubloons
                movsd $0.1, %xmm1           # Warship win factor: 0.1
                jmp .Lvoyage.warship.event

            .Lvoyage.warship.event:
            # Calculate fight win chance (technically a lie, as damage can also cause a loss)
            # fight win chance = 1 - 1/((ship_cannons * xmm1) + 1)
            cvtsi2sd ship_cannons(%rip), %xmm0
            mulsd %xmm1, %xmm0
            addsd $1.0, %xmm0
            movsd $1.0, %xmm1
            divsd %xmm0, %xmm1          
            movsd $1.0, %xmm0
            subsd %xmm1, %xmm0

            movsd %xmm0, -20(%rsp)          # stores fight win chance in local memory

            # Print messages to player
            lea fstr13(%rip), %rdi
            movq -8(%rbp), %rsi
            xorq %rax, %rax
            call printf

            lea fstr14(%rip), %rdi
            movl ship_cannons(%rip), %esi
            xorq %rax, %rax
            call printf

            movsd -20(%rsp), %xmm0
            mulsd $100, %xmm0
            lea fstr15(%rip), %rdi
            movq $1, %rax
            call printf

            lea str6(%rip), %rdi
            call vgprint

            lea str7(%rip), %rdi
            call vgprint

            lea str8(%rip), %rdi
            call vgprint

            lea str9(%rip), %rdi
            call vgprint

            movq $0, %rax                   # syscall read (0)
            movq $0, %rdi                   # file descriptor stdin (0)
            lea -24(%rbp), %rsi             # buffer is a pointer to a local variable
            movq $1, %rdx                   # read 1 byte
            syscall

            movb -24(%rbp), %al             # moves byte into al

            cmpb $49, %al
            je .Lvoyage.warship.fight       # checks if user typed '1'

            cmpb $50, %al                   
            je .Lvoyage.warship.flee        # checks if user typed '2'

            # -24-20(%rbp) does not need to be preserved after this point
            .Lvoyage.warship.fight:
                call vgrandsd               # stores random double between 0 and 1 in xmm0
                # xmm0 must be LESS THAN the win probability to win
                ucomisd %xmm0, -20(%rbp)    # compares xmm0 to win chance
                ja 1f                       
                jb 2f
                1:                          # Warship wins
                    lea fstr16(%rip), %rdi
                    movq -8(%rbp), %rsp
                    xorq %rax, %rax
                    call printf
                    movq $1, %rax
                    jmp .Lvoyage.exit
                2:                          # Player wins
                    movl $40, %edi
                    call vgrand
                    movl %eax, -24(%rbp)    # Mateys lost

                    movl $30, %edi
                    call vgrand
                    movl %eax, -28(%rbp)    # Damage taken



                
            .Lvoyage.warship.flee:












        .Lvoyage.merchantman:
    
        .Lvoyage.noincident:

    .Lvoyage.loop.end:
    jmp .Lvoyage.loop

    .Lvoyage.exit:

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

dfstring: .ascii "%lf\0"

# Week messages
fstr0: .ascii "----------Week %d----------\n\0"
fstr1: .ascii "Weeks left: %d\n\0"
fstr2: .ascii "Ship level: %d\n\0"
fstr3: .ascii "Limes: %d/%d\n\0"
fstr4: .ascii "Mateys: %d/%d\n\0"
fstr5: .ascii "Booty: %d/%d\n\0"
fstr6: .ascii "Ship health: %d/%d\n\0"
fstr7: .ascii "Dubloons: %d\n\0"
fstr8: .ascii "Cannons: %d/%d\n\0"
fstr9: .ascii "Weeks until resupply: %d\n\0"

# Becalmed messages
str1: .ascii "The HMS Pirate Ship has been becalmed!\n\0"

# Storm messages
str2: .ascii "The HMS Pirate Ship was destroyed in a storm!\n\0"

str3: .ascii "The HMS Pirate Ship caught in a storm!\n\0"
fstr10: .ascii "Mateys killed: %d\n\0"
fstr11: .ascii "Ship damage: %d\n\0"
fstr12: .ascii "Booty lost: %d\n\0"

# Warship encounter messages
str4: .ascii "Man-o-War\n\0"
str5: .ascii "Frigate\n\0"

fstr13: .ascii "You are being attacked by a %s\n\0"
fstr14: .ascii "Your cannons: %d\n\0"
fstr15: .ascii "Chance of success if you fight: %.2f%%\n\0"
str6: .ascii "Chance of success if you flee: 90.00%\n\0"
str7: .ascii "1 to fight\n\0"
str8: .ascii "2 to flee\n\0"
str9: .ascii "Select one: \0"
fstr16: .ascii "DEFEAT: The HMS Pirate Ship has been sent to Davy Jones' Locker!\n\0"
fstr17: .ascii "PYRRHIC VICTORY: Although you sank the %s, it was able to take you down with it!"
fstr18: .ascii "VICTORY: You successfully defeated the %s and took its cargo as your prize!"

.section .data

game_state: .byte 0                         # 0 means game is active, 1 means game not active, 2 means error
return_voyage: .byte 1                      # whether or not the game is on a return voyage

.section .bss
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





