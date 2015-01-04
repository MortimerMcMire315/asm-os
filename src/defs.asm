%macro beginfun 0
push    ebp
mov     ebp, esp
%endmacro

%macro endfun 0
mov     esp, ebp
pop     ebp
ret
%endmacro
