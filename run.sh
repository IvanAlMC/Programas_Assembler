#!/bin/bash
echo "type a file name: "
read file
gcc -m32 -c driver.c
nasm -f elf -d ELF_TYPE asm_io.asm
nasm -f elf $file.asm
gcc -m32 -o $file driver.o $file.o asm_io.o
./$file