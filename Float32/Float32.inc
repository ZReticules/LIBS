extrn C _Float32_ToString    :far
extrn C Float32_Log         :far
extrn C Float32_Lg          :far
extrn C Float32_Ln          :far
extrn C _Float32_FromString  :far
extrn C Float32_ToRad       :far
extrn C Float32_ToGrad      :far
extrn C Float32_ArcSin      :far
extrn C Float32_ArcCos      :far
extrn C Float32_PowerUndef  :far
extrn C Float32_Power       :far
extrn C Float32_ToInt32     :far

Float32 struc Global method{  
        ToString:dword   = _Float32_ToString
        Log:dword        = Float32_Log
        Lg:dword         = Float32_Lg
        Ln:dword         = Float32_Ln
        FromString:dword = _Float32_FromString
        ToRad:dword      = Float32_ToRad
        ToGrad:dword     = Float32_ToGrad
        ArcSin:dword     = Float32_ArcSin
        ArcCos:dword     = Float32_ArcCos
        PowerUndef:dword = Float32_PowerUndef
        Power:dword      = Float32_Power
        ToInt32:dword    = Float32_ToInt32
    }
    dd 0.0
ends

RoundToZerO macro mem:req, reg:req
    fnstcw word ptr mem
    mov reg, mem
    and word ptr mem, 1111001111111111b
    or word ptr mem, 110000000000b
    fldcw word ptr mem
    mov mem, reg
endm