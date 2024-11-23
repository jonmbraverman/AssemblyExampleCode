;-------------------------------------------------------------------------------
; MSP430 Assembler "variable example" for use with TI Code Composer Assmebler
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

;-------------------------------------------------------------------------------
; Variable/register tnitialization section
;-------------------------------------------------------------------------------
			mov.w #0, R5
			mov.w #01234h, R4
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
MAIN
			mov.b R5, &byte1
			mov.w #0x1234, &byte1
			mov.w &byte1, &word1
			mov.b R5,&byte1
			mov.w #0x1234,&byte1
			mov.w &byte1,&word1
			mov.w R4, array1(R5)
			inc.w R4  ; next value
			add.w #0x02, R5  ; next location
                                            
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
_byte .equ 1
_word .equ 2
			; Declaring a variable is a two-step process
			; 	1) reserve memory with a name (variable)
			;   2) declare the variable as global to make it "visable"
			; Syntax Description
			; [keyword to reserve memory]		[name of variable] , [size in bytes]
			; .bss								word1              , _2 (_word is equated to 2)

			; [keyword to declare the variable as global] 	[name of variable]
			; .global 										word1

			.bss   word1 , _word				; Reserve a word (2 bytes) named "word1"
			.global word1
			
			.bss  array1 , (_word * 32)
			.global array1

			.bss   word2 , _word				; Reserve a word (2 bytes) named "word1"
			.global word2

			.bss	byte1, _byte
			.global byte1

			.bss	byte2, _byte
			.global byte2

