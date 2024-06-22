%include "asm_io.inc"

LINE_FEED   equ 10

%macro generate_random 1
    pusha
    mov     ecx, 0xff
    rdtsc
    xor     edx, edx
    and     eax, ecx
    imul    eax, %1
    mov     edi, eax
    idiv    ecx
    mov     [number], eax
    popa
%endmacro

%macro request_continue_or_exit 0
    pusha

%%request:
    mov     eax, msg_exit     ; print the exit request message
    call    print_string

%%again:
    call    read_char           ; read integer the request teh exit or not

    cmp     al, LINE_FEED       ; compare if the char is an Enter
    je      %%again
    cmp     al, 'n'             ; Compare eax with n (in this case), to do the brach
    je      end_program         ; if the previous compare is zero, the program finish
    cmp     al, 'y'             ; Compare eax with y (in this case), to do the brach
    je      start               ; if the previous compare is y, the program continue
    cmp     al, 'N'             ; Compare eax with n (in this case), to do the brach
    je      end_program         ; if the previous compare is zero, the program finish
    cmp     al, 'Y'             ; Compare eax with y (in this case), to do the brach
    je      start               ; if the previous compare is y, the program continue
    jmp     %%option_exit_nv    ; if user in other char go to option_exit_nv label
%%option_exit_nv:
    mov     eax, msg_option_nv   ; print the error option no valid
    call    print_string 
    call    print_nl             ;print next line
    jmp     %%request     ;go macro to request exit or not
    popa
%endmacro

    segment .data

msg_exit db     "Choose an option: Exit (n) or Continue (y): ", 0       ;message to request an option
msg_option_nv db "Option no valid, please try again", 0    ;Message to option no valid
msg_winner db "El ganador es: ",0
msg_input db "Ingrese el numero del jugador a iniciar", 0

msg_removed     db " ha sido eliminado de la lista.", 0
msg_change     db " ha cambiado de pie.", 0

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
msg_first_player     db "El primer jugador es: ", 0


segment .bss

selected_name resd 1 ; Variable para almacenar el seleccionado de ronda
num_names resd 1    ;Variable para almacenar la cantidad de nombres para los comienzos de rondas
res_num_names resd 1 ;Variable para almacenar la cantidad de nombres para los finales de rondas (cuando alguien va a salir)
current_player resd 1 ;Toma el indice del jugador seleccionado de la ronda (si cambia de pie) o del siguiente (si sale)
last_name resd 1    ; Variable para almacenar el seleccionado de ronda
ind_player resd 1   ;Variable para almacenar el indice de un jugador
cc_round resd 1     ; Vairable para contar las rondas de cambio de pie
ind_final_cf resd 1 ;Variable para almacenar el ultimo indice para el cambio de pie
ind_first resd 1    ;Variable para contener el indice del primer jugador
number resd 1       ;Almacena el aleatorio generado
input_player resd 1 ;Variable que ingresa el usuario, para el jugador que selecciona

segment .text
        global  asm_main
asm_main:
        enter   0,0               
        pusha

start:
      ;  generate_random 4     ;Go to gern_random macro

     ;   mov     eax, dword [number]
      ;  call    print_nl

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

        mov     dword [ind_final_cf], 0  ;Aca se inicializar el jugador a comenzar el juego

loop_names:

        ; Acceder al nombre actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada nombre es 4 bytes
        call    print_string
        call    print_nl
    
        inc     edi        ; Incrementar el índice
    
        loop loop_names  ; Volver al principio del bucle hasta que ecx llegue a 0

        call    print_nl

        call    print_nl

        call    print_nl
        mov     eax, msg_input
        call    print_string
        call    print_nl

        call    read_int
        mov     dword [ind_player], eax

      ;  mov     dword [ind_player], 0   ;Indice del jugador para la nueva ronda (1r = 0)
        mov     dword [ind_first], 1   ;Primer jugador
        mov     dword [cc_round], 5     ;5 iteraciones para 5 jugadores

        mov     eax, msg_first_player
        call    print_string
        call    print_nl

        mov     ebx, [ind_player]
        mov     eax, [esi + ebx * 4] ; Obtener el nombre del diccionario en la posición edx
        call    print_string        ; Imprimir el nombre

loop_change_foot:

        call    print_nl
        call    print_nl
        mov     eax, msg_round
        call    print_string
        call    print_nl
        call    print_nl

        sub     dword [cc_round], 1

        mov     ecx, 14

        mov     esi, estribillo   ; Puntero al inicio del diccionario
        mov     edi, 0      ; Índice inicial


loop_estribillo_one:

        ; Acceder al la parte del estribillo actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada parte del estribillo es 4 bytes
        call    print_string
        call    print_nl

        inc     edi        ; Incrementar el índice

        ; Pausa de 1 segundo
        mov     ebx, 20000000   ; Establecer el valor de ebx para el bucle delay_loop
    delay_loop_one:
        dec     ebx
        jnz     delay_loop_one

        loop loop_estribillo_one  ; Volver al principio del bucle estribillo para cambio de pie

        call    print_nl

        mov     ecx, 14              ; Establecer el número de iteraciones
        mov     esi, names           ; Puntero al diccionario de nombres
        mov     edx, dword [ind_player]               ; Inicializar el índice en 0 (nombre1 = Juan)

        call    print_nl

loop_start_one:

        ; Obtener el nombre correspondiente al índice actual
        mov     edi, last_name        ; Puntero a la variable last_name
        mov     eax, [esi + edx * 4]
        mov     [edi], eax

        ; Incrementar el índice del nombre
        inc     edx
        cmp     edx, 5                ; Número total de nombres
        jl      continue_loop_one         ; Saltar a continue_loop_one si no hemos terminado

        ; Reiniciar el índice del nombre
        xor     edx, edx

continue_loop_one: ;Loop para continuar con las rondas de cambio de pie
        ; Decrementar el contador de iteraciones
        dec     ecx
        cmp     ecx, 0
        jne     loop_start_one ;Salta al loop para los cambios de pie

        ; Imprimir el jugador seleccionado
        mov     eax, msg_last_player
        call    print_string
        mov     eax, [last_name]
        call    print_string
        call    print_nl

        ;Imprimir mensaje de jugador cambia de pie
        mov     eax, dword [last_name]
        call    print_string    ; Imprimir el nombre del jugador eliminado
        mov     eax, msg_change
        call    print_string
        call    print_nl
        call    print_nl

        mov     eax, edx
        sub     eax, 1       


        ; Copiar el nombre seleccionado en edi
        mov     dword [ind_player], eax

        cmp     dword [cc_round], 0
        jne        loop_change_foot

        mov     dword [current_player], eax ; Incializar el ulitmo jugador que cambia de pie para las rondas de salida

        mov     dword [num_names], 6
        mov     dword [res_num_names], 5

go_round:

        sub     dword [num_names], 1
        sub     dword [res_num_names], 1

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
        mov     ebx, 20000000   ; Establecer el valor de ebx para el bucle delay_loop
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

        mov     eax, edi                ;Mover el valor edi a eax, para comparar luego

        mov     eax, dword[num_names]   ;Mover el valor de num_names a eax, para comparar luego
        sub     eax, 1

        
        mov     ebx, dword[num_names]   ;Mover el valor de num_names a ebx para comparar luego
        cmp     ebx, 5
        jne     compares
        sub     ebx, 4

compares:

        cmp     edi, eax 
        je      remove_ln
        cmp     edi, 0
        je      remove_ln
        cmp     edi, ebx
        je      remove_om
        jmp     remove_on

remove_ln:

        ; Intercambiar el jugador encontrado con el último jugador de la lista
        mov     ebx, [esi + (ecx - 1) * 4]  ; Obtener el último nombre de la lista
        mov     [esi + edi * 4], ebx        ; Colocar el último nombre en la posición del jugador encontrado

        mov     dword [current_player], edx
        jmp     continue_remove

remove_on:

        ; Intercambiar el jugador encontrado con el último jugador de la lista
        mov     eax, [esi + (edi + 1) * 4]      ; Obtener el siguiente jugador al seleccionado
        mov     ebx, [esi + (ecx - 1) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + (ecx - 1) * 4], eax      ; Intercambia el ultimo con el siguiente jugador
        mov     [esi + (edi + 1) * 4], ebx      ; Intercambia el siguiente jugador con el ultimo
        mov     ebx, [esi + (ecx - 1) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + edi * 4], ebx            ; Colocar el último nombre en la posición del siguiente jugador al encontrado
        mov     dword [current_player], edx
        sub     dword [current_player], 1
        jmp     continue_remove

remove_om:

        ; Intercambiar el jugador encontrado con el último jugador de la lista
        mov     eax, [esi + (edi + 1) * 4]      ; Obtener el siguiente jugador al seleccionado
        mov     ebx, [esi + (ecx - 1) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + (ecx - 1) * 4], eax      ; Intercambia el ultimo con el siguiente jugador
        mov     [esi + (edi + 1) * 4], ebx      ; Intercambia el siguiente jugador con el ultimo
        mov     ebx, [esi + (ecx - 1) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + edi * 4], ebx            ; Colocar el último nombre en la posición del siguiente jugador al encontrado
        mov     eax, [esi + (edi + 1) * 4]      ; Obtener el siguiente jugador al seleccionado
        mov     ebx, [esi + (edi + 2) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + (edi + 2) * 4], eax      ; Intercambia el ultimo con el siguiente jugador
        mov     [esi + (edi + 1) * 4], ebx      ; Intercambia el siguiente jugador con el ultimo
        mov     dword [current_player], edx
        sub     dword [current_player], 1

continue_remove:

        ;Imprimir mensaje de jugador eliminado
        mov     eax, dword [selected_name]
        call    print_string    ; Imprimir el nombre del jugador eliminado
        mov     eax, msg_removed
        call    print_string
        call    print_nl

        mov     ecx, [num_names]         ; Establecer el número total de nombres en el diccionario
        mov     esi, names               ; Puntero al inicio del diccionario de nombres
        mov     edi, 0                   ; Índice inicial

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
        call    print_nl
        
        request_continue_or_exit

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
