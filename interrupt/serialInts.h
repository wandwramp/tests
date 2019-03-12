/*
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
*/
#include "rex.h"

void state_print_intro(void);
void state_wait_for_char(void);
void state_send_cr(void);

extern void serial_evec(int isSp1);
extern void init_serial_evec();
extern void state_print_intro();
void state_wait_for_char();
void state_send_cr();


typedef struct
{
	int curr_counter;
	int curr_char;
	void (*curr_state)(void);
	RexSp_t * serialPort;
	int seen;

} spState;

