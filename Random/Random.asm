model small
.386
.code

public Random_LCG
public Random_XorShift32
public Random_InitXorshift128

VERSION M520

locals __

; m = 2^32 -> xor edx, edx
a equ 214013
c equ 2531011

State_LCG dd 0

Random_LCG proc C far uses edx ds ebx
@@Min equ [esp+14]
@@Max equ [esp+18]
    mov ax, seg State_LCG
    mov ds, ax
    mov eax, State_LCG
    test eax, eax
    jnz @F
        call GetTicks
    @@:
    mov ebx, a
    mul ebx
    add eax, c
    mov edx, eax
    shr edx, 15
    xor eax, edx
    mov State_LCG, eax
    mov ebx, @@Max
    sub ebx, @@Min
    jz __NullDiv
        Call Interval StdCall, dword ptr @@Min
    __NullDiv:
    ret
endp

; state ^= state << 13;
; state ^= state >> 17;
; state ^= state << 5;
; return state;

State_XS32 dd ?

Random_XorShift32 proc C far uses ds ebx
@@Min equ [esp+10]
@@Max equ [esp+14]
    mov ds, ax
    mov eax, State_XS32
    test eax, eax
    jnz @F
        call GetTicks
    @@:
    mov ebx, eax
    shl ebx, 13
    xor eax, ebx
    mov ebx, eax
    shr ebx, 17
    xor eax, ebx
    mov ebx, eax
    shl ebx, 5
    xor eax, ebx
    mov State_XS32, eax
    mov ebx, @@Max
    sub ebx, @@Min
    jz __NullDiv
        Call Interval StdCall, dword ptr @@Min
    __NullDiv:
    ret
endp

GetTicks proc C near uses es
    mov ax, 40h
    mov es, ax
    mov eax, es:006Ch
    ret
endp

Interval proc StdCall near
@@Min equ [esp+2]
    xor edx, edx
    div ebx
    mov eax, edx
    add eax, @@Min    
    ret 4
endp

; struct xorshift128_state {
;     uint32_t x[4];
; };

; /* The state must be initialized to non-zero */
; uint32_t xorshift128(struct xorshift128_state *state)
; {
; 	/* Algorithm "xor128" from p. 5 of Marsaglia, "Xorshift RNGs" */
; 	uint32_t t  = state->x[3];
    
;     uint32_t s  = state->x[0];  /* Perform a contrived 32-bit shift. */
; 	state->x[3] = state->x[2];
; 	state->x[2] = state->x[1];
; 	state->x[1] = s;

; 	t ^= t << 11;
; 	t ^= t >> 8;
; 	return state->x[0] = t ^ s ^ (s >> 19);
; }

LinkerMask equ 11b

Initialize dd offset Init
Linker db 0
State_XS128 dd 4 dup(?)

Random_XorShift128 proc C far uses ds edx ebx
@@Min equ [esp+14]
@@Max equ [esp+18]
    mov ax, seg State_XS128
    mov ds, ax
    mov ebx, offset Initialize
    jmp [ebx]
    Init::
        call Random_InitXorshift128
        mov Initialize, offset NoInit
    NoInit::
    movzx ebx, Linker
    mov edx, ebx
    mov eax, State_XS128[edx] ; - s
    dec ebx
    and ebx, LinkerMask
    mov ebx, State_XS128[ebx] ; - t
    inc dl
    and dl, LinkerMask
    mov Linker, dl
    ;сдвиг очереди завершен
    push edx
    mov edx, ebx
    shl edx, 11
    xor ebx, edx
    mov edx, ebx
    shr edx, 8
    xor ebx, edx
    ;первая часть завершена
    xor ebx, eax
    shr eax, 19
    xor eax, ebx
    pop edx
    mov State_XS128[edx], eax
    ;генерация завершена
    mov ebx, @@Max
    sub ebx, @@Min
    jz __NullDiv
        call Interval StdCall, dword ptr @@Min
    __NullDiv:
    ret
endp

Random_InitXorshift128 proc C near uses ds ecx eax
    mov ax, seg State_XS128
    mov ds, ax
    push dword ptr 0
    push dword ptr 0
    mov ecx, 16
    @@:
        call Random_LCG
        mov State_XS128[ecx-4], eax
    sub ecx, 4
    jnz @B
    lea esp, [esp+8]
    ret
endp

end