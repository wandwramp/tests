
#include "rex.h"

int seen_serial;
int finished_status;
char * interrupt_test_msg = "this is my test mesg";
int ssm1_counter;
int ssm1_char;

void state_print_intro(void);
void state_wait_for_char(void);
void state_send_cr(void);

void (*state)(void) = &state_print_intro;

void serial_evec(){
	if (seen_serial == 0b111){
		finished_status |= 0b1000;
	}
	state();
	return;
}

void state_print_intro(){
	if (RexSp1->Stat & SP_STAT_TX_RDY){
		return;
	}
	if(interrupt_test_msg[ssm1_counter] != '\0'){
		RexSp1->Tx = interrupt_test_msg[ssm1_counter];
		RexSp1->Iack &= ~SP_IACK_TX;
	} else {
		state = &state_wait_for_char;
		seen_serial |= 1;
	}
	return;
}

void state_wait_for_char(){
	if (RexSp1->Stat & SP_STAT_RX_RDY){
		if (RexSp1->Stat & SP_STAT_TX_RDY){
			return;
		}
		RexSp1->Tx = ssm1_char;
		RexSp1->Iack &= ~SP_IACK_RX;
		return;
	}
	RexSp1->Iack &= SP_IACK_TX;
	ssm1_char = RexSp1->Rx;
	state = &state_send_cr;
	seen_serial |= 0x2;
	
	return;
}

void state_send_cr(){
	if(RexSp1->Stat & SP_STAT_TX_RDY){
		RexSp1->Tx = '\r';
		RexSp1->Iack &= ~SP_IACK_RX;
		state = &state_wait_for_char;
		seen_serial |= 0x4;
	}
	return;
}

