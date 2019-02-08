.data
    seen_parallel: .word 0
parallel_finished:
    .asciiz "Parallel interface test finished.\r\n"
.bss
.global original_switches
    original_switches: .word

.text
.global parallel_evec
parallel_evec:
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
    
