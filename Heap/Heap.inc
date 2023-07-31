VERSION M520
extrn _Heap_GetTotalSize:far
extrn _Heap_ResizeBlock :far
extrn _Heap_Init        :far
extrn _Heap_AllocBlock  :far
extrn _Heap_GetBlockSize:far
extrn _Heap_FreeBlock   :far
VERSION T410
Heap struc global method{
        GetTotalSize:dword  = _Heap_GetTotalSize
        ResizeBlock:dword   = _Heap_ResizeBlock
        Init:dword          = _Heap_Init
        AllocBlock:dword    = _Heap_AllocBlock
        GetBlockSize:dword  = _Heap_GetBlockSize
        FreeBlock:dword     = _Heap_FreeBlock
    }
ends