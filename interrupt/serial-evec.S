.bss
    # Serial state-machine state
    .global ssm1_state
    ssm1_state: .word
    .global ssm2_state
    ssm2_state: .word
.data
    seen_serial1: .word 0
    seen_serial2: .word 0
    # Serial state-machine counter
    ssm1_counter: .word 0
    ssm1_char: .word '\0'
    ssm2_counter: .word 0
    ssm2_char: .word '\0'
    
interrupt_test_msg:
    .ascii "Next, type a few characters into each serial port. They should begin\r\n"
    .ascii "arriving in the same port very quickly, and begin from the start of\r\n"
    .asciiz "the line when a new character is typed.\r\n"

.text
.global serial1_evec
.global serial2_evec
.global STATE1_PRINT_INTRO
.global STATE2_PRINT_INTRO
serial1_evec:
    # Save some registers to use
    subui $sp, $sp, 2
    sw $9, 1($sp)
    
    addui $9, $0, 0x4
    sw $9, 0x7300A($0)
    
    # If we've been down all the code paths, it must work. Mark that we're done here.
    lw $13, seen_serial1($0)
    seqi $13, $13, 0x7
    bnez $13, skip_serial1_mark_finished
    
    lw $13, finished_status($0)
    ori $13, $13, 0x8
    sw $13, finished_status($0)
    
skip_serial1_mark_finished:
    # Do something different depending on our state
    lw $13, ssm1_state($0)
    jr $13
    
STATE1_PRINT_INTRO:
    # If this was a send done interrupt, send the next character
    # Otherwise, do nothing
    lw $9, 0x70003($0)
    andi $9, $9, 0x2
    beqz $9, serial1_evec_exit

    # If we've sent all the characters, move onto the next state
    lw $9, ssm1_counter($0)
    lw $13, interrupt_test_msg($9)
    seqi $13, $13, '\0'
    beqz $13, send_intro_char1
    
    la $13, STATE1_WAIT_FOR_CHAR
    sw $13, ssm1_state($0)
    lw $13, seen_serial1($0)
    ori $13, $13, 0x1
    sw $13, seen_serial1($0)
    j serial1_evec_exit

send_intro_char1:
    lw $13, interrupt_test_msg($9)
    sw $13, 0x70000($0)
    lw $13, 0x70004($0)
    andi $13, $13, 0x01         # Acknowledge send interrupt only
    sw $13, 0x70004($0)
    addui $9, $9, 1
    sw $9, ssm1_counter($0)
    j serial1_evec_exit

STATE1_WAIT_FOR_CHAR:
    # If we just received a new character, send a \r next time and switch to the new char
    lw $9, 0x70003($0)
    andi $9, $9, 0x1
    beqz $9, serial1_send_char
    
    lw $9, 0x70001($0)
    lw $13, 0x70004($0)
    #andi $13, $13, 0x10         # Acknowledge recv interrupt only ##TODO this is the wrong flag?
	andi $13, $13, 0x1         # Acknowledge recv interrupt only ##TODO this is the wrong flag?
    sw $13, 0x70004($0)
    sw $9, ssm1_char($0)
    la $9, STATE1_SEND_CR
    sw $9, ssm1_state($0)
    lw $13, seen_serial1($0)
    ori $13, $13, 0x2
    sw $13, seen_serial1($0)
    j serial1_evec_exit
    
serial1_send_char:
    # Spam the character we're sending
    lw $9, 0x70003($0)
    andi $9, $9, 0x2
    beqz $9, serial1_evec_exit
    
    lw $9, ssm1_char($0)
    sw $9, 0x70000($0)
    lw $13, 0x70004($0)
    andi $13, $13, 0x01         # Acknowledge send interrupt only
    sw $13, 0x70004($0)
    
    j serial1_evec_exit

STATE1_SEND_CR:
    lw $9, 0x70003($0)
    andi $9, $9, 0x2
    bnez $9, serial1_send_cr
    j serial1_evec_exit
    
serial1_send_cr:
    addui $9, $0, '\r'
    sw $9, 0x70000($0)
    lw $13, 0x70004($0)
    andi $13, $13, 0x01         # Acknowledge send interrupt only
    sw $13, 0x70004($0)
    la $9, STATE1_WAIT_FOR_CHAR
    sw $9, ssm1_state($0)
    lw $13, seen_serial1($0)
    ori $13, $13, 0x4
    sw $13, seen_serial1($0)
    j serial1_evec_exit

serial1_evec_exit:
    # Restore state
    lw $9, 1($sp)
    addui $sp, $sp, 2
    rfe

serial2_evec:
# Save some registers to use
    subui $sp, $sp, 2
    sw $9, 1($sp)
    
    # If we've been down all the code paths, it must work. Mark that we're done here.
    lw $13, seen_serial2($0)
    seqi $13, $13, 0x7
    bnez $13, skip_serial2_mark_finished
    
    lw $13, finished_status($0)
    ori $13, $13, 0x10
    sw $13, finished_status($0)
    
skip_serial2_mark_finished:
    # Do something different depending on our state
    lw $13, ssm2_state($0)
    jr $13
    
STATE2_PRINT_INTRO:
    # If this was a send done interrupt, send the next character
    # Otherwise, do nothing
    lw $9, 0x71003($0)
    andi $9, $9, 0x2
    beqz $9, serial2_evec_exit

    # If we've sent all the characters, move onto the next state
    lw $9, ssm2_counter($0)
    lw $13, interrupt_test_msg($9)
    seqi $13, $13, '\0'
    beqz $13, send_intro_char2
    
    la $13, STATE2_WAIT_FOR_CHAR
    sw $13, ssm2_state($0)
    lw $13, seen_serial2($0)
    ori $13, $13, 0x1
    sw $13, seen_serial2($0)
    j serial2_evec_exit

send_intro_char2:
    lw $13, interrupt_test_msg($9)
    sw $13, 0x71000($0)
    lw $13, 0x71004($0)
    andi $13, $13, 0x01         # Acknowledge send interrupt only
    sw $13, 0x71004($0)
    addui $9, $9, 1
    sw $9, ssm2_counter($0)
    j serial2_evec_exit

STATE2_WAIT_FOR_CHAR:
    # If we just received a new character, send a \r next time and switch to the new char
    lw $9, 0x71003($0)
    andi $9, $9, 0x1
    beqz $9, serial2_send_char
    
    lw $9, 0x71001($0)
    sw $9, ssm2_char($0)
    lw $13, 0x71004($0)
    andi $13, $13, 0x10         # Acknowledge recv interrupt only
    sw $13, 0x71004($0)
    la $9, STATE2_SEND_CR
    sw $9, ssm2_state($0)
    lw $13, seen_serial2($0)
    ori $13, $13, 0x2
    sw $13, seen_serial2($0)
    j serial2_evec_exit
    
serial2_send_char:
    # Spam the character we're sending
    lw $9, 0x71003($0)
    andi $9, $9, 0x2
    beqz $9, serial2_evec_exit
    
    lw $9, ssm2_char($0)
    sw $9, 0x71000($0)
    lw $13, 0x71004($0)
    andi $13, $13, 0x01         # Acknowledge send interrupt only
    sw $13, 0x71004($0)
    
    j serial1_evec_exit

STATE2_SEND_CR:
    lw $9, 0x71003($0)
    andi $9, $9, 0x2
    bnez $9, serial2_send_cr
    j serial2_evec_exit
    
serial2_send_cr:
    addui $9, $0, '\r'
    sw $9, 0x71000($0)
    lw $13, 0x71004($0)
    andi $13, $13, 0x01         # Acknowledge send interrupt only
    sw $13, 0x71004($0)
    la $9, STATE2_WAIT_FOR_CHAR
    sw $9, ssm2_state($0)
    lw $13, seen_serial2($0)
    ori $13, $13, 0x4
    sw $13, seen_serial2($0)
    j serial2_evec_exit

serial2_evec_exit:
    # Restore state
    lw $9, 1($sp)
    addui $sp, $sp, 2
    rfe
