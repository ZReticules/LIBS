extrn C Heap_GetTotalSize:far
extrn C Heap_ResizeBlock :far
extrn C Heap_Init        :far
extrn C Heap_AllocBlock  :far
extrn C Heap_GetBlockSize:far
extrn C Heap_FreeBlock   :far

VERSION T410

Heap struc global method{
        GetTotalSize:dword  = Heap_GetTotalSize
        ResizeBlock:dword   = Heap_ResizeBlock
        Init:dword          = Heap_Init
        AllocBlock:dword    = Heap_AllocBlock
        GetBlockSize:dword  = Heap_GetBlockSize
        FreeBlock:dword     = Heap_FreeBlock
    }
ends