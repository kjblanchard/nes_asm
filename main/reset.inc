.macro INIT_NES
    ;reset happens when it is powered on or reset
    sei ; disables all irq interrupt requests
    cld ; nes does not have bcd, so we should clear the decimal mode flag
    ldx #$40
    stx $4017  ; disable APU frame IRQ
    ldx #$FF ; load stack pointer to the bottom of the stack (clears the stack pointer) stack is at 01FF, and pointer looks at the last 8 bits )FF)
    inx ; increment x so that it is 0
    stx $2000  ; disable NMI
    stx $2001  ; disable rendering
    stx $4010  ; disable DMC IRQs
    ;the blanks are needed to wait for the PPU to be ready to accept graphics
Vblank1:
    bit PPUSTATUS
    bpl Vblank1
MemLoop:
    ;; Loop all memory positions and 0 them out
    lda #$0 ; Load literal decimal 0 into A
    sta $0000,x ;The comma is basically ADD, so initially we are storing the value of a (0) into memory position 0 + ff, then it decrements
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx ; increment x
    bne MemLoop ; if not zero, loop to MemLoop
Vblank2:
    bit PPUSTATUS
    bpl Vblank2

.endmacro
