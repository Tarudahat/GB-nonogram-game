
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
.MainLoop
    ld a, [ShiftedByte]
    rrca
    ld [ShiftedByte], a

    call NC, .DrawNumTile

    ld a, b
    adc a, 0
    ld b, a

    dec c

    jr NZ, .MainLoop

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
    call .DrawNumTile
    call SetHL2DrawNumstartAdr
    call SetHLNextRow
    call SetDrawNumstartAdr2HL

    ld c, 4
    ld a, 255
    ld [DrawNumsState], a
.NotState3

    ld a, [de]
    ld [ShiftedByte], a 
    
    ld a, [DrawNumsState]

    cp a, 1
    jr NZ, .NotState1
    call .DrawNumTile
    call SetHL2DrawNumstartAdr
    call SetHLNextRow
    call SetDrawNumstartAdr2HL
    
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
    call CpHL2DrawNumstartAdr
    ld [hl], 1
    .SkipPut0Tile

    ;one chunk less to go
    ld  a, [GenericCntr]
    dec a
    ld  [GenericCntr], a

    jr NZ, .MainLoop
    ld [hl], 0;patchy garbage code

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

;de src, hl dst, c bitmask, b cntr
DrawColumns12x12:
    ld c, 1;%0000_0001
    ld b, 1
    ld a, 12
    ld [GenericCntr], a
    ld a, 4
    ld [GenericCntr2], a
    ld a, 0
    ld [DrawNumsState], a
    ld a, [de]
    swap a
.MainLoop
    ;a is crnt chunk, c bitmask
    and a, c 
    
    ;if: not filled in > draw num tile else: inc b
    jr NZ, .FilledIn
    call .DrawNumTile
    ;a got eaten :)
    jr .SkipIncB
.FilledIn
    inc b
.SkipIncB

    ld a, [GenericCntr]
    ;check bit0, == 1 then swap, (bc next round will be 0)
    ;if also DrawNumState == 1 then don't swap and dec DE x2
    ;if next will be 1 then go to next byte (@ - 3) and swap else get crnt chunk (no swap)
    bit 0, a
    
    jr Z, .WasMode0
    dec de
    dec de
    dec de

    ld a, [DrawNumsState]
    cp a, 1
    jr NZ, .NotByteReadMode
    inc de
    ld a, [de]
    jr .WasMode1
.NotByteReadMode

    ld a, [de]
    swap a

    jr .WasMode1
.WasMode0
    ;???
    ld a, [DrawNumsState]
    cp a, 1
    jr NZ, .Skipthis
    dec de
.Skipthis

    ld a, [de]
.WasMode1

    ld [ShiftedByte], a

    ld a, [GenericCntr]
    dec a
    ld [GenericCntr], a

    ld a, [ShiftedByte]

    jr NZ, .MainLoop
    
    ;finished a column
    call .DrawNumTile

    call CpHL2DrawNumstartAdr
    jr NZ, .DontDraw0Tile
    ld [hl], 1
.DontDraw0Tile

    ;set HL back to start of a column and move it one to the left store this too
    call SetHL2DrawNumstartAdr
    dec hl
    call SetDrawNumstartAdr2HL

    ;set bitmask to to filter next bit
    sla c

    ;start byte read mode?
    ld a, [GenericCntr2]
    dec a
    ld b, a
    ld a, [DrawNumsState]
    or a, b
    ld b, 1
    jr NZ, .DontStartbyteReadMode
    ;start byte read mode
    ;reset bitmask, set genericCntr2 and DrawNumsState
    ld a, 1
    ld [DrawNumsState], a
    
    ld c, a

    ld a, 9
    ld [GenericCntr2], a
.DontStartbyteReadMode


    ;start reading from the bottom of the columns
    ld a, [DrawNumsPuzzleStartAdr]
    ld e, a
    ld a, [DrawNumsPuzzleStartAdr+1]
    ld d, a

    ;if DrawNumsState==1 then set DE and ShiftedByte correct 
    ld a, [DrawNumsState]
    cp a, 1

    ld a, [de]

    jr NZ, .DrawNumsStateIs0
    inc de
    inc de
    ld a, [de]
    swap a;instead of canceling the swap maybe skip it?
.DrawNumsStateIs0

    swap a
    ld [ShiftedByte], a 

    ld a, 12
    ld [GenericCntr], a

    ld a, [GenericCntr2]
    dec a
    ld [GenericCntr2], a

    ld a, [ShiftedByte]
    jp NZ, .MainLoop

    ret 

.DrawNumTile 
    ld a, 1
    xor a, b
    
    jr Z, .SkipDrawNum
    
    ld a, b
    ld [hl], a

    call SetHLPrevRow

    ld b, 1
    .SkipDrawNum

    ret 