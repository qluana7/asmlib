; head(int* arr, int idx) -> int
head:
    push ebp
    mov ebp, esp

    ; if (arr[idx] == idx) return idx;
    mov edx, [ebp+8]
    mov ecx, [ebp+12]
    mov eax, [ebp+12]
    cmp [edx+ecx*4], eax
    je $+0x1c

    ; return arr[idx] = head(arr, arr[idx]);
    sub esp, 8
    push dword [edx+ecx*4]
    push dword [ebp+8]
    call head
    add esp, 16
    mov edx, [ebp+8]
    mov ecx, [ebp+12]
    mov [edx+ecx*4], eax

    leave
    ret