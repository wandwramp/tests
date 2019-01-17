#include "iolib.h"

int putchar(int c) {
  /* wait until the TDR bit is on */
  while (!(RexSp1->Stat & 2)) {}
  /* write the character to the Tx register */
  RexSp1->Tx = c;
  return c;
}

int puts(const char *s) {
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
