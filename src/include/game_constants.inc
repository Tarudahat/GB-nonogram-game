;include guard
    IF !DEF(GLOBAL_VALS)
DEF GLOBAL_VALS EQU 1
;constants

;Adresses
DEF DRAW_ROWS_START_ADR EQU $98a5
DEF DRAW_COLLUMNS_START_ADR EQU $9891
DEF HEARTS_TILE_ADR EQU $9844
DEF TIMER_TILE_ADR EQU $9864

;TileIDs
DEF BLACK_TILE_ID EQU $1b
DEF FILLED_TILE_ID EQU $13 
DEF X_TILE_ID EQU $12
DEF WIN_TILE_ID EQU $19
DEF LOSE_TILE_ID EQU $1a

;Input related
DEF INPUT_COOLDOWN EQU 9

DEF BTNS_DOWN_BIT EQU 7;u3 value for bit instr
DEF BTNS_UP_BIT EQU 6
DEF BTNS_LEFT_BIT EQU 5
DEF BTNS_RIGHT_BIT EQU 4

DEF BTNS_START_BIT EQU 3
DEF BTNS_SELECT_BIT EQU 2

DEF BTNS_B_BIT EQU 1
DEF BTNS_A_BIT EQU 0

    ENDC