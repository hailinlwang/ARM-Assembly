.global _start
_start:
LDR R1, =0xFF200000 // LEDR Address
LDR R2, =0xFF200050 // KEYS Address
LDR R8, =0xFFFEC600 // Timer Address
LDR R0, =50000000 // Delay (0.25s)
MOV R3, #0 // Direction Tracker (0 = IN, 1 = OUT)
STR R0, [R8]
    MOV R0, #0b011 // I = 0, A = 1, E = 1
  STR R0, [R8, #8]
MOV R6, #0x00000001 // Initial Pattern - LED0
    MOV R9, #0x00000200 // Initial Pattern - LED9
ORR R6, R6, R9 // ORR R6 and R9 so both are lit up

DISPLAY:
STR R6, [R1] // Display LEDs


ROTATE:
CMP R3, #0 // Check direction
BLEQ ROT_IN // Branch to inward rotation if equal
CMP R3, #0 // Check direction again
    BLNE ROT_OUT // Branch to outward direction if not equal
B ROTATE

ROT_IN:
AND R12, R6, #0b10000
CMP R12, #0x00000010 // Check to see if left side is on inside boundary
MOVEQ R3, #1 // If yes, change the direction
AND R10, R6, #0b11111 // Extract the right 5 bits
LSL R10, R10, #1 // Shift the right bits left(in)
  AND R11, R6, #0b1111100000 // Extract left 5 bits
ROR R11, R11, #1 // Shit the left bits right(in)
ORR R6, R10, R11 // Put shifted values back together
    B INTERRUPTCHECK

ROT_OUT:
AND R12, R6, #1 // Extract left most bit of LED
CMP R12, #0x00000001 // Check to see if left side is on outside boundary
MOVEQ R3, #0 // If yes, change the direction
CMP R12, #0x00000001 // Check to see if left side is on outside boundary
BEQ INTERRUPTCHECK

    AND R10, R6, #0b11111 // Extract right 5 bits
ROR R10, R10, #1 // Shift them right(out)
AND R11, R6, #0b1111100000 // Extract left 5 bits
LSL R11, R11, #1 // Shift them left(out)
ORR R6, R10, R11 // Put shifted values back into LED register
    B INTERRUPTCHECK



INTERRUPTCHECK: //DELAY1
LDR R7, [R2] // Read KEYS
CMP R7, #0x00000008 // Check if KEY3 is pressed
    BEQ CHECKRELEASE // Branch to KEY_PRESS_1

TIMER: //DELAY2
LDR R0, [R8, #0xC] // R0 = interrupt status register
CMP R0, #0 // Check F == 0
    BEQ INTERRUPTCHECK // Keep delaying if F is not 0
    STR R0, [R8, #0xC] // Writing to interrupt status register to reset it
    B DISPLAY


// KEY PRESS to pause LEDs

CHECKRELEASE: //PRESS1
LDR R7, [R2] // Read KEYS
CMP R7, #0x00000000 // Check if KEYS have been released
    BEQ CHECKPRESS2 // If yes, branch to KEY_RELEASE_1
    B CHECKRELEASE // Keep looping if KEYS have not been released

CHECKPRESS2: //RELEASE1
LDR R7, [R2] // Read KEYS
CMP R7, #0x00000008 // Check if KEY3 has been pressed
    BEQ CHECKRELEASE2 // If yes, branch to KEY_PRESS_2
    B CHECKPRESS2 // Keep looping if KEY3 has not been released

// KEY PRESS to play LEDs

CHECKRELEASE2: //PRESS2
LDR R7, [R2] // Read KEYS
CMP R7, #0x00000000 // Check if KEYS have been released
    BEQ TIMER // If yes, jump back to original delay block
    B CHECKRELEASE2 // Keep looping if KEYS have not been released
