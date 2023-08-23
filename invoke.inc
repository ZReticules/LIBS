
invoke macro Line:rest
local ProcName, Args, ArgPoint
    ArgPoint instr <Line>,<,>
    ProcName substr <Line>, 1, ArgPoint-1
    Args substr <Line>, ArgPoint+1
    % call ProcName StdCall, Args
    % RetSizeCount len, Args
    lea sp, [esp+len]
endm

RetSizeCount macro retvar:req, argums:Vararg
local KeyWords, x, incrementor
local Next_False
KeyWords    equ <offset, seg, mask, width, type, size, length>
    Next_False=0
    retvar = 0
    irp x, argums
        if Next_False eq 0
            incrementor = 0
            % irp y, <KeyWords>
                ifidni <x>, <y>
                    Next_False=1
                    incrementor = 2
                    exitm
                endif
            endm
            ifidni <x>, <ptr>
                Next_False=1
                incrementor = 0
            endif
            if Next_False eq 0
                RetSize 0, incrementor, x
            endif
            retvar=retvar+incrementor
        else 
            Next_False=0
        endif
    endm
endm

RetSize macro Mode:=<1>, DestVar:req, ArgVar:rest
local x
local RegsByte, RegsWord, RegsDword
local keywords, KeySmb, SpaceInstr
local Nums, InStrng, SubStrng
KeyWords    equ <offset, seg, mask, width, type, size, length>
RegsByte    equ <al, ah, bl, bh, dl, dh, cl, ch>
RegsWord    equ <ax, bx, cx, dx, sp, bp, si, di, cs, ds, es, fs, gs, ss>
RegsDword   equ <eax, ebx, ecx, edx, esi, edi, esp, ebp>
Nums        equ <0 1 2 3 4 5 6 7 8 9>
    ifidn <Mode>, <1>
        % irp x, <RegsByte>
            ifidni <ArgVar>, <x>
                DestVar = 1
                exitm
            endif
        endm
        if DestVar gt 0 
            exitm
        endif
    endif
    SpaceInstr instr <ArgVar>, < >
    if SpaceInstr gt 0
        KeySmb substr <ArgVar>, 1, SpaceInstr-1
        % irp x, <KeyWords>
            ifidni KeySmb, <x>
                DestVar = 2
                exitm
            endif
        endm
    endif
    if DestVar gt 0
        exitm
    endif
    DestVar = type ArgVar
    if DestVar gt 0 
        exitm
    endif
    % irp x, <RegsDword>
        ifidni <ArgVar>, <x>
            DestVar = 4
            exitm
        endif
    endm
    if DestVar gt 0 
        exitm
    endif
    % irp x, <RegsWord>
        ifidni <ArgVar>, <x>
            DestVar = 2
            exitm
        endif
    endm
    if DestVar gt 0 
        exitm
    endif
    if ArgVar lt 65536
        DestVar=2
        exitm
    else
        DestVar=4
        exitm
    endif
endm
