
WaitStartVBlank:
    ld a, [rLY]
    cp 144
    jr nc, WaitStartVBlank;continue when rLY == 144
.Wait2MakeSure
    ld a, [rLY]
    cp a, 144
    jr C, .Wait2MakeSure;continue When rLY > 144 else wait for that to make sure 
    ret

WaitVBlank:
    ld a, [rLY]
    cp a, 144
    jr C, WaitVBlank;continue When rLY > 144 else wait for that to make sure 
    ret

BusyWait4FreeVRAM:
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, BusyWait4FreeVRAM
    ret

;de src, hl dst, bc data size
CopyMem:
    ld a, [de]
    inc de
    ld [hli],a
    dec bc;one less byte
    ld a, b
    or a, c
    jr NZ, CopyMem
    ret

;de src0, hl src1, bc data size
CpMem:
    ld a, [de]
    inc de
    cp a, [hl]
    jr nz, .KnownRet
    inc hl
    dec bc
    ld a, b
    or a, c
    jr NZ, CpMem

    ld hl, $9800;TEMP
    ld [hl], 8;TEMP
    
    ret z
.KnownRet
    ret nz