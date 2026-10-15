.intel_syntax noprefix
.global _start

.text
_start:
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + s1]

    mov rdx, 6

    syscall

exit:
    mov eax, 60
    xor edi, edi
    syscall

.data
s1: .ascii "Hello\n"
s1_len = . - s1

