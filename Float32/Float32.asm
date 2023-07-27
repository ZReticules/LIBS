model tiny
.386
.code

Version M520

public Float32_Lg
public Float32_Ln
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
    fld st(0)               ;копируем аргумент
    fmul st(0), st(0)       ;получаем квадрат
    fld1                    ;получаем 1 - a*a
    fsubrp st(1), st(0)
    fsqrt                   ;квадратный корень
    ret
endp

Float32_ArcSin proc c far   ;arcsin a = arctg (a/(1-a*a)^(1/2))
    call Arcfunc
    fpatan                  ;st(1) = arctg (st(1)/st(0)) с выталкиванием
    ret
endp

Float32_ArcCos proc c far   ;arcsin a = arcctg (a/(1-a*a)^(1/2))
    call Arcfunc
    fxch st(1)              ;arcctg(a) = arctg(1/a)
    fpatan                  ;st(1) = arctg (st(1)/st(0)) с выталкиванием
    ret
endp

Float32_PowerUndef proc C far   ;2^(lg2(base)*power)
    fld1                        ;загружаем единицу для логарифма
    fxch st(1)                  ;ставим ее перед основанием
    fyl2x                       ;st(1) = lg2(st(0))*st(1)) с выталкиванием st(0)
    fmulp st(1)                 ;lg2(base)*power
    fld st(0)                   ;в степень возводим отдельно по дробной части, отдельно по целой
    frndint                     ;округляем до целой
    fld1                        ;добавляем 1 для fscale
    fscale                      ;st(0) = st(0) * 2^(int)st(1), st(1) не меняется
    fxch st(1)                  ;выносим на вершину целую часть степени
    fsubp st(2), st(0)          ;вычитаем с выкидыванием из стека
    fxch st(1)                  ;выносим на вершину полученную дробную степень
    f2xm1                       ;st(0) = 2^st(0) - 1, st(0) ? (-1; 1)
    fld1                        ;дополняем единицей
    faddp st(1), st(0)
    fmulp st(1), st(0)          ;умножаем для получения результата, т.к. x^(a+b) = x^a * x^b
    ret
endp

Float32_Power proc C far uses ax
__Bufer equ [esp-8]
    ftst                                ;проверяем, не 0 ли в степени
    fstsw ax
    sahf
    jne __NoZeroPower
        fstp st(0)
        fstp st(0)
        fstp st(0)
        fld1
        jmp __return                    ;если 0, возвращаем 1
    __NoZeroPower:
    ftst                                ;проверяем не 0 ли в основании
    fstsw	ax
    sahf
    jne __NoZeroBaze
        fstp st(0)
        fstp st(0)
        fldz
        jmp __return
    __NoZeroBaze:                       ;если 0, возвращаем 0
    jb __NegativeBase                   ;если больше 0, то используем простое возведение в степень
        call Float32_PowerUndef
        jmp __return
    __NegativeBase:                     ;если меньше 0, возведение в степень возможно только с целым показателем
    fld st(1)                           ;для проверки, является ли число целым
    frndint                             ;дублируем и округляем
    fcom st(2)                          ;а потом сравниваем
    fstsw ax
    sahf
    je __NoError                        ;если не равны, то
        fstp st(0)
        fstp st(0)
        fstp st(0)
        mov word ptr [esp-10], 0ffh     ;загружаем NaN
        mov dword ptr [esp-6], 0h
        mov dword ptr [esp-4], 7fff8000h
        fld tbyte ptr [esp-10]
        stc
        jmp __return
    __NoError:
    mov dword ptr __Bufer, 2            ;проверяем четность степени
    fild dword ptr __Bufer              ;для этого делим число на 2
    fdivp st(1), st(0)                  ;и определяем, является ли целым остаток
    fld st(0)                           ;копируем и округляем результат деления
    frndint
    fcompp st(1)                        ;выталкиваем из стека оба при сравнении
    fstsw ax                            ;флаги после сравнения - в ax
    push ax                             ;сохраняем перед вызовом
    fabs                                ;спокойно берем по модулю и возводим в степень
    call Float32_PowerUndef
    pop ax                              ;после вызова устанавливаем
    sahf
    je __return
        fchs                            ;инвертируем если была нечетная степень
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