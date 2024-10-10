extern malloc
extern free

; struct iterator {
;     void* container;  [iterator]
;     void* addr;       [iterator+4]
;     int element_size; [iterator+8]
;     padding(4);
; }

; iterator_constructor(void* container, void* addr, int element_size)
iterator_constructor:
    push ebp
    mov ebp, esp
    
    ; eax = malloc(sizeof(iterator));
    push dword 16
    call malloc
    add esp, 4

    ; *eax = { container, addr, element_size };
    mov edx, [ebp+8]
    mov [eax], edx
    mov edx, [ebp+12]
    mov [eax+4], edx
    mov edx, [ebp+16]
    mov [eax+8], edx

    ; return eax;
    pop ebp
    ret

; iterator_inc(iterator* this)
iterator_inc:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov edx, [eax+8]
    add [eax+4], edx

    pop ebp
    ret

; iterator_dec(iterator* this)
iterator_dec:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov edx, [eax+8]
    sub [eax+4], edx

    pop ebp
    ret

; iterator_value(iterator* this)
iterator_value:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov eax, [eax+4]

    pop ebp
    ret

; iterator_add(iterator* this, int v)
iterator_add:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov eax, [eax+8]
    mov edx, 0
    mul dword [ebp+12]
    mov edx, [ebp+8]
    add [edx+4], eax

    pop ebp
    ret

; iterator_sub(iterator* this, int v)
iterator_sub:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov eax, [eax+8]
    mov edx, 0
    mul dword [ebp+12]
    mov edx, [ebp+8]
    sub [edx+4], eax

    pop ebp
    ret

; iterator_equal(iterator* a, iterator* b) -> bool
iterator_equal:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov eax, [eax+4]
    mov edx, [ebp+12]
    mov edx, [edx+4]
    cmp eax, edx
    sete al
    movzx eax, al

    pop ebp
    ret

; iterator_free(iterator* this)
iterator_free:
    push ebp
    mov ebp, esp

    push dword [ebp+8]
    call free
    add esp, 4

    pop ebp
    ret
