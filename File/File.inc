extrn C File_GetPointer :far
extrn C File_SetPointer :far
extrn C File_GetSize    :far
extrn C File_Open       :far
extrn C File_ReadBytes  :far
extrn C File_WriteBytes :far
extrn C File_Create     :far
extrn C File_Close      :far
extrn C File_Delete     :far

File struc global method {                      ;ARGS:
        GetPointer:dword    = File_GetPointer   ;FHandle:WORD
        SetPointer:dword    = File_SetPointer   ;FHandle:WORD, Position:WORD, Mode:WORD
        GetSize:dword       = File_GetSize      ;FHandle:WORD
        Open:dword          = File_Open         ;PathLink:DWORD(ASCIIZ)
        ReadBytes:dword     = File_ReadBytes    ;FHandle:WORD, DesLink:DWORD, ByteCount:WORD
        WriteBytes:dword    = File_WriteBytes   ;FHandle:WORD, SrcLink:DWORD, BtCount:WORD
        Create:dword        = File_Create       ;PathLink:DWORD(ASCIIZ)
        Close:dword         = File_Close        ;FHandle:WORD
        Delete:dword        = File_Delete       ;PathLink:DWORD(ASCIIZ)
    }
    FHandle     dw ?
ends

FILE_START  equ 4200h
FILE_NOW    equ 4201h
FILE_END    equ 4202h
STDIN       equ 00h
STDOUT      equ 01h
STDERR      equ 02h