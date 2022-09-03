###############################################################################
# Rule to assemble and link all assembly files
###############################################################################
build:
	mkdir -p ./build
	ca65 clearmem/clearmem.asm -o build/clearmem.o
	ld65 -C nes.cfg clearmem.o -o build/clearmem.nes

###############################################################################
# Rule to remove all object (.o) files and cartridge (.nes) files
###############################################################################
clean:
	rm ./build/*

###############################################################################
# Rule to run the final cartridge .nes file in the FCEUX emulator
###############################################################################
run:
	fceux build/clearmem.nes
