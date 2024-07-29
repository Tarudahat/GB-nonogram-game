INCLUDE "./src/include/hardware.inc"

ClearOAM:
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
.ClearOAMLoop
    ld [hli], a
    dec b
    jr nz, .ClearOAMLoop
    ret
