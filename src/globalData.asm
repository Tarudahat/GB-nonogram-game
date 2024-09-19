
SECTION "GENERIC_VARS", WRAM0
GenericCntr::db
GenericCntr2::db
FrameCntr::db
ShiftedByte::db
GenericWord::dw
GameState::db;0 puzzling, 1 win, 2 game over

SECTION "TIMER_VARS", WRAM0
TimerDownMin::db
TimerDownSec::db
TimerCntr16thSec::db
TimerHasReset::db

SECTION "PUZZLE_DRAWING_VARS", WRAM0
DrawNumsState::db
DrawNumstartAdr::dw
DrawNumsPuzzleStartAdr::dw

SECTION "CURSOR_VARS", WRAM0
CursorPositionY::db
CursorPositionX::db
CursorGridPositionY::db
CursorGridPositionX::db
CursorTileOffset::dw

SECTION "INPUT_VARS", WRAM0
CurrentBTNS::db
NewBTNS::db
PrevBTNS::db

SECTION "PUZZLE_VARS", WRAM0
CurrentTile::db
OriginalTileID::db
CurrentPuzzle::dw
PuzzleInMem::ds 18
CurrentHeartTileAdr::dw


SECTION "BG", ROM0
EmptyMap::
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$15,$15,$15,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$16,$4,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$10,$10,$10,$11,$10,$10,$10,$11,$10,$10,$10,$10,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0    
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$10,$10,$10,$11,$10,$10,$10,$11,$10,$10,$10,$10,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0    
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$E,$E,$E,$F,$E,$E,$E,$F,$E,$E,$E,$E,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
    db $18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$17,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0