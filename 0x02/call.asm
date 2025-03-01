section .text
	global _start
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
