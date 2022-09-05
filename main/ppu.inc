.macro SET_PPU_ADDRESS val
    ;val is a 16 bit (2byte) address
    bit PPUSTATUS   ; We are using this as due to us needing to clear the 'latch' remember you only have a 8 bit register putting in a 16 bit address for address, so you have to hit it twice.  Calling bi tmakes it so that it is always beginning and good practice
    ldx #>val ; Gets the high bit of val
    stx PPUADDR
    ldx #<val ; gets the low bit of val
    stx PPUADDR
.endmacro

