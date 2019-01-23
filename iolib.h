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
