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
VGA_PTR              equ  0xB80000

global kernel_main

section .text

kernel_main:
    mov byte [VGA_PTR],7
    mov byte [VGA_PTR+1],'Y'
    ret