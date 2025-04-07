;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
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

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

SetupP1
            bis.b   #BIT3, &P1REN           ; Enable pullup resistors for button
            bis.b   #BIT0, &P1DIR           ; Set P1.0 as output
            bis.b   #BIT1 + BIT2, &P1SEL    ; P1.1 = RXD, P1.2=TXD
            bis.b   #BIT1 + BIT2, &P1SEL2   ; P1.1 = RXD, P1.2=TXD
SetupUSCI_A0
            bis.b   #UCSSEL_2, &UCA0CTL1    ; SMCLK as input clock
            mov.b   #104, &UCA0BR0          ; Config baud rate divider 1MHz 9600
            mov.b   #0, &UCA0BR1            ; 1MHz 9600
            mov.b   #UCBRS0, &UCA0MCTL      ; Modulation UCBRSx = 1
            bic.b   #UCSWRST, &UCA0CTL1     ; **Initialize USCI state machine**
            bis.b   #UCA0RXIE, &IE2         ; Enable USCI_A0 RX interrupt


            bis.w   #GIE,SR                 ; Enable global interrupts

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

main
            nop
            bit.b   #BIT3, &P1IN
            jc      done
            bit.b   #UCA0TXIFG, &IFG2
            jnc     txfull
            mov.b   #'t', &UCA0TXBUF
txfull

done:
            jmp     main

                                            

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
