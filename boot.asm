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

;Allocate room for a small temporary stack with 16384 bytes.
section .bootstrap_stack
align 4
stack_bottom:
    times 16384 db 0

stack_top:

section .text
global _start
_start:

    mov esp, stack_top
    extern kernel_main
    call kernel_main

    cli

.hang:
    hlt
    jmp .hang
