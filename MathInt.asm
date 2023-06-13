model tiny
.386
.code

Include c:\macros\Support.inc

RndNow dd 0
RndMul dd 69621                     ;множитель рандома
RndMax dd 7FFFFFFFh                 ;ограничитель хранимых значений

public ChArrInt
public IntChArr
public IntPrint
public IntScan
public Random
public IntLen

ChArrInt proc c far uses si ebx 
arg StrLink:word, StrLen:word
local MaxLink:word, Ten:dword
mov Ten, 10
mov byte ptr StrLen+1, 0
    mov si, StrLink
    push si
    mov ax, StrLen
    add si, StrLen
    mov MaxLink, si
    pop si
    cmp byte ptr [si], '-'
    jne nosign
        inc si
    nosign:
    xor eax, eax
    xor ebx, ebx
    cycle:
        mov bl, [si]
        sub bl, 30h
        mul Ten
        add eax, ebx
        inc si
    cmp si, MaxLink
    jne cycle
    mov si, StrLink
    cmp byte ptr [si], '-'
    jne nosig
        neg eax
    nosig:
ret
endp

IntChArr proc c far
arg ChArrLink:word, Num:dword
    call IntConvertio C, Num, CStrMode, ChArrLink
ret
endp

IntPrint proc c far
arg Num:dword
    call IntConvertio C, Num, PrntMode
ret
endp

MAX_NUM_LEN equ 9+3*1                   ;9 символов - длина макс. числа, +1 для длины, +1 для Enter, +1 для '-'

IntScan proc c far uses ds dx bx
Local StrBuf:byte:14
    mov StrBuf, MAX_NUM_LEN
    mov ax, ss
    mov ds, ax
    lea dx, StrBuf
    mov ah, 0ah
    int 21h
    add dx, 2
    call ChArrInt c, dx, word ptr StrBuf+1
ret
endp

Random proc c far uses edx es ds
arg MinValue:dword, MaxValue:dword
local RetValue:dword, Diver:dword
mov ax, seg RndMax
mov ds, ax
    cmp RndNow, 0
    je GenNew
    mov eax, RndNow
    NextRnd:
        mul RndMul
        push eax
        div RndMax
        mov RndNow, edx
        pop eax
        mov edx, MaxValue
        sub edx, MinValue
        mov Diver, edx
        xor edx, edx
        div Diver
        add edx, MinValue
        mov eax, edx
    ret
    GenNew:
        push 0040h                          ;адрес памяти DOS системным таймером
        pop es
        mov eax, es:006Ch
    jmp NextRnd
endp

Intlen proc C far uses edx
arg num:dword
local count:dword, ten:dword
mov count, 0
mov ten, 10
    mov eax, num
    @@trueneg:
        neg eax
    js @@trueneg
    @@diving:
        xor edx, edx
        div ten
        inc count
    cmp eax, 0
    jne @@diving
    mov eax, count
    ret
endp

end
