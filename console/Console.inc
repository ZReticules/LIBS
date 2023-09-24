extrn Console_SetCursorPos      :far
extrn Console_GetCursorPos      :far
extrn Console_PutChar           :far
extrn Console_GetChar           :far
extrn Console_Write             :far
extrn Console_WriteLine         :far
extrn Console_ReadLine          :far
extrn Console_Clear             :far
extrn Console_SetColor          :far
extrn Console_ClearColor        :far
extrn Console_GetKeyboardState  :far

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