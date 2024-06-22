%include "asm_io.inc"

segment .data

msg_winner db "El ganador es: ",0

msg_removed     db " ha sido eliminado de la lista.", 0

msg_bye db "Un gusto jugar, adios!", 0

timeval:
    tv_sec  dd 0
    tv_usec dd 0

msg_game    db "Juego del zapatico cochinito", 0

; Definir el diccionario de nombres
names dd name1, name2, name3, name4, name5
name1 db "Juan", 0
name2 db "Victor", 0
name3 db "Andrea", 0
name4 db "Laura", 0
name5 db "Nicolas", 0


; Definir el diccionario del estribillo
estribillo dd p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14
p1 db "Za", 0
p2 db "pa", 0
p3 db "ti", 0
p4 db "co", 0
p5 db "co", 0
p6 db "chi", 0
p7 db "ni", 0
p8 db "to", 0
p9 db "cam", 0
p10 db "bia", 0
p11 db "de", 0
p12 db "pie", 0
p13 db "ci", 0
p14 db "to", 0

; Mensajes a mostrar
msg_show_players    db "Los jugadores son: ", 0
msg_last_player     db "El seleccionado de la ronda es: ", 0
msg_round     db "Nueva ronda: ", 0


segment .bss

selected_name resd 1 ; Variable para almacenar el seleccionado de ronda
num_names resd 1    ;Variable para almacenar la cantidad de nombres para los comienzos de rondas
res_num_names resd 1 ;Variable para almacenar la cantidad de nombres para los finales de rondas (cuando alguien va a salir)
current_player resd 1

segment .text
        global  asm_main
asm_main:
        enter   0,0               
        pusha

start:

        call    print_nl

        mov     eax, msg_game
        call    print_string
        call    print_nl

        call    print_nl

        mov     ecx, 5

        mov     esi, names   ; Puntero al inicio del diccionario
        mov     edi, 0       ; Índice inicial

        mov     eax, msg_show_players   ;Mensaje para mostrar jugadores
        call    print_string
        call    print_nl

        call    print_nl

loop_names:
        ; Acceder al nombre actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada nombre es 4 bytes
        call    print_string
        call    print_nl
    
        inc     edi        ; Incrementar el índice
    
        loop loop_names  ; Volver al principio del bucle hasta que ecx llegue a 0

        call    print_nl

        mov     dword [num_names], 6
        mov     dword [res_num_names], 5
        mov     dword [current_player], 0

go_round:

        call    print_nl
        call    print_nl
        mov     eax, msg_round
        call    print_string
        call    print_nl
        call    print_nl

        mov     ecx, 14

        mov     esi, estribillo   ; Puntero al inicio del diccionario
        mov     edi, 0       ; Índice inicial



loop_estribillo:

        ; Acceder al la parte del estribillo actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada parte del estribillo es 4 bytes
        call    print_string
        call    print_nl

        inc     edi        ; Incrementar el índice

        ; Pausa de 1 segundo
        mov     ebx, 2000000000   ; Establecer el valor de ebx para el bucle delay_loop
    delay_loop:
        dec     ebx
        jnz     delay_loop

        loop loop_estribillo  ; Volver al principio del bucle hasta que ecx llegue a 0

        call    print_nl

        mov     ecx, 14              ; Establecer el número de iteraciones
        mov     esi, names           ; Puntero al diccionario de nombres
        mov     edx, dword [current_player]; Inicializar el índice en 0 (nombre1 = Juan)

        call    print_nl


loop_start:

        ; Obtener el nombre correspondiente al índice actual
        mov     edi, selected_name        ; Puntero a la variable selected_name
        mov     eax, [esi + edx * 4]
        mov     [edi], eax

        ; Incrementar el índice del nombre
        inc     edx
        cmp     edx, dword [num_names]      ; Número total de nombres
        jl      continue_loop         ; Saltar a continue_loop si no hemos terminado

        ; Reiniciar el índice del nombre
        xor     edx, edx

continue_loop:
        ; Decrementar el contador de iteraciones
        dec     ecx
        cmp     ecx, 0
        jne     loop_start

        ; Imprimir el último nombre
        mov     eax, msg_last_player
        call    print_string
        mov     eax, dword [selected_name]
        call    print_string
        call    print_nl

        ; Eliminar al jugador seleccionado de la lista de nombres
        mov     ecx, dword [num_names]     ; Tamaño de la lista de nombres
        mov     esi, names           ; Puntero al diccionario de nombres
        mov     edi, 0               ; Índice inicial

        ; Buscar el índice del jugador seleccionado en la lista de nombres
find_player:
        ; Comparar el nombre actual con el jugador seleccionado
        mov     eax, [esi + edi * 4]
        cmp     eax, dword [selected_name]
        je      player_found         ; Saltar a player_found si se encuentra el jugador

        inc     edi                  ; Incrementar el índice
        jmp     find_player          ; Volver a buscar en la siguiente posición

player_found:
        ; Intercambiar el jugador encontrado con el último jugador de la lista
        mov     ebx, [esi + (ecx - 1) * 4]  ; Obtener el último nombre de la lista
        mov     [esi + edi * 4], ebx        ; Colocar el último nombre en la posición del jugador encontrado


        ;Imprimir mensaje de jugador eliminado
        mov     eax, dword [selected_name]
        call    print_string    ; Imprimir el nombre del jugador eliminado
        mov     eax, msg_removed
        call    print_string
        call    print_nl

        mov     dword [current_player], edx

        cmp   dword [num_names], 2 ; Verificar sea la ultima ronda
        je    end_game             ; Saltar a end_game si lo es
        jmp   go_round             ; Saltar a go_round si no lo es

end_game:
        ; Obtener el nombre correspondiente al índice actual
        mov     edi, selected_name        ; Puntero a la variable last_name
        mov     eax, [esi + edx * 4]
        mov     [edi], eax
        ; Imprimir mensaje de ganador
        call    print_nl
        mov     eax, msg_winner
        call    print_string
        mov     eax, dword [selected_name]
        call    print_string
        call    print_nl
        jmp     end_program

end_program:
        ;Imprimir mensaje de salida
        call    print_nl

        mov     eax, msg_bye
        call    print_string
        call    print_nl

        popa
        mov     eax, 0
        leave
        ret
