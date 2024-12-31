extern aligned_alloc
extern free

; value type can be used as void* (address)
; struct q_node {
;     int value    [q_node]
;     q_node* back [q_node+4]
; }

; struct queue {
;     q_node* front [queue]
;     q_node* back  [queue+4]
;     int size      [queue+8]
;     padding(4)
; }

; queue_init() -> queue*
queue_init:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    sub esp, 4

    ; eax = aligned_alloc(16, sizeof(queue));
    sub esp, 8
    push dword 16
    push dword 16
    call aligned_alloc
    add esp, 16

    ; eax->size = 0;
    mov dword [eax+8], 0

    ; return eax;
    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; queue_deinit(queue* q)
queue_deinit:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = int sz, [ebp-16] = q_node* node
    sub esp, 4+4*4
    
    ; sz = q->size;
    mov edx, [ecx]
    mov eax, [edx+8]
    mov [ebp-12], eax

    ; node = q->front;
    mov eax, [edx]
    mov [ebp-16], eax

    ; while (sz --> 0)
    jmp $+0x17

    ; node = node->back; free([old] node);
    sub esp, 12
    mov edx, [ebp-16]
    push edx
    mov eax, [edx+4]
    mov [ebp-16], eax
    call free
    add esp, 16

    mov eax, [ebp-12]
    dec dword [ebp-12]
    cmp eax, 0
    jg $-0x1e

    ; free(q);
    sub esp, 12
    mov ecx, [ebp-4]
    push dword [ecx]
    call free
    add esp, 16

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; queue_push(queue* q, int value)
queue_push:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    sub esp, 4

    ; eax = aligned_alloc(8, sizeof(q_node));
    sub esp, 8
    push dword 8
    push dword 8
    call aligned_alloc
    add esp, 16

    ; eax->value = [para] value;
    mov ecx, [ebp-4]
    mov edx, [ecx+4]
    mov dword [eax], edx

    ; if (q->size == 0)
    mov edx, [ecx]
    cmp dword [edx+8], 0
    jnz $+0x6

    ; q->front = eax;
    mov [edx], eax
    jmp $+0x8
    
    ; q->back->back = eax;
    mov ecx, [edx+4]
    mov [ecx+4], eax

    ; q->back = eax;
    mov [edx+4], eax

    ; q->size++;
    inc dword [edx+8]

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; queue_pop(queue* q)
queue_pop:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-12] = q_node* node
    sub esp, 4+4*4

    ; if (q->size == 0) return;
    mov edx, [ecx]
    cmp dword [edx+8], 0
    jz $+0x21

    ; q->size--;
    dec dword [edx+8]

    ; node = q->front;
    mov eax, [edx]
    mov [ebp-12], eax

    ; if (q->size != 0)
    jz $+0x9

    ; q->front = q->front->back;
    mov ecx, [edx]
    mov eax, [ecx+4]
    mov [edx], eax

    ; free(node);
    sub esp, 12
    push dword [ebp-12]
    call free
    add esp, 16

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret

; queue_front(queue* q) -> int
queue_front:
    push ebp
    mov ebp, esp

    ; return q->front->value;
    mov edx, [ebp+8]
    mov edx, [edx]
    mov eax, [edx]

    leave
    ret

; queue_back(queue* q) -> int
queue_back:
    push ebp
    mov ebp, esp

    ; return q->back->value;
    mov edx, [ebp+8]
    mov edx, [edx+4]
    mov eax, [edx]

    leave
    ret

; queue_size(queue* q) -> int
queue_size:
    push ebp
    mov ebp, esp

    ; return q->size;
    mov edx, [ebp+8]
    mov eax, [edx+8]

    leave
    ret

; queue_empty(queue* q) -> bool
queue_empty:
    push ebp
    mov ebp, esp

    ; return q->size == 0;
    mov edx, [ebp+8]
    cmp dword [edx+8], 0

    setz al
    movzx eax, al

    leave
    ret