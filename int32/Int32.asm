model small
.386
.code

public Int32_ToString
public Int32_FromString
public Int32_Length
public Int32_Power

VERSION M520

locals __

Int32_ToString proc C far uses edx di es cx ebx
@@StrLink equ [esp+18]
@@Num equ dword ptr [esp+22]
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
        xor edx, edx
        div ebx
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
    mov es:[di+1], byte ptr 0
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

Int32_Length proc C far uses edx cx ebx
@@Num equ [esp+14]
    mov cx, 2
    mov ebx, 10
    mov eax, @@Num
    @@:
        dec cx
        neg eax
    jo @F
    js @B
    @@:
        xor edx, edx
        div ebx
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
        @@:
            imul ebx
        dec ecx
        jnz @B
    @@retf:
    ret
endp

end