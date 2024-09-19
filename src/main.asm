INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/gameConstants.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

SECTION "Main", ROM0
EntryPoint:
    ;setup interupt handlers
    ei;Enable Interrupts
    nop
    
    ; turn on CH1-4
    ld a, %10000000
	ld [rNR52], a



    ;Setup timer registers
    ld a, %0000_0100
    ldh [$FF07], a;set TIMA incrementation rate to 4096Hz
    xor a
    ldh [$FF06], a;set Timer modulo to 0 so the Timer interupt will be requested every 1/16th of a sec
    
    ;init some timer values
    xor a
    ld [TimerCntr16thSec],a
    ld a, InputCD
    ld [FrameCntr], a

    ;wait StartVBlank
    call WaitStartVBlank

    ;turn off lcd
    xor a
    ld [rLCDC], a

    call ClearOAM

    ld de, TilesStart
    ld hl, $9000
    ld bc, TilesEnd-TilesStart
    call CopyMem

    ld hl, $8000
    ld de, SpriteTilesStart
    ld bc, SpriteTilesEnd-SpriteTilesStart
    call CopyMem

    ;-=-=- Temp puzzle select -=-=-

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

    call UpdateFrameCntr

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
    
    ;check B
    bit 1, b
    jr Z, .NotB

    ld hl, $99e0
    xor a

    rept 18;ñññ
    ld [hli], a
    endr

    ld hl, $99e0

    dec de
    ld a, [de];ld ofset into a 
    ld b, 0
    ld c, a
    add hl, bc ;add ofset to dst
    inc de
    
    call DrawString
.NotB

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
    jp TempLoop


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

    ;DE is pointing at start of the puzzle
    dec de;one byte before the puzzle is the time
    ld a, [de]
    ld [TimerDownSec], a
    dec de
    ld a, [de]
    ld [TimerDownMin], a
    inc de
    inc de;return de to the start of the puzzle

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

    ;vv ld de, Puzzle0End-3
    ld hl, CurrentPuzzle 
    call Ld_DE_word_HL

    ld a, e
    add a, 15
    ld e, a
    ld a, d
    adc a, 0
    ld d, a 
    ;^^

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
    ld a, WinTileID
    ld [CurrentTile], a

    ld a, 1;win
    ld [GameState], a
    jp GameDone
.NotYetWin
    
    call UpdateBTNS

    call WaitStartVBlank

    /*
    ;check if a life has been lost due to time
    ld a, [TimerHasReset]
    cp a, 1
    jr nz, .TimerHasNotReset
    ;reset the timerreset flag
    xor a
    ld [TimerHasReset], a

    ;put down an empty heart
    ld a, [CurrentHeartTileAdr+1]
    ld h, a
    ld a, [CurrentHeartTileAdr]
    ld l, a
    
    cp a, $42;is the player dead yet?
    */

    ld a, [TimerDownMin]
    ld b, a
    ld a, [TimerDownSec]
    or a, b
    jp nz, .StillAlive
    ld a, 1
    ld [TimerTileAdr], a;set the timer to 0 so user won't rage when they lose with "one second to spare"
    
    ld a, LoseTileID
    ld [CurrentTile], a

    ld a, 2;lose
    ld [GameState], a
    jp GameDone
.StillAlive

    /*ld [hl], $14
    dec hl

    ld a, h
    ld [CurrentHeartTileAdr+1], a
    ld a, l
    ld [CurrentHeartTileAdr], a
.TimerHasNotReset*/

    ;count down the input cooldown timer
    call UpdateFrameCntr
 
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

    ld a, [TimerDownMin]
    inc a
    ld [TimerTileAdr-2], a

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

    ;TEMP ññññ
    bit 2, b;check if Select
    jp NZ, EntryPoint

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

    ;trigger CH1, Don't enable the timer (never shuts down), nothing, Period (higher 3bits)
    ld a, %1_0_000_011
    ld [rNR14], a
    ;sweep periode (~ 1/f), direction (0: T inc -> f dec), Individual step ("speed")
    ;ld a, %0_111_1_011
    ;ld [rNR10], a
    ld a, $00
    ld [rNR13], a
    ;init vol, envelope dir, sweep speed
    ld a, %10000111
    ld [rNR12], a

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

    ld a, %1111_0_111
    ld [rNR43], a

    ;init vol, envelope dir, sweep speed
    ld a, %10000111
    ld [rNR14], a

    ld a, %10000000
    ld [rNR44],a

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

GameDone:
    call WaitStartVBlank
    xor a
    ld [_OAMRAM], a
    
.ScreenWipe0
    call WaitStartVBlank

    call ScreenWipe0

    ld a, [GenericWord+1]
    cp a, $9a;41
    jr nz, .ScreenWipe0

    ld a, [GenericWord]
    cp a, $41;de src, hl dst
   
    jr nz,.ScreenWipe0
    
    ld a, [GameState]
    cp a, 2;lost
    jr z, .lost

    ld hl, CurrentPuzzle
    call Ld_DE_word_HL;ld de, [CurrentPuzzle]

    ld hl, DrawNumsPuzzleStartAdr
    call Ld_word_HL_DE

    call DrawPuzzle

    ld hl, $99e0

    dec de
    ld a, [de];ld ofset into a 
    ld b, 0
    ld c, a
    add hl, bc ;add ofset to dst
    inc de
    
    call DrawString

    jr WaitTillHeatDeathOfUniverse

.lost
    ld hl, $98c6
    ld de, GameOverMSG.Line0
    call DrawString
    ld hl, $9905
    ld de, GameOverMSG.Line1
    call DrawString
    ld hl, $9947
    ld de, GameOverMSG.Line2
    call DrawString

WaitTillHeatDeathOfUniverse:
    call UpdateBTNS

    ld a, [CurrentBTNS]
    bit 0, a
    jp nz, EntryPoint

    jr WaitTillHeatDeathOfUniverse


INCLUDE "./src/include/charmap.inc"

INCLUDE "./src/assets/Sprites.z80"
INCLUDE "./src/assets/TilesSet0.z80"

GameOverMSG:
.Line0
db "YOU LOST", 255
.Line1
db "PLEASE TRY", 255
.Line2
db "AGAIN", $14, 255
