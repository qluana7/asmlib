; strrev(char* arr, int n)
strrev:
    push ebp
    mov ebp, esp

    ; ecx = n / 2;
    mov ecx, [ebp+12]
    shr ecx, 1

    ; if (ecx == 0) return;
    test ecx, ecx
    jz $+0x18

    ; for (char *s = arr, *e = arr + n - 1; ecx --> 0; )
    mov eax, [ebp+8]
    add eax, [ebp+12]
    dec eax
    mov edx, [ebp+8]

    push ecx

    ; xchg(*s, *e);
    mov cl, [edx]
    xchg cl, [eax]
    mov [edx], cl

    ; s++, e--;
    dec eax
    inc edx
    pop ecx
    loop $-0xa

    pop ebp
    ret

; // Remove characters from string with condition.
; // - If __pred(c) is true, remove character.
; strrm(char* __str, bool (*__pred)(char))
strrm:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = int i, [ebp-16] = int j
    ; [ebp-20] = char* str, [ebp-24] = bool (*pred)(char)
    sub esp, 4+4*4

    ; str = __str, pred = __pred;
    mov eax, [ecx]
    mov edx, [ecx+4]
    mov [ebp-20], eax
    mov [ebp-24], edx

    ; for (int i = 0, j = 0; arr[i] != '\0'; i++)
    mov dword [ebp-12], 0
    mov dword [ebp-16], 0
    jmp $+0x31

    ; if (pred(str[i])) continue;
    sub esp, 12
    mov edx, [ebp-20]
    mov ecx, [ebp-12]
    mov al, [edx+ecx]
    movzx eax, al
    push eax
    call dword [ebp-24]
    add esp, 16
    test eax, eax
    jnz $+0x14

    ; str[j] = str[i];
    mov edx, [ebp-20]
    mov ecx, [ebp-12]
    mov al, [edx+ecx]
    mov ecx, [ebp-16]
    mov [edx+ecx], al

    ; j++;
    inc dword [ebp-16]

    inc dword [ebp-12]

    mov edx, [ebp-20]
    mov ecx, [ebp-12]
    cmp byte [edx+ecx], 0
    jne $-0x39

    ; arr[j] = 0;
    mov edx, [ebp-20]
    mov ecx, [ebp-16]
    mov byte [edx+ecx], 0

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; tolower(char* str);
tolower:
    push ebp
    mov ebp, esp
    ; [ebp-4] = char* c
    sub esp, 4

    ; for (char* c = str; *str != 0; str++)
    mov eax, [ebp+8]
    mov [ebp-4], eax
    jmp $+0x16

    ; if (*c < 'A' || 'Z' < *c) continue;
    mov edx, [ebp-4]
    mov al, [edx]
    cmp al, 'A'
    jl $+0xa
    cmp al, 'Z'
    jg $+0x6

    ; *c += 32;
    add al, 32
    mov [edx], al

    inc dword [ebp-4]

    mov eax, [ebp-4]
    cmp byte [eax], 0
    jne $-0x1a

    leave
    ret

; toupper(char* str);
toupper:
    push ebp
    mov ebp, esp
    ; [ebp-4] = char* c
    sub esp, 4

    ; for (char* c = str; *str != 0; str++)
    mov eax, [ebp+8]
    mov [ebp-4], eax
    jmp $+0x16

    ; if (*c < 'a' || 'z' < *c) continue;
    mov edx, [ebp-4]
    mov al, [edx]
    cmp al, 'a'
    jl $+0xa
    cmp al, 'z'
    jg $+0x6

    ; *c += 32;
    sub al, 32
    mov [edx], al

    inc dword [ebp-4]

    mov eax, [ebp-4]
    cmp byte [eax], 0
    jne $-0x1a

    leave
    ret