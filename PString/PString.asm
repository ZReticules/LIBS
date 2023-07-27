model tiny
.386
.code

VERSION M520

includelib c:\libs\int32\int32.lib
    extrn _Int32_ToString      :far
    extrn _Int32_FromString    :far
includelib c:\libs\Float32\Float32.lib
    extrn _Float32_ToString    :far
    extrn _Float32_FromString  :far
includelib c:\libs\datetime\datetime.lib
    extrn DateTime_UnixToStr  :far
    extrn DateTime_StrToUnix  :far
    extrn TimeSpan_UnixToStr  :far
    extrn TimeSpan_StrToUnix  :far

locals __

public PString_Write
public PString_WriteLn
public PString_ReadLn
public PString_Mov
public PString_Copy
public PString_Delete
public PString_Concat
public PString_Insert
public PString_MultiConcat
public PString_Cmp
public PString_Pos
public PString_Int32Val
public PString_Int32Str
public PString_Float32Val
public PString_Float32Str
public PString_DateVal
public PString_DateStr
public PString_TimeVal
public PString_TimeStr

PString_Write proc C far uses dx ax si ds
@@PStrLink equ [esp+12]
    lds si, @@PStrLink
    mov ah, 02h
    mov dh, [si]
    @@:
        mov dl, [si+1]
        int 21h
        inc si
    dec dh
    jnz @B
    ret
endp

PString_WriteLn proc C far uses ax dx
@@PStrLink equ dword ptr [esp+8]
    call PString_Write C, @@PStrLink
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    mov dl, 0Dh
    int 21h
    ret
endp

PString_ReadLn proc C far uses edx ax ds
@@PStrLink equ [esp+12]
    xor edx, edx
    mov ds, dx
    mov dx, @@PStrLink+2                 ;����㧪� �������� 㪠��⥫�
    shl edx, 4
    xor eax, eax
    mov ax, word ptr @@PStrLink       ;� 32-���� ॣ����
    lea edx, [edx+eax-1]
    push word ptr [edx-1]
    mov al, byte ptr [edx+1]
    mov [edx], al
    mov ah, 0Ah
    int 21h
    pop word ptr [edx-1]
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    ret
endp

PString_Mov proc C far uses es di ds si cx
@@StrDesLink equ [esp+14]
@@StrSrcLink equ [esp+18]
    lds si, @@StrSrcLink
    xor cx, cx
    mov cl, byte ptr [si]
    les di, @@StrDesLink
    inc cx
    rep movsb
    ret
endp

PString_Copy proc C far uses es di ds si cx
@@StrDesLink equ [esp+14]
@@StrSrcLink equ [esp+18]
@@StartIndex equ [esp+22]
@@FinIndex   equ [esp+24]
    les di, @@StrDesLink
    lds si, @@StrSrcLink
    xor cx, cx
    mov cl, byte ptr @@StartIndex
    add si, cx
    sub cl, @@FinIndex
    neg cl
    inc cl
    mov es:[di], cl
    inc di
    rep movsb
    ret
endp

PString_Delete proc C far uses es di ds si cx
@@PStrLink   equ [esp+14]
@@StartIndex equ [esp+18]
@@FinIndex   equ [esp+20]
    lds si, @@PStrLink
    les di, @@PStrLink
    xor cx, cx
    mov cl, byte ptr @@FinIndex
    cmp [si], cl
    ja __lowmax
        mov cl, @@StartIndex
        mov [si], cl
        jmp __return
    __lowmax:
    sub cl, [si]
    neg cl
    push cx
    mov cl, @@StartIndex+2
    add di, cx
    mov cl, @@FinIndex+2
    add si, cx
    inc si
    pop cx
    rep movsb
    __return:
    sub di, @@PStrLink
    lea cx, [di-1]
    mov di, @@PStrLink
    mov [di], cl
    ret
endp

PString_Concat proc C far uses es di ds si cx ax
@@PStrDesLink equ [esp+16]
@@PStrSrcLink equ [esp+20]
    les di, @@PStrDesLink
    lds si, @@PStrSrcLink
    lea cx, [di+256]
    xor ax, ax
    mov al, es:[di]
    add di, ax
    mov ah, [si]
    @@:
        inc si
        inc di
        cmp di, cx
            je __ERR
        mov al, [si]
        mov es:[di], al
    dec ah
    jnz @B
    jmp __NOERR
    __ERR:
    mov di, @@PStrDesLink
    mov es:[di], byte ptr 255
    stc
    jmp __return
    __NOERR:
    sub di, @@PStrDesLink
    mov cx, di
    mov di, @@PStrDesLink
    mov es:[di], cl
    __return:
    ret
endp

PString_Insert proc C far uses ecx ebx es eax
@@PStrDesLink   equ [esp+278]
@@PStrSrcLink   equ [esp+282]
@@StartIndex    equ word ptr [esp+286]
@@StrBufer     equ [esp]
    sub esp, 260
    xor ebx, ebx
    mov es, bx
    mov bx, word ptr @@PStrDesLink+2
    shl ebx, 4
    xor ecx, ecx
    mov cx, word ptr @@PStrDesLink
    add ebx, ecx
    xor cx, cx
    mov cl, byte ptr es:[ebx]
    mov al, byte ptr @@StartIndex
    cmp cl, al
    ja @F
        call Concater
        jmp __return
    @@:
    mov es:[ebx], al
    mov bx, sp
    mov ax, @@StartIndex
    inc ax
    call PString_Copy C, ss bx, dword ptr @@PStrDesLink+4, ax, cx
    call Concater
    call PString_Concat C, dword ptr @@PStrDesLink+4, ss bx
    __return:
    add esp, 260
    ret
    Concater proc near
        call PString_Concat C, dword ptr @@PStrDesLink+6, dword ptr @@PStrSrcLink+2
        ret
    endp
endp

PString_MultiConcat proc C far uses ebx eax
@@PStrDesLink equ [esp+16]                  ;ᤢ���� �� 4 ��� ⮣� �⮡� ������ � �⥪
@@PStrSrcLink equ [esp+12]                  ;ᤢ���� ���⭮ �.�. ebx
    xor ebx, ebx
    @@:
        add ebx, 4
        call PString_Concat StdCall, dword ptr @@PStrDesLink, dword ptr @@PStrSrcLink[ebx]
        lea sp, [esp+8]
        jc __carry
    cmp @@PStrSrcLink[ebx+4], dword ptr 0
    jne @B
    __carry:
    ret
endp

PString_Cmp proc StdCall far uses es di ds si cx
@@PStrDesLink equ [esp+14]
@@PStrSrcLink equ [esp+18]
    lds si, @@PStrDesLink   ;㯮��� ��⥬� �ࠢ����� si � di
    les di, @@PStrSrcLink
    xor cx, cx
    mov cl, byte ptr [si]
    cmp cl, es:[di]
    jne __return
        inc cx
        rep cmpsb
    __return:
    ret
endp

PString_Pos proc C far uses es di ds si cx
@@PStrDesLink equ [esp+14]
@@PStrSrcLink equ [esp+18]
    les di, @@PStrDesLink   ;㯮��� ��⥬� �ࠢ����� si � di
    lds si, @@PStrSrcLink
    xor cx, cx
    mov cl, es:[di]
    sub cl, [si]
    jb __PosNotFound
    mov ax, cx
    inc di
    add ax, di
    mov cl, [si]
    inc si
    @@:
        push di si cx
        repz cmpsb
        pop cx si di
        jz __FinallyFound
        inc di
    cmp di, ax
    jle @B
    jmp __PosNotFound
    __FinallyFound:
        sub di, @@PStrDesLink
        mov ax, di
    __return:
    ret
    __PosNotFound:
        xor ax, ax
    jmp __return
endp

PString_Int32Val proc C far uses ds edi
@@PStrLink equ [esp+10]
    lds di, @@PStrLink
    call PrepareStr
    call _Int32_FromString C, word ptr @@PStrLink+2 di
    ret
endp

PrepareStr proc near
    and edi, 0ffffh
    xor eax, eax
    mov al, [di]
    inc di
    mov [edi+eax], byte ptr 0
    ret
endp

PString_Int32Str proc C far uses ds di eax
@@PStrLink equ [esp+12]
@@Int32Val equ [esp+20] ;+4 ��� ⮣� �⮡� ������ � �⥪
    mov ax, @@PStrLink
    inc ax
    call _Int32_ToString C, dword ptr @@Int32Val, word ptr @@PStrLink+2 ax
    lds di, @@PStrLink
    mov [di], al
    ret
endp

PString_Float32Str proc C far uses ds edi
@@PStrLink equ [esp+10]
    mov ax, @@PStrLink
    inc ax
    call _Float32_ToString C, word ptr @@PStrLink+2 ax
    lds di, @@PStrLink
    mov [di], al
    ret
endp

PString_Float32Val proc C far uses ds edi
@@PStrLink equ [esp+10]
    lds di, @@PStrLink
    call PrepareStr
    call _Float32_FromString C, word ptr @@PStrLink+2 di
    ret
endp

PString_DateStr proc C far uses ds di eax
@@PStrLink equ [esp+12]
@@Int32Val equ [esp+20] ;+4 ��� ⮣� �⮡� ������ � �⥪
    mov ax, @@PStrLink
    inc ax
    call DateTime_UnixToStr C, dword ptr @@Int32Val, word ptr @@PStrLink+2 ax
    lds di, @@PStrLink
    mov [di], al
    ret
endp

PString_DateVal proc C far uses ds edi
@@PStrLink equ [esp+10]
    lds di, @@PStrLink
    call PrepareStr
    call DateTime_StrToUnix C, word ptr @@PStrLink+2 di
    ret
endp

PString_TimeVal proc C far uses ds edi
@@PStrLink equ [esp+10]
    lds di, @@PStrLink
    call PrepareStr
    call TimeSpan_StrToUnix C, word ptr @@PStrLink+2 di
    ret
endp

PString_TimeStr proc C far uses ds di eax
@@PStrLink equ [esp+12]
@@Int32Val equ [esp+20] ;+4 ��� ⮣� �⮡� ������ � �⥪
    mov ax, @@PStrLink
    inc ax
    call TimeSpan_UnixToStr C, dword ptr @@Int32Val, word ptr @@PStrLink+2 ax
    lds di, @@PStrLink
    mov [di], al
    ret
endp

end