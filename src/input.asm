INCLUDE "./src/include/hardware.inc"

UpdateBTNS:
    ld  a, $20 ;set get dpad flag
    call .GetBTNS

    and $0F
    swap a
    ld b, a

    ld  a, $10 ;set get ABSS flag
    call .GetBTNS

    and $0F
    or a, b
    xor a, $FF
    ld b, a

    ld a, $30;stop reading BTNS
    ldh [$00], a

    ld a, b
    ld [NewBTNS], a

    ld a,[CurrentBTNS];get the pressed BTNS mask
    and a, b
    or a, b
    ld [CurrentBTNS], a

    ret

.GetBTNS
    ldh [$00], a

    ldh a, [$00]
    call .CycleWaster

    ldh a, [$00]

.CycleWaster
    ret