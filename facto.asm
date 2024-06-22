%include "asm_io.inc"
segment .data

msg_options db "Ingresa el numero desde el cual desea generar el factorial: ", 0
msg_input db "Ingresaste el numero: ", 0
msg_ans db "El resultado del la operacion factoral del numero ingresado es: ", 0
msg_x   db " x ", 0
msg_equ db " = ", 0

segment .bss

number resd 1 ;Variable para guardar el numero ingresado por el usuario
answer resd 1 ;Variable para ir guandando el resultado de la multiplicacion


segment .text
        global  asm_main
        
asm_main:
        enter   0,0               ; setup routine
        pusha

        ;Mostrar el mensaje inicial
        mov eax, msg_options    
        call print_string
        call print_nl

        ;Mostrar mensaje para pedir el numero
        mov eax, msg_input
        call print_string

        ;Leer el numero ingresado
        call    read_int

        ;Validamos los casos si se ingresa 0 o 1 [si es el caso, saltamos a la etiqueta para estos caso]
        cmp     eax, 1
        je      facto_oz
        cmp     eax, 0
        je      facto_oz

        ;Guardamos el numero ingresado en las variables
        mov     dword [answer], eax
        sub     eax, 1
        mov     dword [number], eax

        mov     ecx, dword [number]

loop_facto:
        ;Loop para hacer el factorial

        ;Mostramos el resultado
        mov     eax, dword [answer]
        call    print_int

        ;Mostramos el " x "
        mov     eax, msg_x
        call    print_string

        ;Mostramos la iteracion
        mov     eax, ecx
        call    print_int

        ;Mostramos el " = "
        mov     eax, msg_equ
        call    print_string

        ;Mostramos la respuesta
        mov     eax, dword [answer]
        mul     ecx

        call    print_int
        call    print_nl

        mov     dword [answer], eax

        loop loop_facto

        ;Mostramos el resultado final
        mov     eax, msg_ans
        call    print_string
        mov     eax, dword [answer]
        call    print_int
        call    print_nl

facto_oz:
        ;Caso para validar el 1 o 0

        ;Imprimimos el numero ingresado
        call    print_int

        ;Imprimimos el " x "
        mov     eax, msg_x
        call    print_string

        ;Imprimimos el 1
        mov     eax, 1
        call    print_int

        ;Imprimimos el " = "
        mov     eax, msg_equ
        call    print_string

        ;Mostramos el resultado 1
        mov     eax, 1
        call    print_int
        call    print_nl

        ;Mostramos la respuesta final
        mov     eax, msg_ans
        call    print_string
        mov     eax, 1
        call    print_int
        call    print_nl

        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret