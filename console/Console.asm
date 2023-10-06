model tiny
.386
.code
locals @@

public Console_SetCursorPos
public Console_GetCursorPos
public Console_PutChar
public Console_GetChar
public Console_Write
public Console_WriteLine
public Console_ReadLine
public Console_Clear
public Console_SetColor
public Console_ClearColor
public Console_GetKeyboardState

EscPrint1 db 1bh, '['
EscPrint2 db 16 dup (?)

VERSION M520

Console_SetCursorPos proc C far uses ax dx bx
@@Point  equ [esp+10];word
    mov ah, 0Fh
    INT 10H
    mov dx, @@Point
    mov ah, 02h
    int 10h
    ret
endp

Console_GetCursorPos proc C far uses cx dx bx
    mov ah, 0Fh
    INT 10H
    mov ah, 03h
    int 10h
    mov ax, dx
    ret 
endp

Console_PutChar proc C far uses ax
@@Char = [esp+6];byte
    mov @@Char[1], dl
    mov dl, @@Char
    mov ah, 02h
    int 21h
    mov dl, @@Char[1]
    ret
endp

Console_GetChar proc C far
@@Echo equ [esp+4];byte
    mov ah, @@Echo
    int 21h
    mov ah, al
    in al, 60h
    xchg al, ah
    ret
endp

Console_Write proc C far uses si ds ax dx
@@StrOffset equ [esp+12]
    lds si, @@StrOffset
    mov ah, 02h
    @@:
        mov dl, [si]
        test dl, dl
            jz @F
        int 21h
        inc si
    jmp @B
    @@:
    ret
endp

Console_WriteLine proc C far uses ax
@@StrOffset equ [esp+6]
    call Console_Write C, dword ptr @@StrOffset
    mov ah, 0Eh
    mov al, 0Ah
    int 10h
    mov al, 0dh
    int 10h
    ret
endp

Console_ReadLine proc C far uses edx ds
@@StrLink equ [esp+10]
@@MaxLen equ [esp+14]
    xor edx, edx
    mov ds, dx
    mov dx, @@StrLink+2                 ;загрузка длинного указателя
    shl edx, 4
    movzx eax, word ptr @@StrLink       ;в 32-битный регистр
    lea edx, [edx+eax-2]
    mov al, byte ptr @@MaxLen
    push word ptr [edx]
    mov [edx], al
    mov ah, 0Ah
    int 21h
    xor eax, eax
    mov al, [edx+1]
    mov [edx+eax+2], byte ptr 0
    pop word ptr [edx]
    mov ah, 02h
    mov dh, al
    mov dl, 0Ah
    int 21h
    xor eax, eax
    mov al, dh
    ret
endp

Console_Clear proc C far uses ax edx
    mov dx, seg EscPrint2
    mov ds, dx
    mov edx, offset EscPrint2
    mov al, ds:[edx-1]
    mov [edx], word ptr '$J'
    mov dx, offset EscPrint1
    mov ah, 09h
    int 21h
    ret
endp

VERSION T410

Console_SetColor proc C far uses ax dx bx ds
@@TextAtr equ byte ptr [esp+12];byte
@@BackAtr equ byte ptr [esp+13];byte
    mov bx, seg EscPrint2
    mov ds, bx
    mov bx, offset EscPrint2
    cmp @@TextAtr, 1000b
    jl @@nobright
        mov [bx], word ptr ';1';яркость по 4 биту текста
        add bx, 2
    @@nobright:
    cmp @@BackAtr, 1000b
    jl @@noblink
        mov [bx], word ptr ';5';мерцание по 4 биту фона
        add bx, 2
    @@noblink:
    cmp @@BackAtr, 1111b
    ja @@NoBack
        mov dl, @@BackAtr
        call ConsoleColorToASCII
        MOV [bx], byte ptr '4'
        mov [bx+1], dl
        mov [bx+2], byte ptr ';'
        add bx, 3
    @@NoBack:
    cmp @@TextAtr, 1111b
    ja @@NoText
        mov dl, @@TextAtr
        call ConsoleColorToASCII
        mov [bx], byte ptr '3'
        mov [bx+1], dl
        add bx, 3
    @@NoText:
    mov [bx-1], word ptr '$m';m завершает команду смены цвета
    mov dx, offset EscPrint1
    mov ah, 09h
    int 21h
    ret
endp

ConsoleColorToASCII proc
    and dl, 111b
    test dl, 101b
    jp @@norevers
        xor dl, 101b
    @@norevers:
    add dl, 30h
    ret
endp

Console_ClearColor proc C far uses ax dx ds
    mov ax, seg EscPrint2
    mov ds, ax
    mov dword ptr EscPrint2, '0$m0'
    mov ah, 09h
    int 21h
    ret
endp

VERSION M520

Console_GetKeyboardState proc C far
    in al, 60h
    cmp al, 80h
    jb @F
        xor al, al
    @@:
    ret
endp

end