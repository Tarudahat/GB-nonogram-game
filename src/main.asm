INCLUDE "./src/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

;constants
DEF DrawRowsStartAdr EQU $98a5
DEF DrawColumnsStartAdr EQU $9891
DEF FilledTileID EQU $13 
DEF XTileID EQU $12
DEF HeartsStartTileAdr EQU $9844
DEF TimerTileAdr EQU $9864
DEF InputCD EQU 9

EntryPoint:
    ;setup interupt handlers
    ei;Enable Interrupts
    nop

    ;Setup timer registers
    ld a, %0000_0100
    ldh [$FF07], a;set TIMA incrementation rate to 4096Hz
    xor a
    ldh [$FF06], a;set Timer modulo to 0 so the Timer interupt will be requested every 1/16th of a sec
    
    ld a, $F0
    ld [TimerCntr16thSec],a
    ld a, $59
    ld [TimerDownSec], a
    ld a, InputCD
    ld [FrameCntr], a


    ; Shut down audio circuitry
	ld [rNR52], a

    call WaitStartVBlank

    ;turn off lcd
    xor a
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

    ;Temp puzzle select


    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a  
    
    xor a
    ld [GameState], a
    ld [GenericCntr], a
TempLoop:
    call UpdateBTNS

    call WaitStartVBlank

    ;show crnt selected lvl
    ld hl, $98E0
    ld a, [GenericCntr]
    inc a
    ld [hl], a
    dec a
    call WaitStartVBlank
    
    ;de src, hl dst, b cntr, c cntr
    ;SetCurrentPuzzle
    call SetCurrentPuzzle

    ld hl, DrawNumsPuzzleStartAdr
    call Ld_word_HL_DE

    call DrawPuzzle

    call UpdateFrameCooldownCntr

    ;handle input delay
    ld a, [FrameCntr]
    dec a
    jp nz, TempLoop

    ld a, [NewBTNS]
    ;check if BTN
    or a;cp a, 0
    jr z, .NoSetCD
    ld a, [FrameCntr]
    cp a, 1
    jr nz, .NoSetCD
    ld a, InputCD
    ld [FrameCntr], a;temp
    .NoSetCD

    ;load BTNS into b
    ld a, [CurrentBTNS]
    ld b, a

    ld a, [GenericCntr]
    
    ;check down
    bit 7, b
    jr Z, .NotDown
    dec a
    ld [GenericCntr], a
.NotDown       
    ;check up
    bit 6, b
    jr Z, .NotUp
    inc a
    ld [GenericCntr], a
.NotUp

    ;check if A
    ld a, [NewBTNS]

    bit 0, a
    jr Z, .NotA

    ld a, [PrevBTNS]
    bit 0, a
    jr NZ, .NotA
    
    jr PuzzleState
.NotA

    ld a, [NewBTNS]
    ld [PrevBTNS], a
    jr TempLoop


PuzzleState:
    nop
    call WaitStartVBlank

    ;turn off lcd
    xor a
    ld [rLCDC], a

    ld de, EmptyMap
    ld hl, $9800
    ld bc, 1024
    call CopyMem

    ld de, EmptyMap
    ld hl, PuzzleInMem-1
    ld bc, 19
    call CopyMem

    ;SetCurrentPuzzle
    call SetCurrentPuzzle

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

    ;init some values
    ld a, HIGH(HeartsStartTileAdr)
    ld [CurrentHeartTileAdr+1], a
    ld a, LOW(HeartsStartTileAdr)
    ld [CurrentHeartTileAdr], a

    ld a, $98
    ld [GenericWord+1], a
    ld a, $01
    ld [GenericWord], a

    ld a, 6*8+8
    ld [CursorPositionX], a
    ld a, 5*8+16
    ld [CursorPositionY], a
    xor a
    ld [CursorGridPositionX], a
    ld [CursorGridPositionY], a

Main:

    ;update timer
    call UpdateTimer

    ;check if win
    ;de src0, hl src1, bc data size
    ld hl, CurrentPuzzle
    call Ld_DE_word_HL
    ld hl, PuzzleInMem
    ld bc, 18
    call CpMem

    jr nz, .NotYetWin
    jp EntryPoint
.NotYetWin
    
    call UpdateBTNS

    call WaitStartVBlank

    ;check if a life has been lost due to time
    ld a, [TimerHasReset]
    cp a, 1
    jr nz, .TimerHasNotReset
    ;reset the timerreset flag
    xor a
    ld [TimerHasReset], a

    inc a
    ld [GameState], a

    ;put down an empty heart
    ld a, [CurrentHeartTileAdr+1]
    ld h, a
    ld a, [CurrentHeartTileAdr]
    ld l, a
    
    ld [hl], $14
    dec hl

    ld a, h
    ld [CurrentHeartTileAdr+1], a
    ld a, l
    ld [CurrentHeartTileAdr], a
.TimerHasNotReset

    ;count down the input cooldown timer
    call UpdateFrameCooldownCntr
 
    ;draw the timer
    ;a bin val IN, b BCD val out, c cntr, d  
    ld a, [TimerDownSec]
    and a, $0F
    inc a
    ld [TimerTileAdr], a

    ld a, [TimerDownSec]
    and a, $F0
    swap a
    inc a
    ld [TimerTileAdr-1], a

    ;handle input delay
    ld a, [FrameCntr]
    dec a
    jp nz, Main

    ld a, [NewBTNS]
    ;check if BTN
    and $F0
    
    or a;cp a, 0
    jr z, .NoSetCD
    ld a, [FrameCntr]
    cp a, 1
    jr nz, .NoSetCD
    ld a, InputCD
    ld [FrameCntr], a;temp
.NoSetCD

    ;free up c for keeping
    ld a, [CursorGridPositionY]
    ld c, a

    ;load BTNS into b
    ld a, [CurrentBTNS]
    ld b, a 

    ;move cursors with Dpad
    ld a, [CursorPositionY] 

    bit 7, b;check if Down
    jr Z, .NotDown
    inc c
    add a, 8
    ld [PrevBTNS], a;watch out these make the bit that it wants 0 but it might make things weird later
.NotDown   

    bit 6, b;check if Up
    jr Z, .NotUp
    dec c
    sub a, 8
    ld [PrevBTNS], a
.NotUp

    ld [CursorPositionY], a
    ld a, c
    ld [CursorGridPositionY], a
    

    ld a, [CursorGridPositionX]
    ld c, a

    ld a, [CursorPositionX] 

    bit 5, b;check if Left
    jr Z, .NotLeft
    dec c
    sub a, 8
    ld [PrevBTNS], a
.NotLeft

    bit 4, b;check if Right
    jr Z, .NotRight
    inc c
    add a, 8
    ld [PrevBTNS], a
.NotRight

    ld [CursorPositionX], a
    ld a, c
    ld [CursorGridPositionX], a
    ld c, 0

    ;get the tile at the cursor's position
    ;b posX, c posY
    ld a, [CursorPositionX]
    ld [_OAMRAM+1], a

    sub a, 8
    ld b, a

    ld a, [CursorPositionY]
    ld [_OAMRAM], a

    sub a, 16
    ld c, a

    call PixelPosition2MapAdr

    call WaitVBlank

    ld a, [hl]
    ld [CurrentTile], a

    ;check if A
    ld a, [NewBTNS]

    bit 0, a
    jr Z, .NotA

    ld a, [PrevBTNS]
    bit 0, a
    jr NZ, .NotA

    xor a
    ld [CurrentTile], a

    call SetTileAtCursor2OGTile

    cp a, FilledTileID;is not Filled in??
    jr NC, .DontFillTile
    ld [hl], FilledTileID

    ld a, FilledTileID
    ld [CurrentTile], a
.DontFillTile
    call TogglePuzzleBit
.NotA

    ld a, [NewBTNS]

    bit 1, a;check if B
    jr Z, .NotB

    ld a, [PrevBTNS]
    bit 1, a
    jr NZ, .NotB

    call SetTileAtCursor2OGTile

    cp a, XTileID;is not X-ed??
    jr NC, .NoPutX
    ld [hl], XTileID;put down X tile
    ld a, XTileID
    ld [CurrentTile], a

.NoPutX
    cp a, FilledTileID
    jr NZ, .NotB
    ld [hl], XTileID
    ld a, XTileID
    ld [CurrentTile], a
    call TogglePuzzleBit
.NotB

    ;make cursor white on filled tiles
    ld a, %11100100
    ld [rOBP0], a  

    ld a, [CurrentTile]
    cp a, FilledTileID
    jr NZ, .NoInvertCursorPal

    ld a, %00011011
    ld [rOBP0], a  
    .NoInvertCursorPal
    
    ld a, [NewBTNS]
    ld [PrevBTNS], a

    jp Main

INCLUDE "./src/include/puzzles.inc"

INCLUDE "./src/moreHLinst.asm"
INCLUDE "./src/miscFunctions.asm"
INCLUDE "./src/input.asm"
INCLUDE "./src/drawPuzzles.asm"
INCLUDE "./src/sprites.asm"
INCLUDE "./src/handlePuzzles.asm"

INCLUDE "./src/assets/TilesSet0.z80"
INCLUDE "./src/assets/Sprites.z80"


;9842
EmptyMap:
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$15,$15,$15,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$16,$4,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$10,$10,$10,$11,$10,$10,$10,$11,$10,$10,$10,$10,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0    
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$10,$10,$10,$11,$10,$10,$10,$11,$10,$10,$10,$10,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0    
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0

SECTION "GENERIC_VARS", WRAM0
    GenericCntr:db
    GenericCntr2:db
    FrameCntr:db
    ShiftedByte:db
    GenericWord:dw
    GameState:db

SECTION "TIMER_VARS", WRAM0
    TimerDownSec:db
    TimerCntr16thSec:db
    TimerHasReset:db

SECTION "PUZZLE_DRAWING_VARS", WRAM0
    DrawNumsState:db
    DrawNumstartAdr:dw
    DrawNumsPuzzleStartAdr:dw

SECTION "CURSOR_VARS", WRAM0
    CursorPositionY:db
    CursorPositionX:db
    CursorGridPositionY:db
    CursorGridPositionX:db
    CursorTileOffset:dw

SECTION "INPUT_VARS", WRAM0
    CurrentBTNS:db
    NewBTNS:db
    PrevBTNS:db

SECTION "PUZZLE_VARS", WRAM0
    CurrentTile:db
    OriginalTileID:db
    CurrentPuzzle:dw
    PuzzleInMem:ds 18
    CurrentHeartTileAdr:dw
