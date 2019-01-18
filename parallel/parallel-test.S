.equ    SWITCHES,        0x73000
.equ    BUTTONS,         0x73001
.equ    CONTROL,         0x73004
.equ    INTERRUPT_ACK,   0x73005
.equ    SSDUL,           0x73006
.equ    SSDUR,           0x73007
.equ    SSDLL,           0x73008
.equ    SSDLR,           0x73009
.equ    LEDS,            0x7300A

.text
.global run_parallel_tests
run_parallel_tests:
    
    subui $sp, $sp, 7
    sw $ra, 1($sp)
    sw $2, 2($sp)
    sw $3, 3($sp)
    sw $4, 4($sp)
    sw $5, 5($sp)
    sw $6, 6($sp)
    
    la $2, welcome_msg
    sw $2, 0($sp)
    jal puts
    
    # Read the switches, and wait for the user to flip them all
    la $2, flip_switches_msg
    sw $2, 0($sp)
    jal puts

    # Enable hex-ssd
    addui $2, $0, 1
    sw $2, CONTROL($0)
    # Make $2 the original switch value
    lw $2, SWITCHES($0)
    andi $2, $2, 0xFFFF
    addui $5, $0, 0
    
switch_loop:
    # $3 holds the current value of the switches
    lw $3, SWITCHES($0)
    andi $3, $3, 0xFFFF
    # $4 is high if that bit's switch is currently different to its original value
    xor $4, $2, $3
    # $5 is high if the switch has ever been flipped
    or $5, $5, $4
    
    sw $5, LEDS($0)
    
    addui $6, $5, 0
    andi $6, $6, 0xF
    sw $6, SSDLR($0)
    
    srli $6, $5, 4
    andi $6, $6, 0xF
    sw $6, SSDLL($0)
    
    srli $6, $5, 8
    andi $6, $6, 0xF
    sw $6, SSDUR($0)
    
    srli $6, $5, 12
    andi $6, $6, 0xF
    sw $6, SSDUL($0)
    
    sequi $6, $5, 0xFFFF
    bnez $6, switch_loop_end
    j switch_loop

switch_loop_end:
    
    # Make sure all the buttons can be pressed while flashing the SSDs
    # Read the switches, and wait for the user to flip them all
    la $2, press_buttons_msg
    sw $2, 0($sp)
    jal puts
    
    sw $0, CONTROL($0) # Disable hex-ssd-decode and set up their values
    addui $2, $0, 0x87
    sw $2, SSDUL($0)
    addui $2, $0, 0x78
    sw $2, SSDUR($0)
    addui $2, $0, 0x87
    sw $2, SSDLL($0)
    addui $2, $0, 0x78
    sw $2, SSDLR($0)
    jal flip_ssd_values # also sets counter
    
    addui $3, $0, 0

button_loop:
    # $2 holds the current value of the buttons
    lw $2, BUTTONS($0)
    andi $2, $2, 0x7
    # $3 is high if the button was ever pressed
    or $3, $3, $2
    
    sw $2, LEDS($0)
    
    lw $2, loop_counter($0)
    subui $2, $2, 1
    sw $2, loop_counter($0)
    bnez $2, skip_flip_ssd_values
    jal flip_ssd_values
skip_flip_ssd_values:
    
    sequi $2, $3, 0x7
    bnez $2, button_loop_end
    j button_loop

button_loop_end:
    
    # Return 0 for a success
    addui $1, $0, 0
    
    lw $ra, 1($sp)
    lw $2, 2($sp)
    lw $3, 3($sp)
    lw $4, 4($sp)
    lw $5, 5($sp)
    lw $6, 6($sp)
    addui $sp, $sp, 7
    jr $ra

flip_ssd_values:
    subui $sp, $sp, 2
    sw $ra, 0($sp)
    sw $1, 1($sp)
    
    lw $1, SSDUL($0)
    xori $1, $1, 0xFF
    sw $1, SSDUL($0)
    
    lw $1, SSDUR($0)
    xori $1, $1, 0xFF
    sw $1, SSDUR($0)
    
    lw $1, SSDLL($0)
    xori $1, $1, 0xFF
    sw $1, SSDLL($0)
    
    lw $1, SSDLR($0)
    xori $1, $1, 0xFF
    sw $1, SSDLR($0)
    
    addui $1, $0, 0xFFFF
    sw $1, loop_counter($0)
    
    lw $ra, 0($sp)
    lw $1, 1($sp)
    addui $sp, $sp, 2
    jr $ra

.data
welcome_msg:
    .asciiz "Testing parallel interface...\r\n\r\n"
    
flip_switches_msg:
    .ascii "Please flip all the switches.\r\n"
    .ascii "Check that each LED turns on when you flip its switch.\r\n"
    .asciiz "The SSDs should display the values of the LEDs in hex-decode mode.\r\n\r\n"

press_buttons_msg:
    .ascii "Please press all three user input buttons (The row in the middle).\r\n"
    .ascii "You should see the seven-segment displays showing off all their segments.\r\n"
    .ascii "This is in non-hex-decode mode. The LEDs will display which buttons\r\n"
    .asciiz "are currently being pressed.\r\n"

loop_counter: .word 0
