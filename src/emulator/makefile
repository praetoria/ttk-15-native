K15=$(wildcard *.k15)

all: emulator

emulator.o: emulator.asm a.out.b15
	nasm emulator.asm -o emulator.o -f elf64
emulator: emulator.o
	ld emulator.o -o emulator -s
a.out.b15: ${K15}
	ttc ${K15}
