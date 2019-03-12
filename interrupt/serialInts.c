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

#include "serialInts.h"

extern int finished_status;
char * interrupt_test_msg = 
	"Next, type a few characters into each serial port. They should begin\r\n"
    "arriving in the same port very quickly, and begin from the start of\r\n"
    "the line when a new character is typed.\r\n";

void state_print_intro(void);
void state_wait_for_char(void);
void state_send_cr(void);

spState smState1;
spState smState2;

spState * smStateCurr;


void init_serial_evec(){
	smState1.curr_char=0;
	smState1.curr_counter=0;
	smState1.curr_state=&state_print_intro;
	smState1.serialPort = RexSp1;
	smState1.seen = 0;

	smState2.curr_char=0;
	smState2.curr_counter=0;
	smState2.curr_state=&state_print_intro;
	smState2.serialPort = RexSp2;
	smState2.seen = 0;
}

void serial_evec(int isSp1){


	RexParallel->SSD3 = finished_status&0xf;
	RexParallel->SSD2 = (finished_status>>4)&0xf;

	if (isSp1){
		smStateCurr = &smState1;
		if (smStateCurr->seen == 7){		
			finished_status |= 8;
		}
	}
	else {
		smStateCurr = &smState2;
		if (smStateCurr->seen == 7){		
			finished_status |= 16;
		}
	}
	smStateCurr->curr_state();
	return;
}

void state_print_intro(){

	if (!(smStateCurr->serialPort->Stat & SP_STAT_TX_RDY)){
		return;
	}
	if(interrupt_test_msg[smStateCurr->curr_counter] != '\0'){
		smStateCurr->serialPort->Tx = interrupt_test_msg[smStateCurr->curr_counter];
		smStateCurr->serialPort->Iack &= ~SP_IACK_TX;
		smStateCurr->curr_counter++;
	} else {
		smStateCurr->curr_state = &state_wait_for_char;
		smStateCurr->seen |= 1;
		smStateCurr->curr_counter = 0;
	}
	return;
}

void state_wait_for_char(){

	if (smStateCurr->serialPort->Stat & SP_STAT_RX_RDY){ //if we recieved a char
		smStateCurr->serialPort->Iack &= ~SP_IACK_RX; 	//ack the RX
		smStateCurr->curr_char = smStateCurr->serialPort->Rx; 		//update char to send
		smStateCurr->curr_state = &state_send_cr;			//just send a '\n' 
		smStateCurr->seen |= 0x2;				//set flag for INT checking
	}
	else if (smStateCurr->serialPort->Stat & SP_STAT_TX_RDY){ //send the same char as usual
		smStateCurr->serialPort->Tx = smStateCurr->curr_char;
		smStateCurr->serialPort->Iack &= ~SP_IACK_TX;

		if (smStateCurr->curr_counter++ == 80){ //print a CR every 80 chars
			smStateCurr->curr_state = &state_send_cr;	
			smStateCurr->curr_counter = 0;
		}
	}

}

void state_send_cr(){

	if(smStateCurr->serialPort->Stat & SP_STAT_TX_RDY){
		smStateCurr->serialPort->Tx = '\r';
		smStateCurr->serialPort->Iack &= ~SP_IACK_RX;
		smStateCurr->curr_state = &state_wait_for_char;
		smStateCurr->seen |= 0x4;
	}
	return;
}

