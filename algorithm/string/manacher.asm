; min(a, b)
min:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovg eax, [ebp+12]

    pop ebp
    ret

; manacher(int*, int, char*)
manacher:
    push ebp
    mov ebp, esp
    ; [ebp-4] = char* s, [ebp-8] = int r, [ebp-12] = int t
    sub esp, 12

    ; s = malloc(n * sizeof(char))
    push dword [ebp+12]
    call malloc
    add esp, 4
    mov [ebp-4], eax

    ; fill(s, n, '#');
    mov ecx, [ebp+12]
    mov edi, eax
    mov al, '#'
    rep stosb

    ; esi = s + 1; edi = para[char*];
    mov esi, [ebp-4]
    inc esi
    mov edi, [ebp+16]

    ; while (n --> 0)
    mov ecx, [ebp+12]
    dec ecx
    shr ecx, 1

manacher_while1:
    ; *esi = *edi; esi += 2; edi++;
    mov al, [edi]
    mov [esi], al

    add esi, 2
    inc edi

    loop manacher_while1

    ; r = 0, t = 0;
    mov dword [ebp-8], 0
    mov dword [ebp-12], 0

    ; for (int i = 0; i < n; i++)
    mov ecx, 0

manacher_for1_cmp:
    cmp ecx, [ebp+12]
    jl manacher_for1

    jmp manacher_for1_end

manacher_for1:
    mov eax, 0
    ; if (i <= r)
    cmp ecx, [ebp-8]
    jg manacher_if1_end

    ; eax = min(v[(t << 1) - i], r - i);
    mov eax, [ebp-12]
    shl eax, 1
    sub eax, ecx
    mov edx, [ebp+8]
    shl eax, 2
    add edx, eax
    mov edx, [edx]

    mov eax, [ebp-8]
    sub eax, ecx

    push edx
    push eax
    call min
    add esp, 8

manacher_if1_end:
    ; v[i] = eax
    mov edx, [ebp+8]
    mov ebx, ecx
    shl ebx, 2
    add edx, ebx
    mov [edx], eax

    ; while (
manacher_while2:
    ; edx = v[i];
    mov edx, [ebp+8]
    mov eax, ecx
    shl eax, 2
    add edx, eax

    ;   i - v[i] - 1 >= 0 &&
    mov eax, ecx
    sub eax, [edx]
    dec eax
    cmp eax, 0
    jl manacher_while2_end

    ;   i + v[i] + 1 <  n &&
    mov ebx, ecx
    add ebx, [edx]
    inc ebx
    cmp ebx, [ebp+12]
    jge manacher_while2_end

    ;   s[i - v[i] - 1] == s[i + v[i] + 1]
    mov esi, [ebp-4]
    add esi, eax
    mov al, [esi]

    mov esi, [ebp-4]
    add esi, ebx
    mov bl, [esi]

    cmp al, bl
    jne manacher_while2_end

    ; ) v[i]++;
    inc dword [edx]

    jmp manacher_while2

manacher_while2_end:
    ; if (i + v[i] > r)
    mov edx, [ebp+8]
    mov eax, ecx
    shl eax, 2
    add edx, eax
    mov edx, [edx]
    add edx, ecx

    cmp edx, [ebp-8]
    jle manacher_if2_end

    mov [ebp-8], edx
    mov [ebp-12], ecx

manacher_if2_end:
    inc ecx
    jmp manacher_for1_cmp

manacher_for1_end:
    leave
    ret
