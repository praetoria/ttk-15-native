#Standalone binary tool for ttk-15#

TTK-15 emulator is a TTK-15 related project which provides a small linux x64 assembly interpreter for running ttk-15 binaries as standalone 64bit ELF binaries on linux or 64bit Windows binaries.

There is working code for windows 64 bit and Linux 64 bit.

##Compiling a standalone binary##

If one wants to compile a standalone linux binary from a .k15 source, one needs to first compile the source into a ttk-15 binary with ttc (see ttk-15 compiler at github.com/apason/ttk-15) and then use the makefile provided in the src directory to compile the interpreter code and include the ttk-15 binary inside the resulting standalone binary.

##TBD##

Only in ri,=KBD is yet to be implemented on both versions, otherwise basic ttk-91 functionality is done. (ttk-15 has floating point instructions which are not implemented here yet)


##Misc##

Added an example of a crackme in the root directory. If you try to reverse it, try without looking at the source code of the machine first :).

###Author###
Hiski Ruhanen
