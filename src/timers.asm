INCLUDE "./src/include/hardware.inc"

SECTION "TIMER_VARS", WRAM0
TimerDownMin::db
TimerDownSec::db
TimerCntr16thSec::db
TimerHasReset::db

SECTION "TimerFunctions", ROM0
UpdateTimer::
    ;check if Timer intr is requested
    ldh a, [rIF];$FF0F
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
    
    cp a, $F9
    jr nz, .ResetTimerTo60
    ld a, [TimerDownMin]
    dec a
    ld [TimerDownMin], a
    
    ld a, $99
    ;ld a, $59
    ld [TimerDownSec], a

    ld a, 1
    ld [TimerHasReset], a
.ResetTimerTo60

    xor a
.NoIncSecCntr
    ld [TimerCntr16thSec], a
    ldh a, [rIF];$FF0F
    and a, %1111_1011;reset the Timer intrpt
    ldh [rIF], a;$FF0F
.TimerIntrNotRequested
    ret

UpdateFrameCntr::
    ;count down the input cooldown timer
    ld a, [FrameCntr]
    dec a
    jr z, .DontCountDown_FrameCntr
    ld [FrameCntr], a
    .DontCountDown_FrameCntr
    ret