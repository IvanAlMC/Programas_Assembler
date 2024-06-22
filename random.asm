%include "asm_io.inc"

LINE_FEED   equ 10              ;An Enter to validate in the macro request_continue_or_exit

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
    jmp     print_rand  ;Jump to label to print the previos result
    popa
%endmacro

%macro request_continue_or_exit 0
    pusha

%%request:
    mov     eax, msg_exit       ; print the exit request message
    call    print_string

    call    read_char           ; read integer the request teh exit or not

    cmp     al, LINE_FEED       ; compare if the char is an Enter
    call    read_char
    cmp     al, 'n'             ; Compare eax with n (in this case), to do the brach
    je      end                 ; if the previous compare is zero, the program finish
    cmp     al, 'y'             ; Compare eax with y (in this case), to do the brach
    je      start               ; if the previous compare is y, the program continue
    cmp     al, 'N'             ; Compare eax with n (in this case), to do the brach
    je      end                 ; if the previous compare is zero, the program finish
    cmp     al, 'Y'             ; Compare eax with y (in this case), to do the brach
    je      start               ; if the previous compare is y, the program continue
    jmp     %%option_exit_nv    ; if user in other char go to option_exit_nv label
%%option_exit_nv:
    mov     eax, msg_option_nv  ; mov the message (option no valid) to eax register
    call    print_string        ;print the error option no valid
    call    print_nl            ;print next line
    jmp     %%request           ;return macro's loop to request exit or not
    popa
%endmacro

%macro show_register_info 0
    pusha
    dump_regs 1               ; dump out register values
    popa
%endmacro


segment .data

msg_lim     db "Ingresa un limite", 10, 0       ;Message to request a limit
msg_ans     db "Número aleatorio: ", 10, 0      ;Message to show the random number
msg_exit db     "Choose an option: Exit (n) or Continue (y): ", 0   ;message to request an option
msg_option_nv db "Option no valid, please try again", 0    ;Message to option no valid
msg_clean db `\033[2J\033[H`, 0   ; Escape sequence to clear the screen

segment .bss

limit  resd  1       ;Variable para establecer un limite ingresado por el usuario
number resd 1

segment .text
    global asm_main

asm_main:

        enter   0,0                  ; setup routine
        pusha

start:                              ;The start label

        mov     eax, msg_clean      ;Move the escape sequence to eax
        call    print_string        ;print escape sequence to clear screen

        mov     eax, msg_lim        ;Move message to request limit to eax
        call    print_string        ;Print the previous message

        call    read_int            ;read the number of the user
        mov     dword [limit], eax ;save the previous number entered by user in the number varible

        mov     eax, msg_ans        ;move the answer message to eax
        call    print_string        ;print the answer message

        generate_random [limit]     ;Go to gern_random macro

print_rand:
        call    print_int           ;Print the random number
        call    print_nl            ;print next line

        show_register_info        ; macro to print registers
        call    print_nl          ; print next line

        request_continue_or_exit    ;go to the macro to request continue or not

end:                                ;Label to end the program

        mov     eax, msg_clean      ;Move the escape sequence to eax
        call    print_string        ;print escape sequence to clear screen

        popa                        ;It extracts the information from the stack and puts it in the registers.
        mov     eax, 0              ; return back to C
        leave                     
        ret
