DO_ALU_TESTS=y

AS = wasm
LD = wlink
CC = wcc
TRIM = trim

OBJS = main.o \
	   $(if $(filter y,$(DO_ALU_TESTS)), \
	   		alu-test.o tester.o iolib.o, \
			alu-test-dummy.o \
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
