DO_ALU_TESTS=      n#not broken
DO_PARALLEL_TESTS= n#not broken
DO_SERIAL_TESTS=   n#not broken
DO_INTERRUPT_TESTS=y#absoloutly broken

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
			interrupt/serial-evec.o, \
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
