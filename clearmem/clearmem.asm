.include "constants.inc"
.include "header.inc"
.include "reset.inc"

; PRG-ROM
.segment "CODE"
.org $8000 ; this is always where we start the PRG-ROM


Reset:
    ;; Reset happens when the nes is powered on or when the reset button is hit
    ;; We are grabbig this macro, it is like a C macro where it literally just pastes in the code from the macro in here
    INIT_NES


Main:
    ;do something, make the make background $2A
    bit PPUSTATUS   ; We are using this as due to us needing to clear the 'latch' remember you only have a 8 bit register putting in a 16 bit address for address, so you have to hit it twice.  Calling bi tmakes it so that it is always beginning and good practice
    ldx #$3F
    stx PPUADDR
    ldx #$00
    stx PPUADDR
    ldx #$2A
    stx PPUDATA
    ldx #%00011110
    stx PPUMASK


LoopForever:
    jmp LoopForever

NMI:
    rti ; return from interrupt

IRQ:
    rti

;NES goes to this section when the game is first turned on, so it knows where to go
; If we are starting at FFFA, and adding 3 16 bits to it, that will end our code
; ABCDEF, each is 8 bits, divided by 2 for 16 bit words
.segment "VECTORS"
.org $FFFA
;address of the NMI handler
;word is a 16bit
.word NMI
;address of the Reset handler
.word Reset
;address of the IRQ handler
.word IRQ
