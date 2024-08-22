;eats a, b, d, e
SetTileAtCursor2OGTile:
    ;load tileID at cursor into a
    ;check is filled in -> yes -> replace with TileID at 
    ld a, [hl]
    ld b, a;store tileID at cursor in b

    ;load empty tileID from "EmptyMap" into tile
    ld hl, CursorTileOffset
    call Ld_DE_word_HL
    ld hl, EmptyMap
    add hl, de

    ld a, [hl]
    ld [OriginalTileID], a

    ;set hl back to proper VRAM adr
    ld hl, CursorTileOffset
    call Ld_DE_word_HL
    ld hl, $9800
    add hl, de

    ld a, [OriginalTileID]
    ld [hl], a
    ld a, b
    ret

;get which byte it is in
;get which bit it is in
SetPuzzleBit:
    ld a, [CursorGridPositionY]
    ld b, a
    ld a, [CursorGridPositionX]
    
    ld hl, PuzzleInMem
    
    cp a, 8
    ld c, 2
    jr nc, .Bit4Mode
    inc c

.LoopTillCorrectByte
    dec c
    jr nz, .Not4bitchunk
    inc hl
    ld c, 2
.Not4bitchunk
    inc hl

    dec b
    jr NZ, .LoopTillCorrectByte
    
    jr .GetBit;correct byte got


.Bit4Mode
    dec c
    jr nz, .StayOnCrntChunk
    inc hl
    inc hl
    inc hl
    ld c, 2
.StayOnCrntChunk
    dec b
    jr NZ, .Bit4Mode
    
.GetBit
    ;got the correct byte
    ;now egt correct bit
    ld [hl], 69
    ret 





    ;ld [CursorGridPositionX], a
    ;ld [CursorGridPositionY], a
    ;PuzzleInMem

/* Puzzle0Start:;12x12
    db %1001_0001
    0 db %1000_0000;_0001  
    1 db %1001_1111;_1001

    db %1001_1001
    2 db %1001_1111;_1001
    3 db %1011_1111;_1001
    
    db %1001_1001
    4 db %1001_1111;_1001
    5 db %1001_1111;_1001
    
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

        ld a, [CursorGridPositionX]
    cp a, 8
    jr NC, .byteMode

.byteMode
 */