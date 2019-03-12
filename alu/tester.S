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


# This file is the test runner engine for alu-test.c
# It generates instructions on the fly, saves them to memory,
# and executes them.
.text
.global tester_setup
.global tester_cleanup
.global tester_run

# void tester_setup()
tester_setup:
        # save the old exception vector
        movsg $1, $evec
        sw $1, old_vector($0)
        # set the exception vector to our handler
        la $1, handler
        movgs $evec, $1
        # Set some stack
        sw $sp, old_sp($0)
        la $sp, stack
        # return
        jr $ra

# void tester_cleanup()
tester_cleanup:
        # restore the old exception vector
        lw $1, old_vector($0)
        movgs $evec, $1
        #restore the old stack
        lw $sp, old_sp($0)
        # return
        jr $ra

# int tester_run(int rs, int rt, int func, int *overflow, int op)
tester_run:
        # 2 register saves ($2 and $3)
        subui $sp, $sp, 2
        sw $2, 0($sp)
        sw $3, 1($sp)
        # create the instruction being tested
        # R-type instruction, OPcode=(later), Rd=$1, Rs=$2, Func=(later), Rt=$3
        lhi $2, 0x0120
        ori $2, $2, 0x0003
        # set func in instruction
        lw $3, 4($sp) # func parameter
        slli $3, $3, 16
        or $2, $2, $3
        # set op on instruction
        lw $3, 6($sp) # op parameter
        slli $3, $3, 28
        or $2, $2, $3
        # write the instruction into the the code of this subroutine
        sw $2, tester_instruction($0)
        # reset the overflow detection flag
        sw $0, overflow_detected($0)
        # enable overflow detection
        addi $2, $0, 1
        sw $2, overflow_detection_enabled($0)
        # set up $2 and $3 for the instruction being tested
        lw $2, 2($sp) # rs parameter
        lw $3, 3($sp) # rt parameter
tester_instruction:
        add $0, $0, $0 # placeholder for instruction being tested
        # disable overflow detection
        sw $0, overflow_detection_enabled($0)
        # update the overflow parameter
        lw $2, overflow_detected($0)
        lw $3, 5($sp) # overflow parameter (type: int *)
        sw $2, 0($3)
        # restore registers
        lw $3, 1($sp)
        lw $2, 0($sp)
        addui $sp, $sp, 2
        jr $ra

handler:
        # check if overflow detection is enabled
        lw $13, overflow_detection_enabled($0)
        # if not, skip
        beqz $13, handler_next
        # check if it's an arithmetic exception
        movsg $13, $estat
        andi $13, $13, 0x8000
        # if it's not, skip
        beqz $13, handler_next
        # set the overflow detection flag
        addi $13, $0, 1
        sw $13, overflow_detected($0)
        rfe
handler_next:
        lw $13, old_vector($0)
        jr $13

.data
old_vector:
        .word 0
overflow_detection_enabled:
        .word 0
overflow_detected:
        .word 0
old_sp:
        .word 0
.bss
        .space 1024
stack:
