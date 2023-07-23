extrn C Int32_ToString   :far
extrn C Int32_FromString :far
extrn C Int32_Length     :far
extrn C Int32_Power      :far

Int32_MaxValue equ 2147483647
Int32_MinValue equ -2147483648

Int32 struc global method{
        ToString:dword  = Int32_ToString
        FromString:dword= Int32_FromString
        Length:dword    = Int32_Length
        Power:dword     = Int32_Power
    }
    dd ?
ends

Int32_Abs macro @@Num
local @@Abs, @@Exit
    @@Abs:
        neg @@Num
    jo @@Exit
    js @@Abs
    @@Exit:
endm

FastDiv10_Const equ 0CCCCCCCDh

FastDiv10 macro arg:req
    mul arg
    shr edx, 3
endm

FastDiv10_WithOst macro reg32:req
    mov reg32, FastDiv10_Const
    push eax
    mul reg32
    shr edx, 3
    mov reg32, edx
    lea eax, [edx*4+edx]
    shl eax, 1
    pop edx
    sub edx, eax
    mov eax, reg32
endm