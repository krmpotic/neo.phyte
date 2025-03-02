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
