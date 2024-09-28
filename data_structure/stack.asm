extern malloc
extern free

; struct Node {
;     int value;
;     Node* prev;
; }

; struct Stack {
;     Node* top;
;     int size;
; }

; stack_init() -> Stack*
stack_init:
    push ebp
    mov ebp, esp

    ; Stack* s = malloc(sizeof(Stack));
    push dword 8
    call malloc
    add esp, 4

    ; s->top = nullptr; s->size = 0;
    mov dword [eax], 0
    mov dword [eax+4], 0

    ; return s;
    pop ebp
    ret

; stack_push(Stack* s, int v)
stack_push:
    push ebp
    mov ebp, esp

    ; s->size++;
    mov eax, [ebp+8]
    inc dword [eax+4]

    ; eax = malloc(sizeof(Node));
    push dword 8
    call malloc
    add esp, 4

    ; eax->value = v; eax->prev = s->top;
    mov edx, [ebp+12]
    mov [eax], edx
    mov edx, [ebp+8]
    mov ecx, [edx]
    mov [eax+4], ecx

    ; s->top = eax;
    mov [edx], eax

    leave
    ret

; stack_pop(Stack* s) -> int
stack_pop:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp dword [eax+4], 0
    mov eax, -1
    je stack_pop+0x2b

    ; s->size--;
    mov eax, [ebp+8]
    dec dword [eax+4]

    ; edx = s->top;
    ; s->top = edx->prev;
    ; eax = edx->value;
    ; free(edx)
    mov edx, [eax]
    mov ecx, [edx+4]
    mov [eax], ecx
    mov eax, [edx]
    push eax
    push edx
    call free
    add esp, 4
    pop eax

    ; return eax;
    pop ebp
    ret

; stack_deinit(Stack* s)
stack_deinit:
    push ebp
    mov ebp, esp

    ; while (s->size != 0) s->pop();
    mov eax, [ebp+8]
    cmp dword [eax+4], 0
    je stack_deinit+0x17

    push eax
    call stack_pop
    add esp, 4

    jmp stack_deinit+0x3

    pop ebp
    ret

; stack_empty(Stack* s) -> bool
stack_empty:
    ; s->
    mov eax, [esp+4]
    cmp dword [eax+4], 0
    setz al
    movzx eax, al
    ret

; stack_size(Stack* s) -> int
stack_size:
    mov eax, [esp+4]
    mov eax, [eax+4]
    ret

; stack_top(Stack* s) -> int
stack_top:
    mov edx, [esp+4]
    mov edx, [edx]
    mov eax, -1
    test edx, edx
    jz stack_top+0x11
    mov eax, [edx]
    ret
