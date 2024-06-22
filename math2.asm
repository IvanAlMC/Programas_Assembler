%include "asm_io.inc"

%macro print_int_msg 2
    pusha               ;Save the general purpose registers information on the stack
    mov eax, %1         ;Move the first macro argument to EAX (the message string)
    call print_string   ;Print the message string
    mov eax, %2         ;Move the second macro argument to EAX (the value to print)
    call print_int      ;Print the value
    call print_nl       ;Print a new line
    popa                ;Restore the general purpose registers from the stack
%endmacro

segment .data
;
; Output strings
;
prompt          db    "Enter a number: ", 0    ;The message that prompts the user for input
square_msg      db    "Square of input is ", 0  ;The message that displays the square of the input
cube_msg        db    "Cube of input is ", 0    ;The message that displays the cube of the input
cube25_msg      db    "Cube of input times 25 is ", 0 ;The message that displays the cube of the input times 25
quot_msg        db    "Quotient of cube/100 is ", 0   ;The message that displays the quotient of the cube divided by 100
rem_msg         db    "Remainder of cube/100 is ", 0  ;The message that displays the remainder of the cube divided by 100
neg_msg         db    "The negation of the remainder is ", 0  ;The message that displays the negation of the remainder

segment .bss
input   resd 1        ;Allocate space for one 32-bit integer

segment .text
        global  asm_main
asm_main:
        enter   0,0               ;Set up the stack frame
        pusha                     

        mov     eax, prompt       ;Move the prompt message to EAX
        call    print_string      ;Print the prompt message

        call    read_int          ;Read an integer from the user and store it in EAX
        mov     [input], eax      ;Store the input in the input variable

        imul    eax               ;Multiply EAX by itself (calculate the square of the input)
        mov     ebx, eax          ;Move the result (square) to EBX
        print_int_msg   square_msg, ebx    ;Print the message and the value of the square

        mov     ebx, eax          ;Move the square back to EBX
        imul    ebx, [input]      ;Multiply the square by the input (calculate the cube)
        print_int_msg   cube_msg, ebx      ;Print the message and the value of the cube

        imul    ecx, ebx, 25      ;Multiply the cube by 25 (calculate cube * 25)
        print_int_msg   cube25_msg, ecx    ;Print the message and the value of cube * 25

        mov     eax, ebx          ;Move the cube to EAX
        cdq                       ;Sign extend EAX into EDX
        mov     ecx, 100          ;Move 100 to ECX
        idiv    ecx               ;Divide EDX:EAX by ECX (calculate the quotient and remainder of cube/100)
        mov     ecx, eax          ;Move the quotient to ECX
        print_int_msg   quot_msg, ecx      ;Print the message and the value of the quotient
        print_int_msg   rem_msg, edx       ;Print the message and the value of the remainder
        
        neg     edx              

        
        neg     edx               ; negate the remainder
        print_int_msg   neg_msg, edx       ; print negation message and value

        popa                      ; Restore the general purpose registers from the stack
        mov     eax, 0            ; return back to C
        leave                     
        ret