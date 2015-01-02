VGA_WIDTH  equ 80
VGA_HEIGHT equ 25
VGA_PTR    equ 0xB8000

section .text
global make_vgaentry
global make_color
global strlen
global terminal_init


;===============================================================================
;    PARAMETERS: 
;       byte c - The character to print
;       byte color - The VGA color to use (typically the result of make_color)
;        
;    RETURNS:
;       EAX = the VGA code to write into memory
;===============================================================================
make_vgaentry:
    push    ebp
    mov     ebp, esp

    mov     eax, [ebp+8]    ;eax = char
    mov     ecx, [ebp+12]   ;ecx = color

    shl     ecx, 8
    or      eax, ecx

    mov     esp, ebp
    pop     ebp
    ret

;===============================================================================
;    PARAMETERS:
;        byte fg - The foreground color to use (4 bits)
;        byte bg - The background color to use (3 bits)
;        
;    RETURNS:
;        EAX = complete VGA color code
;===============================================================================
make_color:
    push    ebp
    mov     ebp, esp

    mov     eax, [ebp+8]    ;foreground color
    mov     edx, [ebp+12]   ;background color

    and     eax, 0x0F       ;safeguard
    shl     edx, 4          ;stick the bg color in the higher 4 bits

    or      eax, edx

    mov     esp, ebp
    pop     ebp
    ret

;===============================================================================
;    PARAMETERS:
;        dword ptr = pointer to a null-terminated string.
;        
;    RETURNS:
;        EAX = string length
;===============================================================================
strlen:
    push    ebp
    mov     ebp, esp

    mov     edx, [ebp+8]   ;string pointer
    mov     eax, 0

    .loop:
        cmp     byte [edx+eax], 0
        je      .break
        add     eax, 1
        jmp     .loop

    .break:
    
    mov     esp, ebp
    pop     ebp
    ret

;===============================================================================
;    PARAMETERS:
;        None
;        
;    RETURNS:
;        Nothing, but clears the VGA terminal.
;===============================================================================
terminal_init:
    push    ebp
    mov     ebp, esp
    sub     esp, 8

    %define  term_row  [ebp-4]
    %define  term_col  [ebp-8]
    
    mov     dword term_row, 0
    mov     dword term_col, 0
    
    ;Get the proper VGA color value
    push    dword 1
    push    dword 15
    call    make_color
    add     esp, 8

    ;Combine with a character value
    push    dword eax
    push    dword '@'
    call    make_vgaentry
    add     esp, 8

    mov     ecx, eax

    ;ECX contains the VGA character/color value

    .l1:
        ;EAX = term_row * VGA_WIDTH
        mov eax, term_row
        imul eax, VGA_WIDTH

        .l2:
            mov edx, term_col
            add edx, eax

            ;Multiply by 2, because there are 2 bytes for every cell.
            imul edx, 2

            mov word [VGA_PTR+edx], cx

            add dword term_col, 1
            cmp dword term_col, VGA_WIDTH
            jl .l2

        add dword term_row, 1
        mov dword term_col, 0
        cmp dword term_row, VGA_HEIGHT
        jl .l1

    mov esp, ebp
    pop ebp
    ret

    %undef term_row
    %undef term_col
    %undef color
