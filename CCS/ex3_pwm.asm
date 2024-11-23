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
;            |         P1.6/TA1|--> CCR1 - 75% PWM
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
SetupP1     bis.b   #BIT6,&P1DIR            ; P1.6 output
            bis.b   #BIT6,&P1SEL            ; P1.6 TA1 option
SetupC0     mov.w   #512-1,&CCR0            ; PWM Period
SetupC1     mov.w   #OUTMOD_7,&TA0CCTL1        ; CCR1 reset/set
            mov.w   #384,&TA0CCR1              ; CCR1 PWM Duty Cycle	
SetupTA     mov.w   #TASSEL_2+MC_1,&TA0CTL   ; SMCLK, upmode
;-------------------------------------------------------------------------------
; Variable/register tnitialization section
;-------------------------------------------------------------------------------
            mov.w   #0, R5       
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
MAIN
            add     #1, R4
            cmp     #50000, R4
            jlo     sameduty
            add     #1, R5
            AND      #511, R5
            
sameduty:            
            
            mov.w   R5, &TA0CCR1
            nop                             ; Required only for debugger

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
