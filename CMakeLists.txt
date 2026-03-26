cmake_minimum_required(VERSION 3.25)
project(voyagergame ASM C)

add_executable(voyagegame src/main.s)
add_library(vglib STATIC
    src/vglib.s
)

target_link_libraries(voyagegame PRIVATE vglib c)