model tiny
.386
.code

locals @@

StartPoint equ 1980

PushMonths label word
Months db 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

public DateTime_GetHourMinuteSecond
public DateTime_GetYearMonthDay
public DateTime_InToUnix
public DateTime_StrToUnix
public DateTime_UnixToStr
public TimeSpan_GetDay
public TimeSpan_InToUnix
public TimeSpan_UnixToStr
public TimeSpan_StrToUnix

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
LStrLink equ [esp+24]
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

end