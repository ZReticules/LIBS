model tiny
.386
.code

locals @@

EscPrint1 db 1bh, '['
EscPrint2 db 16 dup (?)

Console_GreyPalette proc C far uses ax bx
arg GreyTrue:byte
    mov ah, 12h
    mov bl, 33h
    mov al, GreyTrue
    int 10h
    ret
endp

Console_DrawRect proc C far uses ax bx cx dx
arg TextAtr:byte, FoneAtr:byte, XHigh:byte, YHigh:byte, XLow:byte, YLow:byte
    mov bh, TextAtr
    shl bh, 4
    add bh, FoneAtr
    mov cl, XHigh
    mov ch, YHigh
    mov dl, XLow
    mov dh, YLow
    mov ah, 06
    xor al, al
    int 10h
    ret
endp

Console_Fill proc C far uses ax
arg TextAtr:word, FoneAtr:word
    mov ah, 0fh
    int 10h
    shr ax, 8
    call Console_DrawRect C, TextAtr, FoneAtr, 0, 0, ax, 24
    ret
endp

Console_SetColor proc C far uses ax dx bx ds
arg TextAtr:byte, FoneAtr:byte
    mov bx, seg EscPrint2
    mov ds, bx
    mov bx, offset EscPrint2
    cmp TextAtr, 1000b
    jl @@nobright
        mov [bx], byte ptr '5'
        mov [bx+1], byte ptr ';'
        add bx, 2
    @@nobright:
    cmp TextAtr, 1000b
    jl @@noblink
        mov [bx], byte ptr '1'
        mov [bx+1], byte ptr ';'
        add bx, 2
    @@noblink:
    mov dl, TextAtr
    call Reverse3Bit
    add dl, 30h
    mov [bx], byte ptr '4'
    mov [bx+1], dl
    mov [bx+2], byte ptr ';'
    mov dl, FoneAtr
    call Reverse3Bit
    add dl, 30h
    mov [bx+3], byte ptr '3'
    mov [bx+4], dl
    mov [bx+5], byte ptr 'm'
    mov [bx+6], byte ptr '$'
    mov dx, offset EscPrint1
    mov ah, 09h
    int 21h
    ret
    Reverse3Bit proc
        and dl, 111b
        test dl, 101b
        jp @@norevers
        xor dl, 101b
        @@norevers:
        ret
    endp
endp

Console_ClearColor proc C far uses ax dx ds
    mov ax, seg EscPrint2
    mov ds, ax
    mov EscPrint2, '0'
    mov EscPrint2+1, byte ptr 'm'
    mov EscPrint2+2, byte ptr '$'
    mov dx, offset EscPrint1
    mov ah, 09h
    int 21h
    ret
endp

Console_ChgColor proc C far uses ax bx
arg Color:byte, Red:Byte, Green:byte, Blue:byte
    xor ah, ah
    ror Red, 1
    ror Green, 1
    ror Blue, 1
    call RolColors
    rol Red, 1
    rol Green, 1
    rol Blue, 1
    call RolColors
    shr bx, 2
    mov bl, Color
    mov ax, 1000h;
    int 10h
    ret
    RolColors proc
        mov al, Blue
        shrd bx, ax, 1
        mov al, Green
        shrd bx, ax, 1 
        mov al, Red
        shrd bx, ax, 1  
        ret
    endp
endp

Console_SetCursorPos proc C far uses ax dx bx
arg @X:byte, @Y:byte
    mov ah, 0fh
    int 10h
    mov dl, @X
    mov dh, @Y
    mov ah, 02h
    int 10h
    ret
endp

Console_ColorStrPrint proc C far uses ax bx cx dx es
arg PrntSeg:word, PrntLink:word, NumSmb:word, TextAtr:byte, FoneAtr:byte, @X:byte, @Y:byte, MovCurs:byte
    mov ah, 0fh
    int 10h
    mov ah, 13h
    mov cx, PrntSeg
    mov es, cx
    mov cx, NumSmb
    mov bl, TextAtr
    shl bl, 4
    add bl, FoneAtr
    mov dl, @X
    mov dh, @Y
    mov al, MovCurs
    push bp
    mov bp, PrntLink
    int 10h
    pop bp
    ret
endp

end