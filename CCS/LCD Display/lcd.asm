;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------

            .def    INIT_LCD                                   ; make it known to linker.
            .def	SET_LCD_POS
            .def	LCD_PRINT
            .def	LCD_WRITE
			.def    ROW_SEL

            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.


; Control output definitions
_LCD_RST_OUT_PORT .equ P1OUT
_LCD_RST_DIR_PORT .equ P1DIR
_LCD_RST_PIN .equ BIT1
_LCD_REG_OUT_PORT .equ P1OUT
_LCD_REG_DIR_PORT .equ P1DIR
_LCD_REG_PIN .equ BIT5
ROW_SEL .equ BIT6

;---------------------------------------; Purpose of Function – initializes required hardware for driver
INIT_LCD:                              ;--IN: no dynamic inputs (defines above)
;---------------------------------------; OUT: register, reset lines, and SPI data
        ; CONFIG SPI
        BIS.B #BIT2 + BIT4, &P1SEL
        BIS.B #BIT2 + BIT4, &P1SEL2
        BIS.B #UCCKPL + UCMSB + UCMST + UCSYNC, &UCA0CTL0  ; 3-pin, 8-bit SPI master
        BIS.B #UCSSEL_2, &UCA0CTL1                         ; SMCLK
        BIS.B #0x02, &UCA0BR0                              ; /2
        MOV.B #0,    &UCA0BR1
        MOV.B #0,    &UCA0MCTL                             ; No modulation
        BIC.B #UCSWRST, &UCA0CTL1                       ; **Initialize USCI state machine**

        ; CONFIG RESET PIN
        BIS.B #_LCD_RST_PIN, &_LCD_RST_DIR_PORT

        ; CONFIG REGISTER SELECT PIN
        BIS.B #_LCD_REG_PIN, &_LCD_REG_DIR_PORT

        PUSH R15
        MOV #2000, R15
        ; INITIALIZE LCD
        BIC.B #_LCD_RST_PIN, &_LCD_RST_OUT_PORT
loop1:
        SUB #1, R15
        JNZ  loop1

        BIS.B #_LCD_RST_PIN, &_LCD_RST_OUT_PORT
        MOV #20000, R15
loop2:
        SUB #1, R15
        JNZ  loop2

        BIC.B #_LCD_REG_PIN, &_LCD_REG_OUT_PORT
        MOV #0x30, R15
        CALL #LCD_WRITE
        MOV #2000, R15
loop3:
        SUB #1, R15
        JNZ  loop3

        MOV #0x30, R15
        CALL #LCD_WRITE
        MOV #0x30, R15
        CALL #LCD_WRITE
        MOV #0x39, R15
        CALL #LCD_WRITE
        MOV #0x14, R15
        CALL #LCD_WRITE
        MOV #0x56, R15
        CALL #LCD_WRITE
        MOV #0x6D, R15
        CALL #LCD_WRITE
        MOV #0x70, R15
        CALL #LCD_WRITE
        MOV #0x0C, R15
        CALL #LCD_WRITE
        MOV #0x06, R15
        CALL #LCD_WRITE
        MOV #0x01, R15
        CALL #LCD_WRITE

        MOV #10000, R15
loop4:
        SUB #1, R15
        JNZ  loop4

        ; R15 is already 0 due to above
        CALL #SET_LCD_POS

        POP R15
        ret


;-------------------------------; Purpose of Function – print a character on the display at the current position
SET_LCD_POS:                     ; IN: row as BIT6 of R15 and column as BIT0 to BIT3 in R15
;-------------------------------; OUT: spi data on simo and register select line
; Row 1 is DDRAM address 0 to 40 (only 0 to 15 usable on 16 character display)
; Row 2 is DDRAM address 64 to 103 (only 64 to 79 usable on 16 character display)
; Set address by setting MSB
        BIS.B #BIT7, R15
        BIC.B #_LCD_REG_PIN, &_LCD_REG_OUT_PORT
        CALL  #LCD_WRITE
        ret

;-------------------------------; Purpose of Function – print a character on the display at the current position
LCD_PRINT:                     ; IN: character to be transmitted in R15
;-------------------------------; OUT: spi data on simo, register select line

        BIS.B #_LCD_REG_PIN, &_LCD_REG_OUT_PORT
        CALL  #LCD_WRITE
        ret


;-------------------------------; Purpose of Function – sends a byte over spi port
LCD_WRITE:                     ; IN: byte to be transmitted in R15
;-------------------------------; OUT: spi data on simo

        MOV.B  R15, &UCA0TXBUF                 ; transmit character
wait_for_byte:
        BIT.B  #IFG2, &UCA0TXIFG
        JNC wait_for_byte
        ret
