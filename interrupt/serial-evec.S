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
serial1_evec:  

	subui $sp, $sp, 3
	sw $ra, 2($sp)
	sw $1, 1($sp)
	addui $1, $0, 1
	sw $1, 0($sp)

	jal serial_evec

	lw $1, 1($sp)
	lw $ra, 2($sp)
	addui $sp, $sp, 3

   rfe

serial2_evec:  

	subui $sp, $sp, 3
	sw $ra, 2($sp)
	sw $1, 1($sp)
	addui $1, $0, 0
	sw $1, 0($sp)

	jal serial_evec

	lw $1, 1($sp)
	lw $ra, 2($sp)
	addui $sp, $sp, 3


   rfe