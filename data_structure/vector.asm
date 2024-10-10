extern iterator_constructor ; asmlib/data_structure/stl/iterator.asm

global vector_constructor
global vector_resize
global vector_at
global vector_push_back
global vector_pop_back
global vector_size
global vector_empty
global vector_clear
global vector_destructor
global vector_begin
global vector_end

; TBD
; global vector_insert
; global vector_erase
; global vector_assign
; global vector_reserve

; TBD (Low priority)
; global vector_front ┐ these method can be replaced by vector_at
; global vector_back  ┘
; global vector_data
; global vector_capacity

; TBD (After create reverse_iterator.asm)
; global vector_rbegin
; global vector_rend

extern malloc
extern realloc
extern free
extern memcpy
extern memset

; class vector {
;     void* arr;        [vector]
;     int size;         [vector+4]
;     int capacity;     [vector+8]
;     int element_size; [vector+12]
; };

; vector_constructor(int element_size) -> vector*
vector_constructor:
    push ebp
    mov ebp, esp
    ; [ebp-4] = vector* v;
    sub esp, 4

    ; v = malloc(sizeof(vector));
    push dword 16
    call malloc
    add esp, 4
    mov [ebp-4], eax

    ; v->arr = malloc(16 * element_size);
    mov eax, [ebp+8]
    shl eax, 4
    push eax
    call malloc
    add esp, 4
    mov edx,[ebp-4]
    mov [edx], eax

    ; v->size = 0;
    mov dword [edx+4], 0
    ; v->capacity = 16;
    mov dword [edx+8], 16
    ; v->element_size = element_size;
    mov eax, [ebp+8]
    mov [edx+12], eax

    mov eax, [ebp-4]
    leave
    ret

; vector_upsize(vector* this)
vector_upsize:
    push ebp
    mov ebp, esp

    ; this->arr = realloc(this->arr, this->capacity * this->element_size * 2);
    ; this->capacity <<= 1;
    mov edx, [ebp+8]
    mov eax, [edx+8]
    mov ecx, [edx+12]
    mov edx, 0
    mul ecx
    shl eax, 1
    push eax
    mov edx, [ebp+8]
    push dword [edx]
    call realloc
    add esp, 8

    mov edx, [ebp+8]
    mov [edx], eax
    shl dword [edx+8], 1
    
    pop ebp
    ret

; additional (fill [element_size] bytes with zero) are appended.
; vector_resize(vector* this, int size)
vector_resize:
    push ebp
    mov ebp, esp

    ; while (this->capacity <= size) vector_upsize(this);
    mov edx, [ebp+8]
    mov eax, [edx+8]
    cmp eax, [ebp+12]
    jg vector_resize+0x1b

    push dword [ebp+8]
    call vector_upsize
    add esp, 4

    jmp vector_resize+0x3

    ; if (size > this->size)
    mov edx, [ebp+8]
    mov ecx, [ebp+12]
    sub ecx, [edx+4]
    jle vector_resize+0x53

    ; memset(&this->arr[this->size], 0, (size - this->size) * this->element_size);
    mov eax, [edx+12]
    mov edx, 0
    mul ecx
    push eax
    push dword 0
    mov edx, [ebp+8]
    mov eax, [edx+4]
    mov ecx, [edx+12]
    mov edx, 0
    mul ecx
    mov edx, [ebp+8]
    mov edx, [edx]
    add edx, eax
    push edx
    call memset
    add esp, 12

    ; this->size = size;
    mov eax, [ebp+12]
    mov edx, [ebp+8]
    mov [edx+4], eax

    pop ebp
    ret

; vector_at(vector* this, int index) -> void* pos
vector_at:
    push ebp
    mov ebp, esp

    ; return &this->arr[index];
    mov edx, [ebp+8]
    mov eax, [edx+12]
    mov edx, 0
    mul dword [ebp+12]
    mov edx, [ebp+8]
    mov edx, [edx]
    add edx, eax

    mov eax, edx
    pop ebp
    ret

; value = stack copy value. not pointer.
; example : vector_push_back(v, 32);
; vector_push_back(vector* this, void* value)
vector_push_back:
    push ebp
    mov ebp, esp

    ; if (this->size == this->capacity) vector_upsize(this);
    mov edx, [ebp+8]
    mov eax, [edx+4]
    cmp eax, [edx+8]
    jne vector_push_back+0x19

    push dword [ebp+8]
    call vector_upsize
    add esp, 4

    ; eax = vector_at(this, this->size); this->size++;
    mov edx, [ebp+8]
    push dword [edx+4]
    inc dword [edx+4]
    push edx
    call vector_at
    add esp, 8

    ; memcpy(eax, &value, this->element_size);
    mov edx, [ebp+8]
    push dword [edx+12]
    lea ecx, [ebp+8]
    add ecx, [edx+12]
    push ecx
    push eax
    call memcpy
    add esp, 12

    pop ebp
    ret

; call this on an empty container results in nothing.
; vector_pop_back(vector* this)
vector_pop_back:
    push ebp
    mov ebp, esp

    ; if (this->size == 0) return;
    mov edx, [ebp+8]
    cmp dword [edx+4], 0
    jz vector_pop_back+0xf

    dec dword [edx+4]
    
    pop ebp
    ret

; vector_size(vector* this) -> int
vector_size:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov eax, [eax+4]

    pop ebp
    ret

; vector_empty(vector* this) -> bool
vector_empty:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp dword [eax+4], 0
    setz al
    movzx eax, al

    pop ebp
    ret

; vector_clear(vector* this)
vector_clear:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov dword [eax+4], 0

    pop ebp
    ret

; vector_begin(vector* this) -> iterator*
vector_begin:
    push ebp
    mov ebp, esp

    ; return iterator_constructor(this, this->arr, this->element_size);
    mov eax, [ebp+8]
    push dword [eax+12]
    push dword [eax]
    push eax
    call iterator_constructor
    add esp, 12

    pop ebp
    ret

; vector_end(vector* this) -> iterator*
vector_end:
    push ebp
    mov ebp, esp

    ; eax = vector_at(this, this->size);
    mov eax, [ebp+8]
    push dword [eax+4]
    push eax
    call vector_at
    add esp, 8

    ; return iterator_constructor(this, eax, this->element_size);
    mov edx, [ebp+8]
    push dword [edx+12]
    push eax
    push edx
    call iterator_constructor
    add esp, 12

    pop ebp
    ret

; vector_destructor(vector* this)
vector_destructor:
    push ebp
    mov ebp, esp

    mov edx, [ebp+8]
    push dword [edx]
    call free
    add esp, 4

    push dword [ebp+8]
    call free
    add esp, 4

    pop ebp
    ret
