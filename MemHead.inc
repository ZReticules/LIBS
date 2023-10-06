MemHead struc
    db ?                            ;тип блока
    db 2 dup (?)                    ;сегмент владельца блока
    BlockSize   db 2 dup (?)        ;размер блока
ends