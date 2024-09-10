
WaitStartVBlank:
    ld a, [rLY]
    cp 144
    jr nc, WaitStartVBlank;continue when rLY == 144
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
    
    ret z
.KnownRet
    ret nz


SetCurrentPuzzle:
    ld a, [GenericCntr]
    add a;rla would be fine to

    add LOW(PuzzlesLUT) 
    ld l, a
    adc HIGH(PuzzlesLUT)
    sub l
    ld h, a
    
    call Ld_DE_word_HL;ld de, [PuzzlesLUT-Entry]
    ld hl, CurrentPuzzle
    call Ld_word_HL_DE

    ret

UpdateTimer:
    ;check if Timer intr is requested
    ldh a, [$FF0F]
    bit 2, a
    jr z, .TimerIntrNotRequested
    
    ld a, [TimerCntr16thSec]
    inc a
    
    cp a, 16;maybe set to 16?
    jr nz, .NoIncSecCntr
    
    ld a, [TimerDownSec]
    dec a
    daa
    ld [TimerDownSec], a
    
    or a;cp a, 0
    jr nz, .ResetTimerTo60
    ld a, $59
    ld [TimerDownSec], a

    ld a, 1
    ld [TimerHasReset], a
.ResetTimerTo60

    xor a
.NoIncSecCntr
    ld [TimerCntr16thSec], a
    ldh a, [$FF0F]
    and a, %1111_1011;reset the Timer intrpt
    ldh [$FF0F], a
.TimerIntrNotRequested
    ret


UpdateFrameCooldownCntr:
    ;count down the input cooldown timer
    ld a, [FrameCntr]
    dec a
    jr z, .NoCountDown_FrameCntr
    ld [FrameCntr], a
    .NoCountDown_FrameCntr
    ret