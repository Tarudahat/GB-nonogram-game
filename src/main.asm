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


    ld de, $98a5
    ld hl, DrawNumsRowStartAdr
    call Ld_word_HL_DE

    ld hl, $98a5
    ld de, Puzzle0Start
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

;reset HL to DrawNumsRowStartAdr and add 32 to HL
SetHLNextRow:
    ld  a, [DrawNumsRowStartAdr]
    add a, 32
    ld [DrawNumsRowStartAdr],a
    ld l, a

    ld a, [DrawNumsRowStartAdr+1]
    adc a, 0
    ld [DrawNumsRowStartAdr+1],a
    ld h, a
    ret

CpHLCurrentRowStart:
    ld a, [DrawNumsRowStartAdr]
    cp a, l
    jp Z, DrawRows12x12.SkipDrawNum;just an empty ret
    ld  a, [DrawNumsRowStartAdr+1]
    cp a, h
    ret


;de src, hl dst, c cntr, b cntr
DrawRows12x12:
    ld c, 4
    ld b, 1
    ld a, 0
    
    ld [DrawNumsState], a
    ld a, 24
    ld [GenericCntr], a
    ld a, [de]
    ld [ShiftedByte], a
.Mainloop
    ld a, [ShiftedByte]
    rrca
    ld [ShiftedByte], a

    call NC, .DrawNumTile

    ld a, b
    adc a, 0
    ld b, a

    dec c

    jr NZ, .Mainloop

    ld a, [DrawNumsState]

    ld c, 8
    inc de

    cp a, 2
    jr NZ, .NotState2
    inc de
.NotState2

    ld a, [DrawNumsState]

    cp a, 3
    jr NZ, .NotState3
    call SetHLNextRow
    call .DrawNumTile

    ld c, 4
    ld a, 255
    ld [DrawNumsState], a
.NotState3

    ld a, [de]
    ld [ShiftedByte], a 
    
    ld a, [DrawNumsState]

    cp a, 1
    jr NZ, .NotState1
    call SetHLNextRow
    call .DrawNumTile
    
    ld c, 4
    dec de
    dec de
    ld a, [de]
    swap a
    ld [ShiftedByte], a 
.NotState1

    ld a, [DrawNumsState]
    inc a
    ld [DrawNumsState], a

    ld a, [ShiftedByte]
    add a, 0
    jr Z, .SkipPut0Tile
    ld [hl], 1
    .SkipPut0Tile

    ;one chunk less to go
    ld  a, [GenericCntr]
    dec a
    ld  [GenericCntr], a

    jr NZ, .Mainloop

    ret

.DrawNumTile 
    ld a, 1
    xor a, b

    jr Z, .SkipDrawNum
    ld a, b
    ld [hld], a
    ld b, 1
.SkipDrawNum
    ret



INCLUDE "./src/assets/TilesSet0.z80"

Puzzle0Start:;12x12
    db %0011_1101
    db %1001_1101
    db %1111_0011

    db %0000_1111
    db %0001_0111
    db %0011_0100

    db %0001_0111
    db %0001_0111
    db %0001_0111

    db %0011_1101
    db %1001_1101
    db %1111_0011

    db %0001_1111
    db %0001_0111
    db %0001_0111

    db %0001_0111
    db %0001_0111
    db %0001_0111
Puzzle0End:

SECTION "VARS", WRAM0
    tmp16:dw
    ShiftedByte:db
    DrawNumsState:db
    GenericCntr:db
    DrawNumsRowStartAdr:dw