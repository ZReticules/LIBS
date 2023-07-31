model tiny
.386
.code

VERSION M520

public Heap_GetTotalSize
public Heap_ResizeBlock
public Heap_Init
public Heap_AllocBlock
public Heap_GetBlockSize
public Heap_FreeBlock

locals __

Heap_GetTotalSize proc C far uses ebx       ;���� ��ᨬ���� ��쥬 ����㯭�� �����
    mov bx, 0ffffh                          ;���࠭��� ���
    mov ah, 48h                             ;ࠡ�⠥� �� ⠪: � ��� ����訢�����
    int 21h                                 ;�������� ᫨誮� ����让 ��쥬 �����
    mov ax, bx
    ret
endp

Heap_ResizeBlock proc C far uses es bx ax   ;StdCall, ����� ࠧ��� ����� �����
@@NewSize equ [esp+10]                      ;���� � �⥪� ����� ��㬥�� ࠧ���
@@SegNum equ [esp+12]                       ;�� ��� - ᥣ���� �����
    les bx, @@NewSize                       ;�� �������� �ᯮ�짮���� �������� ����㧪�
    mov ah, 4Ah                             ;�ࠧ� ���� ॣ���஢
    int 21h                                 ;� es - �����塞� ����, � bx - ���� ࠧ���
    jnc __NormalRet
        lea sp, [esp+2]                     ;� ��砥 ��㤠� ��������� 䫠� ��७�� � � ax ��� �訡��
        pop bx
        pop es
        ret 0
    __NormalRet:
    ret
endp

Heap_Init proc C far        ;StdCall. ���樠������� ����
@@FinishSeg equ [esp+6]     ;� ����⢥ ��㬥�� - ��᫥���� ᥣ���� �ணࠬ��
    mov [esp-20], eax        ;��࠭塞 ॣ�����
    mov [esp-24], bx
    mov eax, [esp]          ;�뤥�塞 � �⥪� �������⥫쭮� ���� ��� ࠧ��� ᥣ����
    sub sp, 2
    mov [esp], eax
    mov ah, 62h             ;����砥� ���� PSP ��뢠�饩 �ணࠬ��
    int 21h
    xchg bx, @@FinishSeg    ;� �⥪ �� ���� ᥣ���� ������ ����祭�� ����
    sub bx, @@FinishSeg     ;����砥� ࠧ��� �ணࠬ�� (� 16-���⮢�� ��ࠣ���)
    mov [esp+4], bx         ;������ ��� �� ���設� �⥪�
    mov eax, [esp-18]        ;����⠭�������� ॣ�����
    mov bx, [esp-22]
    jmp Heap_ResizeBlock    ;���室�� � ��楤�� ��������� ࠧ��� �����
endp

Heap_AllocBlock proc C far uses bx          ;StdCall. �㭪�� ������樨 �����
@@MemSize equ [esp+6]                       ;�����⢥��� ��㬥�� - ࠧ��� �뤥�塞��� �����
    xor eax, eax
    mov bx, @@MemSize
    mov ah, 48h
    int 21h
    ret
endp

Heap_GetBlockSize proc C far                ;�뤠�� ࠧ��� �뤥������� ����� ᮣ��᭮ MCB
@@SegNum equ [esp+4]                        ;��㬥�� - ���� �뤥������� �����
    mov ax, ds                              ;����� ��室���� � ��ࠣ��,
    shl eax, 16                             ;�।�����饬 ᠬ��� �����
    mov ax, @@SegNum
    dec ax
    mov ds, ax
    mov ax, ds:[3]                          ;3-4 ����� ᮤ�ঠ� ࠧ��� �����
    ror eax, 16
    mov ds, ax
    xor ax, ax
    ror eax, 16
    ret
endp

Heap_FreeBlock proc C far uses eax  ;४��������� StdCall, �᢮������� ���� �����
@@NumBlock equ [esp+8]              ;ᥣ���� �����
    mov ax, es                      ;es ������� � ���襩 ��� eax
    shl eax, 16
    mov ax, @@NumBlock
    mov es, ax
    mov ah, 49h
    int 21h
    pushf
    ror eax, 16
    mov es, ax
    ror eax, 16
    popf
    jnc __NormalRet
        lea sp, [esp+4]
        ret 0
    __NormalRet:
    ret
endp

end