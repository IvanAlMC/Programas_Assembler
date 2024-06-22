%include "asm_io.inc"

LINE_FEED   equ 10

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
    mov byte [edi], 0       ; move the zero value to the edi's memory position
    popa                    ;It extracts the information from the stack and puts it in the registers.
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
    je      endprogram          ; if the previous compare is zero, the program finish
    cmp     al, 'y'             ; Compare eax with y (in this case), to do the brach
    je      start               ; if the previous compare is y, the program continue
    cmp     al, 'N'             ; Compare eax with n (in this case), to do the brach
    je      endprogram          ; if the previous compare is zero, the program finish
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


segment .data ; initialized data is put in the data segment here

msg_name    db  "Please enter your name: ", 0   ;Message to requesy the name
msg_surname db  "Please enter your surname: ", 0   ;Message to requesy the surname
msg_phone   db  "Please enter your phone: ", 0   ;Message to requesy the phone
msg_subject db  "Please enter your favorite subjec: ", 0   ;Message to requesy the phone
msg_age     db  "Please enter you age: ", 0     ;Message to request the age
msg_kid     db  "Tu eres niñ@", 0               ;Message to say you're a kid
art_kid     db  '    .-. _,,,_ .-.', 0Ah,'    (,         ,)', 0Ah,'    :  0.--.0  :', 0Ah,'    \ /  _   \ /', 0Ah,'     \| (_)  |/', 0Ah,'   .- \_____/` -.', 0Ah,'  /   /      \   \', 0Ah,' (___/        \___)', 0Ah,'  /_ `-. __ .-`_\', 0Ah,'/`  `\ /    \ /   `\', 0Ah, '`---`        ` ---`', 0
msg_teen    db  "Tu eres adolescente", 0        ;Message to say you're a teen
art_teen    db '     _', 0Ah,'    / 7', 0Ah,'   /_(', 0Ah,'   |_|', 0Ah,'   |_|', 0Ah,'   |_|', 0Ah,'   |_| /\', 0Ah,' /\|=|/ /', 0Ah,' \ |_| /', 0Ah,'  ) _  \', 0Ah,' / |_|  \', 0Ah,'/  -=-o /', 0Ah,'\  /~\_/', 0Ah,' \/', 0
msg_adul    db  "Tu eres adult@", 0             ;Message to say you're a adult
art_adult   db  '    ______   ', 0Ah,'   /(    )\  ', 0Ah,'   \ \  / /  ', 0Ah,'    \/[]\/   ', 0Ah,'      /\     ', 0Ah,'     |  |    ', 0Ah,'     |  |    ', 0Ah,'     |  |    ', 0Ah,'     |  |    ', 0Ah,'     |  |    ', 0Ah,'     \  /    ', 0Ah,'      \/     ', 0 
msg_old     db  "Tu eres adorable viejit@", 0   ;Message to say you're a old
art_old     db  '  ) )', 0Ah, '  ====     /\', 0Ah,' _|__|____/  \________', 0Ah,'|::::::::/ || \:::::::|', 0Ah,'|:::::: /______\ :::::|', 0Ah,' | ___ | / | \ | ___ |', 0Ah,' || | || ===== || | ||', 0Ah,' ||-+-|| |   | ||-+-||', 0Ah,' ||_|_|| |  o| ||_|_||', 0Ah,' |=====| |___| |=====|', 0
msg_exit    db     "Choose an option: Exit (n) or Continue (y): ", 0       ;message to request an option
msg_option_nv db "Option no valid, please try again", 0    ;Message to option no valid

segment .bss ; uninitialized data is put in the bss segment

age     resb 1          ;Declare the age variable with 1 byte
name    resb 22         ;Declare the name variable with 22 bytes
surname resb 22         ;Declare the surname variable with 22 bytes
phone   resb 22         ;Declare the phone variable with 22 bytes
subject resb 22         ;Declare the subject variable with 22 bytes

segment .text               ;Here is the code
        global  asm_main    
asm_main:
        enter   0,0                 ; setup routine
        pusha                       ; It saves the general purpose registers information on the stack.

start:
        mov     eax, msg_name       ;Move the message to request name to the eax register
        call    print_string        ;Print the previous message

        call    read_char              ;read char when continue the program
        read_string name, 20        ;Use the macro to read a String

        mov     eax, msg_surname    ;Move the message to request surname to the eax register
        call    print_string        ;Print the previous message

        call    read_char              ;read char when continue the program
        read_string surname, 20     ;Use the macro to read a String

        mov     eax, msg_phone      ;Move the message to request phone to the eax register
        call    print_string        ;Print the previous message

        call    read_char              ;read char when continue the program
        read_string phone, 20       ;Use the macro to read a String

        mov     eax, msg_subject      ;Move the message to request phone to the eax register
        call    print_string        ;Print the previous message

        call    read_char              ;read char when continue the program
        read_string subject, 20       ;Use the macro to read a String

        mov     eax, msg_age        ;Move the message to request age to eax register
        call    print_string        ;Print the previous message
        
        call    read_int            ;Use the macro to read an int
        mov     [age], eax          ;Move the data of eax register to the variable age

        mov     eax, name           ;Move the variable name to the eax register
        call    print_string        ;Print the name

        mov     eax, [age]          ;Move the age to the eax register
        cmp     eax, 12             ;Compare the data of eax (age) with 12
        jle     isKid               ;If the previous instruction is 12 or less jump to isKid label
        cmp     eax, 18             ;Compare the data of eax (age) with 18
        jle     isTeen              ;If the previous instruction is 18 or less jump to isTeen label
        cmp     eax, 60             ;Compare the data of eax (age) with 60
        jle     isAdult             ;If the previous instruction is 60 or less jump to inAdult label
        jmp     isOld               ;Else jump to isOld label

isKid:
        mov     eax, msg_kid        ;Move the Message to say you're kid to eax register
        call    print_string        ;Print the previos message
        call    print_nl            ;Print next line
        mov     eax, art_kid        ;move ascii art kid to eax register
        call    print_string        ;Print the previos message
        call    print_nl            ;Print next line
        request_continue_or_exit    ;Go to label to reques continue or exit

isTeen:
        mov     eax, msg_teen   ;Move the message to say you're teen to eax register
        call    print_string    ;Print the previous message
        call    print_nl        ;Print next line
        mov     eax, art_teen   ;move ascii art kid to eax register
        call    print_string    ;Print the previos message
        call    print_nl        ;Print next line
        request_continue_or_exit;Go to label to reques continue or exit

isAdult:
        mov     eax, msg_adul   ;move the message to say you're adult to eax register
        call    print_string    ;Print the previous message
        call    print_nl        ;Print next line
        mov     eax, art_adult  ;move ascii art ault to eax register
        call    print_string    ;Print the previous message
        call    print_nl        ;Print next line
        request_continue_or_exit;Go to label to reques continue or exit

isOld:
        mov     eax, msg_old    ;move the message to say you're old to eax register
        call    print_string    ;Print the previous message
        call    print_nl        ;Print next line
        mov     eax, art_old    ;move ascii art ault to eax register
        call    print_string    ;Print the previous message
        call    print_nl        ;Print next line
        request_continue_or_exit;Go to label to reques continue or exit        

endprogram:
        call    print_nl        ;Print next line

        popa                    ;It extracts the information from the stack and puts it in the registers.
        mov     eax, 0          ; return back to C
        leave                     
        ret