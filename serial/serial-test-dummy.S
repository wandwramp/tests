# Minimal replacement for serial-test.S that drastically cuts down
# the filesize when those tests are not desired.

.text
.global run_serial_tests
run_serial_tests:
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
msg: .asciiz "Skipping serial tests.\r\n"
