model tiny
.386
.code

public IntConvertio

CStrMode = word ptr 0
PStrMode = word ptr 2
PrntMode = word ptr 4

WorkMods dw offset C_StringMode
         dw offset P_StringMode
         dw offset PrintMode

IntConvertio proc c far uses edx eax bx si
arg Num:dword, WorkMode:word, ArrLink:word
local Diver:dword,Ten:dword,Zflag:byte:1,ArrLen:byte:1, AddressReturn:word
mov Diver, 1000000000
mov zflag, 0
mov ArrLen, 0
mov Ten, 10
mov ax, seg CStrMode
mov ds, ax
    mov bx, WorkMode
    mov si, WorkMods[bx]
    mov WorkMode, si
    mov si, ArrLink
    cmp num, 0
    jne nozero
        mov al, '0'
        push offset @@1
        pop AddressReturn
        jmp WorkMode
        @@1:
        mov eax, 1
        ret
    nozero:
    jg no_neg
        mov al, '-'
        push offset @@2
        pop AddressReturn
        jmp WorkMode
        @@2:
        neg num
    no_neg:
    xor edx, edx
    mov eax, num
    cycle:
        div Diver
        cmp al, 0
        je noflag
            mov ZFlag, 1
        noflag:
        cmp ZFlag, 0
        je noprint
            add al, 30h
            push offset noprint
            pop AddressReturn
            jmp WorkMode
        noprint:
        cmp Diver, 1
        je break
        push edx
        xor edx, edx
        mov eax, Diver
        div Ten
        mov Diver, eax
        pop eax
    jmp cycle
break:
xor eax, eax
mov al, ArrLen
ret
    P_StringMode:
        inc ArrLen
        inc si
        mov [si], al
        push si
        mov si, ArrLink
        mov al, ArrLen
        mov [si], al
        pop si
    jmp AddressReturn

    C_StringMode:
        inc ArrLen
        inc si
        mov [si], al
        mov byte ptr [si+1], 0
    jmp AddressReturn

    PrintMode:
        inc ArrLen
        push dx
        mov dl, al
        mov ah, 02h
        int 21h
        pop dx
    jmp AddressReturn

endp

end
