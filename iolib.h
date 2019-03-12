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

#ifndef IOLIB_H
#define IOLIB_H
/**
 * Print an integer in decimal.
 */
void print_dec(int x);

/**
 * Print an integer in hexadecimal.
 */
void print_hex(unsigned int x);

#define ENDL "\r\n"

/**
 * Prints a character to serial port 1.
 */
int putchar(int c);

/**
 * Prints a string to serial port 1.
 */
int puts(const char *s);

/**
 * Gets a string from serial port 1.
 * Returns the end of the string, not the start!
 */
char* gets(char* buf);

/**
 * REX Serial Ports
 **/
typedef volatile struct
{
	int Tx;
	int Rx;
	int Ctrl;
	int Stat;
	int Iack;
} RexSp_t;

#define RexSp1 		((RexSp_t*)0x70000)
#define RexSp2 		((RexSp_t*)0x71000)

#endif
