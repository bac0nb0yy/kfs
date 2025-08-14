; NASM syntax, 32-bit
BITS 32

SECTION .multiboot
align 4
    ; Multiboot v1 header: magic, flags=0, checksum
    dd 0x1BADB002
    dd 0x0
    dd -(0x1BADB002 + 0x0)

SECTION .text
global multiboot_entry
extern kernel_main

multiboot_entry:
    ; GRUB already put us in 32-bit protected mode with a flat GDT.
    call kernel_main
.hang:
    hlt
    jmp .hang
