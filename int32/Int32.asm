model tiny
.386
.code

public Int32_Length
public Int32_Power

VERSION M520

locals __

FastDiv10_Const equ 0CCCCCCCDh

FastDiv10 macro arg:req
    mul arg
    shr edx, 3
endm

FastDiv10_WithOst macro reg32:req
.ERRIDNI <reg32>, <eax> "Wrong register, don't use eax or edx"
.ERRIDNI <reg32>, <edx> "Wrong register, don't use eax or edx"
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

Int32_Length proc C far uses edx cx ebx
@@Num equ [esp+14]
    mov cx, 2
    mov ebx, FastDiv10_Const
    mov eax, @@Num
    @@:
        dec cx
        neg eax
    jo @F
    js @B
    @@:
        FastDiv10 ebx
        mov eax, edx
        inc cx
    test eax, eax
    jnz @B
    mov ax, cx
    ret
endp

Int32_Power proc C far uses ecx edx ebx
@@Base equ [esp+16]
@@Power equ [esp+20]
@@PowerMask equ 11111b ;максимальная возможная степень для минимального числа
    mov eax, 1
    mov ecx, @@Power
    and ecx, @@PowerMask
    test ecx, ecx
    jz @@retf
        mov ebx, @@Base
       __Mulling:
            test ecx, 1
            jz @F
                imul ebx
            @@:
            imul ebx, ebx
            shr ecx, 1
        test ecx, ecx
        jnz __Mulling
    @@retf:
    ret
endp

end