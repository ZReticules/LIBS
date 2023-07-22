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
    mov eax, @@Num
    @@Abs:
        neg eax
    jo @@Exit
    js @@Abs
    @@Exit:
endm