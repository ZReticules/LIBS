model tiny
.386
.code
includelib c:\libs\Mainlib.lib
include c:\libs\Heap\Heap.inc
include c:\libs\PString\PString.inc

VERSION M520

public Array_New
public Array_GetBlockSize
public Array_GetElemSize
public Array_GetLength

locals __

ArrayHead struc
    db ?                            ;тип блока
    db 2 dup (?)                    ;сегмент владельца блока
    BlockSize   db 2 dup (?)        ;размер блока
    ElementSize db 1                ;_размер элемента
    ArrayLength dw 16               ;_длина массива
ends

Array_New proc C far uses ds si bx cx
@@ArrayType     equ [esp+12]
@@ArrayLength   equ [esp+14]
    xor eax, eax
    mov bx, @@ArrayLength
    bsr cx, @@ArrayType
    mov ax, bx
    shl ax, cl
    dec ax
    shr ax, 4
    inc ax
    call Heap_AllocBlock StdCall, ax
    lea sp, [esp+2]
    jc __return
        dec ax
        push ds
        mov ds, ax
        mov ds:[ElementSize], cl
        mov ds:[ArrayLength], bx
        inc ax
        pop ds
        ror eax, 16
    __return:
    ret
endp

Array_GetBlockSize proc C far
    pop eax
    lea sp, [esp+2]
    push eax
    jmp Heap_GetBlockSize
endp

Array_GetLength proc C far uses ds
@@ArrayLink equ [esp+6]
    mov ax, @@ArrayLink[2]
    dec ax
    mov ds, ax
    mov ax, ds:[ArrayLength]
    ret
endp

Array_GetElemSize proc C far uses ds cx
@@ArrayLink equ [esp+8]
    mov ax, @@ArrayLink[2]
    dec ax
    mov ds, ax
    mov cl, ds:[ElementSize]
    mov ax, 1
    shl ax, cl
    ret
endp

end