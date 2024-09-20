INCLUDE "./src/include/hardware.inc"

SECTION "CURSOR_VARS", WRAM0
CursorPositionY::db
CursorPositionX::db
CursorGridPositionY::db
CursorGridPositionX::db
CursorTileOffset::dw

SECTION "Sprites", ROM0
ClearOAM::
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
.ClearOAMLoop
    ld [hli], a
    dec b
    jr nz, .ClearOAMLoop
    ret

;b posX, c posY
PixelPosition2MapAdr::
    ld hl, $9800
    ;adr = $9800 + X/8 + (Y/8)*8*4
    ;                      |---|-----> this "kills" bit 0-2 
    ld a, c
    and a, %11111000

    ;put it in HL, to *2 by using: add hl, hl
    ld l, a
    ld h, 0

    add hl, hl ; HL = (Y/8)*8 * 2
    add hl, hl ; HL = (Y/8)*8 * 4

    ;X/8
    ld a, b
    srl a; /2
    srl a; /4
    srl a; /8

    add a, l;X/8 + (Y/8)*32 [lower byte of it]
    ld [CursorTileOffset], a
    ld l, a;that's HL's new lower byte
    adc a, h;add higher byte of (Y/8)*32 + carry (+lower byte)
    sub a, l;(remove that lower byte)
    ld [CursorTileOffset+1], a
    ld h, a;(put a into HL's High byte)


    ;add $9800
    ld bc, $9800
    add hl, bc

    ret



