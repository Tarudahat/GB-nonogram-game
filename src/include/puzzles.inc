PuzzlesLUT:
    dw Puzzle0Start
    dw Puzzle1Start
    dw Puzzle2Start
    dw Puzzle3Start
    dw Puzzle4Start
    dw Puzzle5Start
    dw Puzzle6Start
    dw Puzzle7Start
    dw Puzzle8Start
    dw Puzzle9Start
    dw Puzzle10Start
    
;GAME BRICK
    db 5,$00;time in sec x100, sec
Puzzle0Start:;12x12
    db %1001_0001
    db %1000_0000;_0001
    db %1001_1111;_1001

    db %1001_1001
    db %1001_1111;_1001
    db %1011_1111;_1001
    
    db %1001_1001
    db %1001_1111;_1001
    db %1001_1111;_1001
    
    db %0001_0001
    db %1000_0000;_0001
    db %1001_0000;_0001
    
    db %0001_0101
    db %1011_1001;_0101
    db %1001_0000;_0001
    
    db %0011_0001
    db %1000_0000;_0001
    db %1000_0000;_0011
Puzzle0End:
    db 5;offset from left
    db "GAME BRICK", 255

;ANCHOR
    db 5,$00;time in sec x100, sec
Puzzle1Start:;12x12
    db %0000_0000
    db %0000_0110;_0000
    db %0000_1001;_0000

    db %0100_0000
    db %0000_1001;_0000
    db %0010_0110;_0100
    
    db %0100_1110
    db %0111_1111;_1110
    db %0010_0110;_0100
    
    db %0010_0000
    db %0000_0110;_0000
    db %0100_0110;_0010
    
    db %0011_0111
    db %1110_0110;_0111
    db %1100_0110;_0011
    
    db %1100_1110
    db %0111_1111;_1110
    db %0011_1111;_1100
Puzzle1End:
    db 7;offset from left
    db "ANCHOR", 255

;MUSHROOM
    db 7,$00;time in sec x100, sec
Puzzle2Start:;12x12
    db %0000_0000
    db %0000_0000;_0000
    db %0000_1111;_0000

    db %0110_1100
    db %0011_1011;_1100
    db %0111_1110;_0110
    
    db %1010_0010
    db %0101_1111;_0010
    db %0111_0111;_1010
    

    db %0000_1110
    db %0111_1111;_1110
    db %0000_1001;_0000
    
    db %1000_1000
    db %0001_0000;_1000
    db %0001_1100;_1000
    
    db %0000_1000
    db %0001_1110;_1000
    db %0000_1111;_0000
Puzzle2End:
    db 6;offset from left
    db "MUSHROOM", 255

;TREASURE CHEST
    db 5,$00;time in sec x100, sec
Puzzle3Start:;12x12
    db %0000_0000
    db %0000_0000;_0000
    db %0000_0000;_0000

    db %0101_1110
    db %0111_1111;_1110
    db %1010_0000;_0101
    
    db %1111_0101
    db %1010_0110;_0101
    db %1111_1001;_1111

    db %0101_0101
    db %1010_1111;_0101
    db %1010_0110;_0101
    
    db %0101_0101
    db %1010_0000;_0101
    db %1010_0000;_0101

    db %0000_1111
    db %1111_1111;_1000
    db %0000_0000;_0000
Puzzle3End:
    db 3;offset from left
    db "TREASURE CHEST", 255

;BLADE MASTER
    db 5,$00;time in sec x100, sec
Puzzle4Start:;12x12
    db %1111_1111
    db %1111_1111;_1111
    db %1001_1100;_1111

    db %1011_0111
    db %1010_1011;_0111
    db %1011_0010;_1011
    
    db %1011_0101
    db %1101_1001;_0101
    db %1110_1110;_1011

    db %1101_1011
    db %1111_0101;_1011
    db %1111_1010;_1101
    
    db %0110_0101
    db %1111_1000;_0101
    db %1111_1001;_0110

    db %1100_1010
    db %1111_0101;_1010
    db %1111_0011;_1100
Puzzle4End:
    db 4;offset from left
    db "BLADE MASTER", 255

;MEDUSA KID
    db 9,$99;time in sec x100, sec
Puzzle5Start:;12x12
    db %0000_0000
    db %0101_1010;0000 
    db %0110_1100;0000 

    db %0000_0000    
    db %1011_1011;0000 
    db %0100_0101;0000 

    db %0011_0010
    db %1110_1010;0010 
    db %0101_0100;0011 

    db %0101_0011    
    db %0010_0100;0011 
    db %0010_0110;0101 

    db %1101_1011    
    db %0010_0111;1011 
    db %0011_0010;1101 

    db %1100_0110    
    db %0001_1100;0110 
    db %0000_0111;1100 
Puzzle5End:
    db 5;offset from left
    db "MEDUSA KID", 255

;SHIELD
    db 5,$00;time in sec x100, sec
Puzzle6Start:;12x12
    db %1110_1000
    db %0001_1111;1000 
    db %0111_1100;1110 
    
    db %0010_0010
    db %0111_1100;0010 
    db %0111_1100;0010 

    db %1110_0010
    db %0111_1100;0010 
    db %0100_1100;1110 

    db %1110_1110
    db %0100_0011;1110 
    db %0100_0011;1110 

    db %1100_1100
    db %0010_0011;1100 
    db %0011_0011;1100 

    db %0000_1000
    db %0001_1011;1000 
    db %0000_1111;0000 
Puzzle6End:
    db 7;offset from left
    db "SHIELD", 255

;CYCLOPS KID
    db 5,$00;time in sec x100, sec
Puzzle7Start:;12x12
    db %0100_0000
    db %0000_0000;0000 
    db %0010_1111;0100 

    db %1101_1010
    db %0101_1001;1010 
    db %1011_0010;1101 

    db %1010_1001
    db %1001_0110;1001 
    db %0101_1001;1010 

    db %1100_1100
    db %0011_1111;1100 
    db %0011_0110;1100 

    db %1100_1100
    db %0011_0000;1100 
    db %0011_1001;1100 

    db %1110_1000
    db %0001_1111;1000 
    db %0111_1001;1110 
Puzzle7End:
    db 5;offset from left
    db "CYCLOPS KID", 255

;Little Bug
    db 5,$00;time in sec x100, sec
Puzzle8Start:
    db %0000_0000
    db %0000_1001;0000 
    db %0000_1111;0000 
    
    db %1110_1010
    db %0101_0110;1010 
    db %0111_1111;1110 

    db %0100_0100
    db %0010_1111;0100 
    db %0010_0110;0100 

    db %1101_0110
    db %0110_1111;0110 
    db %1011_1001;1101 

    db %1100_0100
    db %0010_0000;0100 
    db %0011_0110;1100 

    db %0000_1010
    db %0101_1111;1010 
    db %0000_0000;0000 
Puzzle8End:
    db 5;offset from left
    db "LITTLE BUG", 255

;Bow And Arrow
    db 5,$00;time in sec x100, sec
Puzzle9Start:
    db %0110_0001
    db %0111_1111;0001 
    db %1011_1100;0110 
    
    db %1011_1101
    db %1101_0001;1101 
    db %1110_0011;1011 

    db %0111_1011
    db %1100_0111;1011 
    db %1100_1011;0111 

    db %1111_0111
    db %1001_1101;0111 
    db %1011_1110;1111 

    db %0101_0011
    db %1011_1001;0011 
    db %0110_0111;0101 

    db %1111_1011
    db %0101_1111;1011 
    db %1011_1111;1111 
Puzzle9End:
    db 4;offset from left
    db "BOW AND ARROW", 255

;Magic Potion
    db 5,$00;time in sec x100, sec
Puzzle10Start:
    db %1000_0000
    db %0000_1111;0000 
    db %0001_1111;1000 
    
    db %0000_0000
    db %0000_1101;0000 
    db %0110_1001;0000 

    db %1000_0000
    db %1010_1001;0000 
    db %1001_0000;1000 

    db %1010_0100
    db %1010_0000;0100 
    db %0100_0001;1010 

    db %0110_1110
    db %0111_0011;1110 
    db %0111_1111;0110 

    db %1100_1110
    db %0111_1100;1110 
    db %0011_1111;1100 
Puzzle10End:
    db 4;offset from left
    db "MAGIC ELIXIR", 255

    db %0000_0000;0000 
    db %0000_0000;0000 
    
    db %0000_0000;0000 
    db %0000_0000;0000 

    db %0000_0000;0000 
    db %0000_0000;0000 

    db %0000_0000;0000 
    db %0000_0000;0000 

    db %0000_0000;0000 
    db %0000_0000;0000 

    db %0000_0000;0000 
    db %0000_0000;0000 


    