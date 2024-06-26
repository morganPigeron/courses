; File: rdtsc.asm

section .text
global GetTimestamp

; Function: GetTimestamp
; Description: Returns the value of the CPU's time-stamp counter (TSC)
; Returns: 64-bit value in RAX containing the timestamp
GetTimestamp:
    rdtsc            ; Read Time-Stamp Counter
    shl rdx, 32
    or rax, rdx
    ret              ; Return with result in RAX
