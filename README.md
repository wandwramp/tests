# Tests for Basys WRAMP

This repository contains a test suite for use with the Basys implementation
of the WRAMP architecture.
It aims to test all instructions and hardware in an automated fashion
where possible, and to guide user interaction where automation is impossible.

It is implemented as a WRAMP program written in a combination of C and
WRAMP assembly. It can be compiled via `make`, and depends on the standard
toolchain including `wasm`, `wlink`, and `wcc`. It can be deployed in the
standard fashion via WRAMPmon.

Thanks to Tom Levy for making the first version of the ALU test runner.

The program can be forced to print instruction test successes by changing
the line `#define PRINT_SUCCESSES 0` in [alu-test.c](alu-test.c).  
It can be compiled without any combinations of tests by changing the value of
DO\_XXX\_TESTS to anything other than `y` in the [Makefile](Makefile).
This drastically reduces the size of the resulting file, leading to faster
download times when those tests are not desired.
