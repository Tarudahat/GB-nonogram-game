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
TogglePuzzleBit:
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
    ;now get correct bit
    ld a, %1000_0000
.GetBitLoop
    rla
    dec d
    jr nz, .GetBitLoop

    ld d, a

    ld a, [hl]
    xor a, d
    ld [hl], a
    
    ret

ScreenWipe0:
    ld de, 32-18

    ld a, [GenericWord+1]
    ld h, a
    ld a, [GenericWord]
    ld l, a

    ld [hl], $19
    
    inc hl
    ld a, [hl]
    cp a, $17

    jr nz, .NotAtRightBorderYet
    add hl, de
.NotAtRightBorderYet

    ld a, h
    ld [GenericWord+1], a
    ld a, l
    ld [GenericWord], a

    ret





