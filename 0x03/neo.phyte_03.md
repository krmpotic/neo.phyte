# neo.phyte 0x03 - Hello World

We have yet to do a "Hello, World!" program. So far, we only used exit-status
to communicate back to the user, but that's not what the exit status is there
for.

## syscall write

from `man 2 write`:
> ssize_t write(int fd, const void buf[.count], size_t count);
>
> write() writes up to count bytes from the buffer starting at buf to the file
> reffered to by the file desriptor fd

When the shell starts a program, it gives it a way to write to the user using
"stdout" & "stderr", which can be accessed by file-descriptors 1 and 2.

```c
#include <unistd.h>

int main() {
	char* hello = "HELLO WORLD!";
	write(2, hello, 12); // write to stderr
}
```

Unlike the `exit` syscall, which only took 1 argument (exit-status), which we
passed to it using `rdi` register, `write` takes 3 arguments!

### System V calling convention

Every kernel can decide for itself what registers mean what. Linux, where I'm
writing this, follows the "System V ABI", where first six parameters are
passed using `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` registers (any more on
the stack). So it looks like we're gonna need to fill `rdi`, `rsi` and `rdx`.

### gcc -S

Let's use gcc, to see the assembly code of the above C program:

`gcc -S hello_world.c -masm=intel`
`-S` stop after compilation proper, don't assemble
`-masm=intel` flag chooses intel syntax, over default AT&T

```
; ... redacted
	mov	edx, 12
	mov	rsi, rax
	mov	edi, 2
	call	write@PLT
; ... redacted
```

- `rdi`, `rsi` and `rdx` are used so this confirms the above
- actually for `rdi` and `rdx` only the 32-bit subregisters `edi` and `edx`
- instead of `mov rax, 1`, `syscall` it does `call write@PLT`

PLT referes to the Procedure Linking Table, because in C, `write` is a wrapper
around the syscall. Anyway,

## hello_world.asm

```
section .data
	sys_write equ 1
	sys_exit equ 60
	stderr equ 2
	hello: db "hello world!", 0x0A
    hello_len equ $-hello
section .text
	global _start
_start:
	mov rax, sys_write
	mov rdi, stderr
	mov rsi, hello
	mov rdx, hello_len
	syscall
	mov rax, sys_exit
	mov rdi, 0
	syscall
```

hello is a pointer to the piece of memory in the .data section, that holds
the bytes of the "hello world!" string (+ 0x0A byte - ascii newline).

we also use a nice trick for hello_len, with the `$-` syntax to find out the
length of the hello world string.

## syscall garbles the registers!

Let's spice up our hello world, and produce this kind of output:

```
HELLO WORLD!
HELLO WORLD
HELLO WORL
HELLO WOR
HELLO WO
HELLO W
HELLO 
HELLO
HELL
HEL
HE
H
```

we will do this by calling `write` repeatedly, with its third argument going
towards 0. My first attempts to do this were unsuccesful, because I tried
storing the changing message length into a register, but values in registers
get overwritten after doing `syscall` - I had to use the stack:

```
section .data
	SYS_WRITE equ 1
	SYS_EXIT equ 60
	STDOUT equ 1
	STR: db "HELLO WORLD!"
	LEN equ $-STR
	NL: db 0x0a

section .text
	global _start
_start:

	push LEN ; store message length on the stack
print:
	mov rax, SYS_WRITE ; this can't be done outside the loop
	mov rdi, STDOUT    ; because registers get overwritten
	mov rsi, STR       ; after doing syscall
	mov rdx, [rsp]     ; new-syntax [rsp]! refers to the value at address rsp
	syscall
	call println

	pop rcx ; get stored message length from the stack
	dec rcx ; decrese it by one
	test rcx, rcx ; only in the case where rcx zero, will this be zero (AND)
	jz exit ; length is zero - we're done!
	push rcx ; put the message length back on the stack
	jmp print ; repeat

println:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, NL
	mov rdx, 1
	syscall
	ret

exit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall
```

This has a trick we didn't use before. Giving `mov` instruction a pointer
to the value, using the syntax with brackets.

## Take-away

We used a new syscall - write, found out which registers are used to pass
more then one argument to a syscall, found out new NASM syntax for calculating
the length of a string, and used pointers for the first time. That's plenty.

Ideas for next time: if we use the "open" syscall we can start reading from
files. And we still have to cover parsing command-line arguments, and getting
input from the user.
