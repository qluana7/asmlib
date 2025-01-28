extern div_u64    ; asmlib/lib64/arithmetic64.asm
extern modpow_u64 ; asmlib/lib64/modulo64.asm

global isprime

section .data
    miller_rabin_i64a: dq 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37

section .text
; ull = unsigned long long
; ll = long long

; miller_rabin(ull n, ull a) -> bool
miller_rabin:
    push ebp
    mov ebp, esp
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-16] = ull d, [ebp-24] = ull t
    sub esp, 8+8*2

    ; if (a % n == 0) return true;
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call div_u64
    add esp, 16
    or eax, edx
    setz al
    movzx eax, al
    jz $+0x7d

    ; d = n - 1;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    add eax, -1
    adc edx, -1
    mov [ebp-16], eax
    mov [ebp-12], edx

    ; while (true)
    ; t = modpow_u64(a, d, n);
    sub esp, 8
    push dword [ebp+12]
    push dword [ebp+8]
    push dword [ebp-12]
    push dword [ebp-16]
    push dword [ebp+20]
    push dword [ebp+16]
    call modpow_u64
    add esp, 32

    mov [ebp-24], eax
    mov [ebp-20], edx

    ; if (t == n - 1) return true;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    add eax, -1
    adc edx, -1
    xor eax, [ebp-24]
    xor edx, [ebp-20]
    or eax, edx
    setz al
    movzx eax, al
    jz $+0x2c

    ; if (d % 2 == 1)
    mov edx, [ebp-16]
    and edx, 1
    jz $+0x17

    test eax, eax
    jnz $+0x20

    mov eax, [ebp-24]
    xor eax, 1
    or eax, [ebp-20]
    setz al
    movzx eax, al

    jmp $+0xf

    ; d >>= 1;
    mov edx, [ebp-12]
    shrd [ebp-16], edx, 1
    shr dword [ebp-12], 1

    jmp $-0x67

    leave
    ret

; isprime(ull n) -> bool
isprime:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-16] = ull n, [ebp-20] = int i
    sub esp, 4+4*4

    mov edx, [ebp-4]
    mov eax, [edx]
    mov edx, [edx+4]
    mov [ebp-16], eax
    mov [ebp-12], edx

    ; if (n == 1) return false;
    mov eax, [ebp-16]
    xor eax, 1
    or eax, [ebp-12]
    jz $+0x6b

    ; if (n == 2 || n == 3) return true;
    mov eax, [ebp-16]
    xor eax, 2
    or eax, [ebp-12]
    jz $+0x59

    mov eax, [ebp-16]
    xor eax, 3
    or eax, [ebp-12]
    jz $+0x4e

    ; if (n % 2 == 0) return false;
    mov eax, [ebp-16]
    and eax, 1
    jz $+0x4d

    ; for (i = 0; i < 12; i++)
    mov dword [ebp-20], 0
    jmp $+0x37

    ; if (n == a) return true;
    mov ecx, [ebp-20]
    lea edx, [miller_rabin_i64a+ecx*8]
    mov ecx, edx

    mov eax, [ecx]
    mov edx, [ecx+4]
    xor eax, [ebp-16]
    xor edx, [ebp-12]
    or eax, edx
    jz $+0x22

    ; if (!miller_rabin(n, a)) return false;
    push dword [ecx+4]
    push dword [ecx]
    push dword [ebp-12]
    push dword [ebp-16]
    call miller_rabin
    add esp, 16

    test eax, eax
    jz $+0x12

    inc dword [ebp-20]

    cmp dword [ebp-20], 12
    jl $-0x39

    mov eax, 1
    jmp $+0x4

    xor eax, eax

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret