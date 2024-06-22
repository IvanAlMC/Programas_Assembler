%include "asm_io.inc"

LINE_FEED   equ 10

%macro showing_result 0
    pusha               ;It saves the general purpose registers information on the stack.
    call print_string   ;print the message of the operation
    mov eax, ebx        ;mov the result of operation since ebx to eax
    call print_int      ;print the result
    call print_nl       ;print next line
    popa                ;It extracts the information from the stack and puts it in the registers.
%endmacro

%macro request_numbers 0
    pusha
    mov     eax, prompt1      ; print out prompt
    call    print_string

    call    read_int          ; read integer
    mov     [input1], eax     ; store into input1

    mov     eax, prompt2      ; print out prompt
    call    print_string

    call    read_int          ; read integer
    mov     [input2], eax     ; store into input2

    mov     eax, outmsg1
    call    print_string      ; print out first message
    mov     eax, [input1]     
    call    print_int         ; print out input1
    mov     eax, outmsg2
    call    print_string      ; print out second message
    mov     eax, [input2]
    call    print_int         ; print out input2
    call    print_nl
    popa
%endmacro


%macro show_register_info 0
    pusha
    dump_regs 1               ; dump out register values
    dump_mem 2, outmsg1, 1    ; dump out memory;
    popa
%endmacro

%macro request_continue_or_exit 0
    pusha

%%request:
    mov     eax, msg_exit     ; print the exit request message
    call    print_string

    call    read_char           ; read integer the request teh exit or not

    cmp     al, LINE_FEED   ; compare if the char is an Enter
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
    mov     eax, msg_option_nv   ; print the error option no valid
    call    print_string 
    call    print_nl             ;print next line
    jmp     %%request     ;go macro to request exit or not
    popa
%endmacro

;
; initialized data is put in the .data segment
;
        segment .data
;
; These labels refer to strings used for output
;
prompt1 db      "Enter a number: ", 0             ; don't forget nul terminator (request teh first number)
prompt2 db      "Enter another number: ", 0       ;this is a message to request second number
outmsg1 db      "You entered ", 0                 ;message to show the numbers input
outmsg2 db      " and ", 0                        ;message to show the numbers input
outmsg3 db      "The sum of these is ", 0         ;message to result of sum
outmsg4 db      "The subtraction of thes is: ", 0        ;message to result of subtraction
outmsg5 db      "The multiplication of thes is: ", 0      ;message to result of multiply
outmsg6 db      "The division of thes is: ", 0            ;message to result of division
msg_exit db     "Choose an option: Exit (n) or Continue (y): ", 0       ;message to request an option
msg_divzero db  "You can't divide by zero, try again", 0   ;Messase error for divide by zero
msg_m_opt_nv db "Menu option no valid, please in a valid option", 0 ; Message to menu option no valid
msg_option_nv db "Option no valid, please try again", 0    ;Message to option no valid
msg_options db  '  ╔════════════════════════╗', 0Ah,  '  ║        OPTIONS         ║', 0Ah,  '  ╠════╦═══════════════════╣', 0Ah,  '  ║ 1  ║     Addition      ║', 0Ah,  '  ╠════╬═══════════════════╣', 0Ah,  '  ║ 2  ║    Subtraction    ║', 0Ah,  '  ╠════╬═══════════════════╣', 0Ah,  '  ║ 3  ║     Multiply      ║', 0Ah,  '  ╠════╬═══════════════════╣', 0Ah,  '  ║ 4  ║      Divide       ║', 0Ah,  '  ╚════╩═══════════════════╝', 0Ah, 'Enter your option: ', 0


;
; uninitialized data is put in the .bss segment
;
        segment .bss
;
; These labels refer to double words used to store the inputs
;
input1  resd 1
input2  resd 1
input3  resd 1

;
; code is put in the .text segment
;
        segment .text
        global  asm_main

asm_main:
        enter   0,0               ; setup routine
        pusha                     ; It saves the general purpose registers information on the stack.

start:                            ; label to continue my program

        mov     eax, msg_options
        call    print_string
        call    print_nl

        call    read_int         ; read char the request option calculator

        cmp     eax, 1            ; Compare al with one (in this case), to do the addition branch
        je      addition          ; if the previous compare is one, jump to addition label

        cmp     eax, 2            ;Compare al with two to do the subtraction branch
        je      subtraction      ; If previous compare is two jump to subtraction label

        cmp     eax, 3            ;Compare eax with three to do the multiply branch 
        je      multiply          ; If previous compare is three jump to multiply label

        cmp     eax, 4            ;Compare eax with four todo the division branch
        je      division          ; If previous compare is four jump to division label

        jmp     option_nv        ; Validate If the user in other number,  

addition:

        request_numbers         ;Macro to request the two numbers
        ;SUMA

        mov     eax, [input1]     ; eax = dword at input1
        add     eax, [input2]     ; eax += dword at input2
        mov     ebx, eax          ; ebx = eax
        mov     eax, outmsg3      ; move msg3 data to eax
        showing_result            ; macro to print result
        call    print_nl          ; print next line

        show_register_info        ; macro to print registers
        call    print_nl          ; print next line

        request_continue_or_exit  ;macro to request continue or exit

subtraction:

        request_numbers         ;Macro to request the two numbers

        ;RESTA

        mov     ebx, [input1]     ; eax = dword at input1
        sub     ebx, [input2]     ; eax +- dword at input2
        mov     eax, outmsg4      ; Move msg4 data to eax
        showing_result            ; macro to print result
        call    print_nl          ; print next line

        show_register_info        ; macro to print registers
        call    print_nl          ; print next line

        request_continue_or_exit  ;macro to request continue or exit

multiply:

        request_numbers           ;Macro to request the two numbers

        ;MULTIPLICACION

        mov     eax, [input1]     ; eax = dword at input1
        mov     ecx, [input2]     ; eax = eax * ebx
        mul     ecx               ; mutiply the numbers
        mov     ebx, eax          ;move eax data to ebx
        mov     eax, outmsg5      ;move msg5 data to eax
        showing_result            ; macro to print result
        call    print_nl          ; print next line

        show_register_info        ; macro to print registers
        call    print_nl          ; print next line

        request_continue_or_exit  ;macro to request continue or exit

division:

        request_numbers           ;Macro to request the two numbers

        ;DIVISION
        cdq
        mov     eax, [input1]     ; eax = dword at input1
        mov     ecx, [input2]     ; eax = eax / ebx
        cmp     ecx, 0            ; compare the second input with zero
        jz      division_by_zero  ; if the previos instruction is 0, go to the division_by_sero label
        div     ecx               ; divide
        mov     ebx, eax          ; mov data eax to ebx
        mov     eax, outmsg6      ; mov msg6 to eax
        showing_result            ; macro to print result
        call    print_nl          ; print next line

        show_register_info         ; macro to print registers
        call    print_nl          ; print next line

        request_continue_or_exit    ;macro to request continue or exit

division_by_zero:

        mov     eax, msg_divzero     ; print the error division by zero message
        call    print_string 
        call    print_nl             ;print next line
        jmp     division             ;return to division label

option_nv:

        mov     eax, msg_m_opt_nv   ; print the error option no valid
        call    print_string 
        call    print_nl             ;print next line
        jmp     start                ;return to start label


; next print out result message as series of steps
;
end:                             ; label to finish my program
        popa                      ;It extracts the information from the stack and puts it in the registers.
        mov     eax, 0            ; return back to C
        leave                     
        ret