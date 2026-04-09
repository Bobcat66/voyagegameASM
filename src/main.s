.extern printf                              # from the C standard library
.extern atoi                                # from the C standard library
.extern fgets_stdin                         # from vglib
.extern randint                             # from vglib
.extern randfp                              # from vglib
.extern srand_vg                            # from vglib
.section .text                     

/*
 * void updateMax(void)
 *
 * updates maximums based on level
 */
.type updateMax, @function
updateMax:
    movl ship_level(%rip), %eax             # update max limes
    imull $50, %eax, %eax
    addl $250, %eax
    movl %eax, ship_max_limes(%rip)

    movl ship_level(%rip), %eax             # update max mateys
    imull $15, %eax, %eax
    addl $165, %eax
    movl %eax, ship_max_mateys(%rip)

    movl ship_level(%rip), %eax             # update max booty
    imull $500, %eax, %eax
    addl $2500, %eax
    movl %eax, ship_max_booty(%rip)

    movl ship_level(%rip), %eax             # update max cannons
    imull $5, %eax, %eax
    addl $18, %eax
    movl %eax, ship_max_cannons(%rip)

    movl ship_level(%rip), %eax             # update max health
    imull $30, %eax, %eax
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
 * void printShipData()
 *
 * returns a copy of the updated stat's value. 
 * Stat will be set at zero if adding 
 * the delta would make it negative
 */
.type printShipData, @function
printShipData:
    lea levelShipDataStr(%rip), %rdi
    movl ship_level(%rip), %esi
    xorq %rax, %rax
    call printf

    lea limesShipDataStr(%rip), %rdi
    movl ship_limes(%rip), %esi
    movl ship_max_limes(%rip), %edx
    xorq %rax, %rax
    call printf

    lea mateysShipDataStr(%rip), %rdi
    movl ship_mateys(%rip), %esi
    movl ship_max_mateys(%rip), %edx
    xorq %rax, %rax
    call printf

    lea bootyShipDataStr(%rip), %rdi
    movl ship_booty(%rip), %esi
    movl ship_max_booty(%rip), %edx
    xorq %rax, %rax
    call printf

    lea healthShipDataStr(%rip), %rdi
    movl ship_health(%rip), %esi
    movl ship_max_health(%rip), %edx
    xorq %rax, %rax
    call printf

    lea dubloonsShipDataStr(%rip), %rdi
    movl ship_dubloons(%rip), %esi
    xorq %rax, %rax
    call printf

    lea cannonsShipDataStr(%rip), %rdi
    movl ship_cannons(%rip), %esi
    movl ship_max_cannons(%rip), %edx
    xorq %rax, %rax
    call printf
.size printShipData, . - printShipData

/* 
 * int updateStatWithMax(int *stat, int *max, int delta)
 *
 * returns a copy of the updated stat's value. Stat will 
 * be set at zero if adding the delta would make it negative, 
 * and will be set to max if adding delta would make it higher than max. Maybe not necessary?
 */
.type updateStatWithMax, @function
updateStatWithMax:
    movl (%rdi), %eax                       # Dereference pointer at rdi and store value in eax
    addl %edx, %eax
    movl (%rsi), %esi                       # Dereference pointer at rsi and store value in esi

    cmpl %esi, %eax
    jg .LupdateStatWithMax.overflow         # Jump to overflow case if stat is greater than max

    cmpl $1, %eax
    jge .LupdateStatWithMax.exit            # Jumps to exit if result is positive
    jmp .LupdateStatWithMax.underflow       # Otherwise, jump to underflow case

.LupdateStatWithMax.overflow:
    movl %esi, %eax                         # Sets stat to max if overflow
    jmp .LupdateStatWithMax.exit  

.LupdateStatWithMax.underflow:
    xorl %eax, %eax                         # Sets stat to zero if underflow
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
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp                          # Allocates 64 bytes of stack space

    movq %rdi, -8(%rbp)                     # Stores pointer to stat in local memory
    movq %rsi, -16(%rbp)                    # Stores pointer to statmax in local memory
    movl %edx, -20(%rbp)                    # Stores pricePerUnit in local memory

    lea purchasePrompt(%rip), %rdi          # Print purchase prompt and get user input
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin

    lea char_buf(%rip), %rdi                # Calculate the actual quantity that is being purchased
    call atoi
    movl %eax, %edi
    movq -8(%rbp), %r10
    addl (%r10), %edi                       # Calculate quantity after purchase
    movq -16(%rbp), %r11
    cmp %edi, (%r11)                        # Compare quantity to stat max
    jb .Lpurchase.aboveMax                  # Jump to error case if quantity is greater than stat max

    movl %eax, %edi                         # edi no longer needs to be preserved after this point
    imull -20(%rbp), %edi                   # Calculate total price of purchase

    cmp %edi, ship_dubloons(%rip)           # Compare price to player's dubloons
    jb .Lpurchase.tooExpensive              # Jump to error case if price is greater than player's dubloons

    movl %eax, -24(%rbp)                    # Stores quantity being purchased in local memory
    movl %edi, -28(%rbp)                    # Stores total price of purchase in local memory
    
    lea confirmPurchaseStr(%rip), %rdi
    movl -24(%rbp), %esi
    movl -28(%rbp), %edx
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin

    movb char_buf(%rip), %al                # Fuck it we ball
    cmpb $121, %al                          # Checks if user input is 'y'
    je .Lpurchase.confirmed
    cmpb $110, %al                          # Checks if user input is 'n'
    je .Lpurchase.exit

.Lpurchase.confirmed:
    movq -8(%rbp), %rdi
    movl -24(%rbp), %esi
    call updateStat

    lea ship_dubloons(%rip), %rdi
    movl -28(%rbp), %esi
    negl %esi
    call updateStat
    jmp .Lpurchase.exit

.Lpurchase.tooExpensive:
    lea tooExpensivePurchaseStr(%rip), %rdi
    xorq %rax, %rax
    call printf
    jmp .Lpurchase.exit

.Lpurchase.aboveMax:
    lea aboveMaxPurchaseStr(%rip), %rdi
    xorq %rax, %rax
    call printf
    jmp .Lpurchase.exit

.Lpurchase.exit:
    # Tear down local stack frame
    movq %rbp, %rsp
    popq %rbp

    ret
.size purchase, . - purchase

.type resupply, @function
resupply:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp                          # Allocates 64 bytes of stack space  

.Lresupply.loop:

    lea resupplyPrompt(%rip), %rdi
    xorq %rax, %rax
    call printf
    
    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin
    movb char_buf(%rip), %al                # Fuck it we ball
    
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
    lea ship_limes(%rip), %rdi
    lea ship_max_limes(%rip), %rsi
    movl $1, %edx
    call purchase
    jmp .Lresupply.loop.end

.Lresupply.recruitmateys:
    lea ship_mateys(%rip), %rdi
    lea ship_max_mateys(%rip), %rsi
    movl $6, %edx
    call purchase
    jmp .Lresupply.loop.end

.Lresupply.repairship:
    movl ship_max_health(%rip), %eax
    subl ship_health(%rip), %eax
    movl %eax, -4(%rbp)                     # Stores total repairs in local memory
    imull $3, %eax
    movl %eax, -8(%rbp)                     # Stores repair cost in local memory

    lea repairPrompt(%rip), %rdi
    movl %eax, %esi
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin

    movb char_buf(%rip), %al
    cmpb $121, %al                          # Checks if user input is 'y'
    je .Lresupply.repairConfirmed

    cmpb $110, %al                          # Checks if user input is 'n'
    je .Lresupply.loop.end

    # TODO: Add error case for unrecognized input

.Lresupply.repairConfirmed:
    movl -8(%rbp), %eax
    cmpl ship_dubloons(%rip), %eax
    jg 1f                                   # Jump to case if player can't afford repairs

    lea ship_dubloons(%rip), %rdi
    movl -8(%rbp), %esi
    negl %esi
    call updateStat
    lea ship_health(%rip), %rdi
    movl -4(%rbp), %esi
    call updateStat
    jmp .Lresupply.loop.end

1:
    lea notEnoughDubloonsRepairStr(%rip), %rdi
    xorq %rax, %rax
    call printf
    jmp .Lresupply.loop.end

.Lresupply.buycannons:
    lea ship_cannons(%rip), %rdi
    lea ship_max_cannons(%rip), %rsi
    movl $20, %edx
    call purchase
    jmp .Lresupply.loop.end
    
.Lresupply.upgradeship:
    movl $5000, %eax
    movl ship_level(%rip), %edi
    imull $2000, %edi, %edi
    addl %edi, %eax
    movl %eax, -4(%rbp)                     # Stores upgrade cost in local memory

    lea upgradePrompt(%rip), %rdi
    movl ship_level(%rip), %esi
    incl %esi
    movl -4(%rbp), %edx
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin

    movb char_buf(%rip), %al
    cmpb $121, %al                          # Checks if user input is 'y'
    je 1f
    cmpb $110, %al
    je .Lresupply.loop

# TODO: Add error case for unrecognized input

1:
    movl -4(%rbp), %eax
    cmpl ship_dubloons(%rip), %eax
    jg 1f                                   # Jump to case if player can't afford upgrade
    jl 2f                                   # Jump to case if player can afford upgrade

1:
    lea notEnoughDubloonsUpgradeStr(%rip), %rdi
    xorq %rax, %rax
    call printf
    jmp .Lresupply.loop.end

2:
    lea ship_dubloons(%rip), %rdi
    movl -4(%rbp), %esi
    negl %esi
    call updateStat
    lea ship_level(%rip), %rdi
    movl $1, %esi
    call updateStat
    call updateMax
    jmp .Lresupply.loop.end

.Lresupply.loop.end:
    call printShipData
    jmp .Lresupply.loop


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
    movl voyage_weeks_left(%rip), %eax
    test %eax, %eax
    movq $0, %rax                           # 0 denotes that the game is not over
    jz .Lvoyage.exit

    movl ship_limes(%rip), %eax             # Not enough limes results in scurvy, which causes the player to lose mateys every week until they get more limes. If the player has no mateys left, the game is over.
    test %eax, %eax
    jnz 1f

    lea noLimesMessage(%rip), %rdi
    xorq %rax, %rax
    call printf

    movl $20, %edi
    call randint
    movl %eax, -4(%rbp)                     # Mateys killed

    lea mateysKilledStr(%rip), %rdi
    movl -4(%rbp), %esi
    xorq %rax, %rax
    call printf

    movl -4(%rbp), %esi
    lea ship_mateys(%rip), %rdi
    negl %esi
    call updateStat                         # Update mateys

    movl ship_mateys(%rip), %eax
    test %eax, %eax
    jnz 1f

    lea mateysDeadMessage(%rip), %rdi       # All mateys dead from scurvy, game over
    xorq %rax, %rax
    call printf
    movq $1, %rax                           # 1 denotes that the game is over
    jmp .Lvoyage.exit

1:
    lea weekLabel(%rip), %rdi               # Prints game data for player. 
    movl voyage_current_week(%rip), %esi
    xorq %rax, %rax
    call printf

    lea weeksLeftStr(%rip), %rdi
    movl voyage_weeks_left(%rip), %esi
    xorq %rax, %rax
    call printf

    lea weeksUntilResupplyStr(%rip), %rdi
    movl voyage_resupply_time(%rip), %esi
    xorq %rax, %rax
    call printf

    call printShipData                      # Print ship data for player

    movl voyage_resupply_time(%rip), %eax
    test %eax, %eax
    jz .Lvoyage.resupply
    jmp .Lvoyage.noResupply

.Lvoyage.resupply:
    call resupply                           # Resupply if resupply time is 0, and reset resupply time, skip to end of loop
    addl $3, voyage_resupply_time(%rip)     # Resupply takes 3 weeks, so add 3 to resupply time
    jmp .Lvoyage.loop.end

.Lvoyage.noResupply:                        # No resupply, continue on from here

    movl $9, %edi                           # Calls RNG function to get random number between 0 and 8 (inclusive), stores result in eax
    call randint

    cmpl $0, %eax                           # Compares RNG result and jumps
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

    jmp .Lvoyage.loop.end                   # default

.Lvoyage.becalmed:                          # ebx no longer needs to be preserved after this point
    incl voyage_weeks_left(%rip)

    incl voyage_resupply_time(%rip)

    lea becalmedMessage(%rip), %rdi
    xorq %rax, %rax
    call printf

    jmp .Lvoyage.loop.end

.Lvoyage.storm:
    movl $50, %edi
    call randint
    movl %eax, -4(%rbp)                     # Mateys killed

    movl %eax, %esi
    lea ship_mateys(%rip), %rdi
    negl %esi
    call updateStat                         # Update mateys

    movl $50, %edi
    call randint
    movl %eax, -8(%rbp)                     # Ship damage

    movl %eax, %esi
    lea ship_health(%rip), %rdi
    negl %esi
    call updateStat                         # Update health

    movl $100, %edi
    call randint
    movl %eax, -12(%rbp)                    # Booty lost

    movl %eax, %esi
    lea ship_booty(%rip), %rdi
    negl %esi
    call updateStat                         # Update booty

    movl $100, %edi                         # If randint returns 0, or the ship damage is greater than the ship's health, the ship sinks
    call randint
    test %eax, %eax
    jz 1f
    movl ship_health(%rip), %eax            # Retrieve damage
    test %eax, %eax
    jz 1f
    jmp 2f

1:
    lea destroyedStormMessage(%rip), %rdi
    xorq %rax, %rax
    call printf

    movq $1, %rax                           # 1 denotes that the game is over
    jmp .Lvoyage.exit

2:
    lea caughtStormMessage(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea mateysKilledStr(%rip), %rdi
    movl -4(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea shipDamageStr(%rip), %rdi
    movl -8(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea bootyLostStr(%rip), %rdi
    movl -12(%rbp), %esi
    xorq %rax, %rax
    call printf

    jmp .Lvoyage.loop.end

.Lvoyage.warship:
    movl $10, %edi                          # Generates integer between 0 and 9 (inclusive), stores in rax
    call randint

    lea loot_table(%rip), %rcx              # Stores loot_table[rax] in -12(%rbp), this is how much loot will be rewarded
    movl (%rcx,%rax,4), %edx
    movl %edx, -12(%rbp)

    movl $2, %edi
    call randint
    test %eax, %eax
    jz .Lvoyage.warship.manowar
    jnz .Lvoyage.warship.frigate

.Lvoyage.warship.manowar:
    lea manowarName(%rip), %rdi
    movq %rdi, -8(%rbp)                     # Warship Name: "Man-o-War"
    movsd double_002(%rip), %xmm1           # Warship win factor: 0.02
    jmp .Lvoyage.warship.event

.Lvoyage.warship.frigate:
    lea frigateName(%rip), %rdi
    movq %rdi, -8(%rbp)                     # Warship Name: "Frigate"
    movsd double_01(%rip), %xmm1            # Warship win factor: 0.1
    jmp .Lvoyage.warship.event

.Lvoyage.warship.event:
    cvtsi2sd ship_cannons(%rip), %xmm0      # Calculate fight win chance (technically a lie, as damage can also cause a loss)
    mulsd %xmm1, %xmm0                      # fight win chance = 1 - 1/((ship_cannons * xmm1) + 1)
    addsd double_1(%rip), %xmm0
    movsd double_1(%rip), %xmm1
    divsd %xmm0, %xmm1          
    movsd double_1(%rip), %xmm0
    subsd %xmm1, %xmm0

    movsd %xmm0, -20(%rbp)                  # stores fight win chance in local memory

    lea attackAnnounceStr(%rip), %rdi       # Print messages to player
    movq -8(%rbp), %rsi
    xorq %rax, %rax
    call printf

    lea cannonNumStr(%rip), %rdi
    movl ship_cannons(%rip), %esi
    xorq %rax, %rax
    call printf

    movsd -20(%rbp), %xmm0
    movsd double_100(%rip), %xmm1
    mulsd %xmm1, %xmm0
    lea fightChanceStr(%rip), %rdi
    movb $1, %al
    call printf

    lea flee_success_chance_90(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea to_fight(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea to_flee(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea attackPrompt(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin
    movb char_buf(%rip), %al                # Fuck it we ball

    cmpb $49, %al
    je .Lvoyage.warship.fight               # checks if user typed '1'

    cmpb $50, %al                   
    je .Lvoyage.warship.flee                # checks if user typed '2'

    movq $2, %rax                 
    jmp .Lvoyage.exit                       # Error on unrecognized input

.Lvoyage.warship.fight:
    call randfp                             # stores random double between 0 and 1 in xmm0
    movsd -20(%rbp), %xmm1                  # xmm0 must be LESS THAN the win probability for the player to win
    ucomisd %xmm0, %xmm1                    # compares xmm0 to win chance
    jb 1f                                   # win chance is less than xmm0                 
    ja 2f                                   # win chance is greater than xmm0

1:                                          # Warship wins
    lea fightDefeatStr(%rip), %rdi
    xorq %rax, %rax
    call printf
    movq $1, %rax
    jmp .Lvoyage.exit

2:                                          # Player wins
    movl $40, %edi
    call randint
    movl %eax, -24(%rbp)                    # Mateys lost
    movl %eax, %esi
    negl %esi
    lea ship_mateys(%rip), %rdi
    call updateStat                         # Update

    movl $30, %edi
    call randint
    movl %eax, -28(%rbp)                    # Damage taken
    movl %eax, %esi
    negl %esi
    lea ship_health(%rip), %rdi
    call updateStat                         # Update

    test ship_mateys(%rip), %eax            # Ship health is stored in eax
    jz 1f                                   # If either mateys or health are 0, jump to pyrrhic victory
    jmp 2f                                  # Otherwise, jump to victory

1:                                          # Pyrrhic victory
    lea pyrrhicVictoryStr(%rip), %rdi
    movq -8(%rbp), %rsi
    xorq %rax, %rax
    call printf
    movq $1, %rax
    jmp .Lvoyage.exit

2:                                          # Victory
    lea fightVictoryStr(%rip), %rdi
    movq -8(%rbp), %rsi
    xorq %rax, %rax
    call printf

    lea mateysKilledStr(%rip), %rdi
    movl -24(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea shipDamageStr(%rip), %rdi
    movl -28(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea dubloonsPillagedStr(%rip), %rdi
    movl -12(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea ship_dubloons(%rip), %rdi
    movl -12(%rbp), %esi
    call updateStat
    jmp .Lvoyage.loop.end

.Lvoyage.warship.flee:
    call randfp                             # stores random double between 0 and 1 in xmm0
    movsd double_09(%rip), %xmm1            # xmm0 must be LESS THAN the win probability to win
    ucomisd %xmm0, %xmm1                    # compares xmm0 to win chance
    jb 1f                                   # win chance is lower than xmm0        
    ja 2f                                   # win chance is higher than xmm0

1:                                          # Warship wins
    movl $90, %edi
    call randint
    movl %eax, -24(%rbp)                    # Mateys lost
    movl %eax, %esi
    negl %esi
    lea ship_mateys(%rip), %rdi
    call updateStat                         # Update

    movl $80, %edi
    call randint
    movl %eax, -28(%rbp)                    # Damage taken
    movl %eax, %esi
    negl %esi
    lea ship_health(%rip), %rdi
    call updateStat                         # Update

    test ship_mateys(%rip), %eax            # Ship health is stored in eax
    jz 3f
    jmp 4f
                    
3:                                          # HMS Pirate Ship sinks
    lea fleeMajorDefeatStr(%rip), %rdi
    movq -8(%rbp), %rsi
    xorq %rax, %rax
    call printf

    movq $1, %rax
    jmp .Lvoyage.exit

4:                                          # HMS Pirate Ship survives
    lea fleeDefeatStr(%rip), %rdi
    movq -8(%rbp), %rsi
    xorq %rax, %rax
    call printf

    lea mateysKilledStr(%rip), %rdi
    movl -24(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea shipDamageStr(%rip), %rdi
    movl -28(%rbp), %esi
    xorq %rax, %rax
    call printf

    jmp .Lvoyage.loop.end

2:                                          # Player wins
    lea fleeVictoryStr(%rip), %rdi
    movq -8(%rbp), %rsi
    xorq %rax, %rax
    call printf

    jmp .Lvoyage.loop.end

.Lvoyage.merchantman:
    movsd double_03(%rip), %xmm1            # Calculate fight win chance (technically a lie, as damage can also cause a loss)
    cvtsi2sd ship_cannons(%rip), %xmm0      # fight win chance = 1 - 1/((ship_cannons * 0.3) + 1)
    mulsd %xmm1, %xmm0
    addsd double_1(%rip), %xmm0
    movsd double_1(%rip), %xmm1
    divsd %xmm0, %xmm1          
    movsd double_1(%rip), %xmm0
    subsd %xmm1, %xmm0

    movsd %xmm0, -20(%rbp)                  # stores fight win chance in local memory

    movl $10, %edi                          # Generates integer between 0 and 9 (inclusive), stores in rax
    call randint

    lea loot_table(%rip), %rcx              # Stores loot_table[rax] in -12(%rbp), this is how much loot will be rewarded
    movl (%rcx,%rax,4), %edx
    movl %edx, -12(%rbp)

    lea merchantmanAnnouncement(%rip), %rdi
    xorq %rax, %rax
    call printf

    movsd -20(%rbp), %xmm0
    movsd double_100(%rip), %xmm1
    mulsd %xmm1, %xmm0
    
    lea successChanceStr(%rip), %rdi
    movb $1, %al
    call printf

    lea merchantmanAttackPrompt(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin
    movb char_buf(%rip), %al                # Fuck it we ball

    cmpb $121, %al
    je .Lvoyage.merchantman.attack

    cmpb $110, %al
    je .Lvoyage.loop.end

    movq $2, %rax                           # Error on unrecognized input
    jmp .Lvoyage.exit

.Lvoyage.merchantman.attack:
    call randfp                             # stores random double between 0 and 1 in xmm0
    movsd -20(%rbp), %xmm1                  # xmm0 must be LESS THAN the win probability for player to win
    ucomisd %xmm0, %xmm1                    # compares xmm0 to win chance
    jb 1f                                   # win chance is lower than xmm0                   
    ja 2f                                   # win chance is higher than xmm0

1:                                          # Merchantman wins
    movl $40, %edi
    call randint
    movl %eax, -24(%rbp)                    # Mateys lost
    movl %eax, %esi
    negl %esi
    lea ship_mateys(%rip), %rdi
    call updateStat                         # Update

    movl $40, %edi
    call randint
    movl %eax, -28(%rbp)                    # Damage taken
    movl %eax, %esi
    negl %esi
    lea ship_health(%rip), %rdi
    call updateStat                         # Update

    test ship_mateys(%rip), %eax            # Ship health is stored in eax
    jz 3f
    jmp 4f
                    
3:                                          # HMS Pirate Ship sinks
    lea majorDefeatMerchantmanStr(%rip), %rdi
    xorq %rax, %rax
    call printf

    movq $1, %rax
    jmp .Lvoyage.exit

4:                                          # HMS Pirate Ship survives
    lea defeatMerchantmanStr(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea mateysKilledStr(%rip), %rdi
    movl -24(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea shipDamageStr(%rip), %rdi
    movl -28(%rbp), %esi
    xorq %rax, %rax
    call printf

    jmp .Lvoyage.loop.end

2:                                          # Player wins
    movl $20, %edi
    call randint
    movl %eax, -24(%rbp)                    # Mateys lost
    movl %eax, %esi
    negl %esi
    lea ship_mateys(%rip), %rdi
    call updateStat                         # Update

    movl $10, %edi
    call randint
    movl %eax, -28(%rbp)                    # Damage taken
    movl %eax, %esi
    negl %esi
    lea ship_health(%rip), %rdi
    call updateStat                         # Update

    test ship_mateys(%rip), %eax            # Ship health is stored in eax
    jz 3f                                   # If either mateys or health are 0, jump to pyrrhic victory
    jmp 4f                                  # Otherwise, jump to victory

3:                                          # Pyrrhic victory
    lea pyrrhicVictoryMerchantmanStr(%rip), %rdi
    xorq %rax, %rax
    call printf

    movq $1, %rax
    jmp .Lvoyage.exit

4:                      # Victory
    lea victoryMerchantmanStr(%rip), %rdi
    call printf

    lea mateysKilledStr(%rip), %rdi
    movl -24(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea shipDamageStr(%rip), %rdi
    movl -28(%rbp), %esi
    xorq %rax, %rax
    call printf

    lea bootyPlunderedStr(%rip), %rdi
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

    lea anyKeyPrompt(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin
    movb char_buf(%rip), %al                # Fuck it we ball

    jmp .Lvoyage.loop
    
.Lvoyage.exit:
    # Tear down local stack frame
    movq %rbp, %rsp
    popq %rbp

    ret
.size voyage, . - voyage



.globl main                                 # The main entry point is called 'main' and not '_start' because this program is designed to run inside the C runtime environment
.type main, @function
main:
    sub $8, %rsp                            # Align stack pointer on 16 bytes, as the code begins misaligned because the CRT's call to main pushes a return pointer to the stack
    call srand_vg
    movl $300, ship_limes(%rip)
    movl $180, ship_mateys(%rip)
    movl $0, ship_booty(%rip)
    movl $23, ship_cannons(%rip)
    movl $100, ship_health(%rip)
    movl $300, ship_dubloons(%rip)
    movl $1, ship_level(%rip)
    call updateMax
.Lmain.loop:                                # Begin Game

    call voyage
    test %rax, %rax
    jnz .Lmain.gameOver

    movl ship_booty(%rip), %eax
    addl %eax, ship_dubloons(%rip)          # Convert booty to dubloons at end of each voyage
    movl $0, ship_booty(%rip)               # Reset booty to 0 at end of each voyage

    cmpl $1, game_state(%rip)
    je .Lmain.exit

    addl $1, voyage_counter(%rip)

    lea endgamePrompt(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea char_buf(%rip), %rdi
    movl $128, %esi
    call fgets_stdin
    movb char_buf(%rip), %al
    cmpb $121, %al
    je .Lmain.loop

    # TODO: Add error case for unrecognized input, currently any input other than 'y' will exit the game

.Lmain.gameOver:
    lea gameOverStr(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea gameOverStatsStr(%rip), %rdi
    xorq %rax, %rax
    call printf

    lea voyagesCompletedStatsStr(%rip), %rdi
    movl voyage_counter(%rip), %esi
    xorq %rax, %rax
    call printf

    lea dubloonsStatsStr(%rip), %rdi
    movl ship_dubloons(%rip), %esi
    xorq %rax, %rax
    call printf

    movl voyage_counter(%rip), %eax
    imull $2000, %eax
    addl ship_dubloons(%rip), %eax
    lea totalScoreStatsStr(%rip), %rdi
    movl %eax, %esi
    xorq %rax, %rax
    call printf

    jmp .Lmain.exit

        
.Lmain.exit:
    add $8, %rsp                             # return stack pointer back to where it was originally so we can return properly
    mov $0, %rax                             # return 0
    ret
.size main, . - main

.section .rodata

str0: .ascii "You are Captain John Birdman, pirate captain of the HMS Pirate Ship\n\0"

# Weekly & supply messages
weekLabel: .ascii "----------Week %d----------\n\0"
weeksLeftStr: .ascii "Weeks left: %d\n\0"
levelShipDataStr: .ascii "---------SHIP DATA---------\nShip level: %d\n\0"
limesShipDataStr: .ascii "Limes: %d/%d\n\0"
mateysShipDataStr: .ascii "Mateys: %d/%d\n\0"
bootyShipDataStr: .ascii "Booty: %d/%d\n\0"
healthShipDataStr: .ascii "Ship health: %d/%d\n\0"
dubloonsShipDataStr: .ascii "Dubloons: %d\n\0"
cannonsShipDataStr: .ascii "Cannons: %d/%d\n\0"
weeksUntilResupplyStr: .ascii "Weeks until resupply: %d\n\0"

# General messages
mateysKilledStr: .ascii "Mateys killed: %d\n\0"
shipDamageStr: .ascii "Ship damage: %d\n\0"
bootyLostStr: .ascii "Booty lost: %d\n\0"
dubloonsPillagedStr: .ascii "Dubloons pillaged: %d\n\0"
bootyPlunderedStr: .ascii "Booty plundered: %d\n\0"
anyKeyPrompt: .ascii "Press any key to continue.\n\0"
noLimesMessage: .ascii "You have run out of limes and your mateys have scurvy! Your mateys will take attrition until you get more limes.\n\0"
mateysDeadMessage: .ascii "All your mateys have died from scurvy! The HMS Pirate Ship has been sent to Davy Jones' Locker!\n\0"
newline: .ascii "\n\0"
resupplyPrompt: .ascii "---------RESUPPLY---------\n1: Buy limes\n2: Hire mateys\n3: Repair ship\n4: Buy cannons\n5: Upgrade Ship\nx: Exit\n\0"
endgamePrompt: .ascii "You have completed your voyage! Would you like to embark on another? [y/n]\n\0"

# Purchase strings
purchasePrompt: .ascii "How much would you like to purchase? (Enter a number)\n\0"
aboveMaxPurchaseStr: .ascii "You cannot purchase that much, it would put you above your max capacity!\n\0"
tooExpensivePurchaseStr: .ascii "You cannot purchase that much, you don't have enough dubloons!\n\0"
confirmPurchaseStr: .ascii "Confirm purchase of %d units for %d dubloons? [y/n]\n\0"

# Repair strings
repairPrompt: .ascii "Cost to repair ship: %d dubloons. Confirm repair? [y/n]\n\0"
notEnoughDubloonsRepairStr: .ascii "You cannot repair your ship, you don't have enough dubloons!\n\0"
repairConfirmStr: .ascii "Your ship has been repaired by %d health points!\n\0"

# Upgrade strings
upgradePrompt: .ascii "Cost to upgrade ship to level %d: %d dubloons. Confirm upgrade? [y/n]\n\0"
notEnoughDubloonsUpgradeStr: .ascii "You cannot upgrade your ship, you don't have enough dubloons!\n\0"
upgradeConfirmStr: .ascii "Your ship has been upgraded to level %d! Your max stats have increased!\n\0"

# Becalmed messages
becalmedMessage: .ascii "The HMS Pirate Ship has been becalmed!\n\0"

# Storm messages
destroyedStormMessage: .ascii "The HMS Pirate Ship was destroyed in a storm!\n\0"
caughtStormMessage: .ascii "The HMS Pirate Ship caught in a storm!\n\0"

attackAnnounceStr: .ascii "You are being attacked by a %s\n\0"
cannonNumStr: .ascii "Your cannons: %d\n\0"
fightChanceStr: .ascii "Chance of success if you fight: %.2f%%\n\0"

flee_success_chance_90: .ascii "Chance of success if you flee: 90.00%\n\0"
to_fight: .ascii "1 to fight\n\0"
to_flee: .ascii "2 to flee\n\0"
attackPrompt: .ascii "Select one: \0"
fightDefeatStr: .ascii "DEFEAT: The HMS Pirate Ship has been sent to Davy Jones' Locker!\n\0"

pyrrhicVictoryStr: .ascii "PYRRHIC VICTORY: Although you sank the %s, it was able to take you down with it!\n\0"
fightVictoryStr: .ascii "VICTORY: You successfully defeated the %s and took it as your prize!\n\0"
fleeVictoryStr: .ascii "VICTORY: The HMS Pirate Ship successfully outran the %s!\n\0"
fleeDefeatStr: .ascii "DEFEAT: The %s caught up to the HMS Pirate Ship!\n\0"
fleeMajorDefeatStr: .ascii "DEFEAT: The %s caught up to the HMS Pirate Ship, and sent her to Davy Jones' Locker!\n\0"

# Merchantman encounter
merchantmanAnnouncement: .ascii "You see a merchantman!\n\0"

successChanceStr: .ascii "Chance of success if you attack: %.2f%%\n\0"

merchantmanAttackPrompt: .ascii "Do you want to attack? [y/n]:\n\0"
defeatMerchantmanStr: .ascii "DEFEAT: The merchantman successfully defended against you!\n\0"
majorDefeatMerchantmanStr: .ascii "DEFEAT: The merchantman sent the HMS Pirate Ship to Dany Jones' Locker!\n\0"
victoryMerchantmanStr: .ascii "VICTORY: You successfully attacked the merchantman and plundered all its booty!\n\0"
pyrrhicVictoryMerchantmanStr: .ascii "PYRRHIC VICTORY: You successfully attacked the merchantman, but the HMS Pirate Ship took too much damage!\n\0"

loot_table: .long 500, 500, 500, 500, 600, 600, 600, 700, 700, 1000

# Ship names
manowarName: .ascii "Man-o-War\0"
frigateName: .ascii "Frigate\0"

# Miscellaneous floating point values
double_002: .double 0.02
double_01:  .double 0.1
double_03:  .double 0.3
double_1:   .double 1.0
double_09:  .double 0.9
double_100: .double 100.0

# Input strings
istrd: .ascii "%d\0"
istrc: .ascii "%c\0"

# Game over messages
gameOverStr: .ascii "Game Over!\n\0"
gameOverStatsStr: .ascii "---------STATS---------\n\0"
voyagesCompletedStatsStr: .ascii "Voyages completed: %d\n\0"
dubloonsStatsStr: .ascii "Dubloons: %d\n\0"
totalScoreStatsStr: .ascii "Total score: %d\n\0"

.section .data

game_state: .byte 0                         # 0 means game is active, 1 means game not active, 2 means error
return_voyage: .byte 0                      # whether or not the game is on a return voyage
voyage_counter: .long 0                     # counts how many voyages the player has completed

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

.lcomm char_buf, 128

.section .note.GNU-stack,"",@progbits



