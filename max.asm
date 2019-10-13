;****************************************************************************************************************************************************
;*	Blank Simple Source File
;*
;****************************************************************************************************************************************************
;*
;*
;****************************************************************************************************************************************************

;****************************************************************************************************************************************************
;*	Includes
;****************************************************************************************************************************************************
	; system includes
	INCLUDE	"Hardware.inc"

	; project includes
	; INCLUDE	"blankasm.inc"


;****************************************************************************************************************************************************
;*	equates
;****************************************************************************************************************************************************


;****************************************************************************************************************************************************
;*	User Variables
;****************************************************************************************************************************************************

;****************************************************************************************************************************************************
;*	cartridge header
;****************************************************************************************************************************************************

	SECTION	"Org $00",ROM0[$00]
RST_00:	
	jp	$100

	SECTION	"Org $08",ROM0[$08]
RST_08:	
	jp	$100

	SECTION	"Org $10",ROM0[$10]
RST_10:
	jp	$100

	SECTION	"Org $18",ROM0[$18]
RST_18:
	jp	$100

	SECTION	"Org $20",ROM0[$20]
RST_20:
	jp	$100

	SECTION	"Org $28",ROM0[$28]
RST_28:
	jp	$100

	SECTION	"Org $30",ROM0[$30]
RST_30:
	jp	$100

	SECTION	"Org $38",ROM0[$38]
RST_38:
	jp	$100

	SECTION	"V-Blank IRQ Vector",ROM0[$40]
VBL_VECT:
	reti
	
	SECTION	"LCD IRQ Vector",ROM0[$48]
LCD_VECT:
	reti

	SECTION	"Timer IRQ Vector",ROM0[$50]
TIMER_VECT:
	reti

	SECTION	"Serial IRQ Vector",ROM0[$58]
SERIAL_VECT:
	reti

	SECTION	"Joypad IRQ Vector",ROM0[$60]
JOYPAD_VECT:
	reti
	
	SECTION	"Start",ROM0[$100]
	nop
	jp	Start

	; $0104-$0133 (Nintendo logo - do _not_ modify the logo data here or the GB will not run the program)
	DB	$CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	DB	$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	DB	$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	; $0134-$013E (Game title - up to 11 upper case ASCII characters; pad with $00)
	DB	"Max is cool"
		;0123456789A

	; $013F-$0142 (Product code - 4 ASCII characters, assigned by Nintendo, just leave blank)
	DB	"    "
		;0123

	; $0143 (Color GameBoy compatibility code)
	DB	$00	; $00 - DMG 
			; $80 - DMG/GBC
			; $C0 - GBC Only cartridge

	; $0144 (High-nibble of license code - normally $00 if $014B != $33)
	DB	$00

	; $0145 (Low-nibble of license code - normally $00 if $014B != $33)
	DB	$00

	; $0146 (GameBoy/Super GameBoy indicator)
	DB	$00	; $00 - GameBoy

	; $0147 (Cartridge type - all Color GameBoy cartridges are at least $19)
	DB	$00	; $19 - ROM + MBC5

	; $0148 (ROM size)
	DB	$01	; $01 - 512Kbit = 64Kbyte = 4 banks

	; $0149 (RAM size)
	DB	$00	; $00 - None

	; $014A (Destination code)
	DB	$00	; $01 - All others
			; $00 - Japan

	; $014B (Licensee code - this _must_ be $33)
	DB	$33	; $33 - Check $0144/$0145 for Licensee code.

	; $014C (Mask ROM version - handled by RGBFIX)
	DB	$00

	; $014D (Complement check - handled by RGBFIX)
	DB	$00

	; $014E-$014F (Cartridge checksum - handled by RGBFIX)
	DW	$00


;****************************************************************************************************************************************************
;*	Program Start
;****************************************************************************************************************************************************

	SECTION "Program Start",ROM0[$0150] ; This code chunk is stored in ROM0 at $0150
Start::
	;ld A, 5 ;  Load intermediate value into a
	;ld [$C000], A ; Load A into the memory address $C000
	
	; THE ACTUAL STUFF
	di ; Prevent hardware interrupts
	ld sp, $FFFE ; set stack to beginning
	call WAIT_VBLANK
	
	ld	a,0		;
	ldh	[rLCDC],a	;turn off LCD 
	
	call LOAD_TILE ; Perform a jump here and at 'jp loop' addr to stack
	call LOAD_LOOP
	
	call CLEAR_MAP
	call CLEAR_MAP_LOOP
	
	call LOAD_MAP
	call LOAD_LOOP
	
	ld	a,%11100100	;load a normal palette up 11 10 01 00 - dark->light
	ldh	[rBGP],a	;load the palette
	
	ld	a,%10010001		;  =$91 
	ldh	[rLCDC],a	;turn on the LCD, BG, etc
	
	jp Loop

Loop:: ; Don't let the program crash, just loop forever
	call WAIT_VBLANK
	ld a, [$FF43] ; Horizontal scroll
	inc a
	ld [$FF43], a
	
	ld a, [$FF42] ; Vertical scroll
	inc a
	ld [$FF42], a
	jp Loop
	

	SECTION "Subroutines",ROM0
WAIT_VBLANK::
	ldh	a,[rLY]		;get current scanline
	cp	$91			;Are we in v-blank yet?
	jp	nz,WAIT_VBLANK	;if A-91 != 0 then loop
	ret		
	
LOAD_TILE:: ; This is I guess stored at $0003
	ld de, TILES ; Load the address of the TILES into register pair hl
	ld hl, $8000 ; Point to VRAM
	ld bc, 16*2
	ret ; pop stack and jp to value stored in stack (in this case that would be 'jp loop')
	
LOAD_LOOP::
	; de contains tile pointer and hl contains VRAM pointer
	ld A, [de] ; Take the value at the tile pointer and put it into A
	ld [hl], A
	inc hl ; increment the VRAM pointer
	inc de ; increment the Tile pointer
	dec bc ; decrement our loop register
	; if b or c != 0
	ld a, b
	or c
	jp NZ, LOAD_LOOP ; if b or c is not zero, keep looping
	ret


CLEAR_MAP::
	ld hl, $9800 ; set to top of Map Ram (in VRAM)
	ld bc, $0401 ; Number of ram address to clear
	ret

CLEAR_MAP_LOOP::
	ld [hl], 1 ; set the map to zero
	inc hl ; inc the map pointer
	dec bc ; dec the loop counter
	ld a, b
	or c
	jp NZ, CLEAR_MAP_LOOP
	ret
	
LOAD_MAP::
	ld hl, $9800 ; start hl at the start of MAP0
	ld de, MAPDATA ; start de at the MAPDATA label
	ld bc, 20*3 ; I have 20 tiles I am loading at the moment
	ret
	

	SECTION "Tile",ROM0 ; This tiledata is stored in ROM0 (somewhere, idc where). Must be transfered to VRAM (first chunk to act as tiledata)
TILES::
; EMPTY TILE
DB $00,$00 ; columns are mirrored (both must be the same value to look right)
DB $00,$00 ; binary to hex for row of pixels
DB $00,$00 
DB $00,$00
DB $00,$00
DB $00,$00
DB $00,$00
DB $00,$00

; colors: [top: 1, bottom: 0] = low, [top: 0, bottom: 1] = medium, [top: 1, bottom: 1] = high
DB $00,%00000000
DB %00000100,%00100000 
DB $00,%00000000 
DB $42,%01000010 
DB $3C,%00111100 
DB $00,%00000000 
DB $00,%00000000 
DB $00,%00000000 

	SECTION "Map",ROM0
MAPDATA::
DB $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
DB $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
DB $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01

;*** End Of File ***