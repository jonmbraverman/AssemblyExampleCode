;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
          ;  .cdecls C,LOST,"lcd.h"
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

            .ref    INIT_LCD                                   ; make it known to linker.
            .ref	SET_LCD_POS
            .ref	LCD_PRINT
            .ref	LCD_WRITE
            .ref 	ROW_SEL

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


        CALL    #INIT_LCD               ; Inialize LCD hardware on MSP430 and LCD registers

        MOV     #0, R10                 ; init location register
        MOV     #0, R11                 ; init number data register
        MOV     #'a', R12               ; init letter data register
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

main:   NOP                             ; main program


        MOV     R10, R15
        BIC     #ROW_SEL, R15           ; use row 1 (0)
        CALL    #SET_LCD_POS

        MOV     R11, R15
        ADD     #0x30, R15              ; convert binary number value to ascii
        CALL    #LCD_PRINT

        INC     R11                     ; calc next number to display
        CMP     #10, R11
        JLO     skipzero
        MOV     #0, R11
skipzero:

        MOV     R10, R15
        BIS     #ROW_SEL, R15           ; use row 2 (1)
        CALL    #SET_LCD_POS


        MOV     R12, R15                ; no conversion necessary because R12 started as ASCII value
        CALL    #LCD_PRINT


        INC     R12
        CMP     #'a' + 26, R12
        JLO     skipa
        MOV     #'a', R12
skipa:


        INC     R10
        AND     #0x0F, R10              ; only using first 16 columns and first row for numbers

        MOV     #100, R15               ; wait ~200ms between characters
        CALL    #sw_delay               ; by setting delay parameter to 100 and calling sw_delay

        JMP main                          ; jump to main
;------------------------------------------------------------------------------------


sw_delay
        PUSH    R14
outer_delay
        MOV     #1000, R14

inner_delay
          SUB     #1, R14
          JNZ     inner_delay

        SUB     #1, R15
        JNZ     outer_delay
        POP     R14
        RET
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
