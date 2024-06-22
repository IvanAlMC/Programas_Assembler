%include "asm_io.inc"

LINE_FEED   equ 10

;Macro para generar un numero aleatorio de 0 a 100
%macro generate_random 0
    pusha
    mov     ecx, 0xff
    rdtsc
    xor     edx, edx
    and     eax, ecx
    imul    eax, 100
    mov     edi, eax
    idiv    ecx
    mov     [number], eax
    jmp     print_rand  ;Jump to label to print the previos result
    popa
%endmacro

;Macro para leer un string (nombre)
%macro read_string 2
    pusha                   ; It saves the general purpose registers information on the stack.
    mov     edi, %1         ; move the first parameter to edi register
    mov     ecx, %2         ; move the second parameter to ecx register
%%loopstrstart:             ; declare a loop to continue to the next char input
    call    read_char       ; read the actual char input
    cmp     al, LINE_FEED   ; compare if the char is an Enter
    je      %%loopstrend    ; if the previos instruction is an enter, jump to end loop
    mov     [edi], al       ; else, move the value in al to register edi's memory position
    inc     edi             ; increment a memory position in edi
    loop    %%loopstrstart  ; we start again the start loop
%%loopstrend:               ; declare a loop when we recive a enter char in the  10 line
    mov     byte [edi], 0   ; move the zero value to the edi's memory position
    popa                    ; It extracts the information from the stack and puts it in the registers.
%endmacro          

segment .data

msg_game    db "El juego de adivinar un numero", 0

msg_request db "Por favor ingresa tu nombre: ", 0
msg_hello   db "Hola ",10, 0
msg_input   db "Adivina el numero del 0 al 100! Ingresalo por favor: ", 0
msg_win     db "Adivinaste el numero! GANASTE!", 0
msg_low     db "El número secreto es menor al que digitaste", 0
msg_up      db "El numero secreto es mayor al que dijitaste", 0
msg_exit    db "Gracias por jugar, hasta pronto", 0
msg_count   db "El numero de intentos fue: ", 0
msg_rand    db "El numero aleatorio es: ", 0

segment .bss

number resd 1   ;Varibale para guardar el numero aleatorio
input  resd 1   ;Variable para guardar el numero ingresado
name   resd 22  ;Variable para guardar el nombre
count  resd 1   ;variable para contar intentos

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

        mov     eax, msg_game
        call    print_string
        call    print_nl
        
        call    print_nl

        mov     eax, msg_request
        call    print_string
        call    print_nl

        call    read_char           ;read char when continue the program
        read_string name, 20        ;Use the macro to read a String

        ;Mensaje de bienvenida
        mov     eax, msg_hello
        call    print_string
        mov     eax, name
        call    print_string
        call    print_nl

        call    print_nl

        ;Generamos nuestro numero aleatorio

        mov     eax, msg_rand
        call    print_string
        generate_random

print_rand:
        call    print_int           ;Print the random number
        call    print_nl            ;print next line
        call    print_nl

        mov     dword [count], 0

game:
        ;Se suma a uno por el intento
        add     dword [count], 1

        ;Se pide al usuario que ingrese el numero
        mov     eax, msg_input
        call    print_string
        call    print_nl

        ;Se leer el numero y se guarda en la variable input
        call    read_int
        mov     dword [input], eax

        ;Se mueve el valor de number a eax, para luego comparar
        mov     eax, dword[number]

        ;Se hacen las comparaciones necesarias
        cmp     eax, dword [input]
        jl     number_lower
        cmp     eax, dword [input]
        jg     number_upper
        cmp     eax, dword [input]
        je      win

;Si el numero ingresado es menor al secreto
number_lower:
        ;Mensaje para este caso
        mov     eax, msg_low
        call    print_string
        call    print_nl
        call    print_nl 
        jmp     game      

;Si el numero ingresado es mayor al secreto
number_upper:
        ;Mensaje para este caso
        mov     eax, msg_up
        call    print_string
        call    print_nl
        call    print_nl
        jmp     game
;Si el numero ingresado es igual al secreto
win:

        call    print_nl
        ;Mensaje para este caso
        mov     eax, msg_win
        call    print_string
        call    print_nl

        mov     eax, msg_count
        call    print_string
        mov     eax, [count]
        call    print_int
        call    print_nl
        call    print_nl

;Finaliza
end:
        ;Mensaje de despedida
        mov     eax, msg_exit
        call    print_string
        call    print_nl

        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret