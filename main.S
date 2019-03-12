########################################################################
# This file is part of tests.srec, a simple testsuite for WRAMP
#
# Copyright (C) 2019 The University of Waikato, Hamilton, New Zealand.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
########################################################################

.text
.global main
main:
    # Set up some stack
    la $sp, stack
    subui $sp, $sp, 1

    # Yell and quit early if the ALU tests fail
    jal run_alu_tests
    beqz $1, alu_test_msg_end

    la $1, alu_test_fail_msg
    sw $1, 0($sp)
    jal puts
    j exit
alu_test_msg_end:

    # Continue if any of the rest of the tests fail
    # Serial 1
    sw $0, 0($sp)
    jal run_serial_tests
    
    la $1, switch_serial_msg
    sw $1, 0($sp)
    jal puts
    
    # Serial 2
    addui $1, $0, 1
    sw $1, 0($sp)
    jal run_serial_tests
    # Parallel
    jal run_parallel_tests
    # Interrupts
    jal run_interrupt_tests

    la $1, all_tests_complete_msg
    sw $1, 0($sp)
    jal puts

exit:
    addui $sp, $sp, 1
    syscall

.bss
    .space 1024
stack:

.data
alu_test_fail_msg:
    .ascii "Some instructions failed testing. Either this program was compiled\r\n"
    .ascii "incorrectly, or the architecture is incorrect.\r\n"
    .asciiz "Exiting...\r\n"

switch_serial_msg:
    .asciiz "Check the second serial port for another test.\r\n"

all_tests_complete_msg:
    .asciiz "\r\nAll tests complete.\r\n\r\n"
