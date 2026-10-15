
.intel_syntax noprefix
.global _start

.text
_start:
    lea rsi, [rip + s1]
    xor rdx, rdx

strlen:
    cmp byte ptr [rsi + rdx], 0
    je print

    inc rdx
    jmp strlen

print:
    mov rax, 1
    mov rdi, 1
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

.data
s1: .asciz "Hello World!\n"
