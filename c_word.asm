%include "asm_io.inc"

%macro random 1
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

%macro choose_word 0
    pusha

    mov     ecx, 0
    mov     ebx, words
    mov     esi, hidden

%%cw01:
    cmp     ecx, [number]
    je      %%cw03
    mov     al, [ebx]
    cmp     al,0
    je      %%cw02
    inc     ebx
    jmp     %%cw01
%%cw02:
    inc     ecx
    inc     ebx
    jmp     %%cw01
%%cw03:
    mov     al, [ebx]
    mov     [esi], al
    cmp     al, 0
    je      %%cw04
    inc     ebx
    inc     esi
    jmp     %%cw03
%%cw04:
    popa
%endmacro

%macro  init_secret_word 0
    pusha

    mov     esi, hidden
    mov     edi, secret
%%isw01:
    mov     al, [esi]
    cmp     al, 0
    je      %%isw02
    mov     byte [edi], Hidden_char
    inc     esi
    inc     edi
    jmp     %%isw01
%%isw02:
    mov     byte [edi], 0

    popa
%endmacro

%macro show_word 0
    pusha
    mov     eax, secret
    call    print_string
    call    print_nl
    popa
%endmacro

segment .data

words   db      "Colombia", 0
        db      "Francia", 0
        db      "USA", 0
        db      "Alemania", 0
        db      "Peru", 0
        db      "Argentina", 0
WORDS_LEN equ 6

segment .bss

Hidden_char     equ '*'
Max_word_len    equ 10
players_live    equ 3

hidden      resd Max_word_len
secret      resd Max_word_len
number      resd 1
lives       resd 1

segment .text
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha

        random WORDS_LEN
        choose_word
        init_secret_word

        mov     byte [lives], players_live

play:

        show_word
        call    read_char

        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret