EGAColors_Black          equ byte ptr 0000b
EGAColors_Blue           equ byte ptr 0001b
EGAColors_Green          equ byte ptr 0010b
EGAColors_Cyan           equ byte ptr 0011b
EGAColors_Red            equ byte ptr 0100b
EGAColors_Magneta        equ byte ptr 0101b
EGAColors_Orange         equ byte ptr 0110b
EGAColors_White          equ byte ptr 0111b 
EGAColors_BrightBlack    equ byte ptr 1000b
EGAColors_BrightBlue     equ byte ptr 1001b 
EGAColors_BrightGreen    equ byte ptr 1010b 
EGAColors_BrightCyan     equ byte ptr 1011b 
EGAColors_BrightRed      equ byte ptr 1100b 
EGAColors_BrightMagneta  equ byte ptr 1101b 
EGAColors_BrightOrange   equ byte ptr 1110b 
EGAColors_BrightWhite    equ byte ptr 1111b
EGAColors_NoColor        equ byte ptr -1
EGAColors_BrightOnly     equ byte ptr 10000b

extrn C EGAColor_ChgColor   :far
extrn Console_SetColor      :far
extrn Console_ClearColor    :far

EGAColor struc global method {          ;ARGS
        Change:dword = EGAColor_ChgColor;EGAColors:WORD(⮫쪮 1 梥�), Red:WORD, Green:WORD, Blue:WORD
    }
    Text db EGAColors_White
    Back db EGAColors_Black
ends 
