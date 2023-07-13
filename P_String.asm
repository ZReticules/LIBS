model tiny
.386
.code

testbuf db 256 dup(?)

locals @@

extrn IntConvertio: far
extrn CharrInt:     far
Include c:\macros\Support.inc

public C P_StringPrint, C P_StringConcat, C P_StringMultiConcat
public C P_StringToInt, C P_StringCopy, C P_StringMov,C P_StringCmp 
public C P_StringPos, C P_StringDelete, C P_IntToString, C P_StringInsert
public C P_StringScan

P_StringPrint proc C far uses ax dx bx ds
arg StrSeg:word, StrLink:word
local MaxLink:word                  ;для вычисляемого указателя на конец строки
    mov bx, StrSeg                  ;загружаем рабочий сегмент
    mov ds, bx
    mov bx, StrLink                 ;перемещаю в bx указатель на строку
    push bx                         ;кладу указатель на строку в стек
    xor ax, ax                      ;очищаю аккумулятор
    mov al, [bx]                    ;в al длина строки
    add bx, ax                      ;получаем указатель на конец строки
    mov MaxLink, bx                 ;кладем в локальную переменную
    pop bx                          ;получаю обратно указатель на начало строки
    mov ah, 02h
    @@cycle:                        ;вывод строки
        inc bx                      ;получаю очередной элемент
        mov dl, [bx]                ;кладу его в регистр al для вывода
        int 21h                     ;вывод прерыванием 29h
    cmp bx, MaxLink                 ;проверка дохода до конца строки
    jb @@cycle
ret
endp

P_StringConcat proc C far uses si di es cx ds
Arg StrDesSeg:word,StrDesLink:word, StrSrcSeg:word,StrSrcLink:word
    mov cx, StrDesSeg                   ;загрузаем сегментные регистры (для movsb)
    mov es, cx                          ;в es сегмент приемника
    mov cx, StrSrcSeg
    mov ds, cx                          ;в ds сегмент источника
    mov di, StrDesLink                  ;в di - приемник
    mov cl, es:[di]                        ;получаем в cl длину приемника
    xor ch, ch
    push cx                             ;кладем в стек длину
    mov si, StrSrcLink                  ;в si - ссылка на источник
    add cl, [si]                        ;получаем новую длину строки
    jc @@fullstr                        ;если получили переполнение - обрабатываем
    mov byte ptr es:[di], cl               ;устанавливаем новую длину строки
    pop cx                              ;восстанавливаем изначальную длину
    add di, cx                          ;устанавливаем указатель на последний символ
    mov cl, [si]                        ;получаем в счетчик длину добавляемой строки
    @@MovStr:
    inc si                              ;смещаем на первый символ
    inc di                              ;смещаем на пустое место
    repe movsb
ret
@@fullstr:
    mov cl, es:[di]                        ;получаем обратно длину строки в cl
    mov byte ptr es:[di], 255              ;приемник заполнен целиком
    xor ch, ch                          ;очищаем счетчик
    add di, cx                          ;перемещаем указатель на последний символ
    pop cx                              ;восстанавливаем изначальную длину строки
    sub cl, 255                         ;вычитаем из изначальной строки 255, чтобы получить разницу
    neg cl                              ;инверсируем разницу
    xor ch, ch                          ;очищаем старшую часть счетчика
jmp @@MovStr
endp

P_StringMultiConcat proc C far uses si
arg StrDesSeg:word, StrDesLink:word, NumConc:word                               ; все строки для сложения лежат после последней переменной
    xor si, si                                                                  ; уможаем на 2 количество сложений,
    rol NumConc, 2                                                              ;т.к. адреса и сегменты занимают по 2 байта
    add si, type NumConc                                                        ; сдвигаем счетчик на место после последней переменной
    @@cycle:
        call P_StringConcat C, StrDesSeg, StrDesLink, NumConc+si,NumConc+si+2   ; передаем адрес следующего элемента
        add si, 4
        cmp si, NumConc
    jb @@cycle
ret
endp

P_StringToInt proc C far uses dx bx ds
arg StrSeg:word, StrLink:word       ;ссылка на строку
    mov bx, StrSeg
    mov ds, bx
    mov bx, StrLink                 ;загружаем ссылку
    xor dh, dh                      ;чистим старшую часть
    mov dl, byte ptr [bx]           ;загружаем длину строки
    inc bx                          ;смещаем на начало строки
    call ChArrInt C, bx, dx         ;вызываем прцедуру преобразования
ret
endp

P_StringCopy proc C far uses si di es cx ds
arg StrDesSeg:word, StrDesLink:word, StrSrcSeg:word,StrSrcLink:word, StartIndex:word, EndIndex:word
mov byte ptr StartIndex+1, 0            ;обнуляю старшую часть индексов
mov byte ptr EndIndex+1, 0
    mov cx, StrDesSeg                   ;загружаем сегментные регистры (для movsb)
    mov es, cx                          ;в es сегмент приемника
    mov cx, StrSrcSeg
    mov ds, cx                          ;в ds сегмент источника
    mov di, StrDesLink                  ;загружаем адрес приемника
    mov si, StrSrcLink                  ;загружаем адрес источника
    add si, StartIndex                  ;смещаем на заданный индекс
    mov cx, EndIndex                    ;вычисляем длину копируемой строки
    sub cx, StartIndex
    xor ch, ch                          ;очищаем старшую часть счетчика
    inc cl                              ;чтобы последнний символ тоже копировался
    mov es:[di], cl
    inc di
    rep movsb
ret
endp

P_StringMov proc C far uses si di es cx ds
arg StrDesSeg:word, StrDesLink:word, StrSrcSeg:word,StrSrcLink:word
    mov cx, StrDesSeg                                               ;загрузаем сегментные регистры (для movsb)
    mov es, cx                                                      ;в es сегмент приемника
    mov cx, StrSrcSeg
    mov ds, cx                                                      ;в ds сегмент источника
    mov di, StrDesLink                                              ;загружаем адрес приемника
    mov si, StrSrcLink                                              ;загружаем адрес источника
    mov cl, es:[di]                                                 ;загружаем длину приемника
    xor ch, ch
    call P_StringCopy C, es, StrDesLink, ds, StrSrcLink, 1, cx
ret
endp

P_StringCmp proc Pascal far uses si di es cx ds
arg StrDesSeg:word, StrDesLink:word, StrSrcSeg:word,StrSrcLink:word
    mov cx, StrDesSeg   ;загрузаем сегментные регистры (для movsb)
    mov es, cx          ;в es сегмент приемника
    mov cx, StrSrcSeg
    mov ds, cx          ;в ds сегмент источника
    mov si, StrSrcLink  ;загружаем адрес источника
    mov di, StrDesLink  ;загружаем адрес приемника
    mov cl, es:[di]     ;сравниваем длины строк
    cmp cl, [si]
    je @@LenEqu
        ret             ;если разные, выходим
    @@LenEqu:
    xor ch, ch
    inc cl              ;увеличиваем чтобы зацепить последний
    repz cmpsb          ;производим сравнение
    ret
endp

P_StringPos proc C far uses si di es cx ds
arg StrDesSeg:word, StrDesLink:word, StrSrcSeg:word,StrSrcLink:word
local MaxLink:word
    mov cx, StrDesSeg   ;загрузаем сегментные регистры (для movsb)
    mov es, cx          ;в es сегмент приемника
    mov cx, StrSrcSeg
    mov ds, cx          ;в ds сегмент источника
    mov si, StrSrcLink  ;загружаем адрес источника
    mov di, StrDesLink  ;загружаем адрес приемника
    mov cl, es:[di]
    cmp cl, [si]        ;проверяем, чтобы строка-источник была меньше
    jb @@False
    xor ch, ch
    mov MaxLink, di     ;вычисляю максимальное смещение для источника
    sub cl, [si]
    add MaxLink, cx
    add MaxLink, 2      ;учитываю байт длины строки и последний символ
    inc di              ;смещаю с длины на начало строки
    @@cycle:
        mov cl, [si]    ;в cl - длина строки
        push si         ;сохраняю si, он не должен меняться от итерации к итерации
        inc si          ;смещаю на первый символ
        repz cmpsb
        pop si
        je @@True       ;di не сохраняю, чтобы он смещался ровно на тот символ, где было обнаружено отличие
    cmp di, MaxLink
    jb @@cycle
    @@False:
        xor eax, eax    ;в eax 0 - значит подстроки не было найдено
        ret
    @@True:
    xor eax, eax
    sub di, StrDesLink  ;вычисляю индекс подстроки через начальное смещение и текущее
    mov ax, di
    sub al, [si]        ;вычитаю длину искомой подстроки
    ret
endp

P_StringDelete proc C far uses si di es cx ds
arg StrSeg:word,StrLink:word, StartIndex:word, FinIndex:word
local DelLen:word
mov byte ptr StartIndex+1, 0    ;обнуляем старшую част индексов
mov byte ptr FinIndex+1, 0
    mov cx, StrSeg              ;загружаем сегмент строки
    mov es, cx
    mov ds, cx
    mov di, StrLink             ;загружаем адрес строки
    mov si, di                  ;и в источник, и в приемник
    mov cx, [di]                ;вычисляю длину перезаписываемой части
    sub cx, FinIndex
    xor ch, ch                  ;очищаю старшую часть, по классике
    inc cl                      ;смещаю на первый символ
    add di, StartIndex          ;смещаю "приемник" на начало стирания
    add si, FinIndex            ;смещаю источник на конец
    inc si                      ;смещаю на "первый" символ
    mov DelLen, si              ;вычисляю удаляемую длину
    sub DelLen, di
    rep movsb
    mov si, StrLink             ;возвращаю адрес начала строки
    mov cl, byte ptr DelLen     ;вычисляю новую длину строки
    sub [si], cl
ret
endp

P_IntToString proc C far uses ds
arg StrSeg:word, StrLink:word, Num:Dword
    push StrSeg
    pop ds
    call IntConvertio C, Num, PStrMode, StrLink
ret
endp

P_StringInsert proc C far uses bx dx ds
arg StrDesSeg:word, StrDesLink:word, StrSrcSeg:word,StrSrcLink:word, StartIndex:word
local Subs:byte:256
mov byte ptr StartIndex+1, 0            ;обнуляю старшую часть индекса
    mov ds, StrDesSeg                   ;загружаю сегмент и смещение
    mov bx, StrDesLink
    mov dl, byte ptr StartIndex         ;получаю индекс начала вставки
    dec dl
    cmp dl, byte ptr [bx]               ;если индекс больше длины строки для вставки
    jbe @@LowLen
        mov dl, [bx]                    ;то устанавливаю его в длину строки+1
        mov byte ptr StartIndex, dl
        inc StartIndex
    @@LowLen:
    call P_StringCopy C, ss, offset Subs, ds, bx, StartIndex, word ptr [bx]
    mov byte ptr [bx], dl
    call P_StringMultiConcat C, ds, bx, 2, StrSrcSeg, StrSrcLink, ss, offset Subs
ret
endp

P_StringScan proc C far uses ds dx ax
arg StrSeg:word, StrLink:word
    mov TestBuf, 254
    mov ax, seg testbuf
    mov ds, ax                          ;в ax - адрес выделенной памяти
    lea dx, TestBuf
    mov ah, 0ah                         ;номер функции для ввода
    int 21h
    mov al, 0ah                         ;перенос строки
    int 29h
    call P_StringCopy C, StrSeg, StrLink, seg testbuf, offset testbuf + 1, 1, word ptr Testbuf+1
ret
endp

end