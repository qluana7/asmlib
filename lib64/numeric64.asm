extern mul_64  ; asmlib/lib64/math64.asm
extern div_u64 ; asmlib/lib64/math64.asm
extern mod_u64 ; asmlib/lib64/math64.asm

global gcd_u64
global lcm_u64

; gcd_u64(u64 a, u64 b) -> u64
gcd_u64:
    push ebp
    mov ebp, esp

    ; if (b == 0)
    mov eax, [ebp+16]
    or eax, [ebp+20]
    jnz $+0xa

    ; return a;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    pop ebp
    ret

    ; return gcd_u64(b, a % b);
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call mod_u64
    add esp, 16
    push edx
    push eax
    push dword [ebp+20]
    push dword [ebp+16]
    call gcd_u64
    add esp, 16

    pop ebp
    ret

; lcm_u64(u64 a, u64 b) -> u64
lcm_u64:
    push ebp
    mov ebp, esp

    ; return a / gcd_u64(a, b) * b;
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call gcd_u64
    mov [esp+8], eax
    mov [esp+12], edx
    call div_u64
    add esp, 16
    push edx
    push eax
    push dword [ebp+20]
    push dword [ebp+16]
    call mul_64
    add esp, 16

    pop ebp
    ret