model tiny
.386
.code

VERSION M520

public Heap_GetTotalSize
public Heap_ResizeBlock
public Heap_Create
public Heap_AllocBlock
public Heap_GetBlockSize
public Heap_FreeBlock

locals __

Heap_GetTotalSize proc C far uses ebx
    mov bx, 0ffffh
    mov ah, 48h
    int 21h
    mov ax, bx
    ret
endp

Heap_ResizeBlock proc C far uses es bx ax
@@NewSize equ [esp+10]
@@SegNum equ [esp+12]
    les bx, @@NewSize
    mov ah, 4Ah
    int 21h
    ret
endp

Heap_Create proc C far
@@FinishSeg equ [esp+6]
@@StartSeg equ [esp+10]
    mov [esp-2], ax
    mov ax, @@FinishSeg
    sub ax, @@StartSeg
    mov @@StartSeg, ax
    mov ax, [esp-2]
    jmp Heap_ResizeBlock
endp

Heap_AllocBlock proc C far uses bx
@@MemSize equ [esp+6]
    xor eax, eax
    mov bx, @@MemSize
    mov ah, 48h
    int 21h
    ret
endp

Heap_GetBlockSize proc C far
@@SegNum equ [esp+4]
    mov ax, ds
    shl eax, 16
    mov ax, @@SegNum
    dec ax
    mov ds, ax
    mov ax, ds:[3]
    ror eax, 16
    mov ds, ax
    xor ax, ax
    ror eax, 16
    ret
endp

Heap_FreeBlock proc StdCall far uses eax
@@NumBlock equ [esp+8]
    mov ax, es
    shl eax, 16
    mov ax, @@NumBlock
    mov es, ax
    mov ah, 49h
    int 21h
    ror eax, 16
    mov es, ax
    ror eax, 16
    jnc __NormalRet
        lea sp, [esp+4]
        ret 0
    __NormalRet:
    ret
endp

end