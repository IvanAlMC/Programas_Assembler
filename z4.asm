%include "asm_io.inc"

LINE_FEED   equ 10

%macro request_continue_or_exit 0
    pusha

%%request:
    mov     eax, msg_exit     ; Imprime el mansaje para solicitar si continua o no
    call    print_string

%%again:
    call    read_char           ; lee el caracter entrado por el usuario

    cmp     al, LINE_FEED       ; compara si es un enter, y lo es pide de nuevo el caracter sin mostrar mensaje
    je      %%again
    cmp     al, 'n'             ; Si es 'n' sale del juego
    je      end_program         ;
    cmp     al, 'y'             ; Si es 'y' continua el juego
    je      start               ; 
    cmp     al, 'N'             ; Si es 'N' sale del juego
    je      end_program         ; 
    cmp     al, 'Y'             ; Si es 'Y' continua el juego
    je      start               ; 
    jmp     %%option_exit_nv    ; Si es otro caracter salta a option_exit_nv
%%option_exit_nv:
    mov     eax, msg_option_nv  ; Imprime el mensaje de opcion no valid
    call    print_string 
    call    print_nl            ;
    jmp     %%request           ;Vuelve a solicitar la opcion
    popa
%endmacro

    segment .data

msg_exit db     "Quieres jugar de nuevo? No (n), Si (y): ", 0       ;Mensaje para solicitr si continua o no
msg_option_nv db "Opccion no valida, por favor intentalo de nuevo", 0    ;Mesaje de opcion no valida
msg_winner db "El ganador es: ",0                               ;Mensaje para mostrar al ganador
msg_input db "Ingrese el numero del jugador a iniciar", 0       ;Mensaje para solicitar el jugador inicial

msg_removed     db " ha sido eliminado del juego. ", 0         ;Mensaje para decir que alguien fue eliminado
msg_change     db " ha cambiado de pie.", 0                     ;Mensaje para decir que alguien cambio de pie

msg_bye db "Un gusto jugar, adios!", 0          ; Mensaje de despedida
msg_clean db `\033[2J\033[H`, 0                 ; Mensaje para limpiar la pantalla

;Creacion de valores para generar un retardo al imprimir el estribillo
timeval:
    tv_sec  dd 0
    tv_usec dd 0

msg_game    db "Juego del zapatico cochinito", 0 ;Mensaje inicial

; Definir el diccionario de nombres que se puede modificar
names dd name1, name2, name3, name4, name5
name1 db " Juan", 0
name2 db " Victor", 0
name3 db " Andrea", 0
name4 db " Laura", 0
name5 db " Nicolas", 0

; Definir la lista de nombres original (para luego restbalcer valores por medio de copia)
initial_names dd initial_name1, initial_name2, initial_name3, initial_name4, initial_name5
initial_name1 db " Juan", 0
initial_name2 db " Victor", 0
initial_name3 db " Andrea", 0
initial_name4 db " Laura", 0
initial_name5 db " Nicolas", 0


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
msg_show_players    db "Los jugadores son: ", 0                 ;Mensaje para mostrar a los jugadores
msg_last_player     db "El seleccionado de la ronda es: ", 0    ;Mensaje para mostrar quien quedo en la ultima silaba en la ronda
msg_round     db "Nueva ronda: ", 0                             ;Mensaje para indicar nueva ronda
msg_first_player     db "El primer jugador es: ", 0             ;Mensaje para mostrar el primer jugador


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

;Iniciamos con el codigo
        segment .text
                global  asm_main

asm_main:
        enter   0,0               
        pusha

start:

        ; Restablecer la lista de nombres original
        mov     ecx, 5          ; Número total de nombres
        mov     edi, 0          ; Índice inicial

;Con el siguiente loop restablecemos el orden original para cuando se inicia un nuevo juego (en caso de que se escoja continuar)
loop_reset_names:
        ; Acceder al nombre original
        mov     eax, [initial_names + edi * 4] ; Tamaño de cada nombre es 4 bytes
        mov     [names + edi * 4], eax         ; Copiar el nombre al diccionario de nombres

        inc     edi        ; Incrementar el índice

        loop    loop_reset_names ; Volver al principio del bucle hasta que ecx llegue a 0

        mov     eax, msg_clean      ;Move the escape sequence to eax
        call    print_string        ;print escape sequence to clear screen

        ;Mostramos el mensaje inicial del juago
        mov     eax, msg_game
        call    print_string
        call    print_nl

        call    print_nl

        ;Iniciamos un contador en 5 (numero de jugadores)
        mov     ecx, 5

        mov     esi, names   ; Puntero al inicio del diccionario
        mov     edi, 0       ; Índice inicial

        mov     eax, msg_show_players   ;Mensaje para mostrar jugadores
        call    print_string
        call    print_nl

        call    print_nl

        mov     dword [ind_final_cf], 0  ;Aca se inicializar el jugador a comenzar el juego

;Este es el loop para imprimir los nombres de los 5 jugadores
loop_names:

        ;Imprimimos el indice del jugador
        mov     eax, edi
        call    print_int

        ; Acceder al nombre actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada nombre es 4 bytes y lo movemos a eax para imprimirlo
        call    print_string
        call    print_nl
    
        inc     edi        ; Incrementar el índice
    
        loop loop_names  ; Volver al principio del bucle hasta que ecx llegue a 0

        call    print_nl

        call    print_nl

        ;Solicitamos el numero del jugador por que cual se desea empezar
        call    print_nl
        mov     eax, msg_input ;Mensage para solicitar el numero del jugador
        call    print_string
        call    print_nl

;Etiqueta para obtener el numero del jugador y validar sus opciones
get_input:

        ;Validador de opciones de jugadores (0-4 aceptar y demas rechazar)
        call    read_int        
        cmp     eax, 0
        je      input_valid
        cmp     eax, 1
        je      input_valid
        cmp     eax, 2
        je      input_valid
        cmp     eax, 3
        je      input_valid
        cmp     eax, 4
        je      input_valid
        jmp     input_no_valid

;En caso de que sea un numero diferente a 0, 1, 2, 3 o 4, se ingresa aca
;Y se muestra un mensaje para intentarlo de nuevo
input_no_valid:
        ;Se muestra el mensaje para intentarlo de nuevo
        call    print_nl
        mov     eax, msg_option_nv
        call    print_string
        call    print_nl
        jmp     get_input; vuelve a solicitar el indice del jugador

;Entra aca si el idice del jugadro es valido
input_valid:
        ;Si el numero de jugador ingresado es valido:
        mov     dword [ind_player], eax ;Comienza por el jugador ingresado
        mov     dword [ind_first], 1    ;Primer jugador
        mov     dword [cc_round], 5     ;5 iteraciones para 5 jugadores

        ;Mostramos el mensaje del jugador seleccionado (el cual va a comenzar el juego)
        mov     eax, msg_first_player
        call    print_string
        call    print_nl

        ;Se obtiene el nombre y se imprime
        mov     ebx, [ind_player]
        mov     eax, [esi + ebx * 4] ; Obtener el nombre del diccionario en la posición edx
        call    print_string        ; Imprimir el nombre

;Este es el loop para cambiar de pies (primer "juego")
loop_change_foot:

        ;Mostramos el mensaje de la ronda
        call    print_nl
        call    print_nl
        mov     eax, msg_round
        call    print_string
        call    print_nl
        call    print_nl

        ;Se resta un a la ronda
        sub     dword [cc_round], 1

        ;Iniciamos un contador en 14 (son 14 silabas) para el cantico o estribillo
        mov     ecx, 14

        mov     esi, estribillo   ; Puntero al inicio del diccionario
        mov     edi, 0      ; Índice inicial

;Se imprime el estribillo
loop_estribillo_one:

        ; Acceder al la parte del estribillo actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada parte del estribillo es 4 bytes
        call    print_string
        call    print_nl

        inc     edi        ; Incrementar el índice

        ; Pausa de 1 segundo
        mov     ebx, 2000000000   ; Establecer el valor de ebx para el bucle delay_loop
    ;Este es el loop que da la sensacion de demora para cantar el estribillo
    delay_loop_one:
        dec     ebx
        jnz     delay_loop_one

        ; Volver al principio del bucle estribillo para cambio de pie
        loop loop_estribillo_one 

        call    print_nl

        ;Establecemos en contador en 14, para recorres 14 veces la lista de jugadores (equivalente a 14 silabas)
        mov     ecx, 14              ; Establecer el número de iteraciones
        mov     esi, names           ; Puntero al diccionario de nombres
        mov     edx, dword [ind_player]               ; Inicializar el índice en 0 (nombre1 = Juan)

        call    print_nl

;Comienza el loop para recorrer a los jugadores
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

        ;Actualizar resgitros para copiar el nombre del seleccionado
        mov     eax, edx
        sub     eax, 1       

        ; Copiar el nombre seleccionado en edi
        mov     dword [ind_player], eax

        ;Validar si llega a la ronda 0, en caso de que no, vuelve al loop_change_foot
        cmp     dword [cc_round], 0
        jne     loop_change_foot

        mov     dword [current_player], eax ; Incializar el ulitmo jugador que cambia de pie para las rondas de salida

        ;Inicializamos valores, para las rondas o "juego", de eliminar a los jugadores
        mov     dword [num_names], 6
        mov     dword [res_num_names], 5

;Este es la parte del juego para eliminar a jugadores
go_round:

        ;Cuando se inicie el juego, decrementan los contadores para ii avanzando en rondas
        sub     dword [num_names], 1
        sub     dword [res_num_names], 1

        ;Se muestra el mensaje de nueva ronda
        call    print_nl
        call    print_nl
        mov     eax, msg_round
        call    print_string
        call    print_nl
        call    print_nl

        ;Se inicia el contador en 14 para imprimir el cantico
        mov     ecx, 14

        mov     esi, estribillo   ; Puntero al inicio del diccionario
        mov     edi, 0       ; Índice inicial

;Se imrpime el cantico
loop_estribillo:

        ; Acceder al la parte del estribillo actual
        mov     eax, [esi + edi * 4] ; Tamaño de cada parte del estribillo es 4 bytes
        call    print_string
        call    print_nl

        inc     edi        ; Incrementar el índice

        ; Pausa de 1 segundo
        mov     ebx, 2000000000   ; Establecer el valor de ebx para el bucle delay_loop
    ;Se genera la sencacion de demora para el cantico
    delay_loop:
        dec     ebx
        jnz     delay_loop

        ; Volver al principio del bucle hasta que ecx llegue a 0
        loop loop_estribillo  

        call    print_nl

        ;Ahora se inicializa en contador en 14 para recorrer a ls lista de jugadores
        mov     ecx, 14              ; Establecer el número de iteraciones
        mov     esi, names           ; Puntero al diccionario de nombres
        mov     edx, dword [current_player]; Inicializar el índice, por ejemplo en 0 (nombre1 = Juan)

        call    print_nl

;Se hace el loop para recorrer los jugadores
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

        ; Imprimir el último nombre al cual le cae la silaba final
        mov     eax, msg_last_player
        call    print_string
        mov     eax, dword [selected_name]
        call    print_string
        call    print_nl

        ; Eliminar al jugador seleccionado de la lista de nombres (acceder al diccionario)
        mov     ecx, dword [num_names]  ; Tamaño de la lista de nombres
        mov     esi, names              ; Puntero al diccionario de nombres
        mov     edi, 0                  ; Índice inicial

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

;Se hace las validaciones para algunos casos para luego hacer los movimientos de registros
;Adecuados segun el caso
compares:

        cmp     edi, eax        ;Si el jugador es el final
        je      remove_ln
        cmp     edi, 0          ;Si el jugador es el inicial
        je      remove_ln
        cmp     edi, ebx        ;Si con el jugador hayq eu hacer mas de un movimineto
        je      remove_om
        jmp     remove_on

;Se hace los movimientos requeridos para el primer y ultimo jugador
remove_ln:

        ; Intercambiar el jugador encontrado con el último jugador de la lista
        mov     ebx, [esi + (ecx - 1) * 4]  ; Obtener el último nombre de la lista
        mov     [esi + edi * 4], ebx        ; Colocar el último nombre en la posición del jugador encontrado

        mov     dword [current_player], edx ;NO se mueve current player, se mantienen en el actual de edx
        jmp     continue_remove             ;Salta a continue_remove para no hacer los otros casos

;Se hace los movimientos requeridos para los otros jugadores
remove_on:

        ; Intercambiar el jugador encontrado con el último jugador de la lista
        mov     eax, [esi + (edi + 1) * 4]      ; Obtener el siguiente jugador al seleccionado
        mov     ebx, [esi + (ecx - 1) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + (ecx - 1) * 4], eax      ; Intercambia el ultimo con el siguiente jugador
        mov     [esi + (edi + 1) * 4], ebx      ; Intercambia el siguiente jugador con el ultimo
        mov     ebx, [esi + (ecx - 1) * 4]      ; Obtener el último nombre de la lista
        mov     [esi + edi * 4], ebx            ; Colocar el último nombre en la posición del siguiente jugador al encontrado
        ;Se mueve el current player para que el loop de eliminacion se ajuste adecuadamente, ya que un jugador sale
        mov     dword [current_player], edx     ; Mueve a current player lo que hay en edx
        sub     dword [current_player], 1       ; Se resta uno
        jmp     continue_remove                 ;Salta a contine_remove para no tener en cuanta el otro caso

;Se hace los movimientos requeridos si con el jugador seleccionado se requiere mas de un movimiento
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
                ;Se mueve el current player para que el loop de eliminacion se ajuste adecuadamente, ya que un jugador sale
        mov     dword [current_player], edx     ; Mueve a current player lo que hay en edx
        sub     dword [current_player], 1       ; Se resta uno

;Se muestra la informacion del jugador eliminado
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

;Finalizamdos en juego, mostrando al ganador
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
        
        request_continue_or_exit ;Pedimos si quiere jugar de nuevo

;Finalizamos el programa
end_program:
        ;Imprimir mensaje de salida
        call    print_nl

        mov     eax, msg_bye
        call    print_string
        call    print_nl

        mov     eax, msg_clean      ;Move the escape sequence to eax
        call    print_string        ;print escape sequence to clear screen

        popa
        mov     eax, 0
        leave
        ret
