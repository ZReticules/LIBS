model tiny
.386
.code

Version M520

public Float32_ToString
public Float32_FromString

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

Float32_FromString proc C far uses ax dx ebx cx esi
__StrLink equ [esp+18]
__Bufer equ [esp-4]
    xor esi, esi
    lds si, __StrLink
    or esi, 10000h                              ;устанавливаем флаг точки
    xor dx, dx
    xor ebx, ebx
    cmp [si], byte ptr'-'                       ;если есть "-", значит устанавливаем флаг знака
    jne @F
        or ebx, 010000h                         ;и переходим на следующий знак
        inc si
    @@:
    test [si], byte ptr 1000000b                ;если есть буква, значит ошибка
    jz __NormalNum
        and [si], byte ptr 1011111b             ;понижаем регистр букв
        mov dword ptr [esp-8], 0h               ;сходу загружаем в стек положительную ошибку
        mov dword ptr [esp-4], 07fff8000h
        test ebx, 010000h
        jz __NoNegErr
            mov dword ptr [esp-4], 0ffff8000h   ;если есть '-', значит ошибка отрицательная
        __NoNegErr:
        mov word ptr [esp-10], 0ffh             ;загружаем NaN
        cmp [si], byte ptr 'I'                  ;если встретилось i - значит бесконечность
        jne __NoInf 
            mov word ptr [esp-10], 0h           ;загружаем inf
        __NoInf:
        fld tbyte ptr [esp-10]
        jmp __return
    __NormalNum:
    mov __Bufer, dword ptr 10
    fild dword ptr __Bufer                      ;на 10 будем умножать
    fldz                                        ;изначально 0
    @@:
        cmp dl, '.'
        jne __BefPoint
            and esi, 0ffffh                     ;если встретили точку, обнуляем флаг точки
            mov dl, [si]
            inc si
            jmp @B                              ;и сразу переходим на следующий символ
        __BefPoint:
        test esi, 010000h
        jnz __NoPointFlag
            inc dh                              ;если флаг опущен, начинаем считать десятичные разряды для деления
        __NoPointFlag:
        and dl, 0fh                             ;оставляем от символа только цифру
        mov __Bufer, dword ptr 0                ;обнуляем буфер
        mov __Bufer, dl                         ;загружаем цифру
        fmul st(0), st(1)                       ;умножаем на 10
        fild dword ptr __Bufer                  ;загружаем цифру
        faddp st(1), st(0)                      ;складываем
        mov dl, [si]                            ;переходим на следующий символ
        inc si
    cmp dl, 'e'                                 ;проверяем, не равен ли 'e'
    setne bh                                    
    test dl, dl                                 ;проверяем, не равен ли 0
    setnz bl
    test bl, bh
    jnz @B                                      ;если ни то, ни другое - крутим дальше
    xor ax, ax
    fxch st(1)                                  ;выкидываем 10 из стека
    fstp st(0)
    test bh, bh                                 ;если было 'e', значит считываем экспоненту
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
    shr dx, 8                                   ;добавляем знаки после запятой к экспоненте
    add ax, dx
    mov cx, ax
    call Normalizing                            ;нормализуем
    test ebx, 010000h                           ;инвертируем знак, если поднят флаг
    jz __return
        fchs
    __return:
    ret
endp

Float32_ToString proc C far uses es ecx edx ebx esi edi
__StrLink equ dword ptr [esp+26]
    les di, __StrLink                   ;загружаем дальний указатель на строку
    fxam                                ;сразу проверяем различные ошибки
    fstsw ax
    test ah, 10b                        ;проверка знака
    jz __NoMinus
        mov es:[di], byte ptr '-'
        inc di
    __NoMinus:
    sahf
    jnz __NoZero
        mov es:[di], dword ptr '0.0'    ;заодно и 0
        add di, 3
        jmp __return
    __NoZero:
    setp dl                             ;флаг C3 (флаг 0)
    setz dh                             ;флаг C2 
    setc bl                             ;флаг C0 (больше/меньше, флаг переноса)
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
    fld st(0)                           ;копируем дважды в стеке входной аргумент чтобы он не пропал
    fabs                                ;здесь вычисляем lg(x) чтобы знать примерное число разрядов числа
    fld st(0)
    fxtract                             ;в этом нам помогает отделение мантиссы от экспоненты                      
    fstp st(0)                          ;выкидываем нахрен мантиссу
    fldlg2                              ;загружаем lg(2)
    fmulp st(1), st(0)                  ;получаем логарифм по формуле приведения логарифма к новому основанию
    fistp dword ptr es:[di]             ;получаем наш логарифм
    mov ebx, dword ptr es:[di]          ;отрицательный показывает, что число меньше 1
    cmp bx, -6                          ;если меньше -6, то надо нормализовать
    setge dl
    cmp bx, 6                           ;если больше 6 - тоже
    setl dh
    test dl, dh
    jnz __AllNormal
        mov cx, bx
        call Normalizing                ;коррекция на 10 нужное число раз
        xor ebx, ebx                    ;так как число нормализовано, чистим счетчик разрядов
        call After_Normalization        ;вызываем вывод в нормальном виде
        mov es:[di], word ptr '/e'      ;выводим экспоненциальное окончание
        @@:
            sub es:[di], word ptr 0200h ;проверяем знак для экспоненты
            neg cx                      ;вывод по модулю
        js @B
        mov ax, cx                      ;выводим степеннь
        aam
        or ax, 3030h
        xchg ah, al
        mov es:[di+2], ax
        add di, 4
        jmp __return
    __AllNormal:
        call After_Normalization
    __return:
    mov es:[di],byte ptr 0              ;нуль в конце как терминант
    sub di, word ptr __StrLink          ;вычисляем и возвращаем длину строки
    mov ax, di
    ret

    After_Normalization proc C near uses cx
        or edi, 010000h                 ;edi выступает в качесте "флага 0" - он определяет, когда начинаются цифры
        fld1                            ;если число меньше 1 - к нему особый подход
        fcomp st(1)                     ;чтобы выводить все значащие цифры даже не в нормализованной форме
        fstsw ax
        ;масштабирование по степеням 10
            mov ecx, -6                 ;умножаются разряды в инверсии
            add ecx, ebx                ;вычитаем количество разрядов чтобы больше/меньше раз умножать
            call Normalizing
            neg cx
        ;конец масштабирования
        xor ebx, ebx
        sahf
        jbe @F
            mov ebx, 010000h            ;флаг состояния для чисел меньше нуля, он определяет, что не все разряды до
        @@:                             ;значимых цифр выведены
        fistp dword ptr es:[di]         ;вытаскиваем в eax наше наконец приведенное к нужному виду число
        mov eax, dword ptr es:[di]
        mov esi, ebx
        __pushing:
            FastDiv10_WithOst ebx       ;цикл деления
            test dx, dx                 ;проверяем, равен ли dx нулю
            jz __zeropointOff
                and edi, 0000ffffh      ;если попался не 0, опускаем флаг
            __zeropointOff:
            test edi, 010000h           ;проверяем состояние флага
            jnz __NoZeroPush            ;если флаг стоит, то не сохраняем цифру
                add dl, 30h             ;заодно заранее добиваем до символа
                push dx                 ;если не стоит, сохраняем цифру
                inc si                  ;и начинаем цифры считать
            __NoZeroPush:
            dec cx                      ;cx так же определяет когда ставить точку
            jnz __NoPoint
                test si, si             ;если ставим точку и до этого не было нулей, надо хоть 1 кинуть
                jnz __NOnlyZeroPush
                    push '0'
                    inc si
                __NOnlyZeroPush:
                push word ptr '.'       ;ставим точку
                and edi, 0000ffffh      ;опускаем флаг нуля
                and esi, 0000ffffh      ;опускаем дополнительный флаг
                inc si
            __NoPoint:
        test esi, 010000h               ;проверяем дополнительный флаг 0
        setnz dh                        ;устанавливаем в dh
        test eax, eax                   ;проверяем не кончилось ли число
        setnz dl
        or dl, dh                       ;если поднят флаг или не кончилось число - продолжаем вывод
        jnz __pushing
        cmp [esp], byte ptr '.'         ;если на вершине стека "."
        jne @F
            mov es:[di], byte ptr '0'   ;то дополняем нулем
            inc di
        @@:
            pop dx                      ;достаем из стека и заносим в строку все символы
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

end