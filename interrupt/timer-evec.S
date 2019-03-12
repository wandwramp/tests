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


.data
    seen_timer: .word 0
timer_finished:
    .asciiz "Timer test finished.\r\n"

.text
.global timer_evec
timer_evec:
    # Acknowledge the interrupt
    sw $0, 0x72003($0)
    
    # Flip the LEDs so we know something's happened
    lw $13, 0x7300A($0)
    xori $13, $13, 0xFFFF
    sw $13, 0x7300A($0)
    
    # If we've not been here before, note down that we now have
    lw $13, seen_timer($0)
    bnez $13, has_seen_timer
    addui $13, $0, 1
    sw $13, seen_timer($0)
    rfe
    # If we've been here before, set the "timer works" flag
has_seen_timer:
    # But only once...
    lw $13, finished_status($0)
    andi $13, $13, 0x2
    bnez $13, exit_timer_evec

    lw $13, finished_status($0)
    ori $13, $13, 0x2
    sw $13, finished_status($0)
    # Talk about it
    subui $sp, $sp, 1
    la $13, timer_finished
    sw $13, 0($sp)
    jal puts
    addui $sp, $sp, 1
exit_timer_evec:
    rfe
