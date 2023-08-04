@echo off
d:\tasm\tasm /zn /m %3\%3.asm
d:\tasm\tlib %1.lib %2%3.obj
del %3.obj