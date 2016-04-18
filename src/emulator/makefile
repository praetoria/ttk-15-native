K15=$(wildcard *.k15)

all: emulator emulator_win.exe

emulator.o: emulator.asm a.out.b15
	nasm emulator.asm -o emulator.o -f elf64
emulator_win.o: emulator_win.asm a.out.b15
	nasm emulator_win.asm -o emulator_win.o -f win64
emulator: emulator.o
	ld emulator.o -o emulator -s
emulator_win.exe: emulator_win.o
	x86_64-w64-mingw32-gcc emulator_win.o -o emulator_win.exe -Wl,-subsystem,console -lkernel32
a.out.b15: ${K15}
	ttc ${K15}
