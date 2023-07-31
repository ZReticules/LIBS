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

Heap_GetTotalSize proc C far uses ebx       ;дает масимальный обьем доступной памяти
    mov bx, 0ffffh                          ;операндов нет
    mov ah, 48h                             ;работает это так: у дос запрашивается
    int 21h                                 ;заведомо слишком большой обьем памяти
    mov ax, bx
    ret
endp

Heap_ResizeBlock proc C far uses es bx ax   ;StdCall, меняет размер блока памяти
@@NewSize equ [esp+10]                      ;первым в стеке лежит арумент размера
@@SegNum equ [esp+12]                       ;за ним - сегмент блока
    les bx, @@NewSize                       ;это позволяет использовать инструкцию загрузки
    mov ah, 4Ah                             ;сразу двух регистров
    int 21h                                 ;в es - изменяемый блок, в bx - новый размер
    jnc __NormalRet
        lea sp, [esp+2]                     ;в случае неудачи поднимает флаг переноса и в ax код ошибки
        pop bx
        pop es
        ret 0
    __NormalRet:
    ret
endp

Heap_Init proc C far        ;StdCall. Инициализирует кучу
@@FinishSeg equ [esp+6]     ;в качестве аргумента - последний сегмент программы
    mov [esp-20], eax        ;сохраняем регистры
    mov [esp-24], bx
    mov eax, [esp]          ;выделяем в стеке дополнительное место мод размер сегмента
    sub sp, 2
    mov [esp], eax
    mov ah, 62h             ;получаем адрес PSP вызывающей программы
    int 21h
    xchg bx, @@FinishSeg    ;в стек на место сегмента кладем полученный адрес
    sub bx, @@FinishSeg     ;получаем размер программы (в 16-байтовых параграфах)
    mov [esp+4], bx         ;кладем его на вершину стека
    mov eax, [esp-18]        ;восстанавливаем регистры
    mov bx, [esp-22]
    jmp Heap_ResizeBlock    ;переходим к процедуре изменения размера блока
endp

Heap_AllocBlock proc C far uses bx          ;StdCall. Функция аллокации памяти
@@MemSize equ [esp+6]                       ;единственный арумент - размер выделяемого блока
    xor eax, eax
    mov bx, @@MemSize
    mov ah, 48h
    int 21h
    ret
endp

Heap_GetBlockSize proc C far                ;выдает размер выделенного блока согласно MCB
@@SegNum equ [esp+4]                        ;аргумент - адрес выделенного блока
    mov ax, ds                              ;который находится в параграфе,
    shl eax, 16                             ;предшествующем самому блоку
    mov ax, @@SegNum
    dec ax
    mov ds, ax
    mov ax, ds:[3]                          ;3-4 байты содержат размер блока
    ror eax, 16
    mov ds, ax
    xor ax, ax
    ror eax, 16
    ret
endp

Heap_FreeBlock proc C far uses eax  ;рекомендуется StdCall, освобождает блок памяти
@@NumBlock equ [esp+8]              ;сегмент блока
    mov ax, es                      ;es сохраяется в старшей части eax
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