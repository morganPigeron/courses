#!/bin/bash
gcc -o fileopen_buffer fileopen_buffer.c -Ofast -Wall
perf stat ./fileopen_buffer

gcc -o fileopen_mmap fileopen_mmap.c -Ofast -Wall
perf stat ./fileopen_mmap
