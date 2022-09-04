.include "constants.inc"
.include "header.inc"
.include "reset.inc"

; PRG-ROM
.segment "CODE"
.org $8000 ; this is always where we start the PRG-ROM

.proc LoadPaletteData ; loop through your Palette data, and send it to the PPU
    bit PPUSTATUS   ; We are using this as due to us needing to clear the 'latch' remember you only have a 8 bit register putting in a 16 bit address for address, so you have to hit it twice.  Calling bi tmakes it so that it is always beginning and good practice
    ldx #$3F
    stx PPUADDR
    ldx $00
    stx PPUADDR
    ldx #0
:
    lda PaletteData,x
    sta PPUDATA
    inx
    cpx #32 ; compare to 32, as that is how many colors we have in our color palette
    bne :-
    rts
.endproc

.proc LoadBackgroundData ; loop through your Palette data, and send it to the PPU
    bit PPUSTATUS ; Ensure the latch is correct for PPU addr
    ;We want to start on nametable1 for loading the data in, so we are starting at memory location $2000
    ldx #$20
    stx PPUADDR
    ldx #$00
    stx PPUADDR
    ldx #0
:
    lda BackgroundData,x
    sta PPUDATA
    inx
    cpx #255
    bne :-
    rts
.endproc

.proc LoadAttributeData ; loop through your Palette data, and send it to the PPU
    bit PPUSTATUS ; Ensure the latch is correct for PPU addr
    ;We want to start on nametable1 for loading the data in, so we are starting at memory location $2000
    ldx #$23
    stx PPUADDR
    ldx #$C0
    stx PPUADDR
    ldx #0
:
    lda AttributeData,x
    sta PPUDATA
    inx
    cpx #16
    bne :-
    rts
.endproc


Reset:
    ;; Reset happens when the nes is powered on or when the reset button is hit
    ;; We are grabbig this macro, it is like a C macro where it literally just pastes in the code from the macro in here
    INIT_NES


Main:
    ldx #0
    jsr LoadPaletteData
    jsr LoadBackgroundData
    jsr LoadAttributeData
    ;For some reason, this needs to happen afterwards.  not enturely sure why
    lda #%10010000           ; Enable NMI and set background to use the 2nd pattern table (at $1000)
    sta PPUCTRL
    ldx #%00011110 ;load the value for the proper ppu mask things to show the data
    stx PPUMASK


LoopForever:
    jmp LoopForever

NMI:
    rti ; return from interrupt

IRQ:
    rti

PaletteData:
    .byte $22,$29,$1A,$0F, $22,$36,$17,$0F, $22,$30,$21,$0F, $22,$27,$17,$0F ; Background palette
    .byte $22,$16,$27,$18, $22,$1A,$30,$27, $22,$16,$30,$27, $22,$0F,$36,$17 ; Sprite palette



BackgroundData:
     ;The background data that we are going to load first for testing
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$60,$61,$62,$63,$24,$24,$24,$24
    .byte $24,$36,$37,$24,$24,$24,$24,$24,$39,$3a,$3b,$3c,$24,$24,$24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$64,$65,$66,$67,$24,$24,$24,$24
    .byte $35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6a,$24,$24,$24,$24
    .byte $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45
    .byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
    .byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

AttributeData:
    .byte %00000000, %00000000, %10101010, %00000000, %11110000, %00000000, %00000000, %00000000
    .byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

.segment "CHARS"
.incbin "./chr/mario.chr"

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
