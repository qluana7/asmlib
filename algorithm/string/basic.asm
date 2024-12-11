global strrev

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