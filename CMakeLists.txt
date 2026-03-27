cmake_minimum_required(VERSION 3.25)
project(voyagergame ASM C)

add_executable(voyagegame src/main.s)
add_library(randlib STATIC
    src/randlib.c
)

target_link_libraries(voyagegame PRIVATE randlib c)