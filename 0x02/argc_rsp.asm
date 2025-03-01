section .data
	SYS_EXIT equ 60

section .text
	global _start
_start:
	mov rdi, [rsp]
	mov rax, SYS_EXIT
	syscall
