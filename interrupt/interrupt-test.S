.text
.global run_interrupt_tests
run_interrupt_tests:
    # Backups
    subui $sp, $sp, 13
    sw $ra, 0($sp)
    sw $2, 2($sp)
    sw $3, 3($sp)
    movsg $1, $cctrl
    sw $1, 4($sp)
    movsg $1, $evec
    sw $1, 5($sp)
    # Maximum number of arguments for a function called here
    subui $sp, $sp, 2
    
    la $1, welcome_msg
    sw $1, 0($sp)
    jal puts
    
    # Set our custom handler
    movsg $1, $evec
    sw $1, system_evec($0)
    la $1, evec
    movgs $evec, $1
    
    # Set timer interrupts, auto restart and enable
    # ~0.5s
    addui $1, $0, 0x4B0
    sw $1, 0x72001($0)
    addui $1, $0, 0x3
    sw $1, 0x72000($0)
    
    # Set parallel interrupts, keep hex-decode
    addui $1, $0, 0x3
    sw $1, 0x73004($0)
    lw $1, 0x73000($0)
    sw $1, original_switches($0)
    
    # Set serial tx/rx interrupts, 38400, 8N1 for both
    
    
    # Enable all the interrupts
    #addui $1, $0, 0x3EA
    addui $1, $0, 0x10A # Only serial 1
    movgs $cctrl, $1
    
check_complete_loop:
    lw $1, finished_status($0)
    seqi $1, $1, 0x7
    bnez $1, exit
    
    j check_complete_loop
    
exit:
    addui $sp, $sp, 2
    lw $1, 4($sp)
    movgs $cctrl, $1
    lw $1, 5($sp)
    movgs $evec, $1
    lw $ra, 0($sp)
    lw $2, 2($sp)
    lw $3, 3($sp)
    addui $sp, $sp, 13
    jr $ra

evec:
    movsg $13, $estat
    andi $13, $13, 0x20
    bnez $13, do_user_interrupt_button_evec
    
    movsg $13, $estat
    andi $13, $13, 0x40
    bnez $13, do_timer_evec
    
    movsg $13, $estat
    andi $13, $13, 0x80
    bnez $13, do_parallel_evec
    
    movsg $13, $estat
    andi $13, $13, 0x100
    bnez $13, do_serial1_evec
    
    movsg $13, $estat
    andi $13, $13, 0x200
    bnez $13, do_serial2_evec
    
    # Any software exceptions should just be handled by the system handler
    j do_system_evec

do_user_interrupt_button_evec:
    # Acknowledge
    sw $0, 0x7F000($0)
    # Skip doing anything if it's happened before
    lw $13, finished_status($0)
    andi $13, $13, 0x1
    bnez $13, exit_user_interrupt_evec
    # Mark down that this has happened
    lw $13, finished_status($0)
    ori $13, $13, 0x1
    sw $13, finished_status($0)
    # Talk about it
    subui $sp, $sp, 1
    la $13, user_interrupt_finished
    sw $13, 0($sp)
    jal puts
    addui $sp, $sp, 1
exit_user_interrupt_evec:
    rfe    
    
do_timer_evec:
    # Acknowledge the interrupt
    sw $0, 0x72003($0)
    
    # Flip the LEDs so we know something's happened
    lw $13, 0x7300A($0)
    xori $13, $13, 0xFFFF
    sw $13, 0x7300A($0)
    
    # If we've not been here before, note down that we now have
    lw $13, seen_timer($0)
    bnez $13, has_seen_timer
    addui $13, $0, 1
    sw $13, seen_timer($0)
    rfe
    # If we've been here before, set the "timer works" flag
has_seen_timer:
    # But only once...
    lw $13, finished_status($0)
    andi $13, $13, 0x2
    bnez $13, exit_timer_evec

    lw $13, finished_status($0)
    ori $13, $13, 0x2
    sw $13, finished_status($0)
    # Talk about it
    subui $sp, $sp, 1
    la $13, timer_finished
    sw $13, 0($sp)
    jal puts
    addui $sp, $sp, 1
exit_timer_evec:
    rfe

do_parallel_evec:
    # Acknowledge the interrupt
    sw $0, 0x73005($0)
    
    # Update the seen_parallel memory location with which sw/btns we've seen high
    subui $sp, $sp, 1
    sw $2, 0($sp)
    
    lw $2, original_switches($0)
    lw $13, 0x73000($0)
    # $2 becomes high if the bit's switch is different to its original value
    xor $2, $2, $13
    # seen_parallel becomes high if it was ever different
    lw $13, seen_parallel($0)
    or $13, $13, $2
    # Same for the buttons, but we assume there isn't one stuck high.
    lw $2, 0x73001($0)
    slli $2, $2, 16
    or $13, $13, $2
    sw $13, seen_parallel($0)
    
    # Check if we've seen everything
    lhi $2, 0x7
    ori $2, $2, 0xFFFF
    seq $13, $2, $13
    beqz $13, parallel_after_set_finished
    
    # Talk about it if this is when we finished
    lw $13, finished_status($0)
    andi $13, $13, 0x4
    bnez $13, set_parallel_finished
    subui $sp, $sp, 1
    la $13, parallel_finished
    sw $13, 0($sp)
    jal puts
    addui $sp, $sp, 1

set_parallel_finished:
    lw $13, finished_status($0)
    ori $13, $13, 0x4
    sw $13, finished_status($0)
    
parallel_after_set_finished:
    lw $2, 0($sp)
    addui $sp, $sp, 1
    
    # Throw the switches on the SSDs
    lw $13, 0x73000($0)
    sw $13, 0x73009($0)
    srli $13, $13, 4
    sw $13, 0x73008($0)
    srli $13, $13, 4
    sw $13, 0x73007($0)
    srli $13, $13, 4
    sw $13, 0x73006($0)
    
    # Override the SSDs with the button value if it's nonzero
    lw $13, 0x73001($0)
    bnez $13, button_pressed
    rfe
    
button_pressed:
    sw $13, 0x73006($0)
    sw $13, 0x73007($0)
    sw $13, 0x73008($0)
    sw $13, 0x73009($0)
    rfe

do_serial1_evec:
    la $13, system_evec
    jr $13

do_serial2_evec:
    la $13, system_evec
    jr $13

do_system_evec:
    la $13, system_evec
    jr $13

.bss
    system_evec: .word
    original_switches: .word

.data    
    finished_status: .word 0
    error_status: .word 0
    seen_timer: .word 0
    seen_parallel: .word 0
    
welcome_msg:
    .ascii "Starting interrupt tests.\r\n"
    .ascii "Please do all of the following actions. Press the user interrupt button,\r\n"
    .ascii "and all three user input buttons. The top button of the five is the reset\r\n"
    .ascii "button, do not press it. When the user input buttons are pressed, observe\r\n"
    .ascii "the seven-segment displays showing the value of the button input register.\r\n"
    .ascii "Observe all the LEDs flashing at 1Hz. Flip all of the switches from their\r\n"
    .ascii "current value. Observe the seven-segment displays showing the value of the\r\n"
    .ascii "switch input register. Enter text in each serial port, and observe the\r\n"
    .ascii "text appearing in the second serial port.\r\n"
    .ascii "If all of these actions correctly generate interrupts, the program will\r\n"
    .asciiz "continue.\r\n"
user_interrupt_finished:
    .asciiz "User interrupt button test finished.\r\n"
timer_finished:
    .asciiz "Timer test finished.\r\n"
parallel_finished:
    .asciiz "Parallel interface test finished.\r\n"
serial1_finished:
    .asciiz "Serial port 1 test finished.\r\n"
serial2_finished:
    .asciiz "Serial port 2 test finished.\r\n"
