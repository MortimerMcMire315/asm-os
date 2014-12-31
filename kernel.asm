;kernel.asm

bits 32
section .text
        ;GRUB multiboot specification
        align 4
        dd 0x1BADB002       ;GRUB magic number
        dd 0x00             ;flags
        dd - (0x1BADB002 + 0x00) ;checksum


global start
extern kmain

start:
    cli
    call kmain
    hlt
