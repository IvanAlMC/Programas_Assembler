%include "asm_io.inc"

LINE_FEED   equ 10              ;An Enter to validate in the macro request_continue_or_exit

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


%macro  print_mult 2
        pusha
        mov     eax, %1         ;Move the iteration (param 1) to eax
        call    print_int       ;Print the first param

        mov     eax, msg_x      ;Move the message x to eax
        call    print_string    ;Print the "x"

        mov     eax, %2         ;Move the iteration (param 2) to eax
        call    print_int       ;Pirnt the second param

        mov     eax, msg_equ    ;Move the equal message to eax
        call    print_string    ;Print the "= "

        popa
%endmacro

segment .data

msg_table   db 'Multiplication table', 0Ah, 0Ah, '------------------------------', 0 ;Header Message
msg_request db "Please Enter a number: ", 0         ;Message to request a number
msg_result  db "The result is --> ", 0              ;Message to show result
msg_exit db     "Choose an option: Exit (n) or Continue (y): ", 0       ;message to request an option
msg_option_nv db "Option no valid, please try again", 0    ;Message to option no valid
msg_clean db `\033[2J\033[H`, 0   ; Escape sequence to clear the screen
msg_x   db "x", 0
msg_equ db "= ", 0

segment .bss

number  resd  1                 ;Create a variable to save the number entered by user
iter    resd  1                 ;Create a variable to iterate the ten multiplications

segment .text
        global  asm_main
asm_main:
        enter   0,0                 ; setup routine
        pusha

start:                              ; label to continue my program

        mov     eax, msg_clean      ;Move the escape sequence to eax
        call    print_string        ;print escape sequence to clear screen

        call    print_nl            ;print next line

        mov     eax, msg_table      ;move the header message to eax
        call    print_string        ;print the header message
        call    print_nl            ;pint next line

        mov     eax, msg_request    ;move the request message to eax
        call    print_string        ;print the request message

        call    read_int            ;read the number of the user
        mov     dword [number], eax ;save the previous number entered by user in the number varible

        mov     dword [iter], 0     ;initialize the iterator in 0

        mov ecx, 11                 ;start the counter in 11 (to print the 11 result 0-10)
        call print_nl               ;print next line

loop_mult:                          ;create a loop to repeat the multiplication

        mov     eax, msg_result     ;move the the result message to eax register
        call    print_string        ;print the result messagen

        mov     eax, [iter]         ;mov the variable iterator to eax
        mov     ebx, [number]       ;mov the variable number to ebx    
        mul     ebx                 ;multiplicate eax * ebx

        print_mult [iter], [number] ;Print "[iter]x[number]= "

        call    print_int           ;print result
        call    print_nl            ;print next line

        add     dword [iter], 1     ;add one to  iterator

        loop    loop_mult           ;back to loop

        call    print_nl            ;print next line

        request_continue_or_exit    ;go to the macro to request continue or not

end:                                 ; label to finish my program

        mov     eax, msg_clean       ;move to escape sequence to eax register
        call    print_string         ;print escape sequence to clear screen

        popa
        mov     eax, 0               ; return back to C
        leave                     
        ret