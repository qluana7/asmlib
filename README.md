<div id="toc">
  <ul style="list-style: none;" align="center">
    <summary>
      <h1> Assembly Preset Library </h1>
    </summary>
  </ul>
</div>

<p align="center"><i>Collection of algorithms, data structures, and other functions implemented in assembly.</i></p>

## Features
- **Collection of assembly presets**: Includes algorithms, data structures, and implementations of functions.
- **Use of Netwide Assembly (NASM)**: Most of the code is written using NASM, targeting the x86_64 architecture.
- **Linking with GCC**: Designed with the assumption that linking will be performed using GCC.
</br>

## Rule of Repository
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

## Collaborator
<img title="ku7431" src="https://avatars.githubusercontent.com/u/75860187" width=16 height=16> ku7431
