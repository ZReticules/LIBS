ConsoleColors_Black          equ byte ptr 0000b
ConsoleColors_Blue           equ byte ptr 0001b
ConsoleColors_Green          equ byte ptr 0010b
ConsoleColors_Cyan           equ byte ptr 0011b
ConsoleColors_Red            equ byte ptr 0100b
ConsoleColors_Magneta        equ byte ptr 0101b
ConsoleColors_Orange         equ byte ptr 0110b
ConsoleColors_White          equ byte ptr 0111b 
ConsoleColors_BrightBlack    equ byte ptr 1000b
ConsoleColors_BrightBlue     equ byte ptr 1001b 
ConsoleColors_BrightGreen    equ byte ptr 1010b 
ConsoleColors_BrightCyan     equ byte ptr 1011b 
ConsoleColors_BrightRed      equ byte ptr 1100b 
ConsoleColors_BrightMagneta  equ byte ptr 1101b 
ConsoleColors_BrightOrange   equ byte ptr 1110b 
ConsoleColors_BrightWhite    equ byte ptr 1111b
ConsoleColors_NoColor        equ byte ptr -1
ConsoleColors_BrightOnly     equ byte ptr 10000b

ConsoleColor struc
    Text db ConsoleColors_White
    Back db ConsoleColors_Black
ends 
