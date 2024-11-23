;*******************************************************************************
;   ex5_adc.s43
;   Modified version of code from TI

;                MSP430G2xx3
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |      P1.1/INCH_1|<--- Analog Value
;
;******************************************************************

#include "msp430.h"

        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0F800h

init:   MOV.W   #0280h, SP        ; set up stack
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        BIS.B   #DIVS_3,&BCSCTL2        ; SMCLK/8
        MOV.W   #0000h, R14
        MOV.W   #0000h, R4  
setupP1:
        BIS.B   #001h, &P1DIR           ; P1.0 output
        
SetupADC10  
        mov.w   #INCH_1+ADC10DIV_3,&ADC10CTL1     ; ADC input on P1.1
        mov.w   #ADC10SHT_3+REFON+ADC10ON+ADC10IE,&ADC10CTL0 ;
        bis.b   #02h,&ADC10AE0          ; P1.1 ADC10 option select
        bis.W   #GIE,SR                         ; enable interrupts
main:   NOP                                     ; main program

;-----------------------------------------------------------------------
;         Student Code Section
;-----------------------------------------------------------------------








;-----------------------------------------------------------------------
continue:
        BIT.W   #0001h,R4                   ; if the conversion has already been started do nothing
        JC      main
        bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Start sampling/conversion
        BIS.W   #0001h,R4                   ; set bit to indicate a conversion has been started

        JMP main                           ; jump to main

ADC10_ISR:
        MOV.W   &ADC10MEM,R14              ; Store value
        BIC.W   #0001h,R4                  ; Allow a new conversion to take place

        reti
        
;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        ORG     0FFEAh                  ; ADC10 interrupt vector 
        DW      ADC10_ISR

        END
