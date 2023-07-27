model tiny
.386
.code

locals @@

StartPoint equ 1980

includelib c:\libs\datetime\datetime.lib

extrn DateTime_GetHourMinuteSecond    :far
extrn DateTime_GetYearMonthDay        :far
extrn DateTime_InToUnix               :far
extrn TimeSpan_InToUnix               :far
public DateTime_GetSecond
public DateTime_GetMinute
public DateTime_GetHour
public DateTime_GetYear
public DateTime_GetMonth
public DateTime_GetDay
public DateTime_GetNow
public DateTime_AddMonth
public DateTime_AddYear
public TimeSpan_GetSecond
public TimeSpan_GetMinute
public TimeSpan_GetHour
public DateTime_AddDay
public DateTime_AddHour
public DateTime_AddMinute
public DateTime_SetDate
public DateTime_SetTime

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
@TimeSpan equ dword ptr [esp+16]
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

;следующая процедура является служебной. Кривыми руками не лезть!
;первый аргумент - количество, адрес состоит из:
; 1. Адреса возврата (близкий адрес -> 2 байта) 
; 2. Коэффициента dword (4)
; 3. Адреса возврата внешней процедуры (дальний адрес, 4 байта)
; 4. Исходной даты dword (4 байта)

DateTime_Add proc C near
    xor eax, eax
    mov ax, word ptr [esp+14]    ;получаем количество дней/часов/минут
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