
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

