# neo.phyte 0x02

Today, we will introduce the stack, and instructions that modify it. 

## The stack

A stack is a LIFO data structure - last in, first out. Like a stack of plates
in your cupboard, the one added to the stack last, will also be the first one
you take off.

The two instructions `push` and `pop` add, or take data from the stack.

```asm
_start:
	push 13
	push 60
	pop rax ; 60
	pop rdi ; 13
	syscall
```

### argc

On Linux, the first thing on the stack is the number of arguments the program
was called with. The following assembly program, will return this as the
exit-status. Since the program name is also counted, we decrease the value by
one after popping it off the stack, using the `dec` instruction.

```asm
_start:
	pop rdi
    dec rdi
	mov rax, SYS_EXIT
	syscall
```

```sh
./argc first_arg second_arg
echo $?
> 2
```

### RSP register

The thing is... the stack grows down! When a program gets loaded into memory
by the OS, it looks something like this:

```
=============== 0xfff...
----       ----
---- stack ----
----       ----  <---RSP


     ...


----       ----
---- heap  ----
----       ----
 section .bss
 section .data
 section .text
=============== 0x00000000
```

On the bottom we have the .text section, holding program instructions, then
.data and .bss sections for initialized and uninitialized data whose size is
known at compile time. Then the heap (growing upwards), from which memory
of arbitrary size (< 4GB) is allocated, and from the top down grows the
stack.

The Stack Pointer register RSP points to the last element on the stack.

So when we `push` a value on the stack, the RSP is decreased.
And wen we `pop` a value from the stack, the RSP is increased.

Can we access the value on the top of the stack using `rsp` register directly,
without doing `pop`? Yes:

```
_start:
	mov rdi, [rsp]
	mov rax, 60
	syscall
```

Here we encounter new nasm syntax, the braces show that rsp holds the pointer
to the value we want, not the value itself.

### call & ret

As the program runs, the RIP Instruction Pointer register points the CPU to
the instruction it should execute. The RIP register cannot be modified
directly (e.g. `add rip, 5` doesn't work), but instructions `call` and `ret`
do modify it.

`call` stores the value of RIP on the stack, and changes RIP to the
location of the "label". `ret` pops the value of the RIP from the stack.
You can imagine `ret` as `pop rip` (but `pop rip` is impossible).

Here is a program that uses `call` and `ret` instructions. Also, we use `mul`
for the first time, `mul` instruction always works on the `rax` register.

```
_start:
	mov rax, 5
	mov rbx, 6
	call mul
	call add
	mov rdi, rax
	mov rax, 60
	syscall
mul:
	mul rbx
	ret
add:
	add rax, rbx
	ret
```

Can you guess what the exit-status will be?

## Short but sweet

Todays neo.phyte is short. It introduced the stack, and four instructions that
work with it: `push`, `pop`, `call` and `ret`. A lot of possibilites have
just opened up...
