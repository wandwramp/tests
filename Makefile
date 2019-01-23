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
	$(LD) -v -o $@ $^

clean:
	rm -f *.mem *.srec *.o *.s
	rm -f alu/*.o alu/*.s
	rm -f parallel/*.o
	rm -f serial/*.o
