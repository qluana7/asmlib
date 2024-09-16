; min(a, b)
min:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovg eax, [ebp+12]

    pop ebp
    ret

; max(a, b)
max:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, [ebp+12]
    cmovl eax, [ebp+12]

    pop ebp
    ret
