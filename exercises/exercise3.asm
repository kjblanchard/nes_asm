.segment "HEADER" ; Don’t forget to always add the iNES header to your ROM files .org $7F00
.byte $4E,$45,$53,$1A,$02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.segment "CODE"
.org $8000
Reset:
    LDA #100
    CLC
    ADC #5
    SEC
    SBC #10
NMI: rti
IRQ: rti
; Define a segment called "CODE" for the PRG-ROM at $8000
; TODO:
; Load the A register with the literal hexadecimal value $82
; Load the X register with the literal decimal value 82
; Load the Y register with the value that is inside memory position $82
; NMI handler
; doesn't do anything
; IRQ handler
; doesn't do anything
.segment "VECTORS" ; Add addresses with vectors at $FFFA .org $FFFA
.word NMI
.word Reset
.word IRQ
; Put 2 bytes with the NMI address at memory position $FFFA
; Put 2 bytes with the break address at memory position $FFFC ; Put 2 bytes with the IRQ address at memory position $FFFE
