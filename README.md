This is an an ASM version of VoyageGame, a simple text based game I wrote in freshman year of HS.
The original python code can be found in the py/ directory. NOTE: This program adheres to the 64-bit SystemV ABI (https://wiki.osdev.org/
System_V_ABI), and uses AT&T Assembly Syntax. It is designed to be assembled by the GNU assembler, and links to the C standard
library. The C parts of the code are designed to be compiled with gcc. I've only tested this on my system, which is an AMD64 machine
running Ubuntu, so YMMV. Theoretically it should work for any AMD64 machine running linux. It probably won't work on windows because
Bill Gates is a special boy with his very own special calling convention that is incompatible with SystemV (even if you use something like MinGW). 
Your best bet for running ts on windows is probably WSL or VirtualBox.


## BUILD INSTRUCTIONS
Requirements:
- Linux
- gcc 13.3+
- CMake 3.23.3+

### Step 1
Clone this repository with `git clone https://github.com/Bobcat66/voyagegameASM`  
this will create a new `voyagegameASM/` directory, containing this repository
### Step 2
Enter the voyagegameASM directory with `cd voyagegameASM`
### Step 3
Configure the build system by running `cmake -S . -B build`.  
Then run `cmake --build build`  

Once the game is built, it can be run by executing `./build/voyagegame` from the `voyagegameASM` directory



