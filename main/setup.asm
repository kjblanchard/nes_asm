.include "constants.inc"
.include "header.inc"
.include "reset.inc"
.include "ppu.inc"

.segment "ZEROPAGE"
Frame: .res 1 ; reserve 1 byte for the frame.
Seconds: .res 1 ; reserve 1 byte for total seconds;
BgPtr: .res 2 ; reserve 2 bytes to hold an address that we can use for a pointer

; PRG-ROM
.segment "CODE"
;.org $8000 ; this is always where we start the PRG-ROM

.proc LoadPaletteData ; loop through your Palette data, and send it to the PPU
    SET_PPU_ADDRESS $3F00
    ldx #0 ; use this as a i
:
    lda PaletteData,x
    sta PPUDATA
    inx
    cpx #32 ; compare to 32, as that is how many colors we have in our color palette
    bne :-
    rts
    inc Frame

.endproc

.proc LoadBackgroundData ; loop through your Palette data, and send it to the PPU, remember a byte can only go up to 255
    bit PPUSTATUS ; Ensure the latch is correct for PPU addr
    ;We want to start on nametable1 for loading the data in, so we are starting at memory location $2000
    SET_PPU_ADDRESS $2000
    ldx #0 ; use this as i for the outer loop
    ldy #0 ; use this as j for the inner loop
InnerLoop:
    lda (BgPtr),y ; Dereference the bgptr and then offset by y (which is 00-FF)
    sta PPUDATA
    iny
    cpy #0
    bne InnerLoop
OuterLoop:
    inx
    inc BgPtr+1 ; increment the first byte of the BgPtr by 1
    cpx #4 ; we need to do 3 loops, so if x gets to 4, we are done.
    bne InnerLoop
    rts
.endproc

.proc WriteText
    ;proc is a subroutine, which means the code will jump here, and store the memory address where we came from on the stack.  We pushed the regester we were at.
    SET_PPU_ADDRESS $21C8 ;Call to the macro to set the memory address we will draw the tile to, since an address is 16bits and registers are 8 bits, created a macro to handle the steps for conversion
    ldy #0 ;y is used for incrementing each letter, and we start at 0.  Load this value into register y (ldy)
    ;  # means it is a literal number, so it is 0
Start:
    lda Text,y ; Text is the location in memory of the FIRST LETTER in the message to write, and we are offsetting by y bytes.  We are loading this into register a (lda)
    ;we use the a register here since it is the only register that you can perform addition and subtraction on
    beq End ; if a is equal to 0, end the loop by jumping to the End label on line 83 (strings are null terminated which is zero), else continue down (Branch if equal, beq)
    cmp #$20 ; $20 in ascii is space (Compare the a register CMP)
    ; $20 means that it is in hex.  #$20 means it is the literal value $20.  If we didn't have the # then it would be what is in memory location $20
    beq DrawSpace ; if we are equal to #$20, then we should jump to the label DrawSpace
    cmp #65 ; check if it is greater than 65, which is a letter in ascii text
    bcs DrawLetter ; jump to the label DrawLetter if we are >=65 (branch if carry is set BCS)

    ; if we are not a space or a letter, then we continue down
DrawNumber:
    ;ascii #48 is 0,$00 is 0 In the spritesheet, so we need to offset by #48 to draw the numbers.
    sec ; always have to set the carry flag before subtracting (set carry, sec)
    sbc #48 ; subtract 48 from the a register
    jmp DrawText ; jump to the EndDrawText label
DrawLetter:
    ;ascii #65 is A, $0A is A in the spritesheet, so we need to offset by #55
    ; We only have uppercase letters in our sheet, so if the letter we are drawing starts at #97 (which is lowercase) we need to subtract #32
    cmp #97 ; check to see if a register is equal to 97
    bcc HandleLetter ; if we are <97, do not convert to uppercase and jump to HandleLetter
    sec ; you always need to set the carry flag before you subtract, else you get an answer that is off by one.
    sbc #32 ; subtract #32 to convert to uppercase
HandleLetter:
    sec
    sbc #55 ; Subtract #55 as that is our sprite:ascii offset
    jmp DrawText ; jump to the EndDrawText label
DrawSpace:
    lda #$24 ; $24 is the space character on the spritesheet
DrawText:
    sta PPUDATA ; Store the value in register a to the ppudata memory location, to draw on the screen, this automatically increments the ppumemoryaddress where it will store the next data
    iny ; increment Y so that we move to the next letter
    jmp Start ; jump back to the start
End:
    rts ; return from subroutine, Pop the value from the stack so we go back to the location in memory that jumped us here.
.endproc

Reset:
    ;; Reset happens when the nes is powered on or when the reset button is hit
    ;; We are grabbig this macro, it is like a C macro where it literally just pastes in the code from the macro in here
    INIT_NES
    ;init our zero page variables properly
    ldx #0
    sta Frame
    sta Seconds
InitializeBgPtr:
    ;Load the low byte and then the high byte into the Bgptr memory location, due to little endian
    ldx #< BackgroundData
    stx BgPtr
    ldx #> BackgroundData
    stx BgPtr+1


Main:
    ldx #0
    jsr LoadPaletteData
    jsr LoadBackgroundData
    jsr WriteText
    lda #%10010000           ; Enable NMI and set background to use the 2nd pattern table (at $1000)
    sta PPUCTRL
    lda #0
    sta PPUSCROLL           ; Disable scroll in X
    sta PPUSCROLL           ; Disable scroll in Y
    lda #%00011110
    sta PPUMASK             ; Set PPU_MASK bits to render the backgroundFor some reason, this needs to happen afterwards.  not enturely sure why


LoopForever:
    jmp LoopForever

NMI:
    inc Frame
    ldy Frame
    cpy #60
    bne :+ ; if Frame is not equal to 60, just return else reset Frame to 0 and increment seconds
    ldx #0
    stx Frame
    inc Seconds
:
    rti ; return from interrupt

IRQ:
    rti

PaletteData:
    .byte $22,$29,$1A,$0F, $22,$36,$17,$0F, $22,$30,$21,$0F, $22,$27,$17,$0F ; Background palette
    .byte $22,$16,$27,$18, $22,$1A,$30,$27, $22,$16,$30,$27, $22,$0F,$36,$17 ; Sprite palette



BackgroundData:
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$36,$37,$36,$37,$36,$37,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$35,$25,$25,$25,$25,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$39,$3A,$3B,$3A,$3B,$3A,$3B,$3C,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$39,$3A,$3B,$3C,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$45,$45,$53,$54,$45,$45,$53,$54,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$47,$47,$55,$56,$47,$47,$55,$56,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$60,$61,$62,$63,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$24,$31,$32,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$64,$65,$66,$67,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$24,$30,$26,$34,$33,$24,$24,$24,$24,$36,$37,$36,$37,$24,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6A,$24,$24,$24,$24
    .byte $24,$24,$24,$24,$30,$26,$26,$26,$26,$33,$24,$24,$35,$25,$25,$25,$25,$38,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6A,$24,$24,$24,$24
    .byte $B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5
    .byte $B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7
    .byte $B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B6
    .byte $B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7
    .byte $B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5
    .byte $B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7    ;The background data that we are going to load first for testing

AttributeData:
    .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .byte %00000000, %10101010, %10101010, %00000000, %00000000, %00000000, %10101010, %00000000
    .byte %00000000, %00000000, %00000000, %00000000, %11111111, %00000000, %00000000, %00000000
    .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .byte %11111111, %00000000, %00000000, %00001111, %00001111, %00000011, %00000000, %00000000
    .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

Text:
    .byte "Yoooo bois"

.segment "CHARS"
.incbin "./chr/mario.chr"

;NES goes to this section when the game is first turned on, so it knows where to go
; If we are starting at FFFA, and adding 3 16 bits to it, that will end our code
; ABCDEF, each is 8 bits, divided by 2 for 16 bit words
.segment "VECTORS"
;.org $FFFA
;address of the NMI handler
;word is a 16bit
.word NMI
;address of the Reset handler
.word Reset
;address of the IRQ handler
.word IRQ
