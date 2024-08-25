
WaitVBlank:
    ld a, [rLY]
    cp 144
    jr nc, WaitVBlank;continue when rLY == 144
.Wait2MakeSure
    ld a, [rLY]
    cp a, 144
    jr C, .Wait2MakeSure;continue When rLY > 144 else wait for that to make sure 
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