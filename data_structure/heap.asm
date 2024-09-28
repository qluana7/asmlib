extern malloc
extern realloc

; struct Heap {
;     int[] nodes;      [eax]
;     int size;         [eax+4]
;     int capacity;     [eax+8]
;     padding(4);
; };

; heap_init() -> Heap*
heap_init:
    push ebp
    mov ebp, esp
    sub esp, 4

    ; Heap* h = malloc(sizeof(Heap));
    push dword 16
    call malloc
    add esp, 4
    mov [ebp-4], eax

    ; h->nodes = malloc(1048576 * sizeof(int));
    push dword 4*1048576
    call malloc
    add esp, 4

    mov edx, [ebp-4]
    mov [edx], eax

    ; h->size = 0; h->capacity = 1048576;
    mov dword [edx+4], 0
    mov dword [edx+8], 1048576
    mov eax, edx

    leave
    ret

; Not working now
; Don't call this function manually
; heap_resize(Heap* h)
heap_resize:
    push ebp
    mov ebp, esp

    ; h->capacity *= 2;
    mov eax, [ebp+8]
    shl dword [eax+8], 1
    mov ecx, [eax+8]

    ; h->nodes = realloc(h->nodes, h->capacity * sizeof(int));
    shl ecx, 2
    mov eax, [eax]
    push ecx
    push eax
    call realloc
    add esp, 8

    mov edx, [ebp+8]
    mov [edx], eax

    pop ebp
    ret

; heap_insert(Heap* h, int p)
heap_insert:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int i;
    sub esp, 4

    ; h->size++;
    ; if (h->size >= h->capacity) heap_resize(h);
    mov eax, [ebp+8]
    inc dword [eax+4]
    mov edx, [eax+4]
    cmp edx, [eax+8]
    jge heap_insert+0x54

    ; i = h->size;
    mov eax, [ebp+8]
    mov ecx, [eax+4]
    mov [ebp-4], ecx

    ; while (i != 1 && p > h->nodes[i / 2])
    mov ecx, [ebp-4]
    cmp ecx, 1
    je heap_insert+0x44

    mov edx, [ebp+12]
    mov eax, [ebp+8]
    mov eax, [eax]
    shr ecx, 1
    cmp edx, [eax+ecx*4]
    jle heap_insert+0x44

    ; h->nodes[i] = h->nodes[i / 2];
    mov edx, [eax+ecx*4]
    mov ecx, [ebp-4]
    mov [eax+ecx*4], edx

    ; i /= 2;
    shr ecx, 1
    mov [ebp-4], ecx

    jmp heap_insert+0x1a

    ; h->nodes[i] = p;
    mov eax, [ebp+8]
    mov eax, [eax]
    mov ecx, [ebp-4]
    mov edx, [ebp+12]
    mov [eax+ecx*4], edx

    leave
    ret

    push dword [ebp+8]
    call heap_resize
    add esp, 4
    jmp heap_insert+0x14


; heap_delete(Heap* h)
heap_delete:
    push ebp
    mov ebp, esp
    ; [ebp-4] = int p, [ebp-8] = int c
    ; [ebp-12] = int v, [ebp-16] = int t
    sub esp, 16

    ; v = h->nodes[1]; t = h->nodes[h->size]; h->size--;
    mov eax, [ebp+8]
    mov edx, [eax]
    mov ecx, [edx+4]
    mov [ebp-12], ecx
    mov ecx, [eax+4]
    mov ecx, [edx+ecx*4]

    mov [ebp-16], ecx
    dec dword [eax+4]

    mov dword [ebp-4], 1
    mov dword [ebp-8], 2

    ; while (c <= h->size)
    mov ecx, [ebp-8]
    mov eax, [ebp+8]
    cmp ecx, [eax+4]
    jg heap_delete+0x6d

    ; if (c < h->size && h->nodes[c] < h->nodes[c + 1])
    je heap_delete+0x47

    mov edx, [eax]
    lea edx, [edx+ecx*4]
    mov ecx, [edx]
    cmp ecx, [edx+4]
    jge heap_delete+0x47

    ; c++;
    inc dword [ebp-8]

    ; if (t >= h->nodes[c]) break;
    mov ecx, [ebp-8]
    mov edx, [eax]
    mov edx, [edx+ecx*4]
    cmp [ebp-16], edx
    jge heap_delete+0x6d

    ; h->nodes[p] = h->nodes[c];
    mov edx, [eax]
    mov ecx, [ebp-8]
    mov eax, [edx+ecx*4]
    mov ecx, [ebp-4]
    mov [edx+ecx*4], eax

    ; p = c; c *= 2;
    mov eax, [ebp-8]
    mov [ebp-4], eax
    shl dword [ebp-8], 1

    jmp heap_delete+0x2b

    ; h->nodes[p] = t;
    mov eax, [ebp+8]
    mov edx, [eax]
    mov ecx, [ebp-4]
    mov eax, [ebp-16]
    mov [edx+ecx*4], eax

    leave
    ret

; heap_top(Heap* h) -> int
heap_top:
    mov eax, [esp+4]
    mov eax, [eax]
    mov eax, [eax+4]
    ret

; heap_size(Heap* h) -> int
heap_size:
    mov eax, [esp+4]
    mov eax, [eax+4]
    ret

; heap_empty(Heap* h) -> bool
heap_empty:
    mov eax, [esp+4]
    cmp dword [eax+4], 0
    sete al
    movzx eax, al
    ret
