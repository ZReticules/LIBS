extrn C Random_LCG               :far
extrn C Random_XorShift32        :far
extrn C Random_InitXorshift128   :far

random struc global method{
        LCG:dword           = Random_LCG
        XorShift32:dword    = Random_XorShift32
        XorShift128:dword   = Random_XorShift128
    }
ends