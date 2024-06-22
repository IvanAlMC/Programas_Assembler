%include "asm_io.inc"

%macro request_continue_or_exit 0
    pusha
    mov     eax, msg_exit     ; print the exit request message
    call    print_string

    call    read_int          ; read integer the request teh exit or not

    cmp     eax, 0            ; Compare eax with zero (in this case), to do the brach
    je      end               ; if the previous compare is zero, the program finish
    jmp     start             ; if the previous compare isn't zero, the program continue
    popa
%endmacro

segment .data

Message            db      "Find primes up to: ", 0                                 ;message to input a limit for the prime numbers
ResultMessage      db      "The addition of the inputed prime numbers is: ", 0      ;message to show the result of the addition of the founded prime numbers
Error              db      "Input a upper number ", 0                               ;message to show an error in the limit input
msg_exit           db     "Choose an option: Exit (0) or Continue (1): ", 0         ;message to request an option


segment .bss
Limit           resd    1               ; find primes up to this limit
Guess           resd    1               ; the current guess for prime
sum             resd    1   
 

segment .text
        global  asm_main
asm_main:


start:
        enter   0,0               ; setup routine
        pusha

        mov     eax,  Message
        call    print_string
        
        call    read_int             ; scanf("%u", & limit );
        mov     [Limit], eax

        mov     eax, 2               ; printf("2\n");
        call    print_int
        call    print_nl
        
        mov     eax, 3               ; printf("3\n");
        call    print_int
        call    print_nl
        
        cmp     byte [Limit], 1
        jle     errorNumeroMayor

        mov     eax, 2 
        add     [sum],eax              ; printf("2\n");

        cmp     byte [Limit], 2
        je      end_while_limit

        mov     eax, 3 
        add     [sum],eax               ; printf("3\n");
     
        cmp     byte [Limit], 3
        je      end_while_limit


        mov     dword [Guess], 5     ; Guess = 5;

while_limit:                         ; while ( Guess <= Limit )
        mov     eax,[Guess]
        cmp     eax, [Limit]
        jnbe    end_while_limit      ; use jnbe since numbers are unsigned
        mov     ebx, 3               ; ebx is factor = 3;

while_factor:
        mov     eax,ebx
        mul     eax                  ; edx:eax = eax*eax
        jo      end_while_factor     ; if answer won't fit in eax alone
        cmp     eax, [Guess]
        jnb     end_while_factor     ; if !(factor*factor < guess)
        mov     eax,[Guess]
        mov     edx,0
        div     ebx                  ; edx = edx:eax % ebx
        cmp     edx, 0
        je      end_while_factor     ; if !(guess % factor != 0)
        add     ebx,2                ; factor += 2;
        jmp     while_factor

end_while_factor:
        je      end_if               ; if !(guess % factor != 0)
        mov     eax,[Guess]          ; printf("%u\n")
        call    print_int
        call    print_nl
        add     [sum],eax
        mov     eax, [sum]

end_if:
        mov     eax,[Guess]
        add     eax, 2
        mov     [Guess], eax        ; guess += 2
        jmp     while_limit
       
end_while_limit:
        mov     eax, ResultMessage
        call    print_string
        mov     eax, [sum]
        call    print_int
        call    print_nl
        mov     byte [sum], 0
        request_continue_or_exit

errorNumeroMayor:
        mov     eax,Error
        call    print_string
        mov     byte [sum], 0
        request_continue_or_exit
end:                             ; label to finish my program
        popa                      ;It extracts the information from the stack and puts it in the registers.
        mov     eax, 0            ; return back to C
        leave                     
        ret



