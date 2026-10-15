
.intel_syntax noprefix
.global _start

.text
_start:
    lea rdx, [rip + s1]
    xor rcx, rcx

loop:
    mov bl, [rdx]
    cmp bl, 0
    je done

    inc rcx
    inc rdx
    jmp loop

done:
    int3

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

.data
s1: .asciz "Hello"
