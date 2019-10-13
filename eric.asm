;********************************************************************************
;*	Blank Simple Source File
;*
;********************************************************************************
;*
;*
;********************************************************************************

;********************************************************************************
;*	Includes
;********************************************************************************
	; system includes
	INCLUDE	"Hardware.inc"

	; project includes
	;INCLUDE	"blankasm.inc"

;********************************************************************************
;*	CONSTANTS
;********************************************************************************


SECTION "Const",ROM0
VRA::
	db $80, $00


;********************************************************************************
;*	equates
;********************************************************************************


;********************************************************************************
;*	cartridge header
;********************************************************************************
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
	DB	"Eric Game",0,0
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
	DB	$00	; $01 - 512Kbit = 64Kbyte = 4 banks

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

;************************************
 SECTION "Tiles", ROM0

; Start of tile array. ; each pair of numbers: left: 2, right:1;  add to get bit color,
		       ; then put the binary representation in one row, starting from the top.
TILES::
DB %00000000,%00000000
DB %00000000,%00000000
DB %00000000,%00000000
DB %00000000,%00000000
DB %00000000,%00000000
DB %00000000,%00000000
DB %00000000,%00000000
DB %00000000,%00000000

DB %00000000,%00000000
DB %00100100,%00100100
DB %00000000,%00000000
DB %01111110,%01111110
DB %01111110,%01000010
DB %01000010,%01111110
DB %00111100,%00111100
DB %00000000,%00000000

DB %11111111, $FF
DB %11111111, $FF
DB %11111111, $FF
DB %11111111, $FF
DB %11111111, $FF
DB %11111111, $FF
DB %11111111, $FF
DB %11111111, $FF

SECTION "Map", ROM0
MAP::
DB $01,$01,$01,$01,$01,$01,$01,$01
DB $01,$01,$01,$01,$01,$01,$01,$01
DB $01,$01,$01,$01,$01,$01,$01,$01
DB $01,$01,$01,$01,$01,$01,$01,$01
DB $02
;********************************************************************************
;*	Program Start
;********************************************************************************

SECTION "Program Start",ROM0[$0150]
Start::    ;Program Code starts here.

	di
	ld sp, $FFFE
	call WAIT_VBLANK

	ld a,0
	ldh [rLCDC],a


	call LOAD_TILES ; load tile data starting at address in de
	call LOAD_LOOP

	call CLEAR_MAP
	call CLEAR_MAP_LOOP

	call LOAD_MAP
	call LOAD_LOOP
	
	call LOAD_PALETTE

	ld a, 1
	ld [$C000], a

	ld a, $91
	ldh [rLCDC],a


Mainloop:
	call WAIT_VBLANK

	ld a, [$C000]
	dec a
	ld [$C000], a
	cp 0  ; compares a to 0, in this case
	jp nz, Mainloop
	
	ld a, 3
	ld [$C000], a
	call SCROLLDOWN
	call SCROLLLEFT
	jp Mainloop



SECTION "Subroutines", ROM0

SCROLLLEFT::  ; $ff42-scrolly , $ff43-scrollx
	ld a, [$ff43]
	inc a
	ld [$ff43], a
	ret
SCROLLDOWN::
	ld a, [$ff42]
	dec a
	ld [$ff42], a
	ret
SCROLLRIGHT::
	ld a, [$ff43]
	dec a
	ld [$ff43], a
	ret
SCROLLUP::
	ld a, [$ff42]
	inc a
	ld [$ff42], a
	ret
WAIT_VBLANK::
	ldh A, [rLY]
	cp $91
	jp nz, WAIT_VBLANK
	ret
LOAD_PALETTE::
	ld A, %11100100 ;(11 -> 10 -> 01 -> 00 dark -> light)
	ldh [rBGP], A
	ret

LOAD_MAP::
	ld de, MAP
	ld hl, $9800
	ld bc, 33
	ret


LOAD_TILES::
	ld de, TILES
	ld hl, $8000  ; load address of vram into hl
	ld bc, 16*3
	ret

LOAD_LOOP::
	ld A,  [de]
	ld [hl], A
	inc hl
	inc de
	dec bc
	ld a, c		; if b||c != 0
	or b
	jp NZ, LOAD_LOOP	
	ret


CLEAR_MAP::
	ld hl, $9800
	ld bc, $0401  ; number of addresses for bg1
	ret

CLEAR_MAP_LOOP::
	ld [hl], 0
	dec bc
	inc hl
	ld a, b
	or c
	jp NZ, CLEAR_MAP_LOOP
	ret


;*** End Of File ***
