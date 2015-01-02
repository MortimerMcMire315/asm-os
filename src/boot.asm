;Multiboot header constants
MBALIGN     equ     1<<0                ;align modules on page boundaries
MEMINFO     equ     1<<1                ;provide memory map
FLAGS       equ     MBALIGN | MEMINFO   
MAGIC       equ     0x1BADB002          ;Bootloader can find the header
CHECKSUM    equ     -(MAGIC + FLAGS)    

COLOR_BLACK          equ  0
COLOR_BLUE           equ  1
COLOR_GREEN          equ  2
COLOR_CYAN           equ  3
COLOR_RED            equ  4
COLOR_MAGENTA        equ  5
COLOR_BROWN          equ  6
COLOR_LIGHT_GREY     equ  7
COLOR_DARK_GREY      equ  8
COLOR_LIGHT_BLUE     equ  9
COLOR_LIGHT_GREEN    equ  10
COLOR_LIGHT_CYAN     equ  11
COLOR_LIGHT_RED      equ  12
COLOR_LIGHT_MAGENTA  equ  13
COLOR_LIGHT_BROWN    equ  14
COLOR_WHITE          equ  15
VGA_PTR              equ  0xB8000

;Bootloader will search for this magic sequence and recognize a multiboot kernel.
section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .data
    st:     db  'String!!!',0

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
    extern terminal_init

kernel_main:
    ;push    dword st
    ;call    strlen
    ;add     esp, 4

    ;push    eax     ;String length

    ;push    dword 0
    ;push    dword 11
    ;call    make_color
    ;add     esp, 8

    ;pop     edx     ;String length
    ;add     edx, 48

    ;push    dword eax
    ;push    dword edx

    ;call    make_vgaentry
    ;add     esp, 8
    ;
    ;mov     word [VGA_PTR], ax

    call    terminal_init

    ret

_start:

    mov esp, stack_top
    call kernel_main

    cli

.hang:
    hlt
    jmp .hang
