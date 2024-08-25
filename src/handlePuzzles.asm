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
    inc b
    ld a, [CursorGridPositionX]
    ld d, a

    ld hl, PuzzleInMem
    
    cp a, 8
    ld c, 3
    jr nc, .Bit4Mode

    ;8bit chunk
    ld a, 9
    sub a, d
    ld d, a

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

    ld a, [CursorGridPositionY]
    ld b, a

    ;4bit chunk
    ld a, 11
    ;if uneven row, ld a, 8
    bit 0, b
    jr z, .IsEven
    ld a, 15
.IsEven

    sub a, d
    ld d, a
    inc d
    inc d
.GetBit
    ;got the correct byte
    ;now egt correct bit
    ld a, %1000_0000
.GetBitLoop
    rla
    dec d
    jr nz, .GetBitLoop

    ld d, a

    ld a, [hl]
    or a, d;ññññ should be xor but cursor bs has to be fixed first
    ld [hl], a

    
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