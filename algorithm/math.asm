; min(int a, int b) -> int
min:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovg eax, [ebp+12]

    pop ebp
    ret

; max(int a, int b) -> int
max:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovl eax, [ebp+12]

    pop ebp
    ret

; gcd(int a, int b) -> int
gcd:
    push ebp
    mov ebp, esp

    mov eax, [ebp+12]
    test eax, eax
    jnz gcd+15
    mov eax, [ebp+8]
    leave
    ret

    mov eax, [ebp+8]
    mov edx, 0
    div dword [ebp+12]
    push edx
    push dword [ebp+12]
    call gcd
    add esp, 8

    leave
    ret

; lcm(int a, int b) -> int
lcm:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov edx, 0
    mul dword [ebp+12]
    push eax

    push dword [ebp+12]
    push dword [ebp+8]
    call gcd
    add esp, 8

    pop ebx
    xchg eax, ebx
    mov edx, 0
    div ebx

    leave
    ret
