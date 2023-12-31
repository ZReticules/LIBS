extrn C Array_New           :far
extrn C Array_GetBlockSize  :far
extrn C Array_GetElemSize   :far
extrn C Array_GetLength     :far
extrn C Array_FromStatic    :far

ArrayHead struc
    db ?                            ;⨯ �����
    db 2 dup (?)                    ;ᥣ���� �������� �����
    BlockSize   db 2 dup (?)        ;ࠧ��� �����
    ElementSize db 1                ;_ࠧ��� �������
    ArrayLength dw 16               ;_����� ���ᨢ�
ends

Array struc global method {
        New:dword           = Array_New            
        GetBlockSize:dword  = Array_GetBlockSize   
        GetElemSize:dword   = Array_GetElemSize    
        GetLength:dword     = Array_GetLength
        FromStatic:dword    = Array_FromStatic      
    }
    dw 0
    dw 0
ends

Array_NewFromVal macro ElemsType:req, Values:vararg
local ArrLoc, ArrSize
    jmp @F
    ifidni <ElemsType>, <DWORD>
        ArrLoc dd Values
    else ifidni <ElemsType>, <WORD>
        ArrLoc dw Values
    else 
        ArrLoc db Values
    endif
    ArrSize equ $-ArrLoc
    @@:
    call Array_FromStatic StdCall, ElemsType, cs offset ArrLoc, ArrSize
    lea sp, [esp+8]
endm

; Array_NewFromVal macro ElemsType:req, Values:vararg
; local ArgCount, A_reg, ErrorLabel
;     ArgCount=0
;     irp x, Values
;         ArgCount=ArgCount+1
;     endm
;     if argcount eq 0
;         err '�������⨬�� ������⢮ ��㬥�⮢'
;     else 
;         call Array_New StdCall, ElemsType, argcount
;         lea sp, [esp+4]
;         jc ErrorLabel
;             push fs eax
;             ror eax, 16
;             mov fs, ax
;             ifidni <ElemsType>, <dword>
;                 A_reg equ <eax>
;             else ifidni <ElemsType>, <word>
;                 A_reg equ <ax>
;             else
;                 A_reg equ <al>
;             endif
;             ValueCounter=0
;             irp ArgValue, Values
;                 mov A_reg, ArgValue
;                 mov fs:[ValueCounter*ElemsType], A_reg
;                 ValueCounter=ValueCounter+1
;             endm
;             pop eax fs
;         ErrorLabel:
;     endif
; endm