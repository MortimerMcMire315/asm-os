%include "src/defs.asm"

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

    st_mmap:           db  '===Memory Map===',0
    st_mmap_size:      db  'size:           ',0
    st_mmap_base_low:  db  'base_addr_low:  ',0
    st_mmap_base_high: db  'base_addr_high: ',0
    st_mmap_len_low:   db  'length_low:     ',0
    st_mmap_len_high:  db  'length_high:    ',0
    st_mmap_type:      db  'type:           ',0

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
    beginfun
    mov     edx, [ebp+8]

    ;push    dword edx
    ;call    dump_multiboot_info
    ;add     esp, 4

    add     edx, 44 ;location of mmap_length
    push    dword [edx]
    add     edx, 4
    push    dword [edx] ;location of mmap_addr
    call    dump_memorymaps
    add     esp, 4

    endfun

;===============================================================================
;    PARAMETERS:
;        memory_map* mmap_addr
;        int mmap_length
;        
;    RETURNS:
;        The number of memory map entries to expect
;===============================================================================
dump_memorymaps:
    beginfun
    sub     esp, 4
    %define mmap_start [ebp-4]

    mov     edx, [ebp+8]

    mov     mmap_start, edx

    %macro mmap_info_line 3
    push    edx
    push    dword [%1]
    push    dword st_mmap_%3
    call    vga_writestring
    add     esp, 4
    call    vga_put_%2
    add     esp, 4
    call    vga_put_newline
    pop     edx
    %endmacro

    %macro mmap_info 0
    mmap_info_line  edx,    dec,          size
    mmap_info_line  edx+4,  unsigned_hex, base_low
    mmap_info_line  edx+8,  unsigned_hex, base_high
    mmap_info_line  edx+12, unsigned_hex, len_low
    mmap_info_line  edx+16, unsigned_hex, len_high
    mmap_info_line  edx+20, unsigned_hex, type
    %endmacro

    ;while edx < mmap_length:
    .l1:
        ;if(EDX - mmap_start) >= mmap_length, jump out of the loop.
        mov     ecx, edx
        sub     ecx, mmap_start

        cmp     ecx, [ebp+12]
        jae     .endloop

        push    dword edx
        call    is_usable_mem

        cmp     eax, 1
        jne     .noprint

        mmap_info_line edx+4, unsigned_hex, base_low
        mmap_info_line edx+12, unsigned_hex, len_low
        mmap_info_line edx+20, unsigned_hex, type
        call    vga_put_newline
        pop     edx

    .noprint:
        mov     ecx, [edx]
        add     edx, 4
        add     edx, ecx  ;EDX += this_mmap->size
        jmp     .l1

    .endloop:

    endfun

;===============================================================================
;    PARAMETERS:
;       mmap_struct* m;
;        
;    RETURNS:
;       EAX = 1 if the described memory segment is deemed usable.
;===============================================================================
is_usable_mem:
    beginfun
    mov     eax, [ebp+8]
    mov     eax, [eax+20]
    cmp     eax, 1
    je      .end

    .false:
    mov     eax, 0

    .end:

    endfun

dump_multiboot_info:
    beginfun
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

    %macro multibootline 3
        push    edx
        push    dword %3
        call    vga_writestring
        add     esp, 4
        pop     edx
        push    edx
        mov     eax, [%1]
        push    dword eax
        call    vga_put_%2
        add     esp, 4
        call    vga_put_newline
        pop     edx
    %endmacro

    multibootline  flags,        unsigned_hex, st_flags
    multibootline  mem_lower,    unsigned_hex, st_mem_lower
    multibootline  mem_upper,    unsigned_hex, st_mem_upper
    multibootline  boot_device,  unsigned_hex, st_boot_device
    multibootline  cmdline,      unsigned_hex, st_cmdline
    multibootline  mods_count,   unsigned_hex, st_mods_count
    multibootline  mods_addr,    unsigned_hex, st_mods_addr
    multibootline  mmap_length,  dec,          st_mmap_length
    multibootline  mmap_addr,    unsigned_hex, st_mmap_addr

    %undef flags
    %undef mem_lower
    %undef mem_upper
    %undef boot_device
    %undef cmdline
    %undef mods_count
    %undef mods_addr
    %undef mmap_length
    %undef mmap_addr

    endfun
