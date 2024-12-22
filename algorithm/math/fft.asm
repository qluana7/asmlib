; Warning : This function has problem when calling realloc and free in some environment.

global FFT
global convolution

extern malloc
extern free
extern realloc

extern __muldi3
extern __divdi3
extern __moddi3
extern __cmpdi2

; swapll(long long* a, long long* b)
swapll:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]
    mov edx, [ebp+12]

    mov ecx, [eax]
    xchg ecx, [edx]
    mov [eax], ecx

    mov ecx, [eax+4]
    xchg ecx, [edx+4]
    mov [edx+4], ecx

    pop ebp
    ret

; npow(long long a, long long b, long long mod_p) -> long long (edx:eax)
npow:
    push ebp
    mov ebp, esp
    ; [ebp-8] = long long a, [ebp-16] = long long b, [ebp-24] = long long r;
    sub esp, 24
    
    mov edx, [ebp+12]
    mov eax, [ebp+8]
    mov [ebp-4], edx
    mov [ebp-8], eax
    mov edx, [ebp+20]
    mov eax, [ebp+16]
    mov [ebp-12], edx
    mov [ebp-16], eax
    mov dword [ebp-20], 0
    mov dword [ebp-24], 1

; while (b)
    mov eax, [ebp-16]
    or eax, [ebp-12]
    jz npow+0x9d

    ; if(b & 1) r = (r * a) % mod_p;
    mov eax, [ebp-16]
    and eax, 1
    jz $+0x2c

    push dword [ebp+28]
    push dword [ebp+24]
    push dword [ebp-4]
    push dword [ebp-8]
    push dword [ebp-20]
    push dword [ebp-24]
    call __muldi3
    add esp, 16
    push edx
    push eax
    call __moddi3
    add esp, 16

    mov [ebp-20], edx
    mov [ebp-24], eax

    ; a = (a * a) % mod_p;
    push dword [ebp+28]
    push dword [ebp+24]
    push dword [ebp-4]
    push dword [ebp-8]
    push dword [ebp-4]
    push dword [ebp-8]
    call __muldi3
    add esp, 16
    push edx
    push eax
    call __moddi3
    add esp, 16
    
    mov [ebp-4], edx
    mov [ebp-8], eax

    ; b = b >> 1;
    mov edx ,[ebp-12]
    
    shrd [ebp-16], edx, 1

    mov [ebp-12], edx

    jmp npow+0x2c

    mov edx, [ebp-20]
    mov eax, [ebp-24]
    leave
    ret

; NTT Implementation
; FFT(long long* arr, int n, bool(4) inv, long long _w, long long mod_p)
FFT:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int i, [ebp-8] = int j, [ebp-12] = int b, [ebp-16] = int k
    ; [ebp-20] = int k_len, [ebp-24] = long long* root
    ; [ebp-32] = long long x, [ebp-40] = long long c
    ; [ebp-48] = long long a, [ebp-56] = long long b
    ; [ebp-64] = long long t
    sub esp, 64

    ; for (i = 1, j = 0; i < n; i++)
    mov dword [ebp-4], 1
    mov dword [ebp-8], 0

    mov eax, [ebp-4]
    cmp eax, [ebp+12]
    jge $+0x4b

    ; int b = n >> 1;
    mov eax, [ebp+12]
    shr eax, 1
    mov [ebp-12], eax

    ; while ( ! ( (j ^= b) & b) ) b >>= 1;
    mov eax, [ebp-12]
    xor [ebp-8], eax
    mov edx, [ebp-8]
    and edx, eax
    test edx, edx
    jnz $+0x7

    shr dword [ebp-12], 1

    jmp $-0x12

    ; if (i < j) swap(v[i], v[j]);
    mov eax, [ebp-4]
    cmp eax, [ebp-8]
    jge $+0x22

    mov eax, [ebp+8]
    mov edx, [ebp-8]
    shl edx, 3
    add eax, edx
    push eax
    mov eax, [ebp+8]
    mov edx, [ebp-4]
    shl edx, 3
    add eax, edx
    push eax
    call swapll
    add esp, 8

    inc dword [ebp-4]
    jmp $-0x4f

    ; x = npow(_w, (mod_p - 1) / n, mod_p);
    push dword [ebp+32]
    push dword [ebp+28]
    push dword 0
    push dword [ebp+12]
    mov edx, [ebp+32]
    mov eax, [ebp+28]
    add eax, -1
    adc edx, -1
    push edx
    push eax
    call __divdi3
    add esp, 16
    push edx
    push eax
    push dword [ebp+24]
    push dword [ebp+20]
    call npow
    add esp, 24

    mov [ebp-32], eax
    mov [ebp-28], edx

    ; if (inv)
    cmp dword [ebp+16], 0
    je $+0x2a

    ; x = npow(x, mod_p - 2, mod_p);
    push dword [ebp+32]
    push dword [ebp+28]
    mov edx, [ebp+32]
    mov eax, [ebp+28]
    add eax, -2
    adc edx, -1
    push edx
    push eax
    push dword [ebp-28]
    push dword [ebp-32]
    call npow
    add esp, 24

    mov [ebp-32], eax
    mov [ebp-28], edx

    ; root = malloc((n >> 1) * sizeof(long long));
    mov eax, [ebp+12]
    shl eax, 2
    push eax
    call malloc
    add esp, 4
    mov [ebp-24], eax

    ; root[0] = 1;
    mov dword [eax], 1
    mov dword [eax+4], 0

    ; for (i = 1; i < (n >> 1); i++)
    mov dword [ebp-4], 1

    mov eax, [ebp+12]
    shr eax, 1
    cmp [ebp-4], eax
    jge $+0x48

    ; root[i] = (root[i - 1] * x) % mod_p;
    push dword [ebp+32]
    push dword [ebp+28]
    push dword [ebp-28]
    push dword [ebp-32]
    mov eax, [ebp-24]
    mov edx, [ebp-4]
    dec edx
    shl edx, 3
    add eax, edx
    push dword [eax+4]
    push dword [eax]
    call __muldi3
    add esp, 16
    push edx
    push eax
    call __moddi3
    add esp, 16
    push edx
    mov ecx, [ebp-24]
    mov edx, [ebp-4]
    shl edx, 3
    add ecx, edx
    pop edx
    mov [ecx+4], edx
    mov [ecx], eax

    inc dword [ebp-4]
    jmp $-0x4e

    ; for (i = 2; i <= n; i <<= 1)
    mov dword [ebp-4], 2

    mov eax, [ebp-4]
    cmp eax, [ebp+12]
    jg $+0x150

    ; c = n / i;
    mov eax, [ebp+12]
    mov edx, 0
    div dword [ebp-4]
    mov dword [ebp-36], 0
    mov [ebp-40], eax

    ; for (j = 0; j < n; j += i)
    mov dword [ebp-8], 0

    mov eax, [ebp-8]
    cmp eax, [ebp+12]
    jge $+0x120

    ; for (k = 0, k_len = i >> 1; k < k_len; k++)
    mov dword [ebp-16], 0
    mov eax, [ebp-4]
    shr eax, 1
    mov [ebp-20], eax

    mov eax, [ebp-16]
    cmp eax, [ebp-20]
    jge $+0xfa

    ; a = v[j | k], b = (v[j | k | k_len] * root[c * k]) % mod_p;
    mov eax, [ebp-8]
    or eax, [ebp-16]
    shl eax, 3
    mov edx, [ebp+8]
    add edx, eax
    mov eax, [edx]
    mov edx, [edx+4]
    mov [ebp-44], edx
    mov [ebp-48], eax

    push dword [ebp+32]
    push dword [ebp+28]
    mov eax, [ebp-40]
    mov edx, 0
    mul dword [ebp-16]
    shl eax, 3
    mov edx, [ebp-24]
    add edx, eax
    push dword [edx+4]
    push dword [edx]
    mov eax, [ebp-8]
    or eax, [ebp-16]
    or eax, [ebp-20]
    shl eax, 3
    mov edx, [ebp+8]
    add edx, eax
    push dword [edx+4]
    push dword [edx]
    call __muldi3
    add esp, 16
    push edx
    push eax
    call __moddi3
    add esp, 16
    mov [ebp-52], edx
    mov [ebp-56], eax

    ; v[j | k] = (a + b) % mod_p;

    push dword [ebp+32]
    push dword [ebp+28]
    mov eax, [ebp-48]
    mov edx, [ebp-44]
    add eax, [ebp-56]
    adc edx, [ebp-52]
    push edx
    push eax
    call __moddi3
    add esp, 16
    push edx
    push eax
    mov eax, [ebp-8]
    or eax, [ebp-16]
    shl eax, 3
    mov edx, [ebp+8]
    add edx, eax
    pop dword [edx]
    pop dword [edx+4]

    ; v[j | k | k_len] = (a - b) % mod_p;
    push dword [ebp+32]
    push dword [ebp+28]
    mov eax, [ebp-48]
    mov edx, [ebp-44]
    sub eax, [ebp-56]
    sbb edx, [ebp-52]
    push edx
    push eax
    call __moddi3
    add esp, 16
    push edx
    push eax
    mov eax, [ebp-8]
    or eax, [ebp-16]
    or eax, [ebp-20]
    shl eax, 3
    mov edx, [ebp+8]
    add edx, eax
    pop dword [edx]
    pop dword [edx+4]

    ; if (v[j | k | k_len] < 0) v[j | k | k_len] += mod_p;
    push edx
    push dword 0
    push dword 0
    push dword [edx+4]
    push dword [edx]
    call __cmpdi2
    add esp, 16
    pop ecx
    test eax, eax
    jnz $+0xd

    mov eax, [ebp+28]
    mov edx, [ebp+32]
    add [ecx], eax
    adc [ecx+4], edx

    inc dword [ebp-16]
    jmp $-0xfb

    mov eax, [ebp-4]
    add [ebp-8], eax
    jmp $-0x121

    shl dword [ebp-4], 1
    jmp $-0x151

    ; if (inv)
    cmp dword [ebp+16], 0
    je $+0x7d

    ; t = npow(n, mod_p - 2, mod_p);
    push dword [ebp+32]
    push dword [ebp+28]
    mov eax, [ebp+28]
    mov edx, [ebp+32]
    add eax, -2
    adc edx, -1
    push edx
    push eax
    push dword 0
    push dword [ebp+12]
    call npow
    add esp, 24

    mov [ebp-60], edx
    mov [ebp-64], eax

    ; for (i = 0; i < n; i++)
    mov dword [ebp-4], 0

    mov eax, [ebp-4]
    cmp eax, [ebp+12]
    jge $+0x47

    ; v[i] = (v[i] * t) % mod_p;
    push dword [ebp+32]
    push dword [ebp+28]
    push dword [ebp-60]
    push dword [ebp-64]
    mov eax, [ebp+8]
    mov edx, [ebp-4]
    shl edx, 3
    add eax, edx
    push dword [eax+4]
    push dword [eax]
    call __muldi3
    add esp, 16
    push edx
    push eax
    call __moddi3
    add esp, 16
    push edx
    push eax
    mov eax, [ebp+8]
    mov edx, [ebp-4]
    shl edx, 3
    add eax, edx
    pop dword [eax]
    pop dword [eax+4]

    inc dword [ebp-4]
    jmp $-0x4b

    push dword [ebp-24]
    call free
    add esp, 4

    leave
    ret

; After call function, copy all parameter to original variable.
; ex) long long* arr; convolution(arr, ...); arr = (parameter)arr;
; convolution(long long* arr1, int& n, long long* arr2, int& m, long long _w, long long mod_p)
convolution:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int s, [ebp-8], int i
    sub esp, 8

    ; s = 2;
    mov dword [ebp-4], 2

    ; while (s < n + m) s <<= 1;
    mov eax, [ebp+12]
    add eax, [ebp+20]

    cmp [ebp-4], eax
    jge $+0x7

    shl dword [ebp-4], 1

    jmp $-0x8

    ; arr1 = realloc(arr1, s * sizeof(long long));
    mov eax, [ebp-4]
    shl eax, 3
    push eax
    push dword [ebp+8]
    call realloc
    add esp, 8
    mov [ebp+8], eax
    mov eax, [ebp-4]
    mov [ebp+12], eax

    ; FFT(arr1, n, false, _w, mod_p);
    push dword [ebp+36]
    push dword [ebp+32]
    push dword [ebp+28]
    push dword [ebp+24]
    push dword 0
    push dword [ebp+12]
    push dword [ebp+8]
    call FFT
    add esp, 28

    ; arr2 = realloc(arr2, s * sizeof(long long));
    mov eax, [ebp-4]
    shl eax, 3
    push eax
    push dword [ebp+16]
    call realloc
    add esp, 8
    mov [ebp+16], eax
    mov eax, [ebp-4]
    mov [ebp+20], eax

    ; FFT(arr2, m, false, _w, mod_p);
    push dword [ebp+36]
    push dword [ebp+32]
    push dword [ebp+28]
    push dword [ebp+24]
    push dword 0
    push dword [ebp+20]
    push dword [ebp+16]
    call FFT
    add esp, 28

    ; for (i = 0; i < s; i++)
    mov dword [ebp-8], 0

    mov eax, [ebp-8]
    cmp eax, [ebp-4]
    jge $+0x4b

    ; arr1[i] = (arr1[i] * arr2[i]) % mod_p;
    push dword [ebp+36]
    push dword [ebp+32]
    mov edx, [ebp-8]
    shl edx, 3
    mov eax, [ebp+16]
    add eax, edx
    push dword [eax+4]
    push dword [eax]
    mov eax, [ebp+8]
    add eax, edx
    push dword [eax+4]
    push dword [eax]
    call __muldi3
    add esp, 16
    push edx
    push eax
    call __moddi3
    add esp, 16
    push edx
    push eax
    mov eax, [ebp+8]
    mov edx, [ebp-8]
    shl edx, 3
    add eax, edx
    pop dword [eax]
    pop dword [eax+4]

    inc dword [ebp-8]
    jmp $-0x4f

    ; FFT(arr1, n, true, _w, mod_p);
    push dword [ebp+36]
    push dword [ebp+32]
    push dword [ebp+28]
    push dword [ebp+24]
    push dword 1
    push dword [ebp+12]
    push dword [ebp+8]
    call FFT
    add esp, 28

    leave
    ret
