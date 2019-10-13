rgbasm -omGame/game.o max.asm
rgblink -omGame/game.gb mGame/game.o
rgbfix -v mGame/game.gb