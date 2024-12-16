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

; Delcare data section (global) variables for functions.
section .data
     ; Use nasm data section variable delcaration syntax.
     ; name: <type> <values>
     ; for example
     var1: dd 0, 1, 2
     str1: db "Hello, World!", 0

; If data section used, use section directive to specific that it is a text section;
; otherwise, not necessary
section .text

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
   - For example: `jmp func+0x40`, `jne $-0x4d`

4. Classify folders well.

5. Data section variable name must relate with function name.
   - Any format is fine as long as each name is distinct.
   - For example
      ```
      function name : add
      variable name : constant

      =>

      data section variable name : add_constant
      ```