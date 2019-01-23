#include "iolib.h"

RexSp_t* active_serial = RexSp1;

int strcmp(const char* a, const char* b) {
  while (*a != '\0' && *b != '\0')
  {
    if (*a != *b) {
      if (*a < *b) {
        return -1;
      }
      else return 1;
    }
    a++;
    b++;
  }
  if (*a == '\0' && *b == '\0') {
    return 0;
  }
  if (*a == '\0') {
    return -1;
  }
  else return 1;
}

char getchar() {
  /* wait until the RDR bit is on */
  while (!(active_serial->Stat & 1)) {}
  /* return the character */
  return active_serial->Rx;
}

// NOTE: This function returns a pointer to the *end* of buf
// after it has been populated with the string! This differs
// to the implementation of gets in C's stdio.h
char* gets(char* buf) {
  char* curPos = buf;
  char thischar;
  do
  {
    thischar = getchar();
    *curPos = thischar;
    curPos++;
  }
  while (thischar != '\r');
  
  *curPos = '\n';
  curPos++;
  *curPos = '\0';
  
  return curPos;
}

int putchar(int c) {
  /* wait until the TDR bit is on */
  while (!(active_serial->Stat & 2)) {}
  /* write the character to the Tx register */
  active_serial->Tx = c;
  return c;
}

int puts(const char* s) {
  while (*s != '\0') {
    putchar(*s);
    s++;
  }
  return 0;
}

void print_dec(int x) {
  int r = 0;
  if (x == 0) {
    /* special case */
    putchar('0');
    return;
  } else if (x < 0) {
    putchar('-');
    x = -x;
  }
  /* fill r with digits of x in reverse */
  while (x > 0) {
    r = r * 10 + x % 10;
    x /= 10;
  }
  /* print digits of r */
  while (r > 0) {
    putchar('0' + r % 10);
    r /= 10;
  }
}

static char hex_char(int x) {
  return x < 10 ? '0' + x : 'A' + (x - 10);
}

void print_hex(unsigned int x) {
  int i;
  puts("0x");
  for (i = 7; i >= 0; i--) {
    putchar(hex_char((x >> (i * 4)) & 0xF));
  }
}
