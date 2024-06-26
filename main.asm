INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

WaitVBlank:
    ld a, [rLY]
    cp 144
    jr C, WaitVBlank

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
    ld hl, $9885

    ld a,l
    ld [DrawPuzzleNumRowsSmallCurrentYPosAdr],a
    ld a,h
    ld [DrawPuzzleNumRowsSmallCurrentYPosAdr+1],a
    
    ld b, 1
    ld a, 8
    ld [DrawPuzzleNumRowsSmallCurrentBit],a
    inc a
    ld [DrawPuzzleNumRowsSmallCurrentRow],a

    ld de, PuzzleSmall0Start

    call DrawPuzzleNumRowsSmall


    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a

Done:
    jr Done


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

;hl dest, de source
;b used as counter (should be 1 from start)
;c used as
DrawPuzzleNumRowsSmall:
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

    ;add 32 to start val of hl to make it the next rows addr

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
    ld a, [DrawPuzzleNumRowsSmallCurrentRow]
    dec a
    ld [DrawPuzzleNumRowsSmallCurrentRow],a 
    jp NZ,DrawPuzzleNumRowsSmall

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


    db $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff, $ff,$ff
    db $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f, $0f,$0f
TilesEnd:   

TileMap0Start:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TileMap0End:

PuzzleSmall0Start:
    db %01010111
    db %00100100
    db %00100100
    db %00100100
    db %00000000
    db %01000010
    db %00111111
    db %01011111
    db %01111111
PuzzleSmall0End:

SECTION "DrawPuzzleNumRowsSmall vars", WRAM0
DrawPuzzleNumRowsSmallShiftedRow:db
DrawPuzzleNumRowsSmallCurrentBit:db
DrawPuzzleNumRowsSmallCurrentRow:db
DrawPuzzleNumRowsSmallCurrentYPosAdr:dw

