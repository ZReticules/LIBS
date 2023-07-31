model tiny
.386
.code

public Int32_ToString
public Int32_FromString

VERSION M520

locals __

FastDiv10_Const equ 0CCCCCCCDh

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

Int32_ToString proc C far uses edx di es cx ebx
@@Num equ dword ptr [esp+18]
@@StrLink equ [esp+22]
    mov ebx, 10
    xor cx, cx
    mov eax, @@Num
    les di, @@StrLink
    test eax, eax
    jge @F
        mov es:[di], byte ptr '-'
        neg eax
        inc di
    @@:
        FastDiv10_WithOst ebx
        add dl, 30h
        push dx
        inc cx
    test eax, eax
    jnz @B
    @@:
        pop dx
        mov es:[di], dl
        inc di
    loop @B
    mov es:[di], byte ptr 0
    sub di, @@StrLink
    mov ax, di
    ret
endp

Int32_FromString proc C far uses ds si edx
@@StrLink equ [esp+12]
    xor edx, edx
    xor eax, eax
    lds si, @@StrLink
    cmp [si], byte ptr '-'
    sete dl
    add si, dx
    push dx
    mov edx, 30h
    @@:
        sub dl, 30h
        lea eax, [eax*4+eax]
        shl eax, 1
        add eax, edx
        mov dl, [si]
        inc si
    cmp dl, 0
    jne @B
    pop dx
    test dx, dx
    jz @F
        neg eax
    @@:
    ret
endp

end