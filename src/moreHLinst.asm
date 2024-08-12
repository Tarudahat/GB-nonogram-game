Ld_HL_DE:
    ld a, d
    ld h, a
    ld a, e
    ld l, a
    ret

Ld_DE_HL:
    ld a, h
    ld d, a
    ld a, l
    ld e, a
    ret

Ld_HL_BC:
    ld a, b
    ld h, a
    ld a, c
    ld l, a
    ret

Ld_BC_HL:
    ld a, h
    ld b, a
    ld a, l
    ld c, a
    ret

;load DE into a WORD at HL
Ld_word_HL_DE:
    ld a,e
    ld [hli],a
    ld a,d
    ld [hl],a
    ret

;load WORD at HL into DE
Ld_DE_word_HL:
    ld a, [hli]
    ld e,a
    ld a, [hl]
    ld d,a
    ret

;cp HL to [DrawNumstartAdr]
CpHL2DrawNumstartAdr:
    ld a, [DrawNumstartAdr]
    cp a, l
    ret Z
    ld a, [DrawNumstartAdr]
    cp a, l
    ret 

;reset HL to [DrawNumstartAdr]
SetHL2DrawNumstartAdr:
    ld a, [DrawNumstartAdr]
    ld l, a
    ld a, [DrawNumstartAdr+1]
    ld h, a
    ret

;set [DrawNumstartAdr] to HL
SetDrawNumstartAdr2HL:
    ld a, l
    ld [DrawNumstartAdr], a
    ld a, h
    ld [DrawNumstartAdr+1], a
    ret

;add 32 to HL
;for when there aren't any 16bit registers free
SetHLNextRow:
    ld a, l
    add a, 32
    ld l, a
    ld a, h
    adc a, 0
    ld h, a
    ret

;sub 32 from HL
SetHLPrevRow:
    ld a, l
    sub a, 32
    ld l, a
    ld a, h
    sbc a, 0
    ld h, a
    ret