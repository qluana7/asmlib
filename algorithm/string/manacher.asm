extern aligned_alloc
extern memset
extern free

; ret capacity can be calculate as `ret_size + 3 & -4`
; manacher_i(int* arr, int size) -> eax(int* ret):edx(int ret_size)
manacher_i:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-40]
    ; [ebp-12] = int* arr, [ebp-16] = int r, [ebp-20] = int t, [ebp-24] = int n
    ; [ebp-28] = int i, [ebp-32] = int* ret, [ebp-36] = int ret_size
    sub esp, 4+4*8

    ; n = size * 2 + 1;
    mov eax, [ecx+4]
    add eax, eax
    inc eax
    mov [ebp-24], eax

    ; arr = aligned_alloc(16, sizeof(int) * (n + 3 & -4));
    sub esp, 8
    add eax, 3
    and eax, -4
    shl eax, 2
    push eax
    push dword 16
    call aligned_alloc
    add esp, 16
    mov [ebp-12], eax

    ; memset(arr, -1, sizeof(int) * n);
    sub esp, 4
    mov eax, [ebp-24]
    shl eax, 2
    push eax
    push dword -1
    push dword [ebp-12]
    call memset
    add esp, 16

    ; r = [para] size;
    mov ecx, [ebp-4]
    mov eax, [ecx+4]
    mov [ebp-16], eax

    ; t = [para] arr;
    mov edx, [ecx]
    mov [ebp-20], edx

    ; for (int i = 0; i < r; i++)
    mov dword [ebp-28], 0
    jmp $+0x17

    ; arr[i * 2 + 1] = t[i];
    mov edx, [ebp-20]
    mov ecx, [ebp-28]
    mov eax, [edx+ecx*4]
    mov edx, [ebp-12]
    add ecx, ecx
    inc ecx
    mov [edx+ecx*4], eax

    inc dword [ebp-28]

    mov eax, [ebp-28]
    cmp eax, [ebp-16]
    jl $-0x1b

    ; r = t = 0;
    mov dword [ebp-16], 0
    mov dword [ebp-20], 0

    ; ret_size = n;
    mov eax, [ebp-24]
    mov [ebp-36], eax

    ; ret = aligned_alloc(16, sizeof(int) * (ret_size + 3 & -4));
    sub esp, 8
    add eax, 3
    and eax, -4
    shl eax, 2
    push eax
    push dword 16
    call aligned_alloc
    add esp, 16
    mov [ebp-32], eax

    ; for (int i = 0; i < n; i++)
    mov dword [ebp-28], 0
    jmp $+0x85

    ; ret[i] = i <= r ? min(ret[(t << 1) - i], r - i) : 0;
    ; // eax = min(ret[(t << 1) - i], r - i);
    mov edx, [ebp-32]
    mov ecx, [ebp-20]
    add ecx, ecx
    sub ecx, [ebp-28]
    mov eax, [edx+ecx*4]
    mov edx, [ebp-16]
    sub edx, [ebp-28]
    cmp eax, edx
    cmovg eax, edx

    ; // ret[i] = i <= r ? eax : 0;
    mov ecx, 0
    mov edx, [ebp-28]
    cmp edx, [ebp-16]
    cmovg eax, ecx
    mov edx, [ebp-32]
    mov ecx, [ebp-28]
    mov [edx+ecx*4], eax

    ; while (
    ;     i - ret[i] - 1 >= 0 &&
    ;     i + ret[i] + 1 < n &&
    ;     s[i - ret[i] - 1] == s[i + ret[i] + 1]
    ; ) ret[i]++;
    jmp $+0xb

    ; // ret[i]++;
    mov edx, [ebp-32]
    mov ecx, [ebp-28]
    inc dword [edx+ecx*4]

    ; // i - ret[i] - 1 >= 0
    mov eax, [ebp-28]
    mov edx, [ebp-32]
    sub eax, [edx+eax*4]
    dec eax
    jl $+0x21
    mov [ebp-40], eax

    ; // i + ret[i] + 1 < n
    mov eax, [ebp-28]
    add eax, [edx+eax*4]
    inc eax
    cmp eax, [ebp-24]
    jge $+0x12

    ; s[i - ret[i] - 1] == s[i + ret[i] + 1]
    mov edx, [ebp-12]
    mov ecx, eax
    mov eax, [edx+ecx*4]
    mov ecx,[ebp-40]
    cmp eax, [edx+ecx*4]
    je $-0x32

    ; if (i + ret[i] > r)
    mov eax, [ebp-28]
    mov edx, [ebp-32]
    add eax, [edx+eax*4]
    cmp eax, [ebp-16]
    jle $+0xb

    ; r = i + ret[i]
    mov [ebp-16], eax
    
    ; t = i;
    mov eax, [ebp-28]
    mov [ebp-20], eax

    inc dword [ebp-28]

    mov eax, [ebp-28]
    cmp eax, [ebp-24]
    jl $-0x86

    ; free(arr);
    sub esp, 12
    push dword [ebp-12]
    call free
    add esp, 16

    ; return ret;
    mov eax, [ebp-32]
    mov edx, [ebp-36]

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret