# Rule of Repository
The assembly code you upload should adhere to the following rules:

1. File Format
```nasm
; Write comments about the dependencies of the file.
extern ... ; Name of the file or link.

; If there are private functions, use the global directive for public functions.
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

2. Add pseudo code (similar to C/C++) in lines.
   - Include pseudocode (similar to C/C++) alongside your assembly code for clarity.
   - Example : [Stack.asm](https://github.com/qluana7/asmlib/blob/main/data_structure/stack.asm)

3. Do not use label as branch. (* All labels are treated as functions.)
   - Instead, use the format `jmp function+address`.
   - For example: `jmp func+0x40`.

5. Classify folders well.<br/>
<br/>
