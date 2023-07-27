extrn _PString_Write         :far
extrn _PString_WriteLn       :far
extrn _PString_ReadLn        :far
extrn _PString_Mov           :far
extrn _PString_Copy          :far
extrn _PString_Delete        :far
extrn _PString_Concat        :far
extrn _PString_Insert        :far
extrn _PString_MultiConcat   :far
extrn _PString_Cmp           :far
extrn _PString_Pos           :far
extrn _PString_Int32Val      :far
extrn _PString_Int32Str      :far
extrn _PString_Float32Val    :far
extrn _PString_Float32Str    :far
extrn _PString_DateVal       :far
extrn _PString_DateStr       :far
extrn _PString_TimeVal       :far
extrn _PString_TimeStr       :far

PString struc global method {
        Write:dword         = _PString_Write
        Writeln:dword       = _PString_WriteLn
        ReadLn:dword        = _PString_ReadLn
        Movs:dword          = _PString_Mov
        Copy:dword          = _PString_Copy
        Delete:dword        = _PString_Delete
        Concat:dword        = _PString_Concat
        Insert:dword        = _PString_Insert
        MultiConcat:dword   = _PString_MultiConcat
        Cmps:dword          = _PString_Cmp
        Pos:dword           = _PString_Pos
        Int32Val:dword      = _PString_Int32Val
        Int32Str:dword      = _PString_Int32Str
        Float32Val:dword    = _PString_Float32Val
        Float32Str:dword    = _PString_Float32Str
        DateVal:dword       = _PString_DateVal
        DateStr:dword       = _PString_DateStr
        TimeVal:dword       = _PString_TimeVal
        TimeStr:dword       = _PString_TimeStr
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
