#!/usr/bin/env bash
nasm -f elf64 main.asm -g
ld -m elf_x86_64 main.o -o main
./main