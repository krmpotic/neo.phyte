section .data ; stores initialized data
	neophyte dq 0xff00ff00ff00ff00 ; declares a quadword unsigned integer

section .text
	global _start
_start:
	popcnt rdi, [neophyte]
	mov rax, 60
	syscall
