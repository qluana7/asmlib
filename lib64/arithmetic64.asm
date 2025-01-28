
; /* Math64 Purpose */
; use 64 bits arithmetics in 32 bits assembly
;     without glibc's integer arithmetic routines

global div_u64
global mod_u64
global div_i64
global mod_i64
global abs_i64

; Return value : a <=> b { less = -1, equal = 0, greater = 1 }
; cmp_u64(u64 a, u64 b) -> int
cmp_u64:
    push ebp
    mov ebp, esp

    ; if ((u32)a.h < (u32)b.h) return -1;
    xor eax, eax
    mov edx, [ebp+12]
    cmp edx, [ebp+20]
    jb $+0x1a

    ; else if ((u32)a.h > (u32)b.h) return 1;
    mov eax, 1
    ja $+0x13

    ; if ((u32)a.l < (u32)b.l) return -1;
    xor eax, eax
    mov edx, [ebp+8]
    cmp edx, [ebp+16]
    jb $+0x9

    ; else if ((u32)a.l > (u32)b.l) return 1;
    seta al
    add eax, 1

    dec eax
    pop ebp
    ret

; Return value : a <=> b { less = -1, equal = 0, greater = 1 }
; cmp_i64(i64 a, i64 b) -> int
cmp_i64:
    push ebp
    mov ebp, esp

    ; if (a.h < b.h) return -1;
    xor eax, eax
    mov edx, [ebp+12]
    cmp edx, [ebp+20]
    jl $+0x1a

    ; else if (a.h > b.h) return 1;
    mov eax, 1
    jg $+0x13

    ; if ((u32)a.l < (u32)b.l) return -1;
    xor eax, eax
    mov edx, [ebp+8]
    cmp edx, [ebp+16]
    jb $+0x9

    ; else if ((u32)a.l > (u32)b.l) return 1;
    seta al
    add eax, 1

    dec eax
    pop ebp
    ret

; mul_64(64 a, 64 b) -> 64
mul_64:
    push ebp
    mov ebp, esp

    mov eax, [ebp+12]
    imul eax, [ebp+16]
    mov edx, eax
    mov eax, [ebp+20]
    imul eax, [ebp+8]
    lea ecx, [eax+edx]
    mov eax, [ebp+8]
    mul dword [ebp+16]
    add ecx, edx
    mov edx, ecx

    pop ebp
    ret

; div_u64(u64 a, u64 b) -> u64
div_u64:
    push ebp
    mov ebp, esp
    ; [ebp-8] = u64 _a { u32 h [-4], u32 l [-8] }
    ; [ebp-16] = u64 _b { u32 h [-12], u32 l [-16] }
    ; [ebp-24] = u64 _r { u32 h [-20], u32 l [-24] }
    ; [ebp-28] = u32 n
    sub esp, 28

    ; if (b.h == 0)
    cmp dword [ebp+20], 0
    jne $+0x47

    ; if (a.h < b)
    mov eax, [ebp+12]
    xor edx, edx
    cmp eax, [ebp+16]
    sbb edx, [ebp+20]
    jnc $+0x12

    ; return a / b.l;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    div dword [ebp+16]
    xor edx, edx
    jmp $+0x92

    ; _a = a;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    mov [ebp-8], eax
    mov [ebp-4], edx

    ; _b.h = _a.h / b.l;
    mov eax, [ebp-4]
    xor edx, edx
    div dword [ebp+16]
    mov [ebp-12], eax

    ; _b.l = ((_a.h % b.l << 32) | _a.l) / b.l
    mov eax, [ebp-8]
    div dword [ebp+16]
    mov [ebp-16], eax

    ; return _b;
    mov eax, [ebp-16]
    mov edx, [ebp-12]

    jmp $+0x67

    ; n = clz(b.h);
    bsr eax, [ebp+20]
    xor eax, 31
    mov [ebp-28], eax

    ; _b.h = (b << n) >> 32;
    mov cl, [ebp-28]
    mov eax, [ebp+16]
    mov edx, [ebp+20]
    shld edx, eax, cl
    mov [ebp-12], edx
    
    ; _r.h = (_a >> 1) / _b.h;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    shrd eax, edx, 1
    shr edx, 1
    div dword [ebp-12]
    mov [ebp-20], eax

    ; _r.l = (_r.h << n) >> 31;
    mov eax, [ebp-20]
    mov cl, 31
    sub cl, [ebp-28]
    shr eax, cl
    mov [ebp-24], eax

    ; if (_r.l != 0)
    test eax, eax
    jz $+0x6

    ; _r.l--;
    dec eax
    mov [ebp-24], eax

    ; if ((a - _r.l * b.l) >= b)
    mul dword [ebp+16]
    mov [ebp-32], eax
    mov [ebp-28], edx
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    sub eax, [ebp-32]
    sbb edx, [ebp-28]
    cmp eax, [ebp+16]
    sbb edx, [ebp+20]
    jc $+0x5

    ; _r.l++;
    inc dword [ebp-24]

    mov eax, [ebp-24]
    xor edx, edx

    leave
    ret

; Require(div_u64, mul_64);
; mod_u64(u64 a, u64 b) -> u64
mod_u64:
    push ebp
    mov ebp, esp

    ; return a - (a / b) * b;
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call div_u64
    add esp, 8
    push edx
    push eax
    call mul_64
    add esp, 16
    mov ecx, [ebp+8]
    xchg eax, ecx
    sub eax, ecx
    mov ecx, [ebp+12]
    xchg edx, ecx
    sbb edx, ecx

    pop ebp
    ret

; div_i64(i64 a, i64 b) -> i64
div_i64:
    push ebp
    mov ebp, esp
    ; [ebp-8] = u64 ua, [ebp-16] = u64 ub, [ebp-24] = i64 q, [ebp-32] = i64 t
    sub esp, 32

    ; ua = abs_i64(a), ub = abs_i64(b);
    sub esp, 8
    push dword [ebp+12]
    push dword [ebp+8]
    call abs_i64
    add esp, 8
    mov [ebp-8], eax
    mov [ebp-4], edx
    push dword [ebp+20]
    push dword [ebp+16]
    call abs_i64
    add esp, 16
    mov [ebp-16], eax
    mov [ebp-12], edx

    ; if (ub >> 31 == 0 && ua < ub << 31)
    mov eax, [ebp-16]
    mov edx, [ebp-12]
    shrd eax, edx, 31
    shr edx, 31
    or eax, edx
    jnz $+0x25

    mov eax, [ebp-16]
    mov edx, [ebp-12]
    shld edx, eax, 31
    shl eax, 31
    cmp [ebp-8], eax
    mov eax, [ebp-4]
    sbb eax, edx
    jnc $+0xe

    ; return a / b << 32 >> 32;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    idiv dword [ebp+16]
    cdq
    jmp $+0x3a

    ; q = ua / ub;
    push dword [ebp-12]
    push dword [ebp-16]
    push dword [ebp-4]
    push dword [ebp-8]
    call div_u64
    add esp, 16
    mov [ebp-24], eax
    mov [ebp-20], edx

    ; t = (a ^ b) >> 63;
    mov eax, [ebp+12]
    mov edx, [ebp+20]
    xor eax, edx
    sar eax, 31
    cdq
    mov [ebp-32], eax
    mov [ebp-28], edx

    ; return (q ^ t) - t;
    xor eax, [ebp-24]
    xor edx, [ebp-20]
    sub eax, [ebp-32]
    sbb edx, [ebp-28]

    leave
    ret

; Require(div_i64, mul_64);
; mod_i64(i64 a, i64 b) -> i64
mod_i64:
    push ebp
    mov ebp, esp

    ; return a - (a / b) * b;
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call div_i64
    add esp, 8
    push edx
    push eax
    call mul_64
    add esp, 16
    mov ecx, [ebp+8]
    xchg eax, ecx
    sub eax, ecx
    mov ecx, [ebp+12]
    xchg edx, ecx
    sbb edx, ecx

    pop ebp
    ret

; abs_i64(i64 x) -> u64
abs_i64:
    push ebp
    mov ebp, esp
    ; [ebp-8] = u64 t
    sub esp, 8

    ; t = x >> 63;
    mov eax, [ebp+12]
    sar eax, 31
    cdq
    mov [ebp-8], eax
    mov [ebp-4], edx

    ; return (x ^ t) - t;
    mov eax, [ebp+8]
    mov edx, [ebp+12]
    xor eax, [ebp-8]
    xor edx, [ebp-4]
    sub eax, [ebp-8]
    sbb edx, [ebp-4]

    leave
    ret