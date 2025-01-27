# How to calculate arithmetic of 64bits

### Definitions
```assembly
; [ebp-8 ] = 64 a ; Stack variables. Structure of 64 is
; [ebp-16] = 64 b ;     '64 [-8] = { 32 high [-4], 32 low [-8] }'.
```

## A + B
```assembly
mov eax, [ebp-8]
mov edx, [ebp-4]
add eax, [ebp-16] ; Add low bits first.
adc edx, [ebp-12] ; Add high bits with carry.
                  ; Now, stored result of A+B on edx:eax.
```

## A - B
```assembly
mov eax, [ebp-8]
mov edx, [ebp-4]
sub eax, [ebp-16] ; Subtract low bits first.
sbb edx, [ebp-12] ; Subtract high bits with borrow.
                  ; Now, stored result of A-B on edx:eax.
```

## A >> #n (0 <= #n <= 63)
```assembly
; if (#n < 32)
shrd eax, edx, #n  ; Shift #n bits with edx.
shr edx, #n        ; Since shrd modify eax only, should modify edx too.

; if (#n >= 32)
mov eax, edx       ; You can use high bits only.
shr eax, (#n - 32) ; Move to low bits and shift #n - 32 bits.
xor edx, edx       ; Clear high bits.

; if A is signed integer, replace shr to sar but, not shrd
;    and replace 'xor edx, edx' to 'cdq'.
```

## A << #n (0 <= #n <= 63)
```assembly
; if (#n < 32)
shld edx, eax, #n  ; Shift #n bits with eax.
shl eax, #n        ; Since shld modify edx only, should modify eax too.

; if (#n >= 32)
mov edx, eax       ; You can use low bits only.
shl edx, (#n - 32) ; Move to high bits and shift #n - 32 bits.
xor eax, eax       ; Clear low bits.

; if A is signed integer, replace shl to sal but, not shld.
```

## -A (negative opeartor)
```assembly
mov eax, [ebp-8]
mov edx, [ebp-4]
neg eax          ; Get negative of low bits first.
adc edx, 0       ; Add carry to high bits.
neg edx          ; Get negative of high bits.
                 ; Now, stored result of -A on edx:eax.
```

## Compare(A, B)
```assembly
; edx:eax = a;

; a == b, a != b
xor eax, [ebp-16] ; eax will be 0 if high bits are same.
xor edx, [ebp-12] ; Same as above.
or eax, edx       ; ZF will set to 1 if low and high bits are same.
jz equal          ; branch if equal
jnz not_equal     ; branch if not equal

; a < b, a >= b
cmp eax, [ebp-16] ; Compare low bits first..
sbb edx, [ebp-12] ; Compare high bits with borrow.
jc less           ; branch if less
jnc greater_equal ; branch if greater_equal

; a > b, a <= b
cmp [ebp-16], eax ; Convert 'a > b' to 'b < a'
mov ecx, [ebp-12] ; and calculate same as 'a < b'.
sbb ecx, edx      ;
jc greater        ; branch if greater
jnc less_equal    ; branch if less_equal
```