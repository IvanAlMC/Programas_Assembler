section .data
    dictionary db 2, 2, 2   ; Vidas iniciales de las personas en el diccionario
    dict_size equ $ - dictionary
    round_msg db "Ronda ", 0
    winner_msg db "La persona ganadora es: ", 0

section .text
    global _start

_start:
    ; Configurar el contador de rondas y el índice de la persona actual
    mov ecx, 1  ; Contador de rondas
    xor esi, esi  ; Índice de la persona actual

play_game:
    ; Mostrar el número de ronda
    mov eax, ecx
    add eax, '0'
    mov [round_msg + 6], al
    mov eax, 4
    mov ebx, 1
    mov ecx, round_msg
    mov edx, 7
    int 0x80

    ; Mostrar las vidas de cada persona en el diccionario
    mov ecx, dict_size
    xor esi, esi  ; Índice de la persona actual
    mov edi, dictionary

print_lives:
    mov eax, esi
    add eax, '0'
    mov [round_msg + 13], al
    movzx eax, byte [edi + esi]
    add eax, '0'
    mov [round_msg + 15], al
    mov eax, 4
    mov ebx, 1
    mov ecx, round_msg
    mov edx, 16
    int 0x80

    ; Restar una vida a la persona actual
    dec byte [edi + esi]

    ; Verificar si la persona actual perdió todas sus vidas
    cmp byte [edi + esi], 0
    jle person_lost

    ; Actualizar el índice de la persona actual
    inc esi

    ; Verificar si se alcanzó el final del diccionario
    cmp esi, dict_size
    jl print_lives

next_round:
    ; Verificar si queda solo un jugador
    mov ecx, dict_size
    xor esi, esi
    mov edi, dictionary
    mov ebx, 0  ; Contador de personas con vidas
    xor edx, edx  ; Índice de la persona ganadora

count_players:
    cmp byte [edi + esi], 0
    jg player_has_life
    inc ebx

player_has_life:
    cmp ebx, 1
    jne not_last_player
    mov edx, esi

not_last_player:
    inc esi
    loop count_players

    cmp ebx, 1
    jne play_game  ; Si queda más de un jugador, volver a jugar

    ; Mostrar al ganador del juego
    mov eax, edx
    add eax, '0'
    mov [winner_msg + 24], al
    mov eax, 4
    mov ebx, 1
    mov ecx, winner_msg
    mov edx, 27
    int 0x80

    ; Salir del programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

person_lost:
    ; Mostrar que la persona actual perdió
    mov eax, esi
    add eax, '0'
    mov [round_msg + 13], al
    mov eax, 4
    mov ebx, 1
    mov ecx, round_msg
    mov edx, 14
    int 0x80

    ; Actualizar el índice de la persona actual
    inc esi

    ; Verificar si se alcanzó el final del diccionario
    cmp esi, dict_size
    jl next_round

exit:
    ; Salir del programa sin ganador
    mov eax, 1
    xor ebx, ebx
    int 0x80
