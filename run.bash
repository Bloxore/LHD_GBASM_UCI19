fname=egame
sOurce=eric


rgbasm -o $fname/$sOurce.o $sOurce.asm
rgblink -i $fname/game.gb $sOurce.o
rgbfix -v $fname/game.gb
