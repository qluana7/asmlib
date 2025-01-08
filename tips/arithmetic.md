<div id="toc">
  <ul style="list-style: none;">
    <summary>
      <h1> Arithmetic Tips </h1>
    </summary>
  </ul>
</div>

## Multiply/Divide Power of 2

Multiplying $n$ by a power of 2 can be converted to a left shift instruction.

$x \times 2^n$ can be replaced with $x$ << $n$

example code
```assembly
; Calculate eax * 16

shl eax, 4
```

</br>

Similarly, dividing $n$ by a power of 2 can be converted to a right shift instruction.

$x \div 2^n$ can be replaced with $x$ >> $n$

It is recommended to use this only for unsigned integers. It has some problems with signed integers.

example code
```assembly
; Calculate eax / 16

shr eax, 4
```

</br>

## Unsigned Integer Dividision by Positive Constant

The `mul` instruction takes about 3 to 4 cycles, while the `div` instruction takes about 23 to 26 cycles.</br>
This means that the `div` instruction is slower than the `mul` instruction.</br>
Therefore, this technique replaces the `div` instruction with the `mul` instruction for optimization.

The division by positive constant can be converted to following formula.

$n \div d = \Large \frac{nf(d)}{2^{k}}$

</br>

If $C \geq 2^{32}$, then use the another formula.

$n \div d = \Large [\frac{[\frac{n - [\frac{nf(d)}{2^{32}}]}{2}] + [\frac{nf(d)}{2^{32}}]}{2^{k}}]$

</br>

The code of getting magic number $f(d)$ and $k$ is in [divmagic.cpp](divmagic.cpp)

example code
```assembly
; Calculate eax / 3

; Magic number = { -1431655765, 1, Complex: false };
mov ecx, eax
mov edx, -1431655765
mul edx
mov eax, edx
shr eax

; Calculate eax / 7

; Magic number = { 613566757, 2, Complex: true };
mov ecx, eax
mov edx, 613566757
mul edx
mov eax, ecx
sub eax, edx
shr eax
add eax, edx
shr eax, 2
```