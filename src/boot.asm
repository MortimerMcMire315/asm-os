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
    extern make_vgaentry
    extern make_color
    extern strlen
    extern terminal_cls
    extern terminal_putentryat
    extern terminal_writestring
    extern terminal_putchar
    extern terminal_writestring_withcolor


kernel_main:
    call    terminal_cls

    push    dword 0
    push    dword 10
    push    dword st
    call    terminal_writestring_withcolor
    add     esp, 12

    push    dword 0
    push    dword 3
    push    dword st
    call    terminal_writestring_withcolor
    add     esp, 12

    ret

_start:

    mov esp, stack_top
    call kernel_main

    cli

.hang:
    hlt
    jmp .hang
