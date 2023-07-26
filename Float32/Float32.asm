model tiny
.386
.code

Version M520

public Float32_ToString
public Float32_Log
public Float32_Lg
public Float32_Ln
public Float32_FromString
public Float32_ToRad
public Float32_ToGrad
public Float32_ArcSin
public Float32_ArcCos
public Float32_PowerUndef
public Float32_Power
public Float32_ToInt32

Locals __

FastDiv10_Const equ 0CCCCCCCDh

FastDiv10_WithOst macro reg32:req
    mov reg32, FastDiv10_Const
    push eax
    mul reg32
    shr edx, 3
    mov reg32, edx
    lea eax, [edx*4+edx]
    shl eax, 1
    pop edx
    sub edx, eax
    mov eax, reg32
endm

Float32_ToString proc C far uses es ecx edx ebx esi edi
__StrLink equ dword ptr [esp+26]
    les di, __StrLink                   ;����㦠�� ���쭨� 㪠��⥫� �� ��ப�
    fxam                                ;�ࠧ� �஢��塞 ࠧ���� �訡��
    fstsw ax
    test ah, 10b                        ;�஢�ઠ �����
    jz __NoMinus
        mov es:[di], byte ptr '-'
        inc di
    __NoMinus:
    sahf
    jnz __NoZero
        mov es:[di], dword ptr '0.0'    ;������ � 0
        add di, 3
        jmp __return
    __NoZero:
    setp dl                             ;䫠� C3 (䫠� 0)
    setz dh                             ;䫠� C2 
    setc bl                             ;䫠� C0 (�����/�����, 䫠� ��७��)
    test bl, dl
    jz __NoInf
        mov es:[di], dword ptr 'fni'
        add di, 3
        jmp __return
    __NoInf:
    or dh, dl
    jnz __NoNan
        mov es:[di], dword ptr 'NaN'
        add di, 3
        stc
        jmp __return
    __NoNan:
    fld st(0)                           ;�����㥬 ������ � �⥪� �室��� ��㬥�� �⮡� �� �� �ய��
    fabs                                ;����� ����塞 lg(x) �⮡� ����� �ਬ�୮� �᫮ ࠧ�冷� �᫠
    fld st(0)
    fxtract                             ;� �⮬ ��� �������� �⤥����� ������� �� �ᯮ�����                      
    fstp st(0)                          ;�모�뢠�� ���७ �������
    fldlg2                              ;����㦠�� lg(2)
    fmulp st(1), st(0)                  ;����砥� ������ �� ��㫥 �ਢ������ �����䬠 � ������ �᭮�����
    fistp dword ptr es:[di]             ;����砥� ��� ������
    mov ebx, dword ptr es:[di]          ;����⥫�� �����뢠��, �� �᫮ ����� 1
    cmp bx, -6                          ;�᫨ ����� -6, � ���� ��ଠ��������
    setge dl
    cmp bx, 6                           ;�᫨ ����� 6 - ⮦�
    setl dh
    test dl, dh
    jnz __AllNormal
        mov cx, bx
        call Normalizing                ;���४�� �� 10 �㦭�� �᫮ ࠧ
        xor ebx, ebx                    ;⠪ ��� �᫮ ��ଠ��������, ��⨬ ���稪 ࠧ�冷�
        call After_Normalization        ;��뢠�� �뢮� � ��ଠ�쭮� ����
        mov es:[di], word ptr '/e'      ;�뢮��� �ᯮ���樠�쭮� ����砭��
        @@:
            sub es:[di], word ptr 0200h ;�஢��塞 ���� ��� �ᯮ�����
            neg cx                      ;�뢮� �� �����
        js @B
        mov ax, cx                      ;�뢮��� �⥯����
        aam
        or ax, 3030h
        xchg ah, al
        mov es:[di+2], ax
        add di, 4
        jmp __return
    __AllNormal:
        call After_Normalization
    __return:
    mov es:[di],byte ptr 0              ;��� � ���� ��� �ନ����
    sub di, word ptr __StrLink          ;����塞 � �����頥� ����� ��ப�
    mov ax, di
    ret

    After_Normalization proc C near uses cx
        or edi, 010000h                 ;edi ����㯠�� � ����� "䫠�� 0" - �� ��।����, ����� ��稭����� ����
        fld1                            ;�᫨ �᫮ ����� 1 - � ���� �ᮡ� ���室
        fcomp st(1)                     ;�⮡� �뢮���� �� ����騥 ���� ���� �� � ��ଠ���������� �ଥ
        fstsw ax
        ;����⠡�஢���� �� �⥯��� 10
            mov ecx, -6                 ;㬭������� ࠧ��� � �����ᨨ
            add ecx, ebx                ;���⠥� ������⢮ ࠧ�冷� �⮡� �����/����� ࠧ 㬭�����
            call Normalizing
            neg cx
        ;����� ����⠡�஢����
        xor ebx, ebx
        sahf
        jbe @F
            mov ebx, 010000h            ;䫠� ���ﭨ� ��� �ᥫ ����� ���, �� ��।����, �� �� �� ࠧ��� ��
        @@:                             ;���稬�� ��� �뢥����
        fistp dword ptr es:[di]         ;���᪨���� � eax ��� ������� �ਢ������� � �㦭��� ���� �᫮
        mov eax, dword ptr es:[di]
        mov esi, ebx
        __pushing:
            FastDiv10_WithOst ebx       ;横� �������
            test dx, dx                 ;�஢��塞, ࠢ�� �� dx ���
            jz __zeropointOff
                and edi, 0000ffffh      ;�᫨ ������� �� 0, ���᪠�� 䫠�
            __zeropointOff:
            test edi, 010000h           ;�஢��塞 ���ﭨ� 䫠��
            jnz __NoZeroPush            ;�᫨ 䫠� �⮨�, � �� ��࠭塞 ����
                add dl, 30h             ;������ ��࠭�� �������� �� ᨬ����
                push dx                 ;�᫨ �� �⮨�, ��࠭塞 ����
                inc si                  ;� ��稭��� ���� �����
            __NoZeroPush:
            dec cx                      ;cx ⠪ �� ��।���� ����� �⠢��� ���
            jnz __NoPoint
                test si, si             ;�᫨ �⠢�� ��� � �� �⮣� �� �뫮 �㫥�, ���� ��� 1 ������
                jnz __NOnlyZeroPush
                    push '0'
                    inc si
                __NOnlyZeroPush:
                push word ptr '.'       ;�⠢�� ���
                and edi, 0000ffffh      ;���᪠�� 䫠� ���
                and esi, 0000ffffh      ;���᪠�� �������⥫�� 䫠�
                inc si
            __NoPoint:
        test esi, 010000h               ;�஢��塞 �������⥫�� 䫠� 0
        setnz dh                        ;��⠭�������� � dh
        test eax, eax                   ;�஢��塞 �� ���稫��� �� �᫮
        setnz dl
        or dl, dh                       ;�᫨ ������ 䫠� ��� �� ���稫��� �᫮ - �த������ �뢮�
        jnz __pushing
        cmp [esp], byte ptr '.'         ;�᫨ �� ���設� �⥪� "."
        jne @F
            mov es:[di], byte ptr '0'   ;� ������塞 �㫥�
            inc di
        @@:
            pop dx                      ;���⠥� �� �⥪� � ����ᨬ � ��ப� �� ᨬ����
            mov es:[di], dl
            inc di
        dec si
        jnz @B
        ret
    endp

endp

Normalizing proc C near uses cx
__Ten equ dword ptr [esp-4]
    mov __Ten, 10
    fild __Ten
    test cx, cx
    jns __Diving
        neg cx
        @@:
            fmul st(1), st(0)
        loop @B
    jmp __endf
    __Diving:
        @@:
            fdiv st(1), st(0)
        loop @B
    __endf:
    fstp st(0)
    ret
endp

Float32_Log proc C far  ;logA(B) = log2(A)/log2(B)
    fld1
    fxch st(1)
    fyl2x
    fxch st(1)
    fld1
    fxch st(1)
    fyl2x
    fdivp st(1), st(0)
    ret
endp

Float32_Lg proc c far
    fld1
    fxch st(1)
    fyl2x
    fldl2t
    fdivp st(1), st(0)
    ret
endp

Float32_Ln proc c far
    fld1
    fxch st(1)
    fyl2x
    fldl2e
    fdivp st(1), st(0)
    ret
endp

Float32_FromString proc C far uses ax dx ebx cx esi
__StrLink equ [esp+18]
__Bufer equ [esp-4]
    xor esi, esi
    lds si, __StrLink
    or esi, 10000h                              ;��⠭�������� 䫠� �窨
    xor dx, dx
    xor ebx, ebx
    cmp [si], byte ptr'-'                       ;�᫨ ���� "-", ����� ��⠭�������� 䫠� �����
    jne @F
        or ebx, 010000h                         ;� ���室�� �� ᫥���騩 ����
        inc si
    @@:
    test [si], byte ptr 1000000b                ;�᫨ ���� �㪢�, ����� �訡��
    jz __NormalNum
        and [si], byte ptr 1011111b             ;�������� ॣ���� �㪢
        mov dword ptr [esp-8], 0h               ;�室� ����㦠�� � �⥪ ������⥫��� �訡��
        mov dword ptr [esp-4], 07fff8000h
        test ebx, 010000h
        jz __NoNegErr
            mov dword ptr [esp-4], 0ffff8000h   ;�᫨ ���� '-', ����� �訡�� ����⥫쭠�
        __NoNegErr:
        mov word ptr [esp-10], 0ffh             ;����㦠�� NaN
        cmp [si], byte ptr 'I'                  ;�᫨ ����⨫��� i - ����� ��᪮��筮���
        jne __NoInf 
            mov word ptr [esp-10], 0h           ;����㦠�� inf
        __NoInf:
        fld tbyte ptr [esp-10]
        jmp __return
    __NormalNum:
    mov __Bufer, dword ptr 10
    fild dword ptr __Bufer                      ;�� 10 �㤥� 㬭�����
    fldz                                        ;����砫쭮 0
    @@:
        cmp dl, '.'
        jne __BefPoint
            and esi, 0ffffh                     ;�᫨ ����⨫� ���, ����塞 䫠� �窨
            mov dl, [si]
            inc si
            jmp @B                              ;� �ࠧ� ���室�� �� ᫥���騩 ᨬ���
        __BefPoint:
        test esi, 010000h
        jnz __NoPointFlag
            inc dh                              ;�᫨ 䫠� ���饭, ��稭��� ����� ������� ࠧ��� ��� �������
        __NoPointFlag:
        and dl, 0fh                             ;��⠢�塞 �� ᨬ���� ⮫쪮 ����
        mov __Bufer, dword ptr 0                ;����塞 ����
        mov __Bufer, dl                         ;����㦠�� ����
        fmul st(0), st(1)                       ;㬭����� �� 10
        fild dword ptr __Bufer                  ;����㦠�� ����
        faddp st(1), st(0)                      ;᪫��뢠��
        mov dl, [si]                            ;���室�� �� ᫥���騩 ᨬ���
        inc si
    cmp dl, 'e'                                 ;�஢��塞, �� ࠢ�� �� 'e'
    setne bh                                    
    test dl, dl                                 ;�஢��塞, �� ࠢ�� �� 0
    setnz bl
    test bl, bh
    jnz @B                                      ;�᫨ �� �, �� ��㣮� - ���⨬ �����
    xor ax, ax
    fxch st(1)                                  ;�모�뢠�� 10 �� �⥪�
    fstp st(0)
    test bh, bh                                 ;�᫨ �뫮 'e', ����� ���뢠�� �ᯮ�����
    jnz @F
        mov ax, [si+1]
        xchg ah, al
        and ax, 0f0fh
        aad
        cmp [si], byte ptr '+'
        jne __NoNeg
            neg ax
        __NoNeg:
    @@:
    shr dx, 8                                   ;������塞 ����� ��᫥ ����⮩ � �ᯮ����
    add ax, dx
    mov cx, ax
    call Normalizing                            ;��ଠ���㥬
    test ebx, 010000h                           ;�������㥬 ����, �᫨ ������ 䫠�
    jz __return
        fchs
    __return:
    ret
endp

Float32_ToRad proc C far
__Bufer equ [esp-4]
    mov dword ptr __Bufer, 360
    fild dword ptr __Bufer
    fxch st(1)
    fprem
    fdivrp st(1), st(0)
    fld1
    fadd st(0), st(0)
    fldpi
    fmulp st(1), st(0)
    fmulp st(1), st(0)
    ret
endp

Float32_ToGrad proc C far
__Bufer equ [esp-4]
    fld1
    fadd st(0), st(0)
    fldpi
    fmulp st(1), st(0)
    fxch st(1)
    fprem
    fdivrp st(1), st(0)
    mov dword ptr __Bufer, 360
    fild dword ptr __Bufer
    fmulp st(1), st(0)
    ret
endp

Arcfunc proc c near         ;a - st(1), (1-a*a)^(1/2) - st(0)
    fld st(0)               ;�����㥬 ��㬥��
    fmul st(0), st(0)       ;����砥� ������
    fld1                    ;����砥� 1 - a*a
    fsubrp st(1), st(0)
    fsqrt                   ;������� ��७�
    ret
endp

Float32_ArcSin proc c far   ;arcsin a = arctg (a/(1-a*a)^(1/2))
    call Arcfunc
    fpatan                  ;st(1) = arctg (st(1)/st(0)) � ��⠫��������
    ret
endp

Float32_ArcCos proc c far   ;arcsin a = arcctg (a/(1-a*a)^(1/2))
    call Arcfunc
    fxch st(1)              ;arcctg(a) = arctg(1/a)
    fpatan                  ;st(1) = arctg (st(1)/st(0)) � ��⠫��������
    ret
endp

Float32_PowerUndef proc C far   ;2^(lg2(base)*power)
    fld1                        ;����㦠�� ������� ��� �����䬠
    fxch st(1)                  ;�⠢�� �� ��। �᭮������
    fyl2x                       ;st(1) = lg2(st(0))*st(1)) � ��⠫�������� st(0)
    fmulp st(1)                 ;lg2(base)*power
    fld st(0)                   ;� �⥯��� �������� �⤥�쭮 �� �஡��� ���, �⤥�쭮 �� 楫��
    frndint                     ;���㣫塞 �� 楫��
    fld1                        ;������塞 1 ��� fscale
    fscale                      ;st(0) = st(0) * 2^(int)st(1), st(1) �� �������
    fxch st(1)                  ;�뭮ᨬ �� ���設� 楫�� ���� �⥯���
    fsubp st(2), st(0)          ;���⠥� � �모�뢠���� �� �⥪�
    fxch st(1)                  ;�뭮ᨬ �� ���設� ����祭��� �஡��� �⥯���
    f2xm1                       ;st(0) = 2^st(0) - 1, st(0) ? (-1; 1)
    fld1                        ;������塞 �����楩
    faddp st(1), st(0)
    fmulp st(1), st(0)          ;㬭����� ��� ����祭�� १����, �.�. x^(a+b) = x^a * x^b
    ret
endp

Float32_Power proc C far uses ax
__Bufer equ [esp-8]
    ftst                                ;�஢��塞, �� 0 �� � �⥯���
    fstsw ax
    sahf
    jne __NoZeroPower
        fstp st(0)
        fstp st(0)
        fstp st(0)
        fld1
        jmp __return                    ;�᫨ 0, �����頥� 1
    __NoZeroPower:
    ftst                                ;�஢��塞 �� 0 �� � �᭮�����
    fstsw	ax
    sahf
    jne __NoZeroBaze
        fstp st(0)
        fstp st(0)
        fldz
        jmp __return
    __NoZeroBaze:                       ;�᫨ 0, �����頥� 0
    jb __NegativeBase                   ;�᫨ ����� 0, � �ᯮ��㥬 ���⮥ ���������� � �⥯���
        call Float32_PowerUndef
        jmp __return
    __NegativeBase:                     ;�᫨ ����� 0, ���������� � �⥯��� �������� ⮫쪮 � 楫� ������⥫��
    fld st(1)                           ;��� �஢�ન, ���� �� �᫮ 楫�
    frndint                             ;�㡫��㥬 � ���㣫塞
    fcom st(2)                          ;� ��⮬ �ࠢ������
    fstsw ax
    sahf
    je __NoError                        ;�᫨ �� ࠢ��, �
        fstp st(0)
        fstp st(0)
        fstp st(0)
        mov word ptr [esp-10], 0ffh     ;����㦠�� NaN
        mov dword ptr [esp-6], 0h
        mov dword ptr [esp-4], 7fff8000h
        fld tbyte ptr [esp-10]
        stc
        jmp __return
    __NoError:
    mov dword ptr __Bufer, 2            ;�஢��塞 �⭮��� �⥯���
    fild dword ptr __Bufer              ;��� �⮣� ����� �᫮ �� 2
    fdivp st(1), st(0)                  ;� ��।��塞, ���� �� 楫� ���⮪
    fld st(0)                           ;�����㥬 � ���㣫塞 १���� �������
    frndint
    fcompp st(1)                        ;��⠫������ �� �⥪� ��� �� �ࠢ�����
    fstsw ax                            ;䫠�� ��᫥ �ࠢ����� - � ax
    push ax                             ;��࠭塞 ��। �맮���
    fabs                                ;ᯮ����� ��६ �� ����� � �������� � �⥯���
    call Float32_PowerUndef
    pop ax                              ;��᫥ �맮�� ��⠭��������
    sahf
    je __return
        fchs                            ;�������㥬 �᫨ �뫠 ���⭠� �⥯���
    __return:
    ret
endp

RoundToZerO macro mem:req, reg:req
    fnstcw word ptr mem
    mov reg, mem
    and word ptr mem, 1111001111111111b
    or word ptr mem, 110000000000b
    fldcw word ptr mem
    mov mem, reg
endm

Float32_ToInt32 proc C far
__Bufer equ [esp-4]
    RoundToZerO __Bufer, ax
    fld st(0)
    frndint
    fldcw word ptr __Bufer
    fistp dword ptr __Bufer
    mov eax, __Bufer
    ret
endp

end