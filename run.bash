fname=egame
sOurce=eric


rgbasm -o $fname/$sOurce.o $sOurce.asm
rgblink -o $fname/game.gb $fname/$sOurce.o
rgbfix -v $fname/game.gb
