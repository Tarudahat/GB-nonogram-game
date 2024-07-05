INCLUDE "./src/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

    call WaitVBlank

    ;turn off LCD
    ld a, 0
    ld [rLCDC],a

    ld de, TilesStart;source
    ld bc, TilesEnd - TilesStart;data blk length
    ld hl, $9000;destination

    call CopyMem


    ld de, TileMap0Start;source
    ld bc, TileMap0End - TileMap0Start;data blk length
    ld hl, $9800;destination

    call CopyMem

    ;hl dest, de source
    ;b used as counter (should be 1 from start)
    ld hl, $9825

    ld de, DrawPuzzleNumRowsSmallCurrentYPosAdr
    call Ld_adrDE_HL
    
    ld b, 1

    ;8 bits/byte
    ld a, 8
    ld [DrawPuzzleNumRowsSmallCurrentBit],a
    
    ;15 rows
    ld a, 15
    ld [DrawPuzzleNumSmallCurrentRow],a

    ld de, PuzzleSmall0Start

    call DrawPuzzleNumsRowsSmall


    ld hl, $988D;Ñ^*Ñ^Ñ*^Ñ^Ñ

    ld de, DrawPuzzleNumColumnsSmallCurrentXPosAdr
    call Ld_adrDE_HL

    ;9 rows
    ld a, 9
    ld [DrawPuzzleNumSmallCurrentRow], a
    
    ;7 columns  
    ld a, 0
    ld [DrawPuzzleNumColumnsSmallCurrentColumn], a
    ;yeah we reading these backwards
    ld hl, PuzzleSmall0End-1
    ld de, DrawColumnsSmallEndAdr
    call Ld_adrDE_HL

    ld b,1
    call DrawPuzzleNumsColumnsSmall

    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a

    ld a, %11100100
    ld [rOBP0], a


Done:
    jr Done

WaitVBlank:
    ld a, [rLY]
    cp 144
    jr C, WaitVBlank

    ret 

;hl dest, de source, bc counter/data block length
CopyMem:
    ld a,[de];grab src byte
    ld [hli],a;put in dest at hl, then inc hl
    inc de;inc de to get next byte
    dec bc;one byte less to go

    ld a, b;check if any bytes left to go
    or c

    jr NZ, CopyMem
    ret

;loads HL into the adress at DE
Ld_adrDE_HL:
    ld a,l
    ld [de],a
    ld a,h
    inc de
    ld [de],a
    ret

;Subtracts 32 from HL
Sub_HL_32:
    ld  a, l
    sub a, 32
    ld l, a

    ld a, h
    sbc a, 0
    ld h, a
    ret

;subtract num from word at adress

;hl start dest, de source
;b used as counter (should be 1 from start)
DrawPuzzleNumsRowsSmall:
    ld a, [de]
  
    ;if the row is empty put a 0 and move on
    or a, 0 
    jr NZ, .DrawCurrentRow
    ld [hl], 1
    jp .SkipRow
.DrawCurrentRow
    ;shift
    rrca 
    ;store in var
    ld [DrawPuzzleNumRowsSmallShiftedRow],a
    ;if carry add to cntr
    jr NC, .Flush
    inc b
.Flush

    ;if no carry and cntr>1 (cntr not 1) draw num
    jr C, .SkipDrawNumTile
    ld a, 1
    xor a, b

    jr Z, .SkipDrawNumTile 
    ld a, b
    ld [hld], a
    ld b, 1
.SkipDrawNumTile

    ld a, [DrawPuzzleNumRowsSmallCurrentBit]
    dec a
    ld [DrawPuzzleNumRowsSmallCurrentBit], a
    ld a, [DrawPuzzleNumRowsSmallShiftedRow]

    jr NZ, .DrawCurrentRow

.SkipRow
    ;go to the next row

    ;next byte/row
    inc de

    ;add 32 to start val of hl (to make it the next rows addr)
    ld a,[DrawPuzzleNumRowsSmallCurrentYPosAdr]
    add a, 32
    ld l,a

    ld a,[DrawPuzzleNumRowsSmallCurrentYPosAdr+1]
    adc a, 0
    ld h,a
    
    ld a,l
    ld [DrawPuzzleNumRowsSmallCurrentYPosAdr],a
    ld a,h
    ld [DrawPuzzleNumRowsSmallCurrentYPosAdr+1],a
    
    ;reset bit counter
    ld a, 8
    ld [DrawPuzzleNumRowsSmallCurrentBit],a

    ;one less row left
    ld a, [DrawPuzzleNumSmallCurrentRow]
    dec a
    ld [DrawPuzzleNumSmallCurrentRow],a 
    jp NZ,DrawPuzzleNumsRowsSmall

    ret

;hl dest, de src, b cntr (dft = 1), c cntr
DrawPuzzleNumsColumnsSmall:
    ld a, [DrawPuzzleNumColumnsSmallCurrentColumn]
    ld c, a
    
    ld a, [de]

;shift till got needed bit (probably super slow)
.ShiftCrntRow
    ;shift
    rrca 
    dec c
    jr NZ, .ShiftCrntRow

    jr NC, .NoBit
    inc b   
.NoBit
    ;if no carry and cntr>1 (cntr not 1) draw num

    jr C, .SkipDrawNumTile2
    ld a, 1
    xor a, b

    jr Z, .SkipDrawNumTile2

    ld a, b

    ld [hl], a

    ;hl -= 32
    call Sub_HL_32

    ld b, 1
.SkipDrawNumTile2

    dec de
    ;one less
    ld a, [DrawPuzzleNumSmallCurrentRow]
    dec a
    ld [DrawPuzzleNumSmallCurrentRow], a

    jr NZ, DrawPuzzleNumsColumnsSmall

    ;"flush" the last num
    ld a, 1
    xor a, b

    jr Z, .SkipFlush
    ld a, b
    ld [hl], a
    ld b, 1
.SkipFlush 

    ;reset crnt row counter
    ld a, 9
    ld [DrawPuzzleNumSmallCurrentRow], a

    ld a, [DrawColumnsSmallEndAdr+1]
    ld d,a

    ld a, [DrawColumnsSmallEndAdr]
    ld e, a

    ;HL to og -> HL -= 1
    
    ld a, [DrawPuzzleNumColumnsSmallCurrentXPosAdr+1]
    ld h,a

    ld a, [DrawPuzzleNumColumnsSmallCurrentXPosAdr]
    ld l, a

    dec hl

    ld a,l
    ld [DrawPuzzleNumColumnsSmallCurrentXPosAdr],a
    ld a,h
    ld [DrawPuzzleNumColumnsSmallCurrentXPosAdr+1],a

    ;inc DrawPuzzleNumColumnsSmallCurrentColumn

    ld a, [DrawPuzzleNumColumnsSmallCurrentColumn]
    inc a
    ld [DrawPuzzleNumColumnsSmallCurrentColumn], a
    xor a, $08

    jp NZ, DrawPuzzleNumsColumnsSmall

    ret

TilesStart: 
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$3C,$3C,$66,$66,$66,$66
    DB $6E,$6E,$76,$76,$66,$66,$3C,$3C
    DB $00,$00,$18,$18,$38,$38,$18,$18
    DB $18,$18,$18,$18,$18,$18,$3C,$3C
    DB $00,$00,$3C,$3C,$66,$66,$66,$66
    DB $0C,$0C,$18,$18,$36,$36,$7E,$7E
    DB $00,$00,$3C,$3C,$66,$66,$66,$66
    DB $0C,$0C,$6E,$6E,$66,$66,$3C,$3C
    DB $00,$00,$6C,$6C,$6C,$6C,$6C,$6C
    DB $7E,$7E,$3E,$3E,$0C,$0C,$0C,$0C
    DB $00,$00,$7E,$7E,$66,$66,$60,$60
    DB $7C,$7C,$06,$06,$66,$66,$7C,$7C
    DB $00,$00,$3C,$3C,$66,$66,$60,$60
    DB $7C,$7C,$66,$66,$66,$66,$3C,$3C
    DB $00,$00,$7E,$7E,$66,$66,$06,$06
    DB $0C,$0C,$0C,$0C,$18,$18,$18,$18

    db $01,$00,$01,$00,$01,$00,$01,$00
    db $01,$00,$01,$00,$01,$00,$FF,$00

    db $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff
    db $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f
TilesEnd:   

TileMap0Start:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TileMap0End:

PuzzleSmall0Start:
    db %01110100
    db %00100101
    db %00100100
    db %00100101
    db %00000001
    db %01000011
    db %00111110
    db %01011110
    db %01111110
    db %00100100
    db %00100100
    db %00100100
    db %01011110
    db %01011110
    db %01011110

PuzzleSmall0End:

SECTION "DrawPuzzleNumRowsSmall vars", WRAM0
DrawPuzzleNumSmallCurrentRow:db

DrawPuzzleNumRowsSmallShiftedRow:db
DrawPuzzleNumRowsSmallCurrentBit:db
DrawPuzzleNumRowsSmallCurrentYPosAdr:dw

DrawPuzzleNumColumnsSmallCurrentColumn:db
DrawPuzzleNumColumnsSmallCurrentXPosAdr:dw
DrawColumnsSmallEndAdr:dw

