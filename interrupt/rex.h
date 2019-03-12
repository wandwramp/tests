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

#ifndef REX_H
#define REX_H

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

#define SP_STAT_RX_RDY    (1 <<  0)
#define SP_STAT_TX_RDY    (1 <<  1)
#define SP_STAT_ERR_OVR   (1 <<  2)
#define SP_STAT_ERR_FRM   (1 <<  3)
#define SP_STAT_ERR_PAR   (1 <<  4)

#define SP_CTRL_TX_INT_EN (1 <<  9)
#define SP_CTRL_RX_INT_EN (1 << 10)
#define SP_CTRL_INT_EN    (1 << 11)

#define SP_IACK_RX         (1 <<  0)
#define SP_IACK_TX         (1 <<  1)
#define SP_IACK_ERR        (1 <<  2)


/**
 * REX Timer
 **/
typedef volatile struct
{
	int Ctrl;
	int Load;
	int Count;
	int Iack;
} RexTimer_t;
 
/**
 * REX Parallel Port
 **/
typedef volatile struct
{
	int Switches;
	int Buttons;
	int LeftSSD;
	int RightSSD;
	int Ctrl;
	int Iack;
	int SSD0;
	int SSD1;
	int SSD2;
	int SSD3;
	int LEDs;
} RexParallel_t;

/**
 * REX User Interrupt Button
 **/
typedef volatile struct
{
	int Iack;
} RexUserInt_t;

/**
 * Declarations
 **/
#define RexSp1 		((RexSp_t*)0x70000)
#define RexSp2 		((RexSp_t*)0x71000)
#define RexTimer  	((RexTimer_t*)0x72000)
#define RexParallel	((RexParallel_t*)0x73000)
#define RexUserInt	((RexUserInt_t*)0x7f000)

#endif

