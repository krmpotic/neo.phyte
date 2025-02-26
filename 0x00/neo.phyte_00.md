# neo.phyte 0x00

## Introduction

### Inspiration & goal

These series of text files will follow my journey of learning assembly
programming, but I will write so that it will serve as a guide to somebody
just getting into computers, and also as a summary of concepts & source of
assembly examples for somebody experienced.

We will start with creating the smallest possible program. While programming
language tutorials usually start with writing "Hello World!" to the screen -
tradition started by Brian Kernighan & Denis Ritchie of K&R fame -  we will
not do so here, and start with something much simpler, a program that
does nothing, and exits.

This is a work of love, inspired by and dedicated to:
- T.M.J.K. - to whom I hope it will serve as an interesting overview
- E.P.J.   - who inspires me with his endless learning

### Prerequisites

If you want to follow along you will need

- a UNIX operating system
- `nasm` the Netwide Assembler
- `ld` the GNU linker
- `make`

### Exit status

In the UNIX family of operating systems (Linux, BSDs, Plan9), when a process
terminates, it exits with a status - a number from 0-255.

0 status indicates a success, anything else a failure.

The parent process can find out what the exit status was using the wait system
call. In the Bash shell, we can see the exit status of the last command
in the `$?` variable.

```sh
touch /tmp/
echo $?
# 0
```

The 0 indicates that we have successfuly "touched" (updated the access and
modification times of) the /tmp directory (test with `ls -ld /tmp`).

Executing `false`, we get exit status 1.
```sh
false
echo $?
# 1
```

These exit statuses can be used to conditionally chain together commands.
```sh
true && echo good || echo bad
# good
```

```sh
false && echo good || echo bad
# bad
```

(given this output, where are the invisible parentheses?)

By the way, this exit status is the reason why the `main` function in C is
`int main()` and not `void main()`.

## First steps into assembly

### The smallest program

```asm
section .text
	global _start
_start:
	mov di, 1
	mov ax, 60
	syscall
```

Here is our first assembly program, which uses just two different instructions
`mov` and `syscall`.

### mov instruction

The CPU has registers, and a register is the smallest and fastest memory
storage available - living inside the CPU itself. The `mov` instruction
takes two operands: a destination, and a source. It copies (i.e. moves)
what is in the second operand and puts it in the memory of the first operand.

`mov di, 1`

moves 1 into the `di` register

`mov ax, 60`

moves 60 into the `ax` register

### syscall instruction

And last but not least, `syscall` invokes the kernel's syscall handler,
providing `ax` and `di` as arguments!
Kernel is the operating system, and the syscall handler is the interface where
the kernel communicates with "userspace" processes.

Imagine the handler something like this C pseudocode:

```c
void syscall_handler(int ax, int di) {
    switch (ax) {
    case 0: // read syscall
    case 1: // write sycall
    case 2: // open syscall
    case 3: // close syscall
    //...
    case 60: // exit syscall
        exit(di); // terminate process with `di` exit status
    //...
    }
}
```

And our program invokes it with two values in `ax` and `di`:
`syscall_handler(60, 1)`

Which in turn will invoke `syscall60` aka `exit` with the value in di as
its argument.

`exit(1)`

### Summary

Now, we understand better what the following program does,

````asm
	mov di, 1
	mov ax, 60
	syscall
````

while new questions have arisen - e.g. how does the syscall handler really
look like? where is it stored - probably not in main memory (RAM) - that
would be too slow!

### .text section

every program has .data, .bss, & .text sections, where .data & .bss store
initialized and uninitialized data, and .text stores executable
instructions, which `mov` and `syscall` are.

```asm
section .text
	global _start
_start:
	mov di, 1
	mov ax, 60
	syscall
```

the `_start:` label is where program starts it's execution.

## What have we done?

We have recreated the `false` program, which simply returns exit-status 1.
If you have nasm, ld and make installed, you should be able to simply
run make in this directory, and test it:

```sh
make
./false
echo $?
# 1
```

Running `make` will invoke `nasm` to create the `false.o` object file,
and then the `ld` linker to create the `false` executable.

You can clean up these two files using
`make clean`

## hexdump

To look at the ones and zeros of the created ./false executable, we can use
the `hexdump` program.

`hexdump -C false` outputs

```
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  02 00 3e 00 01 00 00 00  00 10 40 00 00 00 00 00  |..>.......@.....|
// ...redacted
00001000  66 bf 01 00 66 b8 3c 00  0f 05 00 00 00 00 00 00  |f...f.<.........|
// ...redacted
```

At the beginnig, we have the ELF header. And at position 0x1000, we have the
10 bytes that make up our program!

`66 bf 01 00 66 b8 3c 00 0f 05`

There is some pattern in these bytes, we can see two `0x66` bytes,
and we have two `mov` instruction. If we align the bytes as so:

```
66 bf 01 00
66 b8 3c 00
0f 05
```

We can already imagine the:

```
mov di, 1
mov ax, 60
syscall
```

`0x3c` is 60 in hexadecimal which was assigned to ax! Above it we have

`0x01` which was assigned to di.

So 0xbf must refer to the di register, and 0xb8 to the ax register.

That leaves us with 0x0f 0x05 sequence, which must correspond to the
`syscall` instruction!
