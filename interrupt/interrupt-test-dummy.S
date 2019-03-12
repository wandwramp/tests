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
