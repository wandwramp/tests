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

/*
 * Sets up exception handler.
 * Must be called once before any calls to tester_run().
 */
void tester_setup();

/*
 * Opposite of tester_setup.
 * Should be called at the end.
 */
void tester_cleanup();

/*
 * Executes the given arithmetic function specifier on rs and rt.
 * If an arithmetic overflow occurred, stores 1 in *overflow.
 */
int tester_run(int rs, int rt, int func, int *overflow, int op);
