;*******************************************************************************
;   MSP430G2xx3 Demo - Basic Clock, Output Buffered SMCLK, ACLK and MCLK/10
;
;   Description: Buffer ACLK on P1.0, default SMCLK(DCO) on P1.4 and MCLK/10 on
;   P1.1.
;   ACLK = LFXT1 = 32768, MCLK = SMCLK = default DCO
;   //* External watch crystal installed on XIN XOUT is required for ACLK *//	
;
;                MSP430G2xx3
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |       P1.4/SMCLK|-->SMCLK = Default DCO
;            |             P1.1|-->MCLK/10 = DCO/10
;            |        P1.0/ACLK|-->ACLK = 32kHz
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
SetupPx     bis.b   #013h,&P1DIR            ; P1.0,1,4 output direction
            bis.b   #011h,&P1SEL            ; P1.0,4 = ACLK,SMCLK
                                            ;
Mainloop    bis.b   #002h,&P1OUT            ; P1.1 = 1
            bic.b   #002h,&P1OUT            ; P1.1 = 0
            jmp     Mainloop                ; Repeat
                                            ;
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .end

