; A more advanced version of the `false` program developed in the previous
; issue of neo.phyte! they say Keep It Simple Stupid! but we're not, so...

section .text
	global _start
_start:
    mov rdi, 1        ; failure
    mov rcx, 0xc0ffee ;
    test rcx, 0       ; 0xc0ffee AND 0x000000 = 0 so ZERO FLAG will be SET
    jz no_coffee      ; jumps to no_coffee since ZF is SET, skipping success
    mov rdi, 0        ; success        |
no_coffee: ; <-------------------------/
    mov rax, 60 ; syscall 60 = exit
    syscall     ; exit(rdi)
