# Rule of Repository
The assembly code you upload should adhere to the following rules:

1. File Format
```nasm
; If there are private functions, use the global directive.
global ...

; Declare any external glibc functions required by your code.
extern ...

; Write your code below. The following is an example.

; Define your function prototype in the following format:
; func(int a, int b) -> int*

; If the function returns void, use the following format:
; func(int a, int b)
func:
    push ebp
    mov ebp, esp

    ; Function body goes here

    leave
    ret
```

2. Add pesudo code (similar to C/C++) in lines.
- Include pseudocode (similar to C/C++) alongside your assembly code for clarity.
- Example : [Stack.asm](https://github.com/qluana7/asmlib/blob/main/data_structure/stack.asm)

3. Classify folders well.<br/>
<br/>
