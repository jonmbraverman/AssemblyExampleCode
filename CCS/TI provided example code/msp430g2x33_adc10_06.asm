;*******************************************************************************
;   MSP430G2x33/G2x53 Demo - ADC10, Output Internal Vref on P1.4 & ADCCLK on P1.3
;
;   Description: Output ADC10 internal Vref on P1.4, toggling between two
;   available options, 2.5V and 1.5V. ADC10OSC also output on P1.3.
;
;                MSP430G2x33/G2x53
;             ----------------
;         /|\|             XIN|-
;          | |                |
;          --|RST         XOUT|-
;            |                |
;            |   P1.3/ADC10CLK|--> ADC10OSC ~ 3.5MHz - 6.5MHz
;            |         P1.4/A4|--> Vref
;
;   D. Dang
;   Texas Instruments Inc.
;   December 2010
;   Built with Code Composer Essentials Version: 4.2.0
;*******************************************************************************
 .cdecls C,LIST,  "msp430g2553.h"

;------------------------------------------------------------------------------
            .text                           ; Progam Start
;------------------------------------------------------------------------------
RESET       mov.w   #0280h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupADC10  mov.w   #CONSEQ_2,&ADC10CTL1    ; Repeat single channel
            mov.w   #REFOUT+REFON+MSC+ADC10ON,&ADC10CTL0; ADC10 and VRef
            mov.w   #30,&TACCR0             ; Delay to allow Ref to settle
            bis.w   #CCIE,&TACCTL0          ; Compare-mode interrupt.
            mov.w   #TACLR+MC_1+TASSEL_2,&TACTL; up mode, SMCLK
            bis.w   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
            bic.w   #CCIE,&TACCTL0          ; Disable timer interrupt
            dint                            ; Disable Interrupts
            bis.b   #010h,&ADC10AE0         ; P1.4 = ADC10 option select
            bis.b   #008h,&P1DIR            ; P1.3 = output directon
            bis.b   #008h,&P1SEL            ; P1.3 = ADC10OSC option select
                                            ;
Mainloop    bic.w   #ENC,&ADC10CTL0         ; ADC10 disable
            xor.w   #REF2_5V,&ADC10CTL0     ; Toggle Vref 1.5/2.5V
            bis.w   #ENC+ADC10SC,&ADC10CTL0 ; ADC10 enable, start conversion
Delay       mov.w   #00Fh,R15               ; Long Delay
            mov.w   #0,R14                  ;
Delay_1     dec.w   R14                     ;
            sbc.w   R15                     ;
            jnz     Delay_1                 ;
            jmp     Mainloop                ;
                                            ;
;-------------------------------------------------------------------------------
TA0_ISR;    ISR for TACCR0
;-------------------------------------------------------------------------------
            clr.w   &TACTL                  ; Clear Timer_A control registers
            bic.w   #LPM0,0(SP)             ; Exit LPM0 on reti
            reti                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int09"                ; Timer_A0 Vector
            .short  TA0_ISR                 ;
            .end

