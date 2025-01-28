extern mod_u64    ; asmlib/lib64/artihmetic64.asm
extern mulmod_u64 ; asmlib/lib64/modulo64.asm
extern gcd_u64    ; asmlib/lib64/numeric64.asm
extern isprime    ; asmlib/algorithm/math/miller_rabin.asm

global pollard_rho

extern rand

; ull = unsigned long long
; ll = long long

; pollard_rho_g(ull x, ull n, ull r) -> ull
pollard_rho_g:
    push ebp
    mov ebp, esp
    sub esp, 8

    ; return (mulmod_u64(x, x, n) + r) % n;
    sub esp, 8
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    push dword [ebp+12]
    push dword [ebp+8]
    call mulmod_u64
    add esp, 32
    add eax, [ebp+24]
    adc edx, [ebp+28]
    push dword [ebp+20]
    push dword [ebp+16]
    push edx
    push eax
    call mod_u64
    add esp, 16

    leave
    ret

; ull pollard_rho(ull __n)
pollard_rho:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-56]
    ; [ebp-16] = ll x, [ebp-24] = ll y, [ebp-32] = ll d, [ebp-40] = ll r
    ; [ebp-48] = ll n
    sub esp, 4+4*12

    ; n = __n;
    mov eax, [ecx]
    mov edx, [ecx+4]
    mov [ebp-48], eax
    mov [ebp-44], edx

    ; if (n == 1)
    xor eax, 1
    or eax, edx
    jnz $+0x11

    ; return 1;
    mov edx, 0
    mov eax, 1
    jmp $+0x166

    ; if (isprime(n))
    sub esp, 8
    push dword [ebp-44]
    push dword [ebp-48]
    call isprime
    add esp, 16
    test eax, eax
    jz $+0xd

    ; return n;
    mov edx, [ebp-44]
    mov eax, [ebp-48]
    jmp $+0x146

    ; if (n % 2 == 0)
    mov eax, [ebp-48]
    and eax, 1
    jnz $+0x11

    ; return 2;
    mov edx, 0
    mov eax, 2
    jmp $+0x12f

    ; x = rand() % 19 + 1, y = x, d = 1, r = rand() % 19 + 1;
    call rand
    mov ecx, eax
    mov edx, -1356305461
    mul edx
    mov eax, ecx
    sub eax, edx
    shr eax, 1
    add eax, edx
    shr eax, 4
    imul eax, 19
    sub ecx, eax
    inc ecx
    mov dword [ebp-12], 0
    mov [ebp-16], ecx
    mov dword [ebp-20], 0
    mov [ebp-24], ecx
    mov dword [ebp-28], 0
    mov dword [ebp-32], 1
    call rand
    mov ecx, eax
    mov edx, -1356305461
    mul edx
    mov eax, ecx
    sub eax, edx
    shr eax, 1
    add eax, edx
    shr eax, 4
    imul eax, 19
    sub ecx, eax
    inc ecx
    mov dword [ebp-36], 0
    mov [ebp-40], ecx

    ; while (d == 1)
    jmp $+0xa0

    ; x = g(x, n, r);
    sub esp, 8
    push dword [ebp-36]
    push dword [ebp-40]
    push dword [ebp-44]
    push dword [ebp-48]
    push dword [ebp-12]
    push dword [ebp-16]
    call pollard_rho_g
    add esp, 8
    mov [ebp-16], eax
    mov [ebp-12], edx

    ; y = g(g(y, n, r), n, r);
    push dword [ebp-20]
    push dword [ebp-24]
    call pollard_rho_g
    add esp, 8
    push edx
    push eax
    call pollard_rho_g
    add esp, 32
    mov [ebp-24], eax
    mov [ebp-20], edx

    ; d = gcd_u64(abs(x - y), n);
    mov eax, [ebp-16]
    mov edx, [ebp-12]
    sub eax, [ebp-24]
    sbb edx, [ebp-20]
    mov [ebp-32], eax
    mov [ebp-28], edx
    neg eax
    adc edx, 0
    neg edx
    cmovs eax, [ebp-32]
    cmovs edx, [ebp-28]
    push dword [ebp-44]
    push dword [ebp-48]
    push edx
    push eax
    call gcd_u64
    add esp, 16
    mov [ebp-32], eax
    mov [ebp-28], edx

    ; if (d == n) return pollard_rho(n);
    mov eax, [ebp-32]
    xor eax, [ebp-48]
    mov edx, [ebp-28]
    xor edx, [ebp-44]
    or eax, edx
    jnz $+0x15

    ; return pollard_rho(n);
    sub esp, 8
    push dword [ebp-44]
    push dword [ebp-48]
    call pollard_rho
    add esp, 16

    jmp $+0x22

    mov eax, [ebp-32]
    xor eax, 1
    or eax, [ebp-28]
    jz $-0xa4
    
    ; return pollard_rho(d);
    sub esp, 8
    push dword [ebp-28]
    push dword [ebp-32]
    call pollard_rho
    add esp, 16

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret