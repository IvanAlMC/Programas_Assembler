%include "asm_io.inc"
segment .data

msg_options db "Ingresa la cantidad de N numeros de la serie fibonacii que quiere generar: ", 0
msg_input db "Ingresaste el numero: "
msg_sum db "La suma de los N digitos es: "

segment .bss

guess resd  1
previous resd 1
sum resd 1


segment .text
        global  asm_main
        
asm_main:
        enter   0,0               ; setup routine
        pusha

        mov eax, msg_options
        call print_string
        call print_nl

        mov eax, msg_input
        call print_string

        call read_int
        sub eax, 2
        mov ecx, eax
        call print_nl

        mov eax, 0
        call print_int
        call print_nl

        mov eax, 1
        call print_int
        call print_nl

        mov dword [guess], 1
        mov dword [previous], 0
        mov dword [sum], 1

loop_f:

        mov eax, [guess]      ;eax = 1
        add eax, [previous]   ;eax = 1+1 = 2
        call print_int
        call print_nl

        mov ebx, [guess]      ;ebx = 1

        mov dword [previous], ebx   ;prev=1
        mov dword [guess], eax      ;guess=1
        
        add dword [sum], eax

        loop loop_f


        mov eax, msg_sum
        call print_string

        mov eax, [sum]
        call print_int
        call print_nl

        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret