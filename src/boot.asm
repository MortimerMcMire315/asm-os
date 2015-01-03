BITS 32

;Multiboot header constants
MBALIGN     equ     1<<0                ;align modules on page boundaries
MEMINFO     equ     1<<1                ;provide memory map
FLAGS       equ     MBALIGN | MEMINFO   
MAGIC       equ     0x1BADB002          ;Bootloader can find the header
CHECKSUM    equ     -(MAGIC + FLAGS)    

;Bootloader will search for this magic sequence and recognize a multiboot kernel.
section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .data
    st:     db  'The quick brown fox jumps over the lazy dog',0

;Allocate room for a small temporary stack with 16384 bytes.
section .bootstrap_stack
    align 4
    stack_bottom:
        times 16384 db 0

    stack_top:

section .text
    global _start
    extern vga_cls
    extern vga_writestring
    extern vga_writestring_withcolor
    extern vga_put_dec
    extern vga_put_newline
    extern vga_put_unsigned_hex
    extern map_mem


kernel_main:
    ret

_start:
    mov esp, stack_top

    push    dword ebx
    call    map_mem
    add     esp, 4

    call kernel_main

    cli

.hang:
    hlt
    jmp .hang
