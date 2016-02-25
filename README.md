#Standalone binary tool for ttk-15#

TTK-15 emulator is a TTK-15 related project which provides a small linux x64 assembly interpreter for running ttk-15 binaries as standalone 64bit ELF binaries on linux.

At the moment there is only code for 64 bit linux.

##compiling a standalone binary##

If one wants to compile a standalone linux binary from a .k15 source, one needs to first compile the source into a ttk-15 binary with ttc (see ttk-15 compiler at github.com/apason/ttk-15) and then use the makefile provided in the src directory to compile the interpreter code and include the ttk-15 binary inside the resulting linux binary.

###author###
Hiski Ruhanen
