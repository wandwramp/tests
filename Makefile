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


DO_ALU_TESTS=      y
DO_PARALLEL_TESTS= y
DO_SERIAL_TESTS=   y
DO_INTERRUPT_TESTS=y

AS = wasm
LD = wlink
CC = wcc
TRIM = trim

OBJS = main.o iolib.o \
	   $(if $(filter y,$(DO_ALU_TESTS)), \
			alu/alu-test.o alu/tester.o, \
			alu/alu-test-dummy.o \
		) \
	   $(if $(filter y,$(DO_PARALLEL_TESTS)), \
			parallel/parallel-test.o, \
			parallel/parallel-test-dummy.o \
		) \
	   $(if $(filter y,$(DO_SERIAL_TESTS)), \
	   		serial/serial-test.o, \
			serial/serial-test-dummy.o \
		) \
	   $(if $(filter y,$(DO_INTERRUPT_TESTS)), \
			interrupt/interrupt-test.o \
			interrupt/timer-evec.o \
			interrupt/parallel-evec.o \
			interrupt/serial-evec.o \
			interrupt/serialInts.o, \
			interrupt/interrupt-test-dummy.o \
		) \


.PHONY: clean all
all: tests.srec

.S.o:	$<
	$(AS) $<

.s.o:	$<
	$(AS) $<

.c.s:	$<
	$(CC) -S $<

.srec.mem: $<
	$(TRIM) -o $@ $<

tests.srec: $(OBJS)
	$(LD) -o $@ $^

clean:
	rm -f *.mem *.srec *.o *.s
	rm -f alu/*.o alu/*.s
	rm -f parallel/*.o
	rm -f serial/*.o
	rm -f interrupt/*.o
