model tiny
.386
.code
org 100h

locals @@

StartPoint equ 1980

PushMonths label word
Months db 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

public DateTime_GetHourMinuteSecond
public DateTime_GetSecond
public DateTime_GetMinute
public DateTime_GetHour
public DateTime_GetYearMonthDay
public DateTime_GetYear
public DateTime_GetMonth
public DateTime_GetDay
public DateTime_InToUnix
public DateTime_StrToUnix
public DateTime_UnixToStr
public DateTime_GetNow
public DateTime_AddMonth
public DateTime_AddYear
public TimeSpan_GetSecond
public TimeSpan_GetMinute
public TimeSpan_GetHour
public TimeSpan_GetDay
public TimeSpan_InToUnix
public TimeSpan_UnixToStr
public TimeSpan_StrToUnix
public DateTime_AddDay
public DateTime_AddHour
public DateTime_AddMinute
public DateTime_SetDate
public DateTime_SetTime

DateTime_GetHourMinuteSecond proc C far uses esi
    xor edx, edx
    mov esi, 60
    div esi
    mov ecx, edx
    xor edx, edx
    div esi
    mov ebx, edx
    xor edx, edx
    mov esi, 24
    div esi
    ret
endp

DateTime_GetSecond proc C far uses ecx ebx edx
@DateTime equ [esp+16]
    mov eax, @DateTime
    call DateTime_GetHourMinuteSecond
    mov eax, ecx
    ret
endp

DateTime_GetMinute proc C far uses ecx ebx edx
@DateTime equ [esp+16]
    mov eax, @DateTime
    call DateTime_GetHourMinuteSecond
    mov eax, ebx
    ret
endp

DateTime_GetHour proc C far uses ecx ebx edx
@DateTime equ [esp+16]
    mov eax, @DateTime
    call DateTime_GetHourMinuteSecond
    mov eax, edx
    ret
endp

DateTime_GetYearMonthDay proc C far uses edx esi edi ds PushMonths
    mov bx, seg Months
    mov ds, bx
    mov ebx, offset Months
    xor edx, edx
    mov esi, 24*3600
    div esi
    xor edx, edx
    mov esi, 3*365+366
    div esi
    shl eax, 2
    mov edi, eax
    add edi, StartPoint
    mov eax, edx
    xor edx, edx
    xor ecx, ecx
    mov esi, 365
    cmp eax, 366
    jle @SubMonths
        dec eax
        dec byte ptr [ebx+1]
        div esi
        add edi, eax
        mov eax, edx
    @SubMonths:
        sub eax, ecx
        movzx ecx, byte ptr[ebx]
        inc bx
        cmp eax, ecx
    jge @SubMonths
    inc eax
    sub ebx, offset Months
    mov ecx, edi
    ret
endp

DateTime_GetYear proc C far uses ecx ebx
@DateTime equ [esp+12]
    mov eax, @DateTime
    call DateTime_GetYearMonthDay
    mov eax, ecx
    ret
endp

DateTime_GetMonth proc C far uses ecx ebx
@DateTime equ [esp+12]
    mov eax, @DateTime
    call DateTime_GetYearMonthDay
    mov eax, ebx
    ret
endp

DateTime_GetDay proc C far uses ecx ebx
@DateTime equ [esp+12]
    mov eax, @DateTime
    call DateTime_GetYearMonthDay
    ret
endp

DateTime_InToUnix proc C far uses edx ecx edx ebx esi PushMonths
Year    equ word ptr [esp+26]
Month   equ word ptr [esp+28]
Day     equ word ptr [esp+30]
Hour    equ word ptr [esp+32]
Minute  equ word ptr [esp+34]
Second  equ word ptr [esp+36]
    mov ax, seg Months
    mov ds, ax
    xor ecx, ecx
    xor ebx, ebx
    movzx eax, Year
    sub eax, StartPoint
    mov esi, 365
    jz @NullYear
        mov ebx, eax
        shr ebx, 2
        shl ebx, 2
        mov edx, eax
        sub edx, ebx
        setnz cl
        sub Months+1, cl
        sub cl, 1
        neg cl
        mov ebx, eax
        mul esi
        sub ebx, ecx
        shr ebx, 2
        add eax, ebx
        xor ecx, ecx
        xor ebx, ebx
        inc eax
    @NullYear:
        add eax, ecx
        movzx ecx, byte ptr [Months+bx]
        inc bx
    cmp bx, Month
    jl @NullYear
    dec eax
    movzx ebx, Day
    add eax, ebx
    mov esi, 24
    mul esi
    movzx ebx, Hour
    add eax, ebx
    mov esi, 60
    mul esi
    movzx ebx, Minute
    add eax, ebx
    mul esi
    movzx ebx, Second
    add eax, ebx
    ret
endp

DateTime_StrToUnix proc C far uses si bx ds
StrLongLink equ [esp+10]
    lds si, StrLongLink
    mov bx, 15
    @@PushLoop:
        mov ax, [si+bx+2]
        call AsciToInt
        push ax
        sub bx, 3
    jnz @@PushLoop
    mov eax, [si]
    call AsciToInt
    mov bx, ax
    shr eax, 16
    call AsciToInt
    xchg bx, ax
    mov si, 100
    mul si
    add ax, bx
    call DateTime_InToUnix StdCall, ax
    add esp, 12
    ret
endp

AsciToInt proc
    sub al, 30h
    sub ah, 30h
    xchg al, ah
    aad
    ret
endp

DateTime_UnixToStr proc C far uses si ebx ds ecx edx
@DateTime   equ [esp+20]
StrLongLink equ [esp+24]
    lds si, StrLongLink
    mov eax, @DateTime
    call DateTime_GetHourMinuteSecond
    mov ax, cx
    call InToAsci
    mov [si+17], ax
    mov [si+16], byte ptr ':'
    mov ax, bx
    call InToAsci
    mov [si+14], ax
    mov [si+13], byte ptr ':'
    mov ax, dx
    call InToAsci
    mov [si+11], ax
    mov [si+10], byte ptr ' '
    mov eax, @DateTime
    call DateTime_GetYearMonthDay
    call InToAsci
    mov [si+8], ax
    mov [si+7], byte ptr '/'
    mov ax, bx
    call InToAsci
    mov [si+5], ax
    mov [si+4], byte ptr '/'
    mov ax, cx
    xor dx, dx
    mov bx, 100
    div bx
    call InToAsci
    mov [si], ax
    mov ax, dx
    call InToAsci
    mov [si+2], ax
    mov [si+19], byte ptr 0
    mov eax, 19
    ret
endp

InToAsci proc
    aam
    xchg al, ah
    add al, 30h
    add ah, 30h
    ret
endp

DateTime_GetNow proc C far uses ecx edx bx
    xor bx, bx
    mov ah, 2Ch
    int 21h
    mov bl, dh
    push bx
    mov bl, cl
    push bx
    mov bl, ch
    push bx
    mov ah, 2Ah
    int 21h
    mov bl, dl
    push bx
    mov bl, dh
    push bx
    mov bx, cx
    call DateTime_InToUnix StdCall, bx
    add esp, 12
    ret
endp

DateTime_AddMonth proc C far uses edx ebx ecx edi esi
@DateTime   equ [esp+24]
AddMonth    equ [esp+28]
    xor edx, edx
    mov eax, @DateTime
    mov esi, 24*3600
    div esi
    mov eax, @DateTime
    call DateTime_GetYearMonthDay
    mov di, ax
    dec bx
    mov si, 12
    add bx, AddMonth
    jns @@PositiveNumber
        @@NegativeCycle:
            dec cx
            add bx, si
        js @@NegativeCycle
    @@PositiveNumber:
    mov eax, ebx
    mov ebx, edx
    xor dx, dx
    div si
    add ecx, eax
    inc edx
    call DateTime_InToUnix C, cx, dx, di, 0, 0, 0
    add eax, ebx
    ret
endp

DateTime_AddYear proc C far uses edx ebx ecx
@DateTime   equ [esp+16]
@AddYear    equ [esp+20]
    mov eax, @DateTime
    xor edx, edx
    mov ecx, 24*3600
    div ecx
    mov eax, @DateTime
    call DateTime_GetYearMonthDay
    add cx, @AddYear
    call DateTime_InToUnix C, cx, bx, ax, 0, 0, 0
    add eax, edx
    ret
endp

TimeSpan_GetSecond proc c far uses edx ebx ecx si
@TimeSpan equ [esp+18]
    mov eax, @TimeSpan
    mov esi, 1
    @@Abs:
        neg esi
        neg eax
    js @@Abs
    call DateTime_GetHourMinuteSecond
    mov eax, ecx
    xor edx, edx
    imul esi
    ret
endp

TimeSpan_GetMinute proc c far uses edx ebx ecx si
@TimeSpan equ [esp+18]
    mov eax, @TimeSpan
    mov esi, 1
    @@Abs:
        neg esi
        neg eax
    js @@Abs
    call DateTime_GetHourMinuteSecond
    mov eax, ebx
    xor edx, edx
    imul esi
    ret
endp

TimeSpan_GetHour proc c far uses edx ebx ecx si
@TimeSpan equ [esp+18]
    mov eax, @TimeSpan
    mov esi, 1
    @@Abs:
        neg esi
        neg eax
    js @@Abs
    call DateTime_GetHourMinuteSecond
    mov eax, edx
    xor edx, edx
    imul esi
    ret
endp

TimeSpan_GetDay proc c far uses edx ebx esi
@TimeSpan equ dword ptr [esp+12]
    xor edx, edx
    mov eax, @TimeSpan
    mov esi, 1
    @@Abs:
        neg esi
        neg eax
    js @@Abs
    mov ebx, 24*3600
    xor edx, edx
    idiv ebx
    imul esi
    ret
endp

TimeSpan_InToUnix proc C far uses edx esi
@Days       equ word ptr [esp+12]
@Hours      equ word ptr [esp+14]
@Minutes    equ word ptr [esp+16]
@Seconds    equ word ptr [esp+18]
    xor edx, edx
    movsx eax, @Days
    mov esi, 24
    imul esi
    movsx esi, @Hours
    add eax, esi
    mov esi, 60
    imul esi
    movsx esi, @Minutes
    add eax, esi
    mov esi, 60
    imul esi
    movsx esi, @Seconds
    add eax, esi
    ret
endp

TimeSpan_UnixToStr proc C far uses edx ecx ebx si ds
@TimeSpan   equ dword ptr [esp+20]
StrLongLink equ [esp+24]
    lds si, StrLongLink
    mov eax, @TimeSpan
    mov [si], byte ptr '/'
    @@Abs:
        sub [si], byte ptr 2
        neg eax
    js @@Abs
    call DateTime_GetHourMinuteSecond
    mov ax, cx
    call InToAsci
    mov [si+13], ax
    mov [si+12], byte ptr ':'
    mov ax, bx
    call InToAsci
    mov [si+10], ax
    mov [si+9], byte ptr ':'
    mov ax, dx
    call InToAsci
    mov [si+7], ax
    mov [si+6], byte ptr '.'
    call TimeSpan_GetDay C, @TimeSpan
    @@Abs1:
        neg eax
    js @@Abs1
    xor dx, dx
    mov bx, 10000
    div bx
    add al, 30h
    mov [si+1], al
    mov ax, dx
    xor dx, dx
    mov bx, 100
    div bx
    call InToAsci
    mov [si+2], ax
    mov ax, dx
    call InToAsci
    mov [si+4], ax
    mov [si+15], byte ptr 0
    mov eax, 15
    ret
endp

TimeSpan_StrToUnix proc C far uses edx ecx ebx si edi ds
LStrLink equ [esp+20]
    lds si, LStrLink
    mov edi, 1
    cmp [si], byte ptr '-'
    jne @@NoNeg
        neg edi
    @@NoNeg:
    mov bx, 9
    @@PushLoop:
        mov ax, [si+bx+4]
        call AsciToInt
        push ax
        sub bx, 3
    jnz @@PushLoop
    mov bx, 1
    mov cx, 10
    xor ax, ax
    @@MulLoop:
        mul cx
        mov dl, [si+bx]
        sub dx, 30h
        add ax, dx
        inc bx
    cmp bx, 5
    jle @@MulLoop
    call TimeSpan_InToUnix StdCall, ax
    add esp, 8
    xor edx, edx
    imul edi
    ret
endp

;следующая процедура является служебной. Кривыми руками не лезть!
;первый аргумент - количество, адрес состоит из:
; 1. Адреса возврата (близкий адрес -> 2 байта) 
; 2. Коэффициента dword (4)
; 3. Адреса возврата внешней процедуры (дальний адрес, 4 байта)
; 4. Исходной даты dword (4 байта)

DateTime_Add proc C near
    movsx eax, word ptr [esp+14]    ;получаем количество дней/часов/минут
    imul eax, [esp+2]               ;умножаем на соответствующий коэффициент
    add eax, [esp+10]               ;складываем с исходной датой
    ret
endp

DateTime_AddDay proc C far
    call DateTime_Add C, dword ptr 24*3600
    ret
endp

DateTime_AddHour proc C far
    call DateTime_Add C, dword ptr 3600
    ret
endp

DateTime_AddMinute proc C far
    call DateTime_Add C, dword ptr 60
    ret
endp

DateTime_SetDate proc C far uses eax ebx ecx
    mov eax, [esp+16]
    call DateTime_GetYearMonthDay
    mov dl, al
    mov dh, bl
    mov ah, 2bh
    int 21h
    ret
endp
;следующая процедура не работает в DosBox.
DateTime_SetTime proc C far uses eax ebx ecx edx
    mov eax, [esp+20]
    call DateTime_GetHourMinuteSecond
    mov dh, cl
    xchg ch, dl
    mov cl, bl
    mov ah, 2dh
    int 21h
    ret
endp

end