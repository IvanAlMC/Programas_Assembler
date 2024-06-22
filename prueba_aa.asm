;
; file: skel.asm
; This file is a skeleton that can be used to start assembly programs.

%include "asm_io.inc"
section .data
    mensaje db 'Hola,', 0Ah, 'mundo!', 0

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

_start:
    ; Imprimir el mensaje
        mov eax, mensaje                   ; El número de la llamada al sistema para escribir en la salida estándar (stdout)
        call print_string


        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret