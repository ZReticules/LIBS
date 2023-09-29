extrn C Console_SetCursorPos        :far
extrn C Console_GetCursorPos        :far
extrn C Console_PutChar             :far
extrn C Console_GetChar             :far
extrn C Console_Write               :far
extrn C Console_WriteLine           :far
extrn C Console_ReadLine            :far
extrn C Console_Clear               :far
extrn Console_SetColor              :far
extrn Console_ClearColor            :far
extrn C Console_GetKeyboardState    :far

ECHO_ON     equ 1h
ECHO_OFF    equ 8h

Console struc method {
    SetCursorPosition:dword = Console_SetCursorPos
    GetCursorPosition:dword = Console_GetCursorPos
    PutChar:dword           = Console_PutChar
    GetChar:dword           = Console_GetChar
    Write:dword             = Console_Write
    WriteLine:dword         = Console_WriteLine
    ReadLine:dword          = Console_ReadLine
    Clear:dword             = Console_Clear
    SetColor:dword          = Console_SetColor
    ClearColor:dword        = Console_ClearColor
    GetKeyboardState:dword  = Console_GetKeyboardState
}
ends