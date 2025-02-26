section .text
	global _start
_start:
	mov di, 1
	mov ax, 60
	syscall
