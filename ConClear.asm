model tiny
.386
.code

public ConClear

ConClear proc c far uses ax
        mov ah, 0fh         ; получаем текущий режим экрана в al
        int 10h
        mov ah, 00h         ; переустанавливаем его, очищая экран
        int 10h
    ret
ConClear endp
end