model small
.386
.code

VERSION M520

LOCALS __

public EGAColor_ChgColor

EGAColor_ChgColor proc C far uses ax bx
Color   equ byte ptr [esp+8]
Red     equ byte ptr [esp+10]
Green   equ byte ptr [esp+12]
Blue    equ byte ptr [esp+14]
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
    RolColors proc near
        mov al, Blue+2
        shrd bx, ax, 1
        mov al, Green+2
        shrd bx, ax, 1 
        mov al, Red+2
        shrd bx, ax, 1  
        ret
    endp
endp

end