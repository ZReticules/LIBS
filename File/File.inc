extrn C File_GetPointer :far
extrn C File_SetPointer :far
extrn C File_GetSize    :far
extrn C File_Open       :far
extrn C File_ReadBytes  :far
extrn C File_WriteBytes :far
extrn C File_Create     :far
extrn C File_Close      :far
extrn C File_Delete     :far

File struc global method {
        GetPointer:dword    = File_GetPointer
        SetPointer:dword    = File_SetPointer
        GetSize:dword       = File_GetSize
        Open:dword          = File_Open
        ReadBytes:dword     = File_ReadBytes
        WriteBytes:dword    = File_WriteBytes
        Create:dword        = File_Create
        Close:dword         = File_Close
        Delete:dword        = File_Delete
    }
    FHandle     dw ?
ends

FILE_START  equ 4200h
FILE_NOW    equ 4201h
FILE_END    equ 4202h
STDIN       equ 00h
STDOUT      equ 01h
STDERR      equ 02h