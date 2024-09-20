INCLUDE "./src/include/hardware.inc"

SECTION "MiscFunctions", ROM0

;-=- these 3 are often made MACROs instead of functions -=-
WaitStartVBlank::
    ld a, [rLY]
    cp 144
    jr nc, WaitStartVBlank;continue when rLY == 144
WaitVBlank::
    ld a, [rLY]
    cp a, 144
    jr C, WaitVBlank;continue When rLY > 144 else wait for that to make sure 
    ret

BusyWait4FreeVRAM::
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, BusyWait4FreeVRAM
    ret
;-=-=-=-=- but they are made to wait so to me it doesn't seem to matter rly

;de src, hl dst, bc data size
CopyMem::
    ld a, [de]
    inc de
    ld [hli],a
    dec bc;one less byte
    ld a, b
    or a, c
    jr NZ, CopyMem
    ret

;de src0, hl src1, bc data size
CpMem::
    ld a, [de]
    inc de
    cp a, [hl]
    jr nz, .KnownRet
    inc hl
    dec bc
    ld a, b
    or a, c
    jr NZ, CpMem
    
    ret z
.KnownRet
    ret nz

;de src, hl dst
DrawString::
    call WaitStartVBlank

    call UpdateFrameCntr
    ld a, [FrameCntr]
    dec a
    jr nz, DrawString 

    ld a, [de]
    
    cp a, 255;terminator char
    jr z, .Return

    inc de

    ld [hli], a

    ld a, 5;set the cooldown to 5 frames per char
    ld [FrameCntr], a

    jr DrawString
.Return
    ret


ScreenWipe0::
    ld de, 32-18

    ld a, [GenericWord+1]
    ld h, a
    ld a, [GenericWord]
    ld l, a

    ld a, [CurrentTile]
    ld [hl], a
    
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
