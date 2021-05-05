# Makefile MINE

.PHONY: clean start_debugger start_server

all: ./calc.out

calc.out: calc.S
	 arm-linux-gnueabi-gcc $< -o $@ -ggdb3 -static -mfpu=vfp -lm

start_server:
	qemu-arm -L usr/arm-linux-gnueabi -g 3142 calc.out "3/(1+2)"

start_debugger:
	gdb-multiarch -q --nh -ex 'set architecture arm' -ex 'set sysroot /usr/arm/arm-linux-gnueabi' -ex 'file calc.out' -ex 'target remote localhost:3142' -ex 'break main'

clean:
	rm -f calc.out
