section .data ; stores initialized data
	neophyte dq 0xff00ff00ff00ff00 ; declares a quadword unsigned integer

section .text
	global _start
_start:
	mov rdi, 0  ; will store popcount (returned as exit-status)
	mov rcx, [neophyte] ; will be >>1 until 0

popcount:
	test rcx, 0xffffffffffffffff
	jz exit

	test rcx, 1
	jz unset
set:
	add rdi, 1
unset:
	shr rcx, 1
	jmp popcount
exit:
	mov rax, 60
	syscall
