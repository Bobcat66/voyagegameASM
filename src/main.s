.extern printf                              # from the C standard library
.extern vgsrand                             # from vglib
.extern vgrand                              # from vglib
.extern vgrandsd                            # from vglib
.section .text                              # from vglib

/*
 * void updateMax(void)
 *
 * updates maximums based on level
 */
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

/* 
 * int updateStat(int *stat, int delta)
 *
 * returns a copy of the updated stat's value. 
 * Stat will be set at zero if adding 
 * the delta would make it negative
 */
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

/* 
 * int updateStatWithMax(int *stat, int *max, int delta)
 *
 * returns a copy of the updated stat's value. Stat will 
 * be set at zero if adding the delta would make it negative, 
 * and will be set to max if adding delta would make it higher than max
 */
.type updateStatWithMax, @function
updateStatWithMax:
    movl (%rdi), %eax
    addl %edx, %eax
    movl (%rsi), %esi                       # Dereference pointer at rsi and store value in esi

    cmpl %esi, %eax
    jg .LupdateStatWithMax.overflow         # Jump to overflow case if stat is greater than max

    cmpl $1, %eax
    jge .LupdateStatWithMax.exit            # Jumps to exit if result is positive
    jmp .LupdateStatWithMax.underflow       # Otherwise, jump to underflow case

    .LupdateStatWithMax.overflow:
        movl %esi, %eax                     # Sets stat to max if overflow
        jmp .LupdateStatWithMax.exit               
    .LupdateStatWithMax.underflow:
        xorl %eax, %eax                     # Sets stat to zero if underflow
        jmp .LupdateStatWithMax.exit
    
    .LupdateStatWithMax.exit:
    movl %eax, (%rdi)
    ret
.size updateStatWithMax, . - updateStatWithMax

/*
 * int purchase(int* stat, int* statmax, int pricePerUnit)
 */
.type purchase, @function
purchase:
    
.size purchase, . - purchase

.type resupply, @function
resupply:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp                          # Allocates 64 bytes of stack space  

    .Lresupply.loop:
        movq $0, %rax                       # syscall read (0)
        movq $0, %rdi                       # file descriptor stdin (0)
        lea -4(%rbp), %rsi                  # buffer is a pointer to a local variable
        movq $1, %rdx                       # read 1 byte
        syscall
        
        movb -4(%rbp), %al
        
        cmpb $49, %al
        je .Lresupply.buylimes

        cmpb $50, %al
        je .Lresupply.recruitmateys

        cmpb $51, %al
        je .Lresupply.repairship

        cmpb $52, %al
        je .Lresupply.buycannons

        cmpb $53, %al
        je .Lresupply.upgradeship

        cmpb $120, %al
        je .Lresupply.exit

        .Lresupply.buylimes:

        .Lresupply.recruitmateys:

        .Lresupply.repairship:

        .Lresupply.buycannons:

        .Lresupply.upgradeship:


    .Lresupply.exit:
    # Tear down local stack frame
    movq %rbp, %rsp
    popq %rbp

    ret
.size resupply, . - resupply

# -4(%rbp): Mateys lost
# -8(%rbp): Damage taken
# -12(%rbp): Booty lost / reward
# -20(%rbp): win probability (double)
# -24(%rbp): input buffer (char)
.type voyage, @function
voyage:

    /* Sets up local stack frame */
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp                          # Allocates 64 bytes of stack space    

    lea str0(%rip), %rdi
    xorq %rax, %rax
    call printf

    movl $18, voyage_weeks_left(%rip)
    movl $0, voyage_current_week(%rip)
    movl $3, voyage_resupply_time(%rip)
    .Lvoyage.loop:
        # TODO: Add resupply check here
        movl voyage_resupply_time(%rip), %eax
        test %eax, %eax
        # Jump to a label or call a function or something here

        # No resupply, continue on from here
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
        cmpl $0, %eax 
        je .Lvoyage.becalmed

        cmpl $1, %eax 
        je .Lvoyage.becalmed

        cmpl $2, %eax 
        je .Lvoyage.storm

        cmpl $3, %eax 
        je .Lvoyage.warship

        cmpl $4, %eax 
        je .Lvoyage.merchantman

        cmpl $5, %eax 
        je .Lvoyage.merchantman

        jmp .Lvoyage.loop.end               # default

        # ebx no longer needs to be preserved after this point
        .Lvoyage.becalmed:

            incl voyage_weeks_left(%rip)

            incl voyage_resupply_time(%rip)

            lea str1(%rip), %rdi
            xorq %rax, %rax
            call printf

            jmp .Lvoyage.loop.end
        .Lvoyage.storm:
            movl $50, %edi
            call vgrand
            movl %eax, -4(%rbp)             # Mateys killed

            movl %eax, %esi
            lea ship_mateys(%rip), %rdi
            negl %esi
            call updateStat                 # Update mateys

            movl $50, %edi
            call vgrand
            movl %eax, -8(%rbp)             # Ship damage

            movl %eax, %esi
            lea ship_health(%rip), %rdi
            negl %esi
            call updateStat                 # Update health

            movl $100, %edi
            call vgrand
            movl %eax, -12(%rbp)            # Booty lost

            movl %eax, %esi
            lea ship_booty(%rip), %rdi
            negl %esi
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
                xorq %rax, %rax
                call printf

                movq $1, %rax               # 1 denotes that the game is over
                jmp .Lvoyage.exit

            2:
                lea str13(%rip), %rdi
                xorq %rax, %rax
                call printf

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
            jnz .Lvoyage.warship.frigate

            .Lvoyage.warship.manowar:
                lea manowarName(%rip), %rdi
                movq %rdi, -8(%rbp)         # Warship Name: "Man-o-War"
                movl $30000, -12(%rbp)      # Warship reward: 30000 dubloons
                movsd double_002(%rip), %xmm1          # Warship win factor: 0.02
                jmp .Lvoyage.warship.event

            .Lvoyage.warship.frigate:
                lea frigateName(%rip), %rdi
                movq %rdi, -8(%rbp)         # Warship Name: "Frigate"
                movl $5000, -12(%rbp)       # Warship reward: 5000 dubloons
                movsd double_01(%rip), %xmm1           # Warship win factor: 0.1
                jmp .Lvoyage.warship.event

            .Lvoyage.warship.event:
            # Calculate fight win chance (technically a lie, as damage can also cause a loss)
            # fight win chance = 1 - 1/((ship_cannons * xmm1) + 1)
            cvtsi2sd ship_cannons(%rip), %xmm0
            mulsd %xmm1, %xmm0
            addsd double_01(%rip), %xmm0
            movsd double_01(%rip), %xmm1
            divsd %xmm0, %xmm1          
            movsd double_01(%rip), %xmm0
            subsd %xmm1, %xmm0

            movsd %xmm0, -20(%rbp)          # stores fight win chance in local memory

            # Print messages to player
            lea fstr13(%rip), %rdi
            movq -8(%rbp), %rsi
            xorq %rax, %rax
            call printf

            lea fstr14(%rip), %rdi
            movl ship_cannons(%rip), %esi
            xorq %rax, %rax
            call printf

            movsd -20(%rbp), %xmm0
            movsd double_100(%rip), %xmm1
            mulsd %xmm1, %xmm0
            lea fstr15(%rip), %rdi
            movb $1, %al
            call printf

            lea str6(%rip), %rdi
            xorq %rax, %rax
            call printf

            lea str7(%rip), %rdi
            xorq %rax, %rax
            call printf

            lea str8(%rip), %rdi
            xorq %rax, %rax
            call printf

            lea str9(%rip), %rdi
            xorq %rax, %rax
            call printf

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

            movq $2, %rax                 
            jmp .Lvoyage.exit               # Error on unrecognized input

            # -24(%rbp) does not need to be preserved after this point
            .Lvoyage.warship.fight:
                call vgrandsd               # stores random double between 0 and 1 in xmm0
                # xmm0 must be LESS THAN the win probability to win
                movsd -20(%rbp), %xmm1
                ucomisd %xmm0, %xmm1  # compares xmm0 to win chance
                ja 1f                       
                jb 2f
                1:                          # Warship wins
                    lea str10(%rip), %rdi
                    xorq %rax, %rax
                    call printf
                    movq $1, %rax
                    jmp .Lvoyage.exit
                2:                          # Player wins
                    movl $40, %edi
                    call vgrand
                    movl %eax, -24(%rbp)    # Mateys lost
                    movl %eax, %esi
                    negl %esi
                    lea ship_mateys(%rip), %rdi
                    call updateStat         # Update

                    movl $30, %edi
                    call vgrand
                    movl %eax, -28(%rbp)    # Damage taken
                    movl %eax, %esi
                    negl %esi
                    lea ship_health(%rip), %rdi
                    call updateStat         # Update
                    # Ship health is stored in eax

                    or ship_mateys(%rip), %eax
                    jz 1f                   # If either mateys or health are 0, jump to pyrrhic victory
                    jmp 2f                  # Otherwise, jump to victory

                    1:                      # Pyrrhic victory
                        lea fstr16(%rip), %rdi
                        movq -8(%rbp), %rsi
                        xorq %rax, %rax
                        call printf
                        movq $1, %rax
                        jmp .Lvoyage.exit
                    2:                      # Victory
                        lea fstr17(%rip), %rdi
                        movq -8(%rbp), %rsi
                        xorq %rax, %rax
                        call printf

                        lea fstr10(%rip), %rdi
                        movl -24(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea fstr11(%rip), %rdi
                        movl -28(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea fstr18(%rip), %rdi
                        movl -12(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea ship_dubloons(%rip), %rdi
                        movl -12(%rbp), %esi
                        call updateStat
                        jmp .Lvoyage.loop.end

            .Lvoyage.warship.flee:
                call vgrandsd               # stores random double between 0 and 1 in xmm0
                # xmm0 must be LESS THAN the win probability to win
                movsd double_90(%rip), %xmm1
                ucomisd %xmm0, %xmm1        # compares xmm0 to win chance
                ja 1f                       
                jmp 2f
                1:                          # Warship wins
                    movl $90, %edi
                    call vgrand
                    movl %eax, -24(%rbp)    # Mateys lost
                    movl %eax, %esi
                    negl %esi
                    lea ship_mateys(%rip), %rdi
                    call updateStat         # Update

                    movl $80, %edi
                    call vgrand
                    movl %eax, -28(%rbp)    # Damage taken
                    movl %eax, %esi
                    negl %esi
                    lea ship_health(%rip), %rdi
                    call updateStat         # Update
                    # Ship health is stored in eax

                    or ship_mateys(%rip), %eax
                    jz 1f
                    jmp 2f
                    
                    1:                      # HMS Pirate Ship sinks
                        lea fstr22(%rip), %rdi
                        movq -8(%rbp), %rsi
                        xorq %rax, %rax
                        call printf

                        movq $1, %rax
                        jmp .Lvoyage.exit
                    2:                      # HMS Pirate Ship survives
                        lea fstr21(%rip), %rdi
                        movq -8(%rbp), %rsi
                        xorq %rax, %rax
                        call printf

                        lea fstr10(%rip), %rdi
                        movl -24(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea fstr11(%rip), %rdi
                        movl -28(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        jmp .Lvoyage.loop.end

                2:                          # Player wins
                    lea fstr20(%rip), %rdi
                    movq -8(%rbp), %rsi
                    xorq %rax, %rax
                    call printf

                    jmp .Lvoyage.loop.end

        .Lvoyage.merchantman:
            # Calculate fight win chance (technically a lie, as damage can also cause a loss)
            # fight win chance = 1 - 1/((ship_cannons * 0.3) + 1)
            movsd double_03(%rip), %xmm1
            cvtsi2sd ship_cannons(%rip), %xmm0
            mulsd %xmm1, %xmm0
            addsd double_1(%rip), %xmm0
            movsd double_1(%rip), %xmm1
            divsd %xmm0, %xmm1          
            movsd double_1(%rip), %xmm0
            subsd %xmm1, %xmm0

            movsd %xmm0, -20(%rbp)          # stores fight win chance in local memory

            # Generates integer between 0 and 9 (inclusive), stores in rax
            movl $10, %edi
            call vgrand

            # Stores loot_table[rax] in -12(%rbp), this is how much loot will be rewarded
            lea loot_table(%rip), %rcx
            movl (%rcx,%rax,4), %edx
            movl %edx, -12(%rbp)

            lea str11(%rip), %rdi
            xorq %rax, %rax
            call printf

            movsd -20(%rbp), %xmm0
            movsd double_100(%rip), %xmm1
            mulsd %xmm1, %xmm0
            
            lea fstr23(%rip), %rdi
            movb $1, %al
            call printf

            lea str12(%rip), %rdi
            xorq %rax, %rax
            call printf

            movq $0, %rax                   # syscall read (0)
            movq $0, %rdi                   # file descriptor stdin (0)
            lea -24(%rbp), %rsi             # buffer is a pointer to a local variable
            movq $1, %rdx                   # read 1 byte
            syscall

            movb -24(%rbp), %al             # Moves read character into al

            cmpb $121, %al
            je .Lvoyage.merchantman.attack

            cmpb $110, %al
            je .Lvoyage.loop.end

            movq $2, %rax                   # Error on unrecognized input
            jmp .Lvoyage.exit

            .Lvoyage.merchantman.attack:
                call vgrandsd               # stores random double between 0 and 1 in xmm0
                # xmm0 must be LESS THAN the win probability to win
                movsd -20(%rbp), %xmm1
                ucomisd %xmm0, %xmm1        # compares xmm0 to win chance
                ja 1f                       
                jb 2f
                1:                          # Merchantman wins
                    movl $40, %edi
                    call vgrand
                    movl %eax, -24(%rbp)    # Mateys lost
                    movl %eax, %esi
                    negl %esi
                    lea ship_mateys(%rip), %rdi
                    call updateStat         # Update

                    movl $40, %edi
                    call vgrand
                    movl %eax, -28(%rbp)    # Damage taken
                    movl %eax, %esi
                    negl %esi
                    lea ship_health(%rip), %rdi
                    call updateStat         # Update
                    # Ship health is stored in eax

                    or ship_mateys(%rip), %eax
                    jz 1f
                    jmp 2f
                    
                    1:                      # HMS Pirate Ship sinks
                        lea str14(%rip), %rdi
                        xorq %rax, %rax
                        call printf

                        movq $1, %rax
                        jmp .Lvoyage.exit
                    2:                      # HMS Pirate Ship survives
                        lea str13(%rip), %rdi
                        xorq %rax, %rax
                        call printf

                        lea fstr10(%rip), %rdi
                        movl -24(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea fstr11(%rip), %rdi
                        movl -28(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        jmp .Lvoyage.loop.end

                2:                          # Player wins
                    movl $20, %edi
                    call vgrand
                    movl %eax, -24(%rbp)    # Mateys lost
                    movl %eax, %esi
                    negl %esi
                    lea ship_mateys(%rip), %rdi
                    call updateStat         # Update

                    movl $10, %edi
                    call vgrand
                    movl %eax, -28(%rbp)    # Damage taken
                    movl %eax, %esi
                    negl %esi
                    lea ship_health(%rip), %rdi
                    call updateStat         # Update
                    # Ship health is stored in eax

                    or ship_mateys(%rip), %eax
                    jz 1f                   # If either mateys or health are 0, jump to pyrrhic victory
                    jmp 2f                  # Otherwise, jump to victory

                    1:                      # Pyrrhic victory
                        lea str16(%rip), %rdi
                        xorq %rax, %rax
                        call printf

                        movq $1, %rax
                        jmp .Lvoyage.exit
                    2:                      # Victory
                        lea str15(%rip), %rdi
                        call printf

                        lea fstr10(%rip), %rdi
                        movl -24(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea fstr11(%rip), %rdi
                        movl -28(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea fstr19(%rip), %rdi
                        movl -12(%rbp), %esi
                        xorq %rax, %rax
                        call printf

                        lea ship_booty(%rip), %rdi
                        lea ship_max_booty(%rip), %rsi
                        movl -12(%rbp), %edx
                        call updateStatWithMax
                        jmp .Lvoyage.loop.end

    .Lvoyage.loop.end:

    lea voyage_weeks_left(%rip), %rdi       # Update voyage weeks left
    movl $-1, %esi
    call updateStat

    incl voyage_current_week(%rip)          # Update voyage current week

    lea voyage_resupply_time(%rip), %rdi    # Update resupply time
    movl $-1, %esi
    call updateStat

    lea ship_limes(%rip), %rdi              # Update limes
    movl $-10, %esi
    call updateStat

    lea str17(%rip), %rdi
    xorq %rax, %rax
    call printf

    movq $0, %rax                   # syscall read (0)
    movq $0, %rdi                   # file descriptor stdin (0)
    lea -24(%rbp), %rsi             # buffer is a pointer to a local variable.
    movq $1, %rdx                   # read 1 byte. We don't actually care what it is, and it is effectively discarded
    syscall

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
    sub $8, %rsp                            # Align stack pointer on 16 bytes, as the code begins misaligned because the CRT's call to main pushes a return pointer to the stack
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
    add $8, %rsp                             # return stack pointer back to where it was originally so we can return properly
    mov $0, %rax                             # return 0
    ret
.size main, . - main

.section .rodata

str0: .ascii "You are Captain John Birdman, pirate captain of the HMS Pirate Ship\n\0"

# Weekly & supply messages
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

# General messages
fstr10: .ascii "Mateys killed: %d\n\0"
fstr11: .ascii "Ship damage: %d\n\0"
fstr12: .ascii "Booty lost: %d\n\0"
fstr18: .ascii "Dubloons pillaged: %d\n\0"
fstr19: .ascii "Booty plundered: %d\n\0"
str17: .ascii "Press [Enter] to continue.\n\0"

# Becalmed messages
str1: .ascii "The HMS Pirate Ship has been becalmed!\n\0"

# Storm messages
str2: .ascii "The HMS Pirate Ship was destroyed in a storm!\n\0"
str3: .ascii "The HMS Pirate Ship caught in a storm!\n\0"

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
str10: .ascii "DEFEAT: The HMS Pirate Ship has been sent to Davy Jones' Locker!\n\0"

fstr16: .ascii "PYRRHIC VICTORY: Although you sank the %s, it was able to take you down with it!\n\0"
fstr17: .ascii "VICTORY: You successfully defeated the %s and took it as your prize!\n\0"
fstr20: .ascii "VICTORY: The HMS Pirate Ship successfully outran the %s!\n\0"
fstr21: .ascii "DEFEAT: The %s caught up to the HMS Pirate Ship!\n\0"
fstr22: .ascii "DEFEAT: The %s caught up to the HMS Pirate Ship, and sent her to Davy Jones' Locker!\n\0"

# Merchantman encounter
str11: .ascii "You see a merchantman!\n\0"

fstr23: .ascii "Chance of success if you attack: %.2f%%\n\0"

str12: .ascii "Do you want to attack? [y/n]:\n\0"
str13: .ascii "DEFEAT: The merchantman successfully defended against you!\n\0"
str14: .ascii "DEFEAT: The merchantman sent the HMS Pirate Ship to Dany Jones' Locker!\n\0"
str15: .ascii "VICTORY: You successfully attacked the merchantman and plundered all its booty!\n\0"
str16: .ascii "PYRRHIC VICTORY: You successfully attacked the merchantman, but the HMS Pirate Ship took too much damage!\n\0"

loot_table: .long 500, 500, 500, 500, 600, 600, 600, 700, 700, 1000

# Ship names
manowarName: .ascii "Man-o-War\0"
frigateName: .ascii "Frigate\0"

# Miscellaneous floating point values
double_002: .double 0.02
double_01:  .double 0.1
double_03:  .double 0.3
double_1:   .double 1.0
double_90:  .double 90.0
double_100: .double 100.0

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





