@echo off
d:\tasm\tasm /zn %3.asm
d:\tasm\tlib %1.lib %2%3.obj
del %3.obj