# Minimal replacement for parallel-test.S that drastically cuts down
# the filesize when those tests are not desired.

.text
.global run_parallel_tests
run_parallel_tests:
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
msg: .asciiz "Skipping parallel tests.\r\n"
