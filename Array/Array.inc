extrn C Array_New           :far
extrn C Array_GetBlockSize  :far
extrn C Array_GetElemSize   :far
extrn C Array_GetLength     :far

Array struc global method {
        New:dword           = Array_New            
        GetBlockSize:dword  = Array_GetBlockSize   
        GetElemSize:dword   = Array_GetElemSize    
        GetLength:dword     = Array_GetLength      
    }
    dw 0
    dw 0
ends

Array_NewFromVal macro ElemsType:req, Values:vararg
local ArgCount, A_reg, ErrorLabel
    ArgCount=0
    irp x, Values
        ArgCount=ArgCount+1
    endm
    if argcount eq 0
        err 'Недопустимое количество аргументов'
    else 
        call Array_New StdCall, ElemsType, argcount
        lea sp, [esp+4]
        jc ErrorLabel
            push fs eax
            ror eax, 16
            mov fs, ax
            ifidni <ElemsType>, <dword>
                A_reg equ <eax>
            else ifidni <ElemsType>, <word>
                A_reg equ <ax>
            else
                A_reg equ <al>
            endif
            ValueCounter=0
            irp ArgValue, Values
                mov A_reg, ArgValue
                mov fs:[ValueCounter*ElemsType], A_reg
                ValueCounter=ValueCounter+1
            endm
            pop eax fs
        ErrorLabel:
    endif
endm