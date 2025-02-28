# neo.phyte 0x01 - popularity counts!

Now that we have a way to return some information to the user by exit-status,
we can create more interesting programs!
(for exit-status, see [neo.phyte 0x00](../0x00/neo.phyte_00.md))

Computer is a counting machine, let's count the bits of a 64-bit number!

7 is  111 in binary, it has 3 bits.
8 is 1000 in binary, it has only 1 bit.

a 64-bit number can at-most have 64-bits (duh!) - so whatever its bit-count,
also known as popcount, will fit into the exit-status (0-255).

### Dedication

This is a work of love. I dedicate this issue to:
- MALCOLM - who likes cider and stealing women

## More instructions? No! more tools!

In order to achieve this goal, `mov` and `syscall` will not be enough, we will
need more instructions, let's get to know them, and the bit operations they
are based on.

### test instruction

The test instruction does not affect any of it's operands, it only affects
the so-called FLAGS register.

It does a bit-wise AND on the operands, and if the results is 0, it sets
the "Zero Flag" of the FLAGS register, and if the result is not 0, it unsets
the ZF.

For example `test 0x0f, 0x03` would UNSET the ZERO FLAG, because the result of
```
    0x1110 = 14
AND 0x0011 =  3
===============
    0x0010 =  2
```

is NOT ZERO.

### jz instruction

The jump zero instruction looks at the Zero Flag of the FLAGS register, and
if its ZF is set, it will jump to the location provided as its operand.

```asm
    mov rdi, 1 ; failure - no coffee!
    mov rcx, 0xc0ffee
    test rcx, 0
    jz no_coffee
    mov rdi, 0 ; success - coffee!
no_coffee:
    mov rax, 60
    syscall
```

Since `0xc0ffee AND 0x000000 = 0`, the `test` instruction will SET ZF, and so
`jz` will jump to the `no_coffee` label, over the `mov rdi, 0` instruction.
`rdi` will stay 1, and this will be returned by the exit syscall 60.

### add

Adds the second operand to the first operand.

```
mov rax, 3
add rax, 1
```

`rax` is now 4

### shr

The shift right instruction, shifts the first operand X number of bits to the
right, where X is the second operand. So X number of bits will disappear,
and new 0 will be added on the left.

The shift right operation in C would look like:

```c
int x = 0b10101111; // 0xaf = 175
x >>= 4; // shr x, 4
// x = 0b1010 = 0xa = 10 = 175 / 2^4 = 175 / 16
```

While in assembly,

```asm
mov rax, 0b10111 ; = 0b10111 = 23
shr rax, 3       ; = 0b10 = 2 = 23 / 2^3
```

If you study these examples, you will see that shifting X to the right, is
equal to dividing by 2^X and discarding the leftover - and leftover was
exactly the bits that flew-off the register to the right.

## Pop it to the right, is it one?

The procedure of counting the bits will look something like this:

```
0         SET C to the number whose bits we want to count (e.g. 0x101)
1         SET D to 0 (accumulator for number of bits of C)
2 REPEAT: Is C 0?
3         If so GOTO EXIT
4         If not, is the rightmost bit of C equal to 1?
5         If so ADD 1 to D
6         SHIFT C to the RIGHT by 1 (i.e. DIVIDE it by 2)
7         GOTO REPEAT
8 EXIT:   RETURN D
```

If C would be set to 5 = 0b101, the procedure would go:

```
0,1       ; C=5, D=0
2,3,4,5   ;    , D=1
6         ; C=2
7,2,3,4,5 ;
6         ; C=1
7,2,3,4,5 ;    , D=2
6         ; C=0
7,2,3,8   ; RETURN 2
```

So we manually went through this pseudo assembly, much like the original
programmers surely did before us.

There is nothing left for us to do, but to rewrite the same exact procedure in
x86 assembly, it looks like we have all the instructions we need!

### popcount.asm

```asm
_start:
	mov rdi, 0
	mov rcx, 0b101
repeat:
	test rcx, 0xffffffffffffffff ; these two lines check if rcx register
	jz exit                      ; is equal to to 0, and if so jump to EXIT
	test rcx, 1 ;;; these five lines check the
	jz unset    ;;; rightmost bit of rcx register
set:            ;;; if it is set, they add 1 to
	add rdi, 1  ;;; rdi register, otherwise they
unset:          ;;; do nothing
	shr rcx, 1 ; now that the bit was checked, it is discarded
	jmp repeat ;;; repeat
exit:
	mov rax, 60 ; report the popcount saved in rdi
	syscall     ; in the exit-status of the program (syscall 60 = exit(rdi))
```

A few questions arise - does `test` set only the ZF? Does `jz` need labels,
and does it use relative or absolute addresses under the hood? Does `shr`
set any flags - perhaps if so we can shorten the program? Is there an add 1
instruction equivalent to C's i++, and what are its benefits?

Using exit-status to output data proved useful - now we have to figure out a
way to input data to our assembly programs, in order to make them interactive.

# Appendix

## Learn your A, B, C, Ds

The modern CPU has eight general-purpose registers.
We will learn much from the ESI, EDI, ESP and EBP registers some other time,
and today focus on registers RAX, RBX, RCX and RDX!

### 8-bit registers

In the beginning the A, B, C, D registers were little 8 bit things, and 8
ordered bits can be set or unset in 2x2x2x2x2x2x2x2 = 256 different ways.

```
        BIN   DEC    HEX
   ========
A     |     =  16 = 0x10
B      |||| =  15 = 0x0f
C  ||||     = 240 = 0xf0
D  |||||||| = 255 = 0xff
```

### 16-bit registers (Unix's DEC PDP-11)

Then they eXtended them to 16 bit AX, BX, CX & DX registers.
And these have a High 8-bit part called AH, BH, CH & DH.
And these have a Low  8-bit part called AL, BL, CL & DL.

And 16 ordered bits can be set or unset in 2^16 = 65536 different ways!

```
                BIN     DEC      HEX
   HHHHHHHH========
AX ||||    ||||     =   256 = 0xf0f0
BX |||||||||||||||| = 65535 = 0xffff
CX ||||||||         = 65280 = 0xff00
DX         |||||||| =   255 = 0x00ff
```

### 32-bit registers

And then they Extended them some more to 32 bit EAX, EBX, ECX, EDX registers!
And 32 ordered bits can be set or unset in 1<<32 = 4294967296 different ways!

Thats 4 billion, 294 million, 967 thousand and 296 different ways!

```
                                 BIN     DEC      HEX
    ================HHHHHHHH========
EAX ||||||||||||||||                 =   256 = 0xf0f0
EBX                 |||||||||||||||| = 65535 = 0xffff
ECX                 ||||||||         = 65280 = 0xff00
EDX                         |||||||| =   255 = 0x00ff
```

### 64-bit registers

And then they stRetched them some more to 64-bit RAX, RBX, RCX, RDX registers!
And their E_X parts live as lower 32-bits.
ANd their  _X parts live as lower 16-bits.
And their  _L parts live as lower  8-bits.

```
      56      48      40      32      24      16       8       0
RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEHHHHHHHHLLLLLLLL
```

And 64 ordered bits can be set or unset 18446744073709551616 different ways.
= 4294967296^2
= 65536^4
= 256^8
