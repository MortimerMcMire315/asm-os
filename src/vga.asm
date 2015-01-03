VGA_PTR        equ  0xB8000
VGA_WIDTH      equ  80
VGA_HEIGHT     equ  25
BLACK          equ  0
BLUE           equ  1
GREEN          equ  2
CYAN           equ  3
RED            equ  4
MAGENTA        equ  5
BROWN          equ  6
LIGHT_GREY     equ  7
DARK_GREY      equ  8
LIGHT_BLUE     equ  9
LIGHT_GREEN    equ  10
LIGHT_CYAN     equ  11
LIGHT_RED      equ  12
LIGHT_MAGENTA  equ  13
LIGHT_BROWN    equ  14
WHITE          equ  15

section .bss
    align 4
    global_term_row:    resd 1
    global_term_col:    resd 1

section .text
global make_vgaentry
global make_color
global strlen
global terminal_cls
global terminal_putentryat
global terminal_writestring
global terminal_writestring_withcolor
global terminal_putchar
global terminal_put_number


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
terminal_cls:
    push    ebp
    mov     ebp, esp
    sub     esp, 8

    %define  term_row  [ebp-4]
    %define  term_col  [ebp-8]
    
    mov     dword term_row, 0
    mov     dword term_col, 0
    
    ;Get the proper VGA color value
    push    dword BLACK
    push    dword LIGHT_GREY
    call    make_color
    add     esp, 8

    ;Combine with a character value
    push    dword eax
    push    dword ' '
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

    mov    dword [global_term_row], 0
    mov    dword [global_term_col], 0

    %undef term_row
    %undef term_col
    %undef color

    mov esp, ebp
    pop ebp
    ret

;===============================================================================
;    PARAMETERS:
;       char c - The character to print
;       int16 color - The VGA color to use
;       int term_row
;       int term_col
;        
;    RETURNS:
;       Nothing, but puts the character on the screen.       
;===============================================================================
terminal_putentryat_withvgacolor:
    push    ebp
    mov     ebp, esp

    %define char  [ebp+8]
    %define color [ebp+12]
    %define row   [ebp+16]
    %define col   [ebp+20]

    ;EAX = VGA entry for the color/char combo
    push    dword color
    push    dword char
    call    make_vgaentry
    add     esp, 8

    ;EDX = index at which to write
    mov     edx, row
    imul    edx, VGA_WIDTH
    add     edx, col
    imul    edx, 2  ;2 bytes per cell!

    ;Write the character
    mov     [edx+VGA_PTR], eax

    %undef  char
    %undef  color
    %undef  row
    %undef  col

    mov      esp, ebp
    pop      ebp
    ret

;===============================================================================
;    PARAMETERS:
;       char c - The character to print
;       int fgcolor - The foreground color to use
;       int bgcolor - The background color to use
;       int term_row
;       int term_col
;
;    RETURNS:
;===============================================================================
terminal_putentryat:
    push    ebp
    mov     ebp, esp

    %define c           [ebp+8]
    %define fgcolor     [ebp+12]
    %define bgcolor     [ebp+16]
    %define term_row    [ebp+20]
    %define term_col    [ebp+24]

    push    dword bgcolor
    push    dword fgcolor
    call    make_color
    add     esp, 8

    push    dword term_col
    push    dword term_row
    push    eax
    push    dword c
    call    terminal_putentryat_withvgacolor
    add     esp, 16

    %undef c
    %undef fgcolor
    %undef bgcolor
    %undef term_row
    %undef term_col

    mov     esp, ebp
    pop     ebp
    ret


;===============================================================================
;    PARAMETERS:
;        None
;        
;    If the global cursor is outside of the VGA width, move it to the first
;    column of the next row. If it is outside of the VGA height, move it to the
;    first column of the screen.
;===============================================================================
check_global_cursor_loc:
        push    ebp
        mov     ebp, esp

        cmp     dword [global_term_col], VGA_WIDTH
        jl      .checkrow

        mov     dword [global_term_col], 0
        mov     edx,  [global_term_row]
        inc     edx
        mov     dword [global_term_row], edx

    .checkrow:
        cmp     dword [global_term_row], VGA_HEIGHT
        jl      .end

        mov     dword [global_term_row], 0

    .end:
        mov     esp, ebp
        pop     ebp
        ret

;===============================================================================
;    PARAMETERS:
;        char c - the character to write
;        
;    Plots a character at the global terminal row and column.
;===============================================================================
terminal_putchar:
        push    ebp
        mov     ebp, esp

        %define char [ebp+8]

        push    dword [global_term_col]
        push    dword [global_term_row]
        push    dword BLACK
        push    dword LIGHT_GREY
        push    dword char
        call    terminal_putentryat
        add     esp, 20

        ;increase the global terminal column.
        mov     dword edx, [global_term_col]
        add     edx, 1
        mov     dword [global_term_col], edx

        call    check_global_cursor_loc

        mov     esp, ebp
        pop     ebp

        %undef char
        ret

;===============================================================================
;    PARAMETERS:
;        char c - the character to write
;        byte fgcolor - the foreground color
;        byte bgcolor - the background color
;        
;    Plots a character with the given colors at the global terminal row and col.
;===============================================================================
terminal_putchar_withcolor:
        push    ebp
        mov     ebp, esp

        push    dword [global_term_col]
        push    dword [global_term_row]
        push    dword [ebp+16]
        push    dword [ebp+12]
        push    dword [ebp+8]
        call    terminal_putentryat
        add     esp, 20

        mov     dword edx, [global_term_col]
        add     edx, 1
        mov     dword [global_term_col], edx

        call    check_global_cursor_loc

        mov     esp, ebp
        pop     ebp

        ret

;===============================================================================
;    PARAMETERS:
;        char* string - A pointer to the string to write
;        
;    Plots the string at the global terminal row and column.
;===============================================================================
terminal_writestring:
        push    ebp
        mov     ebp, esp

        %define string_ptr [ebp+8]

    .l1:
        mov     eax, string_ptr
        cmp     byte [eax], 0
        je      .end

        and     ebx, 0
        mov     byte bl, [eax]
        push    dword ebx
        call    terminal_putchar
        add     esp, 4

        add     dword string_ptr, 1
        jmp     .l1

    .end:
        mov     esp, ebp
        pop     ebp
    
        %undef string_ptr

        ret

;===============================================================================
;    PARAMETERS:
;        char* string - A pointer to the string to write
;        byte fgcolor - Foreground color
;        byte bgcolor - Background color
;        
;===============================================================================
terminal_writestring_withcolor:
        push    ebp
        mov     ebp, esp

        %define string_ptr [ebp+8]

    .l1:
        mov     eax, string_ptr
        cmp     byte [eax], 0
        je      .end

        and     ebx, 0
        mov     byte bl, [eax]
        push    dword [ebp+16]
        push    dword [ebp+12]
        push    dword ebx
        call    terminal_putchar_withcolor
        add     esp, 12

        add     dword string_ptr, 1
        jmp     .l1

    .end:
        %undef string_ptr

        mov     esp, ebp
        pop     ebp
        ret

;===============================================================================
;    PARAMETERS:
;        int number - The number to print
;        int row 
;        int col
;===============================================================================
terminal_put_number:
    push    ebp
    mov     ebp, esp
    
    sub     esp, 4

    %define num [ebp+8]
    %define row [ebp+12]
    %define col [ebp+16]
    %define counter [ebp-4]

    mov     eax, num
    cmp     eax, 0
    jge     .realbegin

    push    eax
    push    dword '-'
    call    terminal_putchar
    add     esp, 4
    pop     eax
    neg     eax

 .realbegin:
    mov     dword counter, 0  ;counter
    mov     ebx, 10

 .divloop:
    cdq
    div     ebx
    push    dword edx
    add     dword counter, 1
    cmp     eax, 0
    jne     .divloop

 .printloop:
    pop     eax
    add     eax, 48

    push    eax
    call    terminal_putchar
    add     esp, 4

    sub     dword counter, 1
    mov     dword ecx, counter
    cmp     ecx, 0
    jne     .printloop

    %undef  num
    %undef  row
    %undef  col
    %undef  counter

    mov     esp, ebp
    pop     ebp
    ret
