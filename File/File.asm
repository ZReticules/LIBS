model tiny
.386
.code

;все пути в формате ASCIIZ
VERSION M520

public File_GetPointer
public File_SetPointer
public File_GetSize
public File_Open
public File_ReadBytes
public File_WriteBytes
public File_Create
public File_Close
public File_Delete

LOCALS __

FILE_START  equ 4200h
FILE_NOW    equ 4201h
FILE_END    equ 4202h
STDIN       equ 00h
STDOUT      equ 01h
STDERR      equ 02h

File_GetPointer proc C far
@@FHandle equ word ptr [esp+4]
    call File_SetPointer C, @@FHandle+6, dword ptr 0, FILE_NOW
    ret
endp

;третий аргумент - 3 возможных значения:
;начало файла, конец файла и текущий указатель
File_SetPointer proc C far uses cx dx bx
@@FHandle   equ word ptr [esp+10]
@@Position  equ word ptr [esp+12]      ;x2
@@Mode      equ word ptr [esp+16]
    mov bx, @@FHandle
    mov dx, @@Position
    mov cx, @@Position[2]
    mov ax, @@Mode
    int 21h
    rol eax, 16
    mov ax, dx
    rol eax, 16
    ret
endp

File_GetSize proc C far uses edx
@@FHandle equ word ptr [esp+8]
    call File_GetPointer C, @@FHandle
    mov edx, eax
    call File_SetPointer C, @@FHandle+6, dword ptr 0, FILE_END
    xchg edx, eax
    call File_SetPointer C, @@FHandle+6, eax, FILE_START
    mov eax, edx
    ret
endp

File_Open proc C far uses ds dx
@@PathLink  equ [esp+8]
    lds dx, @@PathLink
    mov al, 10100010b
    mov ah, 3Dh
    int 21h
    ret
endp

;можно использовать для консольного ввода
;через STDIN в качестве дескриптора
File_ReadBytes proc C far uses ds dx bx cx
@@FHandle   equ [esp+12]
@@DesLink   equ [esp+14]
@@BtCount   equ [esp+18]
    mov bx, @@FHandle
    lds dx, @@DesLink
    mov cx, @@BtCount
    mov ah, 3Fh
    int 21h
    ret
endp

;можно использовать для консольного вывода
;через STDOUT в качестве дескриптора
File_WriteBytes proc C far uses ds dx bx cx
@@FHandle   equ [esp+12]
@@SrcLink   equ [esp+14]
@@BtCount   equ [esp+18]
    mov bx, @@FHandle
    lds dx, @@SrcLink
    mov cx, @@BtCount
    mov ah, 40h
    int 21h
    ret
endp

File_Create proc C far uses ds dx cx
@@FPathLink equ [esp+10]
    lds dx, @@FPathLink
    xor cx, cx
    mov ah, 3Ch
    int 21h
    ret
endp

File_Close proc C far uses bx
@@FHandle equ [esp+6]
    mov bx, @@FHandle
    mov ah, 3Eh
    int 21h
    ret
endp

;указывается путь к файлу
File_Delete proc C far uses ds dx
@@FPathLink equ [esp+8]
    lds dx, @@FPathLink
    mov ah, 41h
    int 21h
    ret
endp

end