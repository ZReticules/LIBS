extrn _Heap_GetTotalSize:far
extrn _Heap_ResizeBlock :far
extrn _Heap_Create      :far
extrn _Heap_AllocBlock  :far
extrn _Heap_GetBlockSize:far
extrn _Heap_FreeBlock   :far

Heap struc global method{
        GetTotalSize:dword  = _Heap_GetTotalSize
        ResizeBlock:dword   = _Heap_ResizeBlock
        Create:dword        = _Heap_Create
        AllocBlock:dword    = _Heap_AllocBlock
        GetBlockSize:dword  = _Heap_GetBlockSize
        FreeBlock:dword     = _Heap_FreeBlock
    }
ends