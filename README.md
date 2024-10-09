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

## How to use
Copy the entire source from the file and paste it into your code. The `extern` part indicates the dependency functions required by the implementation. If there are `global` directives, ensure to utilize the functions associated with those directives; functions not designated as `global` in this case should be considered private. If there are no `global` directives, all functions will be considered public.

```nasm
; Do not use the global directive for functions, as it is only intended to mark them as public.
; Example: global func (do not use this)

; Declare the main function as global
global main

; Declare extern functions required by the copied code from the repository
extern ...
; Additional extern dependencies
extern ...

; Function implementation from the copied repository code
func:
    ...

; Main code execution
main:
    ...
```

## Contribute
Please submit a pull request while adhering to the rules outlined in the [RULES.md](https://github.com/qluana7/asmlib/blob/main/RULES.md)

## Collaborator
<img title="ku7431" src="https://avatars.githubusercontent.com/u/75860187" width=16 height=16> ku7431
