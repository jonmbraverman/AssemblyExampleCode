;-------------------------------------------------------------------------------
; MSP430 ADC Example for use with TI Code Composer Assmebler

;   Modified version of code from TI
;  
;                MSP430G2xx3
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |      P1.1/INCH_1|<--- Analog Value

;
;-------------------------------------------------------------------------------*
            .cdecls C,LIST,"msp430.h"       ; Include device header file            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
;------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Hardware Initialization section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
            bis.b   #DIVS_3,&BCSCTL2        ; SMCLK/8
setupP1:
        BIS.B   #001h, &P1DIR           ; P1.0 output
        
SetupADC10  
        mov.w   #INCH_1+ADC10DIV_3,&ADC10CTL1     ; ADC input on P1.1
        mov.w   #ADC10SHT_3+REFON+ADC10ON+ADC10IE,&ADC10CTL0 ;
        bis.b   #02h,&ADC10AE0          ; P1.1 ADC10 option select
        bis.W   #GIE,SR                         ; enable interrupts

;-------------------------------------------------------------------------------
; Variable/register initialization section
;-------------------------------------------------------------------------------

        MOV.W   #0000h, R14
        MOV.W   #0000h, R4  
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

MAIN






        BIT.W   #0001h,R4                   ; if the conversion has already been started do nothing
        JC      MAIN
        bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Start sampling/conversion
        BIS.W   #0001h,R4                   ; set bit to indicate a conversion has been started



		jmp MAIN




;-------------------------------------------------------------------------------
; Subroutines here
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
; Interrupt Service Routines here
;-------------------------------------------------------------------------------
ADC10_ISR:
            MOV.W   &ADC10MEM,R14              ; Store value
            BIC.W   #0001h,R4                  ; Allow a new conversion to take place

            reti        

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
            .sect   ".int05"
            .short  ADC10_ISR

;------------------------------------------------------------------------------
; Global Variable declaraions
;------------------------------------------------------------------------------
