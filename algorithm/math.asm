; min(int a, int b) -> int
min:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovg eax, [ebp+12]

    pop ebp
    ret

; max(int a, int b) -> int
max:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovl eax, [ebp+12]

    pop ebp
    ret

; gcd(int a, int b) -> int
gcd:
    push ebp
    mov ebp, esp

    mov eax, [ebp+12]
    test eax, eax
    jnz gcd+15
    mov eax, [ebp+8]
    leave
    ret

    mov eax, [ebp+8]
    mov edx, 0
    div dword [ebp+12]
    push edx
    push dword [ebp+12]
    call gcd
    add esp, 8

    leave
    ret

; lcm(int a, int b) -> int
lcm:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov edx, 0
    mul dword [ebp+12]
    push eax

    push dword [ebp+12]
    push dword [ebp+8]
    call gcd
    add esp, 8

    pop ebx
    xchg eax, ebx
    mov edx, 0
    div ebx

    leave
    ret

; log10(double x) -> double (eax:edx)
log10:
    push ebp
    mov ebp, esp
    ; [ebp-8] = double invlb10
    sub esp, 8
    
    ; invlb10 = 0.301029995663981198017...
    mov dword [ebp-8], 1352628735
    mov dword [ebp-4], 1070810131

    ; invlb10 *= log2(x)
    fld qword [ebp-8]
    fld qword [ebp+8]
    fyl2x

    fstp qword [ebp-8]

    ; return invlb10;
    mov edx, [ebp-8]
    mov eax, [ebp-4]
    leave
    ret

; logl(double x) -> double (eax:edx)
logl:
    push ebp
    mov ebp, esp
    ; [ebp-8] = double invlbe
    sub esp, 8
    
    ; invlbe = 0.693147180559945286227...
    mov dword [ebp-8], -17155601
    mov dword [ebp-4], 1072049730

    ; invlbe *= log2(x)
    fld qword [ebp-8]
    fld qword [ebp+8]
    fyl2x

    fstp qword [ebp-8]

    ; return invlbe;
    mov edx, [ebp-8]
    mov eax, [ebp-4]
    leave
    ret

; logn(double base, double x) -> double (eax:edx)
logn:
    push ebp
    mov ebp, esp
    ; [ebp-8] = double invlbx
    sub esp, 8

    ; invlbx = 1.0 / log2(base);
    fld1
    fld1
    fld qword [ebp+8]
    fyl2x
    fdivp
    
    ; invlbx *= log2(x);
    fld qword [ebp+16]
    fyl2x
    fstp qword [ebp-8]

    ; return invlbx
    mov edx, [ebp-8]
    mov eax, [ebp-4]
    leave
    ret