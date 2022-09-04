.PHONY: build
###############################################################################
# Rule to assemble and link all assembly files
###############################################################################
build:
	mkdir -p ./build
	ca65 main/setup.asm -o build/setup.o
	ld65 -C nes.cfg build/setup.o -o build/game.nes

###############################################################################
# Rule to remove all object (.o) files and cartridge (.nes) files
###############################################################################
clean:
	rm ./build/*

###############################################################################
# Rule to run the final cartridge .nes file in the FCEUX emulator
###############################################################################
run:
	fceux build/game.nes
