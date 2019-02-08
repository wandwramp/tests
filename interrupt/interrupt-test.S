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
    
    # Enable all the interrupts except serial
    addui $1, $0, 0x0EA
    movgs $cctrl, $1
    
check_complete_loop_1:
    lw $1, finished_status($0)
    seqi $1, $1, 0x7
    bnez $1, exit_loop1
    
    # Temporarily commented
    #j check_complete_loop_1

exit_loop1:
    # Set up the initial state for the serial port state machines
    la $1, STATE1_PRINT_INTRO
    sw $1, ssm1_state($0)
    
    la $1, test_serial_msg
    sw $1, 0($sp)
    jal puts
    
    # Disable the rest of the interrupts
    # Timer
    sw $0, 0x72000($0)
    
    # Parallel
    addui $1, $0, 0x1
    sw $1, 0x73004($0)
    
    # Set serial tx/rx interrupts, 38400, 8N1 for both
    addui $1, $0, 0x3C7
    sw $1, 0x70002($0)
    sw $1, 0x71002($0)
    
    # Enable serial interrupts only
    addui $1, $0, 0x30A
    movgs $cctrl, $1
    
    # Start sending the intro message - it will continue via interrupts
    addui $1, $0, '\0'
    sw $1, 0x70000($0)
    sw $1, 0x71000($0)
    
check_complete_loop_2:
    lw $1, finished_status($0)
    seqi $1, $1, 0x1F
    bnez $1, exit
    
    j check_complete_loop_2
    
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
    
    addui $13, $0, 0x1
    sw $13, 0x7300A($0)
    
    movsg $13, $estat
    andi $13, $13, 0x100
    bnez $13, do_serial1_evec

    addui $13, $0, 0x2
    sw $13, 0x7300A($0)
    
    movsg $13, $estat
    andi $13, $13, 0x200
    bnez $13, do_serial2_evec
    
    # Any software exceptions should just be handled by the system handler
    j do_system_evec

do_system_evec:
    lw $13, system_evec($0)
    jr $13

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
    j timer_evec
do_parallel_evec:
    j parallel_evec
do_serial1_evec:
    j serial1_evec
do_serial2_evec:
    j serial2_evec

.bss
    system_evec: .word

.data
.global finished_status
    finished_status: .word 0
    
welcome_msg:
    .ascii "Starting interrupt tests.\r\n\r\n"
    .ascii "Please do all of the following actions. Press the user interrupt button,\r\n"
    .ascii "and all three user input buttons. The top button of the five is the reset\r\n"
    .ascii "button, do not press it. When the user input buttons are pressed, observe\r\n"
    .ascii "the seven-segment displays showing the value of the button input register.\r\n"
    .ascii "Observe all the LEDs flashing at 1Hz. Flip all of the switches from their\r\n"
    .ascii "current value. Observe the seven-segment displays showing the value of the\r\n"
    .ascii "switch input register.\r\n"
    .ascii "If all of these actions correctly generate interrupts, the program will\r\n"
    .asciiz "continue.\r\n"

test_serial_msg:
    .ascii "\r\nSerial interrupts will now be tested. If the next line appears on both\r\n"
    .asciiz "serial ports, then serial transmit interrupts work.\r\n\n"

user_interrupt_finished:
    .asciiz "User interrupt button test finished.\r\n"
serial1_finished:
    .asciiz "Serial port 1 test finished.\r\n"
serial2_finished:
    .asciiz "Serial port 2 test finished.\r\n"
