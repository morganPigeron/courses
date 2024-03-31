#!/bin/bash

nasm -f elf64 rdtsc.asm -o rdtsc.o
ld -shared -o librdtsc.so rdtsc.o
ar rcs librdtsc.a rdtsc.o
