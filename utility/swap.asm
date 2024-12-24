extern memcpy

; swap(void* a, void* b, int size)
swap:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; void* tmp(size);
    sub esp, 4
    mov eax, [ecx+8]
    add eax, 15
    and eax, -16
    sub esp, eax

    ; *tmp = *a;
    lea edx, [esp]
    sub esp, 4
    push dword [ecx+8]
    push dword [ecx]
    push edx
    call memcpy
    add esp, 8

    ; *a = *b;
    mov ecx, [ebp-4]
    push dword [ecx+4]
    push dword [ecx]
    call memcpy
    add esp, 8

    ; *b = *tmp;
    lea edx, [esp+8]
    push edx
    mov ecx, [ebp-4]
    push dword [ecx+4]
    call memcpy
    add esp, 16

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret