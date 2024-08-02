INCLUDE "./src/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

;constants
DEF DrawRowsStartAdr EQU $98a5
DEF DrawColumnsStartAdr EQU $9891
DEF FilledTileID EQU $13 

EntryPoint:
    ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a
    ;ld sp, $E000


    call WaitVBlank

    ;turn of lcd
    ld a, 0
    ld [rLCDC], a

    call ClearOAM

    ld de, TilesStart
    ld hl, $9000
    ld bc, TilesEnd-TilesStart
    ;de src, hl dst, bc data size
    call CopyMem

    ld hl, $8000
    ld de, SpriteTilesStart
    ld bc, SpriteTilesEnd-SpriteTilesStart
    call CopyMem

    ld de, EmptyMap
    ld hl, $9800
    ld bc, 1024
    call CopyMem

    ;set current puzzle
    ld de, Puzzle0Start
    ld hl, CurrentPuzzle
    call Ld_word_HL_DE


    ;draw num rows 
    ld de, DrawRowsStartAdr
    ld hl, DrawNumstartAdr
    call Ld_word_HL_DE

    ld hl, CurrentPuzzle
    call Ld_DE_word_HL;ld de, [CurrentPuzzle]
    ld hl, DrawRowsStartAdr

    call DrawRows12x12
    
    ;draw num columns
    ld de, DrawColumnsStartAdr
    ld hl, DrawNumstartAdr
    call Ld_word_HL_DE


    ld hl, CurrentPuzzle ;ld de, Puzzle0End-3
    call Ld_DE_word_HL

    ld a, e
    add a, 15
    ld e, a
    ld a, d
    adc a, 0
    ld d, a 

    ld hl, DrawNumsPuzzleStartAdr
    call Ld_word_HL_DE

    ld hl, DrawColumnsStartAdr

    call DrawColumns12x12

    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a  

    ld a, 6*8+8
    ld [CursorPositionX], a
    ld a, 5*8+16
    ld [CursorPositionY], a
Main:
    call WaitVBlank
    
    call UpdateBTNS
 

    ld a, [GenericCntr]
    cp 1
    sbc 1 ; subtracts 1 if nonzero
    ld [GenericCntr], a
    jr nz, Main

    ld a, 5
    ld [GenericCntr], a

    ld a, [CurrentBTNS]
    ld b, a 

    ld a, [CursorPositionY] 

    bit 7, b;check if Down
    jr Z, .NotDown
    add a, 8
    ld [PrevBTNS], a;watch out these make the bit that it wants 0 but it might make things weird later
.NotDown   

    bit 6, b;check if Up
    jr Z, .NotUp
    sub a, 8
    ld [PrevBTNS], a
.NotUp

    ld [_OAMRAM], a
    ld [CursorPositionY], a

    ld a, [CursorPositionX] 

    bit 5, b;check if Left
    jr Z, .NotLeft
    sub a, 8
    ld [PrevBTNS], a
.NotLeft

    bit 4, b;check if Right
    jr Z, .NotRight
    add a, 8
    ld [PrevBTNS], a
.NotRight

    ld [_OAMRAM+1], a

    ld [CursorPositionX], a

    ;call CheckWin; TO DAMN SLOW
    ld a, 5
    ld [GenericCntr], a

    ;get the tile at the cursor's position
    ;b posX, c posY
    ld a, [CursorPositionX]

    sub a, 8
    ld b, a

    ld a, [CursorPositionY]
    sub a, 16
    ld c, a

    call PixelPosition2MapAdr

    ld a, [NewBTNS]

    bit 0, a;check if A
    jr Z, .NotA

    ld a, [PrevBTNS]
    bit 0, a
    jr NZ, .NotA

    ld a, [hl]
    ld [hl], $E

    
    cp a, $0E;is empty??
    jr NZ, .NotA
    ld [hl], FilledTileID
.NotA

    ld a, [NewBTNS]

    bit 1, a;check if B
    jr Z, .NotB

    ld a, [PrevBTNS]
    bit 1, a
    jr NZ, .NotB

    ld [hl], $12
.NotB

    ld a, [NewBTNS]
    ld [PrevBTNS], a

    ld a, %11100100
    ld [rOBP0], a  
    
    ld a, [hl]
    cp a, FilledTileID
    jp NZ, Main

    ld a, %00011011
    ld [rOBP0], a  

    jp Main

WaitVBlank:
    ld a, [rLY]
    cp 144
    jr nc, WaitVBlank;continue when rLY == 144
.Wait2MakeSure
    ld a, [rLY]
    cp a, 144
    jr C, .Wait2MakeSure;continue When rLY > 144 else wait for that to make sure 
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

INCLUDE "./src/input.asm"
INCLUDE "./src/moreHLinst.asm"
INCLUDE "./src/drawPuzzles.asm"
INCLUDE "./src/sprites.asm"

INCLUDE "./src/assets/TilesSet0.z80"
INCLUDE "./src/assets/Sprites.z80"

Puzzle0Start:;12x12
    db %1001_0001
    db %1000_0000;_0001
    db %1001_1111;_1001

    db %1001_1001
    db %1001_1111;_1001
    db %1011_1111;_1001
    
    db %1001_1001
    db %1001_1111;_1001
    db %1001_1111;_1001
    
    db %0101_0001
    db %1000_0000;_0001
    db %1001_0000;_0101
    
    db %0001_0001
    db %1011_1001;_0001
    db %1001_0000;_0001
    
    db %0011_0001
    db %1000_0000;_0001
    db %1000_0000;_0011
Puzzle0End:

CheckWin:
    ;load WORD at HL into DE
    ld hl, CurrentPuzzle
    call Ld_DE_word_HL

    ld hl, DrawColumnsStartAdr
    ld bc, 32
    add hl, bc

    ld bc, 36

    ld a, 4
    ld [GenericCntr], a

    ld a, 11
    ld [GenericCntr2], a

    ld a, [de]
.SmallLoop
    rra

    ld [ShiftedByte], a;store the shifted byte for the next round

    jr NC, .ShouldBeEmpty
    call BusyWait4FreeVRAM
    ;this puzzle tile should be filled in, is it?
    ld a, [hl];put the current tile id in a
    cp a, FilledTileID;is it?
    jr Z, .AllIsFine
    ret;it wasn't so stop checking
.ShouldBeEmpty
    ;this puzzle tile should be Empty, is it?
    call BusyWait4FreeVRAM
    ld a, [hl];put the current tile id in a
    cp a, FilledTileID;is it?
    jr NZ, .AllIsFine
    ret;it wasn't so stop checking
.AllIsFine
    dec hl

    ld a, [GenericCntr]
    dec a
    ld [GenericCntr], a 

    ld a, [ShiftedByte]
    jr NZ, .SmallLoop

    ;Done with a 4 bit chunk
    add hl, bc; check next row 

    ld a, 4
    ld [GenericCntr], a

    ld a, [GenericCntr2]
    bit 0, a
    ;if GenericCntr2 was even ld a, [de] + swap a
    ;if GenericCntr2 was uneven inc de x3 + ld a, [de]
    jr NZ, .WasEven
    ;was uneven
    inc de
    inc de
    inc de
    ld a, [de]
    ld [ShiftedByte], a

    jr .WasUneven
.WasEven
    ld a, [de]
    swap a
.WasUneven
    ld [ShiftedByte], a

    ld a, [GenericCntr2]
    dec a
    ld [GenericCntr2], a 

    ld a, [ShiftedByte]
    jr NZ, .SmallLoop

    ld a, 8
    ld [$9800], a
    ret

BusyWait4FreeVRAM:
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, BusyWait4FreeVRAM
    ret

EmptyMap:
    db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$E,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
    db $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0

SECTION "VARS", WRAM0
    GenericCntr:db
    GenericCntr2:db
    ShiftedByte:db
    DrawNumsState:db
    DrawNumstartAdr:dw
    DrawNumsPuzzleStartAdr:dw
    
    CursorPositionY:db
    CursorPositionX:db
    
    CurrentBTNS:db
    NewBTNS:db
    PrevBTNS:db

    CurrentPuzzle:dw

