model tiny
.386
.code

public NewLine

NewLine proc c far uses ax
    mov al, 0ah
    int 29h
    mov al, 0dh
    int 29h
ret
NewLine endp
end