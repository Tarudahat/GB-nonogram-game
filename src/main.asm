INCLUDE "./src/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

EntryPoint:
    ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a
    ;ld sp, $E000


    call WaitVBlank

    ld a, 0
    ld [rLCDC], a

    ld de, TilesStart
    ld hl, $9000
    ld bc, TilesEnd-TilesStart
    ;de src, hl dst, bc data size
    call CopyMem

    ld de, EmptyMap
    ld hl, $9800
    ld bc, 1024
    call CopyMem

    ;draw num rows 
    ld de, $98a5
    ld hl, DrawNumstartAdr
    call Ld_word_HL_DE

    ld hl, $98a5
    ld de, Puzzle0Start
    call DrawRows12x12
    
    ;draw num columns
    ld de, $9891
    ld hl, DrawNumstartAdr
    call Ld_word_HL_DE

    ld de, Puzzle0End-3
    ld hl, DrawNumsPuzzleStartAdr
    call Ld_word_HL_DE

    ld hl, $9891

    call DrawColumns12x12

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

;de src, hl dst, bc data size
CopyMem:
    ld a, [de]
    inc de
    ld [hli],a
    dec bc;one less byte
    ld a, b
    or a, c
    jr NZ, CopyMem
    ret


INCLUDE "./src/MoreHLinst.asm"
INCLUDE "./src/DrawPuzzles.asm"

INCLUDE "./src/assets/TilesSet0.z80"

Puzzle0Start:;12x12
    db %0001_0001
    db %1000_0000;_0001
    db %1001_1111;_0001

    db %0001_0001
    db %1001_1111;_0001
    db %1011_1111;_0001
    
    db %0001_0001
    db %1001_1111;_0001
    db %1001_1111;_0001
    
    db %1001_0001
    db %1000_0000;_0001
    db %1001_0000;_1001
    
    db %0001_0001
    db %1011_1001;_0001
    db %1001_0000;_0001
    
    db %0011_0001
    db %1000_0000;_0001
    db %1000_0000;_0011
Puzzle0End:

EmptyMap:
    db 255, 0

SECTION "VARS", WRAM0
    GenericCntr:db
    GenericCntr2:db
    ShiftedByte:db
    DrawNumsState:db
    DrawNumstartAdr:dw
    DrawNumsPuzzleStartAdr:dw
