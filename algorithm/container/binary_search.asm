; binary_search(const int* arr, int size, int t) -> int
binary_search:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = int* arr, [ebp-16] = int l, [ebp-20] = int m, [ebp-24] = int r
    sub esp, 4+4*4

    ; arr = [para] arr;
    mov edx, [ebp-4]
    mov eax, [edx]
    mov [ebp-12], eax

    ; l = 0
    mov dword [ebp-16], 0
    
    ; r = [para] size
    mov eax, [edx+4]
    mov [ebp-24], eax

    ; while (l < r)
    jmp $+0x2d

    ; m = l + r >> 1;
    mov eax, [ebp-16]
    add eax, [ebp-24]
    shr eax, 1
    mov [ebp-20], eax

    ; if (arr[m] < [para] t)
    mov edx, [ebp-12]
    mov ecx, [ebp-20]
    mov eax, [edx+ecx*4]
    mov edx, [ebp-4]
    cmp eax, [edx+8]
    jge $+0xb

    ; l = m + 1;
    mov eax, [ebp-20]
    inc eax
    mov [ebp-16], eax

    jmp $+0x8

    ; else r = m;
    mov eax, [ebp-20]
    mov [ebp-24], eax

    mov eax, [ebp-16]
    cmp eax, [ebp-24]
    jl $-0x31

    ; return r;
    mov eax, [ebp-24]
    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret