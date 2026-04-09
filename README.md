This is an an ASM version of VoyageGame, a simple text based game I wrote in freshman year of HS
The original python code can be found in the py/ directory. NOTE: This program adheres to the 64-bit SystemV ABI (https://wiki.osdev.org/
System_V_ABI), and uses AT&T Assembly Syntax. It is designed to be assembled by the GNU assembler, and links to the C standard 
library. The C parts of the code are designed to be compiled with gcc. I've only tested this on my system, which is an AMD64 machine 
running Ubuntu, so YMMV. Theoretically it should work for any AMD64 machine running linux. It probably won't work on windows because Bill Gates is a special boy with his very own special calling convention that is incompatible with SystemV (even if you use something like MinGW). Your best bet for running ts on windows is probably WSL or VirtualBox. As for MacOS IDK about Intel Macs, but it definitely won't work with anything apple silicon unless you use Rosetta or something
