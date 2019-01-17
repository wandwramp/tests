# Tests for Basys WRAMP

This repository contains a test suite for use with the Basys implementation
of the WRAMP architecture.
It aims to test all instructions and hardware in an automated fashion
where possible, and to guide user interaction where automation is impossible.

It is implemented as a WRAMP program written in a combination of C and
WRAMP assembly. It can be compiled via `make`, and depends on the standard
toolchain including `wasm`, `wlink`, and `wcc`. It can be deployed in the
standard fashion via WRAMPmon.
