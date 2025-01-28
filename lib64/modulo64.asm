extern mul_64 ; asmlib/lib64/arithmetic64.asm

; Calculate '((a % m) * (b % m)) % m'.
; mulmod_u64(ull a, ull b, ull m) -> ull
mulmod_u64:
    push ebp
    mov ebp, esp
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-16] = ll r, [ebp-24] = ll t
    sub esp, 8+8*2

    ; r = a * b - m * ull(1.L / m * a * b);
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call mul_64
    add esp, 16

    mov [ebp-16], eax
    mov [ebp-12], edx

    fld1
    fild qword [ebp+24]
    fdivp
    fild qword [ebp+8]
    fild qword [ebp+16]
    fmulp st2
    fmulp
    fisttp qword [ebp-24]
    push dword [ebp-20]
    push dword [ebp-24]
    push dword [ebp+28]
    push dword [ebp+24]
    call mul_64
    add esp, 16
    sub [ebp-16], eax
    sbb [ebp-12], edx

    ; return r + m * (r < 0) - m * (r >= (ll)m);
    cmp dword [ebp-12], 0
    jns $+0xe

    mov eax, [ebp+24]
    mov edx, [ebp+28]
    add [ebp-16], eax
    adc [ebp-12], edx

    mov eax, [ebp-16]
    mov edx, [ebp-12]
    cmp eax, [ebp+24]
    sbb edx, [ebp+28]
    jc $+0xe

    mov eax, [ebp+24]
    mov edx, [ebp+28]
    sub [ebp-16], eax
    sbb [ebp-12], edx

    mov eax, [ebp-16]
    mov edx, [ebp-12]

    leave
    ret

; Calculate 'pow(n, p) % m'.
; #require (mulmod)
; modpow_u64(ull n, ull p, ull m)
modpow_u64:
    push ebp
    mov ebp, esp
    ; variable start = [ebp-8], max depth = [ebp-40]
    ; [ebp-16] = ll n, [ebp-24] = ll p, [ebp-32] = ll r
    sub esp, 8+8*4

    ; n = [para]->n;
    ; p = [para]->p;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    mov [ebp-16], eax
    mov [ebp-12], edx

    mov eax, [ebp+16]
    mov edx, [ebp+20]
    mov [ebp-24], eax
    mov [ebp-20], edx

    ; r = 1;
    mov dword [ebp-32], 1
    mov dword [ebp-28], 0

    ; while (p)
    jmp $+0x5b

    ; if (p & 1)
    mov eax, [ebp-24]
    and eax, 1
    jz $+0x25

    ; r = mulmod(n, r, m);
    sub esp, 8
    push dword [ebp+28]
    push dword [ebp+24]
    push dword [ebp-28]
    push dword [ebp-32]
    push dword [ebp-12]
    push dword [ebp-16]
    call mulmod_u64
    add esp, 32

    mov [ebp-32], eax
    mov [ebp-28], edx
    
    ; n = mulmod(n, n, m);
    sub esp, 8
    push dword [ebp+28]
    push dword [ebp+24]
    push dword [ebp-12]
    push dword [ebp-16]
    push dword [ebp-12]
    push dword [ebp-16]
    call mulmod_u64
    add esp, 32

    mov [ebp-16], eax
    mov [ebp-12], edx

    ; p >>= 1;
    mov edx, [ebp-20]
    shrd [ebp-24], edx, 1
    shr dword [ebp-20], 1

    mov eax, [ebp-24]
    or eax, [ebp-20]
    jnz $-0x5f

    ; return r;
    mov eax, [ebp-32]
    mov edx, [ebp-28]

    leave
    ret