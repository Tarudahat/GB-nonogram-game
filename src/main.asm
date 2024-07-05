INCLUDE "./src/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

EntryPoint:
    ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

    call WaitVBlank

    ld a, 0
    ld [rLCDC], a

    ld de, TilesStart
    ld hl, $9000
    ld b, TilesEnd-TilesStart
    ;de src, hl dst, b data size
    call CopyMem


    ld hl, $98A5

    ld a, 0
    ld [DrawNumsFlags], a

    ld a, 18
    ld [GenericCntr], a

    ld de, Puzzle0Start
    ld a, [de]
    
    ld c, 4
    ld b, 1
    call DrawRows12x12

    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON; | LCDCF_OBJON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a
Done:
    jr Done

WaitVBlank:
    ld a, [rLY]
    cp a, 144
    jr C, WaitVBlank
    ret

;de src, hl dst, b data size
CopyMem:
    ld a, [de]
    inc de
    ld [hli],a
    dec b;one less byte
    jr NZ, CopyMem
    ret

;load DE into a WORD at HL
Ld_word_HL_DE:
    ld a,e
    ld [hli],a
    ld a,d
    ld [hl],a
    ret

;load WORD at HL into DE
Ld_DE_word_HL:
    ld a, [hli]
    ld e,a
    ld a, [hl]
    ld d,a
    ret

DrawRows12x12:
    rrca 

    ld [ShiftedByte], a

    jr C, .SkipDrawNum
    ld a, b
    ld [hld], a
    ld b, 0
.SkipDrawNum
    inc b

    ld a, [ShiftedByte]
    
    dec c
    jr NZ, DrawRows12x12

    ;check if in 4bit or 8bit read state
    ;DrawNumsFlags: modes <-> bit0: 0 = 4bit, 1 = 8bit
    ld a, [DrawNumsFlags]
    bit 0, a; Z if zero

    ld c, 8
    jr Z, .Was4bitmode
    ;was 8 bit mode so...
    ;set bit0 to 0
    ld c, 4
    ;check if using 1st half or scnd half
    ;bit1: 0 = 1st half, 1 = 2nd half
    bit 1, a

    jr NZ, .Was2ndhalf
    ;was 1st so...

    xor a, $3;toggle bit0 & bit1
    ld [DrawNumsFlags], a

    ld a, [GenericCntr];shouldn't the generic cntr start at 24? It detracts on every "chunk" 4bit or 8 bit nvm 18 is correct
    dec a
    ld [GenericCntr], a

    dec de
    ld a, [de]
    swap a
    jr DrawRows12x12; never ending on 1st half 4bit mode so no check needed
.Was2ndhalf    
    xor a, $3;toggle bit0 & bit1
    ld c, 4
    inc de
    ld a, b
    ld [hld], a
    ld b, 0
.Was4bitmode ;aaaaaaa

    bit 1, a;aaaaaa

    jr NZ, .Was2ndhalf;aaaaaa

    xor a, $1;toggle bit0
    ld [DrawNumsFlags], a

    inc de

    ld a, [GenericCntr]
    dec a
    ld [GenericCntr], a

    ld a, [de]

    jr NZ, DrawRows12x12

    ret

INCLUDE "./src/assets/TilesSet0.z80"

Puzzle0Start:;12x12
    db %0011_0111
    db %0111_1111

    db %1111_0011
    db %0001_1111

    db %0001_0111
    db %0001_0111
    db %0001_0111
    db %0001_0111
    db %0001_0111
    db %0001_0111
    db %0001_0110
    db %0001_0111
Puzzle0End:

SECTION "VARS", WRAM0
    tmp16:dw
    ShiftedByte:db
    DrawNumsFlags:db
    GenericCntr:db