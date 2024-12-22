; Introsort Implementation

global sort

extern memcpy

; swap(void* a, void* b, int size)
swap:
    push ebp
    mov ebp, esp
    ; void* tmp(size);
    sub esp, [ebp+16]

    ; *tmp = *a;
    push dword [ebp+16]
    push dword [ebp+8]
    lea edx, [esp+8]
    push edx
    call memcpy
    add esp, 8

    ; *a = *b;
    push dword [ebp+12]
    push dword [ebp+8]
    call memcpy
    add esp, 8

    ; *b = *tmp;
    lea edx, [esp+4]
    push edx
    push dword [ebp+12]
    call memcpy
    add esp, 12

    leave
    ret

; mk_heap(void* arr, int element_size, int left, int right, cmp_func)
mk_heap:
    push ebp
    mov ebp, esp
    ; [ebp-4] = now, [ebp-8] = par
    sub esp, 8

    ; for (int i = left; i <= right; i++)
    mov ecx, [ebp+16]

    cmp ecx, [ebp+20]
    jg mk_heap+0x66

    push ecx
    ; now = i;
    mov [ebp-4], ecx

    ; while (now > 0)
    cmp dword [ebp-4], 0
    jle mk_heap+0x62

    ; par = (now - 1) >> 1;
    mov eax, [ebp-4]
    dec eax
    shr eax, 1
    mov [ebp-8], eax

    ; if (cmp_func(&arr[par], &arr[now], element_size) < 0)
    push dword [ebp+12]
    mov eax, [ebp-4]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx

    mov eax, [ebp-8]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    call dword [ebp+24]
    
    cmp eax, 0
    jge mk_heap+0x57

    ; swap(&arr[par], &arr[now], element_size)
    call swap

    add esp, 12

    ; now = par;
    mov eax, [ebp-8]
    mov [ebp-4], eax

    jmp mk_heap+0x12

    pop ecx
    inc ecx
    jmp mk_heap+0x9

    leave
    ret

; sort_h(void* arr, int element_size, int left, int right, cmp_func)
sort_h:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int l, [ebp-8] = int r
    ; [ebp-12] = int sel, [ebp-16] = int par
    ; [ebp-20] = int i
    sub esp, 20

    ; mk_heap(arr, element_size, left, right, cmp_func);
    push dword [ebp+24]
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call mk_heap
    add esp, 20

    ; for (i = right; i > left; i--)
    mov eax, [ebp+20]
    mov [ebp-20], eax

    mov eax, [ebp-20]
    cmp eax, [ebp+16]
    jle sort_h+0x122

    ; swap(arr, arr + i, element_size)
    push dword [ebp+12]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    push dword [ebp+8]
    call swap
    add esp, 12

    ; left = 1, right = 2, sel = 0, par = 0;
    mov dword [ebp-4], 1
    mov dword [ebp-8], 2
    mov dword [ebp-12], 0
    mov dword [ebp-16], 0

    ; while(1)
    ; if (left >= i) break;
    mov eax, [ebp-4]
    cmp eax, [ebp-20]
    jge sort_h+0x11a

    ; if (right >= i)
    mov eax, [ebp-8]
    cmp eax, [ebp-20]
    jge sort_h+0xbd

    ; else

    ; if (cmp_func(&arr[left], &arr[right], element_size) < 0) sel = right;
    ; else sel = left;
    push dword [ebp+12]
    mov eax, [ebp-8]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx

    mov eax, [ebp-4]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    call dword [ebp+24]
    add esp, 12

    cmp eax, 0
    mov eax, [ebp-8]
    mov edx, [ebp-4]
    cmovge eax, edx
    
    mov [ebp-12], eax

    jmp sort_h+0xc3

    ; sel = left;
    mov eax, [ebp-4]
    mov [ebp-12], eax

    ; if (cmp_func(&arr[sel], &arr[par], element_size) > 0)
    push dword [ebp+12]
    mov eax, [ebp-16]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx

    mov eax, [ebp-12]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    call dword [ebp+24]
    add esp, 12

    cmp eax, 0
    ; else break;
    jle sort_h+0x11a

    ; fix if has issue
    sub esp, 12
    ; swap(&arr[sel], &arr[par], element_size);
    call swap
    add esp, 12

    ; par = sel;
    mov eax, [ebp-12]
    mov [ebp-16], eax

    ; left = (par << 1) + 1;
    mov eax, [ebp-16]
    shl eax, 1
    inc eax
    mov [ebp-4], eax

    ; right = left + 1;
    inc eax
    mov [ebp-8], eax

    jmp sort_h+0x69

    dec dword [ebp-20]
    jmp sort_h+0x23

    leave
    ret

; sort_i(void* arr, int element_size, int left, int right, cmp_func)
sort_i:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int i, [ebp-8] int j, [ebp-element_size] = void* key;
    sub esp, 8
    sub esp, dword [ebp+12]

    ; for (i = left; i < right; i++)
    mov eax, [ebp+16]
    mov [ebp-4], eax

    mov eax, [ebp-4]
    cmp eax, [ebp+20]
    jge sort_i+0xc3

    ; key = arr[i + 1];
    push dword [ebp+12]
    inc eax
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    lea eax, [esp+8]
    push eax
    call memcpy
    add esp, 12

    ; for (j = i; j >= left; j--)
    mov eax, [ebp-4]
    mov [ebp-8], eax

    mov eax, [ebp-8]
    cmp eax, [ebp+16]
    jl sort_i+0x97

    ; if (cmp_func(arr[j], key, element_size) > 0) arr[j + 1] = arr[j];
    ; else break;
    push dword [ebp+12]
    lea eax, [esp+4]
    push eax
    mov eax, [ebp-8]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    call dword [ebp+24]
    add esp, 12

    cmp eax, 0
    jle sort_i+0x97

    ; fix if has issue
    push dword [ebp+12]
    mov eax, [ebp-8]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    add edx, [ebp+12]
    push edx
    call memcpy
    add esp, 12

    dec dword [ebp-8]
    jmp sort_i+0x42

    ; arr[j + 1] = key;
    push dword [ebp+12]
    lea eax, [esp+4]
    push eax
    mov eax, [ebp-8]
    inc eax
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    call memcpy
    add esp, 12

    inc dword [ebp-4]
    jmp sort_i+0xf

    leave
    ret

; sort_q(void* arr, int element_size, int left, int right, int depth, cmp_func)
sort_q:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int i, [ebp-8] int j, [ebp-element_size] = void* pivot;
    sub esp, 8
    sub esp, dword [ebp+12]

    ; if (depth == 0) -> jmp sort_q+0x133
    cmp dword [ebp+24], 0
    jz sort_q+0x133

    ; i = left, j = right;
    mov eax, [ebp+16]
    mov [ebp-4], eax
    mov eax, [ebp+20]
    mov [ebp-8], eax

    ; pivot = arr[(left + right) >> 1];
    push dword [ebp+12]
    mov eax, [ebp+16]
    add eax, [ebp+20]
    shr eax, 1
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    lea eax, [esp+8]
    push eax
    call memcpy
    add esp, 12

    ; do
    mov eax, esp
    push dword [ebp+12]
    push eax

    ; while (cmp_func(arr[i], pivot, element_size) < 0) i++;
    mov eax, [ebp-4]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    
    call dword [ebp+28]
    cmp eax, 0
    jge sort_q+0x73

    inc dword [ebp-4]
    mov eax, [ebp+12]
    add [esp], eax

    jmp sort_q+0x60

    add esp, 4

    ; while (cmp_func(arr[j], pivot, element_size) > 0) j--;
    mov eax, [ebp-8]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx

    call dword [ebp+28]
    cmp eax, 0
    jle sort_q+0x9c

    dec dword [ebp-8]
    mov eax, [ebp+12]
    sub [esp], eax

    jmp sort_q+0x89

    add esp, 12

    ; if (i <= j)
    mov eax, [ebp-4]
    cmp eax, [ebp-8]
    jg sort_q+0xde

    ; swap(&arr[i], &arr[j], element_size);
    push dword [ebp+12]
    mov eax, [ebp-8]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx

    mov eax, [ebp-4]
    mov edx, 0
    mov ecx, [ebp+12]
    mul ecx
    mov edx, [ebp+8]
    add edx, eax
    push edx
    call swap
    add esp, 12

    ; i++, j--;
    inc dword [ebp-4]
    dec dword [ebp-8]

    ; while(i <= j);
    mov eax, [ebp-4]
    cmp eax, [ebp-8]
    jle sort_q+0x47

    ; if (left < j)
    mov eax, [ebp+16]
    cmp eax, [ebp-8]
    jge sort_q+0x10f

    ; sort_q(arr, element_size, left, j, depth - 1, cmp_func);
    push dword [ebp+28]
    push dword [ebp+24]
    dec dword [esp]
    push dword [ebp-8]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call sort_q
    add esp, 24

    ; if (i < right)
    mov eax, [ebp-4]
    cmp eax, [ebp+20]
    jge sort_q+0x131

    ; sort_q(arr, element_size, i, right, depth - 1, cmp_func);
    push dword [ebp+28]
    push dword [ebp+24]
    dec dword [esp]
    push dword [ebp+20]
    push dword [ebp-4]
    push dword [ebp+12]
    push dword [ebp+8]
    call sort_q

    leave
    ret

    ; if ((right - left + 1) > 16)
    mov eax, [ebp+20]
    sub eax, [ebp+16]
    inc eax
    cmp eax, 16
    jle sort_q+0x156

    ; sort_h(arr, element_size, left, right, cmp_func);
    push dword [ebp+28]
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call sort_h
    add esp, 20
    
    ; return
    leave
    ret

; sort(void* arr, int size, int element_size, cmp_func)
sort:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int limit
    sub esp, 4

    ; limit = 2 * ceil(log2(size));
    finit

    fld1
    fild dword [ebp+12]
    fyl2x
    fst dword [ebp-4]

    movss xmm0, dword [ebp-4]
    roundss xmm1, xmm0, 0xa
    cvttss2si eax, xmm1

    shl eax, 1
    mov [ebp-4], eax

    ; if (size <= 16)
    cmp dword [ebp+12], 16
    jle sort+0x49

    ; sort_q(arr, element_size, 0, size - 1, limit, cmp_func)
    push dword [ebp+20]
    push dword [ebp-4]
    push dword [ebp+12]
    dec dword [esp]
    push dword 0
    push dword [ebp+16]
    push dword [ebp+8]
    call sort_q
    add esp, 24

    ; sort_i(arr, element_size, 0, size - 1, cmp_func)
    push dword [ebp+20]
    push dword [ebp+12]
    dec dword [esp]
    push dword 0
    push dword [ebp+16]
    push dword [ebp+8]
    call sort_i
    add esp, 20

    leave
    ret

; Example of cmp_func
; Similar to the compare function used by qsort.
; a <  b -> -1
; a == b ->  0
; a >  b ->  1
; 'element_size' may be unnecessary depending on the implementation.
; cmp_func(const void* a, const void* b, int element_size) -> int
cmp_func:
    push ebp
    mov ebp, esp

    ; eax = *(const int*)a, edx = *(const int*)b;
    mov eax, [ebp+8]
    mov eax, [eax]
    mov edx, [ebp+12]
    mov edx, [edx]

    ; return (eax > edx) - (eax < edx)
    cmp eax, edx
    setg al
    setl ah

    sub al, ah
    movsx eax, al

    pop ebp
    ret
