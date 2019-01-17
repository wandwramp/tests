// Minimal replacement for alu-test.c that drastically cuts down
// the filesize when those tests are not desired.

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

int run_alu_tests() {
    char* msg = "Skipping ALU tests.\r\n";

    // Send msg over the serial
    while (*msg != '\0') {
        while (!(RexSp1->Stat & 2)) {}
        RexSp1->Tx = *msg;
        msg++;
    }

    return 0;
}
