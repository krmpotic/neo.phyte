section .text
	global _start
_start:
	push 13
	push 60
	pop rax ; 60
	pop rdi ; 13
	syscall
