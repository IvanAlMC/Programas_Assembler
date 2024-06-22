%include "asm_io.inc"

%macro showing_result 0
    pusha               ;It saves the general purpose registers information on the stack.
    call print_string   ;print the message of the operation
    mov eax, ebx        ;mov the result of operation since ebx to eax
    call print_int      ;print the result
    call print_nl       ;print next line
    popa                ;It extracts the information from the stack and puts it in the registers.
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
outmsg4 db      "The substraction of thes is: ", 0        ;message to result of substraction
outmsg5 db      "The multiplication of thes is: ", 0      ;message to result of multiply
outmsg6 db      "The division of thes is: ", 0            ;message to result of division
msg_exit db     "Choose an option: Exit (0) or Continue (1): ", 0       ;message to request an option
msg_options db  "Choose an option: Addition (1), Substraction (2), Multiply (3) or Division (4)", 0 ;Messa to request a menu option

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

        mov     eax, msg_options  ; print the exit request option calculator
        call    print_string

        call    read_int          ; read integer the request option calculator

        cmp     eax, 1            ; Compare eax with one (in this case), to do the addition branch
        je      addition          ; if the previous compare is one, jump to addition label

        cmp     eax, 2            ;Compare eax with two to do the subtraction branch
        je      substraction      ; If previous compare is two jump to subtraction label

        cmp     eax, 3            ;Compare eax with three to do the multiply branch 
        je      multiply          ; If previous compare is three jump to multiply label

        cmp     eax, 4            ;Compare eax with four todo the division branch
        je      division          ; If previous compare is four jump to division label


addition:
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

        ;SUMA

        mov     eax, [input1]     ; eax = dword at input1
        add     eax, [input2]     ; eax += dword at input2
        mov     ebx, eax          ; ebx = eax
        mov eax, outmsg3
        showing_result

        dump_regs 1               ; dump out register values
        dump_mem 2, outmsg1, 1    ; dump out memory;

        mov     eax, msg_exit     ; print the exit request message
        call    print_string

        call    read_int          ; read integer the request teh exit or not

        cmp     eax, 0            ; Compare eax with zero (in this case), to do the brach
        je      end               ; if the previous compare is zero, the program finish
        jmp     start             ; if the previous compare isn't zero, the program continue


substraction:

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

        ;RESTA

        mov     ebx, [input1]     ; eax = dword at input1
        sub     ebx, [input2]     ; eax +- dword at input2
        mov     eax, outmsg4
        showing_result

        dump_regs 1               ; dump out register values
        dump_mem 2, outmsg1, 1    ; dump out memory;

        mov     eax, msg_exit     ; print the exit request message
        call    print_string

        call    read_int          ; read integer the request teh exit or not

        cmp     eax, 0            ; Compare eax with zero (in this case), to do the brach
        je      end               ; if the previous compare is zero, the program finish
        jmp     start             ; if the previous compare isn't zero, the program continue

multiply:

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

        ;MULTIPLICACION

        mov     eax, [input1]     ; eax = dword at input1
        mov     ecx, [input2]     ; eax = eax * ebx
        mul     ecx
        mov     ebx, eax
        mov     eax, outmsg5
        showing_result

        dump_regs 1               ; dump out register values
        dump_mem 2, outmsg1, 1    ; dump out memory;

        mov     eax, msg_exit     ; print the exit request message
        call    print_string

        call    read_int          ; read integer the request teh exit or not

        cmp     eax, 0            ; Compare eax with zero (in this case), to do the brach
        je      end               ; if the previous compare is zero, the program finish
        jmp     start             ; if the previous compare isn't zero, the program continue

division:

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

        ;DIVISION
        mov     eax, [input1]     ; eax = dword at input1
        mov     ecx, [input2]     ; eax = eax / ecx
        div     ecx
        mov     ebx, eax 
        mov     eax, outmsg6
        showing_result

        dump_regs 1               ; dump out register values
        dump_mem 2, outmsg1, 1    ; dump out memory;

        mov     eax, msg_exit     ; print the exit request message
        call    print_string

        call    read_int          ; read integer the request teh exit or not

        cmp     eax, 0            ; Compare eax with zero (in this case), to do the brach
        je      end               ; if the previous compare is zero, the program finish
        jmp     start             ; if the previous compare isn't zero, the program continue

; next print out result message as series of steps
;
end:                             ; label to finish my program
        popa                      ;It extracts the information from the stack and puts it in the registers.
        mov     eax, 0            ; return back to C
        leave                     
        ret