@echo off

rem Assemble the assembly file using NASM for x64
nasm -f win64 rdtsc.asm -o rdtsc.obj

rem Link the object file to create a DLL
rem link /DLL /OUT:librdtsc.dll rdtsc.obj

rem Create a static library
lib /OUT:librdtsc.lib rdtsc.obj

rem Cleanup temporary files
del rdtsc.obj
