# Minimal replacement for interrupt-test.S that drastically cuts down
# the filesize when those tests are not desired.

.text
.global run_interrupt_tests
run_interrupt_tests:
    subui $sp, $sp, 2
    sw $ra, 1($sp)
    la $1, msg
    sw $1, 0($sp)
    jal puts
    lw $ra, 1($sp)
    addui $sp, $sp, 2
    addui $1, $0, 0
    jr $ra

.data
msg: .asciiz "Skipping interrupt tests.\r\n"
