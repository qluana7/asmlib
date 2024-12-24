extern __muldi3
extern __cmpdi2

; struct pos_t {
;     long long x [pos_t]
;     long long y [pos_t+8]
; }

; ccw(pos_t s, pos_t a, pos_t b) -> int
ccw:
    lea ecx, [esp+4]
    and esp, -16
    push dword [ecx-4]
    push ebp
    mov ebp, esp
    push ecx
    ; variable start = [ebp-8], max depth = [ebp-24]
    ; [ebp-16] = long long res, [ebp-24] = long long temp;
    sub esp, 4+4*4

    ; res = (a.x - s.x) * (b.y - s.y) - (b.x - s.x) * (a.y - s.y);    
    mov ecx, [ebp-4]
    ; res = (b.x - s.x) * (a.y - s.y);
    mov eax, [ecx+32]
    mov edx, [ecx+36]
    sub eax, [ecx]
    sbb edx, [ecx+4]
    push edx
    push eax
    mov eax, [ecx+24]
    mov edx, [ecx+28]
    sub eax, [ecx+8]
    sbb edx, [ecx+12]
    push edx
    push eax

    ; // res -= (a.x - s.x) * (b.y - s.y)
    mov eax, [ecx+16]
    mov edx, [ecx+20]
    sub eax, [ecx]
    sbb edx, [ecx+4]
    push edx
    push eax
    mov eax, [ecx+40]
    mov edx, [ecx+44]
    sub eax, [ecx+8]
    sbb edx, [ecx+12]
    push edx
    push eax

    call __muldi3
    add esp, 16
    mov [ebp-16], eax
    mov [ebp-12], edx
    call __muldi3
    add esp, 16
    sub [ebp-16], eax
    sbb [ebp-12], edx

    ; return res > 0 ? 1 : res < 0 ? -1 : 0;
    push dword 0
    push dword 0
    push dword [ebp-12]
    push dword [ebp-16]
    call __cmpdi2
    add esp, 16
    dec eax

    mov ecx, [ebp-4]
    leave
    lea esp, [ecx-4]
    ret