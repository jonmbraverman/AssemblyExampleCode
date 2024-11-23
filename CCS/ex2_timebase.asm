;-------------------------------------------------------------------------------
; MSP430 Assembler "timebase example" for use with TI Code Composer Assmebler
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
            mov.b   &CALBC1_1MHZ, &BCSCTL1  ; Load calibrated DCO 1MHZ pt 1/2
            mov.b   &CALDCO_1MHZ, &DCOCTL   ; Load calibrated DCO 1MHZ pt 2/2
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupC0     mov.w   #CCIE,&TA0CCTL0            ; 
            mov.w   #1000,&TA0CCR0            ;
SetupTA     mov.w   #TASSEL_2+MC_1,&TA0CTL   ; 
            bis.w   #GIE,SR                 ; 
SetupP1
            bis.b  #BIT0, &P1DIR
;-------------------------------------------------------------------------------
; Variable/register Initialization section
;-------------------------------------------------------------------------------
            mov #0, &runtimems
            mov #0, &milliseconds
            mov #0, &tenths
            mov #0, &tenthscount
            mov #0, &seconds
            mov #0, &minutes
            mov #10, &A_time_delay
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
MAIN

                                            
			jmp MAIN




;-------------------------------------------------------------------------------
; Subroutines here
;-------------------------------------------------------------------------------








;-------------------------------------------------------------------------------
TA0_ISR;    1ms
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
	    

            reti                                                  ;

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".int09"                ; Timer_A0 Vector
            .short  TA0_ISR                 ;
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;------------------------------------------------------------------------------
; Global Variable declaraions
;------------------------------------------------------------------------------
_byte .equ 1
_word .equ 2
_long .equ 4
			; Declaring a variable is a two-step process
			; 	1) reserve memory with a name (variable)
			;   2) declare the variable as global to make it "visable"
			; Syntax Description
			; [keyword to reserve memory]		[name of variable] , [size in bytes]
			; .bss								word1              , _2 (_word is equated to 2)

			; [keyword to declare the variable as global] 	[name of variable]
			; .global 										word1

			.bss   runtimems , _word			
			.global runtimems

			.bss   milliseconds , _word				
			.global milliseconds

			.bss   tenths , _word				
			.global tenths

			.bss   tenthscount, _word
			.global tenthscount

			.bss   seconds, _word
			.global seconds

			.bss   minutes, _word
			.global minutes

			.bss   hours, _word
			.global hours

			.bss   A_time_start, _word
			.global A_time_start

			.bss   A_time_delay, _word
			.global A_time_delay

            .end

