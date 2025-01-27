<div id="toc">
  <ul style="list-style: none;" align="center">
    <summary>
      <h1> 64bits routines for 32bits </h1>
    </summary>
  </ul>
</div>

### Implementation Purpose
use `64bits` algorithms in `32bits` without glibc's [integer arithmetic routines](https://gcc.gnu.org/onlinedocs/gccint/Integer-library-routines.html)

### Features
- Arithmetic : [math64.asm](math64.asm), [math64.md](math64.md)
- Numeric : [numeric64.asm](numeric64.asm)
- <i>To be added later.</i>

### Rule of Function Name

- Format : `<func_name>_<target>`
- Targets : `64`, `u64`, `i64`
- Examples : `mul_64`, `div_u64`, `abs_i64`

### Type Definition List
- `u64` : unsigned long long
- `i64` : long long
- `64` : /* implementation-defined (u64 or i64) */
- `u32` : unsigned int
- `i32` : int
- `32` : /* implementation-defined (u32 or i32) */