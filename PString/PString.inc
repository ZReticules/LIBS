extrn C PString_Write       :far
extrn C PString_WriteLn     :far
extrn C PString_ReadLn      :far
extrn C PString_Mov         :far
extrn C PString_Copy        :far
extrn C PString_Delete      :far
extrn C PString_Concat      :far
extrn C PString_Insert      :far
extrn C PString_MultiConcat :far
extrn C PString_Cmp         :far
extrn C PString_Pos         :far
extrn C PString_Int32Val    :far
extrn C PString_Int32Str    :far
extrn C PString_Float32Val  :far
extrn C PString_Float32Str  :far
extrn C PString_DateVal     :far
extrn C PString_DateStr     :far
extrn C PString_TimeVal     :far
extrn C PString_TimeStr     :far

PString struc global method {
        Write:dword         = PString_Write
        Writeln:dword       = PString_WriteLn
        ReadLn:dword        = PString_ReadLn
        Movs:dword          = PString_Mov
        Copy:dword          = PString_Copy
        Delete:dword        = PString_Delete
        Concat:dword        = PString_Concat
        Insert:dword        = PString_Insert
        MultiConcat:dword   = PString_MultiConcat
        Cmps:dword          = PString_Cmp
        Pos:dword           = PString_Pos
        Int32Val:dword      = PString_Int32Val
        Int32Str:dword      = PString_Int32Str
        Float32Val:dword    = PString_Float32Val
        Float32Str:dword    = PString_Float32Str
        DateVal:dword       = PString_DateVal
        DateStr:dword       = PString_DateStr
        TimeVal:dword       = PString_TimeVal
        TimeStr:dword       = PString_TimeStr
    }
    PLength db 255
    PText db 255 dup (0)
ends

PString_New macro Name, Text:=<''>, Length, Count:=<1>
local StrText, StrLen
    IFNB <Length>
        StrLen = Length
    ELSE
        StrText equ <Text>
        StrLen sizestr StrText
        StrLen = StrLen - 2
        IF Strlen EQ 0
            StrLen = 255
        ENDIF
    ENDIF
    Name PString Count dup ({PLength = StrLen, PText = Text})
endm
