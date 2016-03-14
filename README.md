#Standalone binary tool for ttk-15#

TTK-15 emulator is a TTK-15 related project which provides a small linux x64 assembly interpreter for running ttk-15 binaries as standalone 64bit ELF binaries on linux.

At the moment there is only code for 64 bit linux.

##compiling a standalone binary##

If one wants to compile a standalone linux binary from a .k15 source, one needs to first compile the source into a ttk-15 binary with ttc (see ttk-15 compiler at github.com/apason/ttk-15) and then use the makefile provided in the src directory to compile the interpreter code and include the ttk-15 binary inside the resulting linux binary.

##TBD##

In the future I still need to add a system call translator from the ttk-15 system calls to linux system calls. Currrently output to the console is done through using a similar interface in the ttk-15 code as the linux write system call.

Still to do the kbd integer input method, and shra instuction, otherwise everything else is in order.

##Misc##

Added an example of a crackme in the root directory. If you try to reverse it, try without looking at the source code of the machine first :).

###author###
Hiski Ruhanen
