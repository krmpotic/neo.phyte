section .data
	SYS_EXIT equ 60

section .text
	global _start
_start:
	pop rdi
	dec rdi
	mov rax, SYS_EXIT
	syscall
