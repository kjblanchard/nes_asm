; This is the iNES header info
; This is a 16 byte header
.segment "HEADER"
.org $7F00
.byte $4E, $45, $53, $1A    ; This is 4 bytes with a break, see the readme for why we are setting this, iNES header
.byte $02 ;2 x 16kb of spac for prg rome
.byte $01 ; 8kb of space for chr rom
.byte %00000000
.byte %00000000
.byte $00
.byte $00 ; ntsc is 0, pal is 1
.byte $00
.byte $00,$00,$00,$00,$00
