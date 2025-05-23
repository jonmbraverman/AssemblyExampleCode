;*******************************************************************************
;
; Module Name: 1ms Timebase with various counters of time with a state machine
; By: Jon Braverman
; Date: 12/3/2020
; Assignment: N/A
; Version 2.1
;
;*******************************************************************************
#include "msp430.h"                     ; #define controlled include file
;-------------------------------------------------------------------------------
_byte   EQU 1
_word   EQU 2
_long   EQU 4


        ; RAM Table
ORG     0200h
runtimems     DS _word
milliseconds  DS _word
tenths        DS _word
tenthscount   DS _word
seconds	      DS _word
minutes	      DS _word
hours	      DS _word
long_var      DS _long
temp_history  DS _word * 32
A_time_start       DS _word
A_time_delay  DS _word
A_state	      DS _byte  ; leave at the end of all word variable definitions
B_state       DS _byte  ; leave at the end of all word variable definitions
            ORG     0F800h                  ; Program Reset
            
            
;-------------------------------------------------------------------------------
RESET       mov.w   #0280h,SP               ; Initialize stackpointer
            mov.b   &CALBC1_1MHZ, &BCSCTL1  ; Load calibrated DCO 1MHZ pt 1/2
            mov.b   &CALDCO_1MHZ, &DCOCTL   ; Load calibrated DCO 1MHZ pt 2/2
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; 

            mov #0, runtimems
            mov #0, milliseconds
            mov #0, tenths
            mov #0, tenthscount
            mov #0, seconds
            mov #0, minutes
            mov.b #0, A_state
            mov #10, &A_time_delay

SetupC0     mov.w   #CCIE,&CCTL0            ; 
            mov.w   #1000,&CCR0            ;
SetupTA     mov.w   #TASSEL_2+MC_1,&TACTL   ; 
            bis.w   #GIE,SR                 ; 

SetupP1
            bis.b  #BIT0, &P1DIR

            

main    
            nop                             ; 
            call #StateMachineA
            nop          
	    jmp     main     
                  
;-------------------------------------------------------------------------------
StateMachineA:  ; LED Blinking Machine
;-------------------------------------------------------------------------------
          PUSH R10
          PUSH R11
; State Machine "A"                                            
           mov.b     &A_state, R11  ; Obtain a copy of A_state for local destructive use in determining state
           ; Determine state {0,1,2,3,defaultstate}
           sub.b      #00h, R11
           jeq	      Astate0
           sub.b      #01h, R11
           jeq        Astate1	
           sub.b      #01h, R11
           jeq        Astate2
           sub.b      #01h, R11
           jeq	      Astate3
           sub.b      #01h, R11
           jeq	      Astate4           
           jmp 	      Adefaultstate
                      
Astate0:
	   mov       &runtimems, &A_time_start	;	   
           add.b     #01h, &A_state      	; Else if 	, proceed to next state (next time through State Machine)
           jmp       Aswitchend      
Astate1:
           mov       &runtimems, R10
           sub       &A_time_start, R10
	   cmp       &A_time_delay, R10   	        ; If 
           jLO       Aswitchend                  ;  		, do not leave state 
           add.b     #01h, &A_state       	; Else if 	, proceed to next state (next time through State Machine)
           jmp       Aswitchend
Astate2:
           xor.b     #BIT0, &P1OUT
	   ;logical operation 		        ; If 
           ;j?        Aswitchend                  ;  		, do not leave state 
           add.b     #01h, &A_state      	; Else if 	, proceed to next state (next time through State Machine)
           jmp       Aswitchend
          
Astate3:
	   ;logical operation 		        ; If 
           ;j?        Aswitchend                  ;  		, do not leave state 
           mov.b     #00h, &A_state       	; Else if	, go back to state 0
           jmp       Aswitchend
Astate4:
	   ;logical operation 		        ; If 
           ;j?        Aswitchend                  ;  		, do not leave state 
           mov.b     #00h, &A_state       	; Else if	, go back to state 0
           jmp       Aswitchend           
Adefaultstate:
           mov.b     #00h, &A_state
Aswitchend:


          POP R11
          POP R10
           ret                                         
                                            
                                            
                                       
;-------------------------------------------------------------------------------
TA0_ISR;   1ms
;-------------------------------------------------------------------------------
;	   runtimems increments every ms and increments up to 65536 and resets to 0 (every 65.5536 seconds)
;	   milliseconds increments every ms and increments up to 1000 and resets to 0 (every second)
;	   tenths increments every 100 ms and increments up to 10 and resets to 0 (every second)
;          minutes increments every 1000 ms and increments up to 60 and resets to 0 (every minute)

        add #1,  &runtimems
	    add #1,  &milliseconds
        add #1,  &tenthscount
	    cmp #999, &milliseconds            
	    jlo donemscount	   
 	    mov #0,   &milliseconds
	    add #1, &seconds
	    cmp #59, &seconds
	    jlo donecount
        add #1, &minutes
	    mov #0, &seconds
donemscount



donecount:	    
	    

            reti                            ;		
                                            ;
;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     0FFFEh                  ; MSP430 RESET Vector
            DW      RESET                   ;
            ORG     0FFF2h                  ; Timer_A0 Vector
            DW      TA0_ISR                 ;
            END
