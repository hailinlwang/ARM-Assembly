.global _start
_start:
LDR R1,=LIST		//Load the list into register 1
    LDR R6, [R1]    	//Load the address of the first word into register 1
    MOV R0, #1		//Set initial value of r0 as 1
    MOV R7, R1
   
    WHILE:
    CMP R0,#0		//continually loop until r0 becomes 0, r0 is used as a boolean for sorted
    MOV R0,#0		//Assume sorted
    SUB R6,#1		//Lower address by 1 for location of next bit
    MOV R2,R6		//Length of word
    MOV R1,R7		//Location of address of list
    BNE FOR
    B END
   
    FOR:
    ADD R1,R1,#4	//Store location of next word/number
    CMP R0,#1		//Check to see if not sorted 
    MOVEQ R8,R0		
    CMP R0,#0
    MOVEQ R8,R0		//Put sorted boolean into r8
    MOV R0,R1		//Put current address into r0
    CMP R2,#0
    BLNE SWAP
   
    SUB R2,R2,#1	//Take one away from length
    CMP R2,#0		//If you reach the end
    MOVEQ R0,R8
    BEQ WHILE		//Repeat since not sorted 
    B FOR
   
    SWAP:		//Subroutine to swap two values
    LDR R3,[R0]		//Get current addres
    LDR R4,[R0,#4]	//Get address of next value in the list
    CMP R3,R4		//When R3>R4
    MOVGT R5,R3		//Move current address temporary
    MOVGT R3,R4		//Swich current address to next address
    MOVGT R4,R5		//Move temp into next address
    STR R3,[R0]		//Switch values
    STR R4, [R0,#4]
    MOVGT R0,#1		//Sorted boolean goes to 1 (not done sorting)
    B EXIT
   
    EXIT:
    MOV PC,LR
   
END: B END

LIST: .word 10, 1400, 45, 23, 5, 3, 8, 17, 4, 20, 33