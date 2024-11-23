;-------------------------------------------------------------------------------
; MSP430 PWM Example for use with TI Code Composer Assmebler

;   Modified version of code from TI
;   MSP430G2xx3 Demo - Timer_A, PWM TA0, Up Mode, DCO SMCLK
;
;   Description: This program generates one PWM output on P1.6 using
;   Timer_A configured for up mode. The value in CCR0, 512-1, defines the PWM
;   period and the value in CCR1 the PWM duty cycles.
;   ACLK = n/a, SMCLK = MCLK = TACLK = default DCO

;                MSP430G2xx3
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |         P1.1/TA0|<--- Capture
;            |             P1.2|---> Trigger
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
            bis.b   #BIT1, &P1SEL           ; enable TIMER A.0 
            bis.b   #BIT2, &P1DIR           ; configure as output
SetupTA 
            mov.w   #TASSEL_2+MC_2,&TACTL   ;

            ; CM_1 Capture mode: 1 - pos. edge 
            ; CCSIS_0  Capture input select 0 
            ; Capture mode: On
            mov.w   #CM_1 + CCIS_0 + SCS + CAP, &TA0CCTL0   ;
;-------------------------------------------------------------------------------
; Variable/register initialization section
;-------------------------------------------------------------------------------
            mov.w   #0, R5       
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

MAIN
		    add.w   #1, R5
			cmp 	#5000, R5
			jlo 	MAIN

           	xor.b  #BIT2, &P1OUT

			mov.w  &TA0CCR0, R6
			mov.w 	#0, &TA0R
			mov.w   #0, R5

			jmp MAIN
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

;------------------------------------------------------------------------------
; Global Variable declaraions
;------------------------------------------------------------------------------
