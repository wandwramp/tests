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


#include "../iolib.h"
#include "tester.h"

typedef int bool_t;
#define true 1
#define false 0

#define INT_MAX 0x7FFFFFFF
#define INT_MIN (-INT_MAX - 1)
#define UINT_MAX 0xFFFFFFFF

#define PRINT_SUCCESSES 0

typedef unsigned int uint;

typedef enum {
  arith_r, arith_i, test_r_special, test_i_special, j, jr, jal, jalr, lw, sw, beqz, bnez, la, undefD, undefE, undefF
} opcode_t;

const char *opcode_names[] = {
  "arith_r", "arith_i", "test_r_special", "test_i_special", "j", "jr", "jal", "jalr", "lw", "sw", "beqz", "bnez", "la", "undefD", "undefE", "undefF"
};

typedef enum {
  add, addu, sub, subu, mult, multu, div, divu, rem, remu, sll, and, srl, or, sra, xor,
  slt, sltu, sgt, sgtu, sle, sleu, sge, sgeu, seq, sequ, sne, sneu, movgs, movsg, lhi, inc
} func_t;

const char *func_names[] = {
  "add  ", "addu ", "sub  ", "subu ", "mult ", "multu", "div  ", "divu ", "rem  ", "remu ", "sll  ", "and  ", "srl  ", "or   ", "sra  ", "xor  ",
  "slt  ", "sltu ", "sgt  ", "sgtu ", "sle  ", "sleu ", "sge  ", "sgeu ", "seq  ", "sequ ", "sne  ", "sneu ", "movgs", "movsg", "lhi  ", "inc  "
};

const opcode_t func_ops[] = {
  arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r, arith_r,
  test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_r_special, test_i_special, test_i_special, test_i_special, undefF
};

const func_t func_funcs[] = {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
};

typedef struct {
  int rs, rt;
  opcode_t op;
  func_t func;
  func_t func_name;
  int expected_result;
  bool_t expected_overflow;
} test_t;

test_t make_test(int rs, int rt, func_t func, int expected_result, bool_t expected_overflow) {
  test_t t;
  t.op = func_ops[func];
  t.func = func_funcs[func];
  t.func_name = func;
  t.rs = rs; t.rt = rt; 
  t.expected_result = expected_result; t.expected_overflow = expected_overflow;
  return t;
}

void test_print_result(test_t *t, int actual_result, bool_t actual_overflow) {
  print_hex(t->rs);
  puts(" ");
  puts(func_names[t->func_name]);
  puts(" ");
  print_hex(t->rt);
  puts(" == ");
  if (t->expected_overflow) {
    puts("overflow  ");
  } else {
    print_hex(t->expected_result);
  }
  puts(", got ");
  if (actual_overflow) {
    puts("overflow  ");
  } else {
    print_hex(actual_result);
  }
  puts(ENDL);
}


int tests_total = 0;
int tests_passed = 0;

void test_run(test_t *t) {
  int overflow = 0;
  int result;
  bool_t pass = false;
  tests_total++;
  result = tester_run(t->rs, t->rt, t->func, &overflow, t->op);
  if (t->expected_overflow) {
    if (overflow) {
      pass = true;
    }
  } else {
    if (!overflow && result == t->expected_result) {
      pass = true;
    }
  }
  if (pass) {
    tests_passed++;
    if (PRINT_SUCCESSES) {
    puts("PASS ");
    test_print_result(t, result, overflow);
    }
  } else {
    puts("FAIL ");
    test_print_result(t, result, overflow);
  }
}

void test_normal(int rs, int rt, func_t func, int expected_result) {
  test_t t = make_test(rs, rt, func, expected_result, false);
  test_run(&t);
}

void test_overflow(int rs, int rt, func_t func) {
  test_t t = make_test(rs, rt, func, 0, true);
  test_run(&t);
}

// Returns the number of failed tests
int run_alu_tests() {

  tester_setup();
  
  tests_total = 0;
  tests_passed = 0;
  
  #include "alu-test-defs.c"

  puts("ALU tests passed: ");
  print_dec(tests_passed);
  puts("/");
  print_dec(tests_total);
  puts(ENDL);

  tester_cleanup();
  return tests_total - tests_passed;
}
