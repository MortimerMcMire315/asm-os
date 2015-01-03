BITS 32

MEM_MAGIC_EAX   equ     0xE820
MEM_MAGIC_EDX   equ     0x534D4150

section .bss
    align 4
    memmap_buffer:  resb 4096

section .data
    st:     db           'Here!',0
    st_flags:        db  'flags:        ',0
    st_mem_lower:    db  'mem_lower:    ',0
    st_mem_upper:    db  'mem_upper:    ',0
    st_boot_device:  db  'boot_device:  ',0
    st_cmdline:      db  'cmdline:      ',0
    st_mods_count:   db  'mods_count:   ',0
    st_mods_addr:    db  'mods_addr:    ',0
    st_mmap_length:  db  'mmap_length:  ',0
    st_mmap_addr:    db  'mmap_addr:    ',0

section .text
    global map_mem
    extern vga_put_unsigned_hex
    extern vga_put_newline
    extern vga_putchar
    extern vga_writestring
    extern vga_put_dec

;===============================================================================
;    PARAMETERS:
;        multiboot_info_t* mbt
;        int magic
;===============================================================================
map_mem:
    push    ebp
    mov     ebp, esp

    ;EDX = &mbt
    mov     edx, [ebp+8]
    %define  flags        edx
    %define  mem_lower    edx+4
    %define  mem_upper    edx+8
    %define  boot_device  edx+12
    %define  cmdline      edx+16
    %define  mods_count   edx+20
    %define  mods_addr    edx+24
    %define  mmap_length  edx+44
    %define  mmap_addr    edx+48

    push    edx
    push    dword st_flags
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [flags]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_mem_lower
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [mem_lower]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_mem_upper
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [mem_upper]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_boot_device
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [boot_device]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_cmdline
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [cmdline]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_mods_count
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [mods_count]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_mods_addr
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [mods_addr]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_mmap_length
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [mmap_length]
    push    dword eax
    call    vga_put_dec
    add     esp, 4
    call    vga_put_newline
    pop     edx

    push    edx
    push    dword st_mmap_addr
    call    vga_writestring
    add     esp, 4
    pop     edx
    push    edx
    mov     eax, [mmap_addr]
    push    dword eax
    call    vga_put_unsigned_hex
    add     esp, 4
    call    vga_put_newline
    pop     edx

    mov     esp, ebp
    pop     ebp
    ret
