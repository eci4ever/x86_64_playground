# Nota Register Assembly x86-64 (Linux / GNU Assembler)

> **Fokus:** `.intel_syntax noprefix`, GNU Assembler (GAS), Linux x86-64. Nota ini membezakan **kegunaan lazim** register dengan **peraturan wajib** ketika `syscall` dan pemanggilan fungsi.

## 1. 16 register umum 64-bit (GPR)

| Register | Nama / kegunaan lazim | Nota ringkas |
|---|---|---|
| `RAX` | Accumulator; hasil operasi / nilai pulangan | **A** = answer; nombor Linux syscall |
| `RBX` | Base register; storan sementara | **B** = base |
| `RCX` | Counter; sesetengah arahan perulangan / shift | **C** = counter |
| `RDX` | Data register; sesetengah operasi aritmetik | **D** = data; panjang buffer dalam `write()` |
| `RSI` | Source Index; alamat sumber data | **S** = source |
| `RDI` | Destination Index; alamat destinasi untuk arahan string | **D** = destination; argumen #1 syscall |
| `RBP` | Base Pointer / frame pointer (konvensyen lazim) | **BP** = base pointer |
| `RSP` | Stack Pointer | **SP** = stack pointer; berhati-hati mengubahnya |
| `R8` | Register umum / argumen | register tambahan |
| `R9` | Register umum / argumen | register tambahan |
| `R10` | Register umum / argumen syscall #4 | register tambahan |
| `R11` | Register umum; diubah oleh `syscall` | register tambahan |
| `R12` | Register umum | register tambahan |
| `R13` | Register umum | register tambahan |
| `R14` | Register umum | register tambahan |
| `R15` | Register umum | sesuai untuk storan sementara, ikut konvensyen |

**Penting:** RAX/RBX/RCX dan lain-lain bukan pemboleh ubah yang mempunyai satu fungsi tetap. Kebanyakannya boleh menyimpan nilai atau alamat; sesetengah arahan CPU dan ABI menetapkan peranan khusus.

## 2. Pecahan saiz register

| 64 bit | 32 bit | 16 bit | 8 bit rendah | 8 bit tinggi (jika ada) |
|---|---|---|---|---|
| `RAX` | `EAX` | `AX` | `AL` | `AH` |
| `RBX` | `EBX` | `BX` | `BL` | `BH` |
| `RCX` | `ECX` | `CX` | `CL` | `CH` |
| `RDX` | `EDX` | `DX` | `DL` | `DH` |
| `RSI` | `ESI` | `SI` | `SIL` | — |
| `RDI` | `EDI` | `DI` | `DIL` | — |
| `RBP` | `EBP` | `BP` | `BPL` | — |
| `RSP` | `ESP` | `SP` | `SPL` | — |
| `R8`–`R15` | `R8D`–`R15D` | `R8W`–`R15W` | `R8B`–`R15B` | — |

- `mov rax, 6`: menulis 64 bit.
- `mov eax, 6`: menulis 32 bit **dan mengosongkan 32 bit atas RAX**.
- `mov al, 6`: menulis 8 bit bawah sahaja; bit selebihnya dikekalkan.
- `AH`, `BH`, `CH`, `DH` ialah register 8 bit tinggi bagi AX/BX/CX/DX dan ada sekatan pengekodan dengan awalan REX.

## 3. Register khas

| Register | Fungsi |
|---|---|
| `RIP` | Instruction pointer; menunjukkan alamat arahan seterusnya dalam aliran pelaksanaan |
| `RFLAGS` | Flag status CPU, contohnya ZF, CF, SF, OF |

Contoh akses data secara RIP-relative:

```asm
lea rsi, [rip + s1]    # RSI = alamat s1, bukan kandungan teks
mov al, [rsi]          # AL = bait pertama pada alamat RSI
```

`RIP` bukan register umum yang boleh diubah terus menggunakan `mov rip, ...`; kawalan aliran berubah melalui `jmp`, `call`, `ret` dan arahan berkaitan.

## 4. Linux syscall x86-64

| Register | Kandungan ketika `syscall` |
|---|---|
| `RAX` | Nombor syscall |
| `RDI` | Argumen 1 |
| `RSI` | Argumen 2 |
| `RDX` | Argumen 3 |
| `R10` | Argumen 4 |
| `R8` | Argumen 5 |
| `R9` | Argumen 6 |

Selepas `syscall`, `RAX` mengandungi nilai pulangan (atau kod ralat negatif). Arahan `syscall` mengubah `RCX` dan `R11`; jangan bergantung pada nilai lamanya selepas syscall.

### Contoh `write(1, s1, 6)`

```asm
.intel_syntax noprefix
.global _start
.text
_start:
    mov eax, 1             # SYS_write
    mov edi, 1             # stdout
    lea rsi, [rip + s1]   # alamat buffer
    mov edx, 6             # 6 bait
    syscall

    mov eax, 60            # SYS_exit
    xor edi, edi           # status 0
    syscall

.data
s1: .ascii "Hello\n"
```

Nota ringkas: **AX = aksi, DI = destinasi output, SI = sumber, DX = saiz** (ini petua khusus untuk `write`, bukan definisi sejagat setiap register).

## 5. Pemanggilan fungsi biasa (System V AMD64 ABI)

**Berbeza daripada syscall.** Untuk fungsi biasa di Linux x86-64, 6 argumen integer/pointer pertama ialah:

`RDI → RSI → RDX → RCX → R8 → R9`

Nilai pulangan integer/pointer lazimnya dalam `RAX`.

- **Callee-saved:** `RBX`, `RBP`, `R12`, `R13`, `R14`, `R15` (fungsi yang mengubahnya perlu pulihkan sebelum `ret`).
- **Caller-saved:** `RAX`, `RCX`, `RDX`, `RSI`, `RDI`, `R8`, `R9`, `R10`, `R11`.
- `RSP` mesti diurus dengan betul dan dipulihkan; `call` menyimpan alamat pulangan pada stack, `ret` menggunakannya.

## 6. Flags dan conditional jump

`cmp a, b` mengemas kini flags seolah-olah mengira `a - b`, tetapi tidak menyimpan hasil penolakan.

| Jump | Maksud | Jenis |
|---|---|---|
| `je` / `jz` | Sama / zero | Umum |
| `jne` / `jnz` | Tidak sama / nonzero | Umum |
| `jg` | Lebih besar | Signed |
| `jge` | Lebih besar atau sama | Signed |
| `jl` | Lebih kecil | Signed |
| `jle` | Lebih kecil atau sama | Signed |
| `ja` | Above / lebih besar | Unsigned |
| `jae` | Above or equal | Unsigned |
| `jb` | Below / lebih kecil | Unsigned |
| `jbe` | Below or equal | Unsigned |
| `jmp` | Lompat tanpa syarat | — |

## 7. Contoh pengiraan panjang string (runtime)

```asm
.intel_syntax noprefix
.global _start
.text
_start:
    lea rsi, [rip + s1]
    xor edx, edx                # RDX = panjang string (mula 0)
strlen_loop:
    cmp byte ptr [rsi + rdx], 0
    je done
    inc rdx
    jmp strlen_loop
done:
    # RDX = 5 untuk "Hello"
    mov eax, 60
    xor edi, edi
    syscall
.data
s1: .asciz "Hello"         # ada byte NULL selepas 'o'
```

`.asciz` menambah NULL terminator; `.ascii` tidak. String ASCII `"Hello"` panjangnya 5 bait, tetapi `.asciz` memperuntukkan 6 bait termasuk NULL.

## 8. Ringkasan register dan arahan

1. **Register umum:** `RAX RBX RCX RDX RSI RDI RBP RSP R8–R15`.
2. **Pointer arahan:** `RIP`; **pointer stack:** `RSP`.
3. **Syscall:** `RAX | RDI RSI RDX R10 R8 R9`.
4. **Fungsi biasa:** `RDI RSI RDX RCX R8 R9`.
5. **Zero register:** `xor edx, edx` memberi RDX = 0.
6. **Baca bait:** `mov bl, [rdx]`; **ambil alamat:** `lea rdx, [rip + s1]`.
7. **Loop:** `cmp` → conditional jump → `inc` → `jmp`.
8. **Call/return:** `call` → stack; `ret` → kembali.

## 9. Kuiz kendiri

1. Dalam Linux `write`, register manakah menyimpan bilangan bait?
2. Apakah beza `mov al, 6` dengan `mov eax, 6`?
3. Kenapa `RSP` tidak patut digunakan sewenang-wenangnya sebagai pointer string?
4. Untuk `cmp rbx, 10`, arahan apakah yang keluar apabila `rbx >= 10` (signed)?
5. Apakah register keempat bagi argumen Linux syscall? Adakah sama dengan argumen keempat fungsi biasa?

<details>
<summary>Jawapan</summary>

1. `RDX`.
2. `AL` hanya mengubah 8 bit bawah; `EAX` mengubah 32 bit bawah dan mengosongkan 32 bit atas `RAX`.
3. Ia mengawal stack, termasuk `push`, `pop`, `call`, `ret`.
4. `jge`.
5. `R10` untuk syscall; `RCX` untuk fungsi biasa.

</details>
