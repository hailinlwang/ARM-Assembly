				.include "address_map_arm.s"
				.extern	LEDR_DIRECTION
				.extern	LEDR_PATTERN

/*****************************************************************************
 * MPCORE Private Timer - Interrupt Service Routine                                
 *                                                                          
 * Shifts the pattern being displayed on the LEDR
 * 
******************************************************************************/
				.global PRIV_TIMER_ISR
PRIV_TIMER_ISR:	
				LDR		R0, =MPCORE_PRIV_TIMER	// base address of timer
				MOV		R1, #1
				STR		R1, [R0, #0xC]				// write 1 to F bit to reset it
															// and clear the interrupt

/* Move the two LEDS to the centre or away from the centre to the outside. */
SWEEP:		LDR		R0, =LEDR_DIRECTION	// put shifting direction into R2
            LDR		R2, [R0]
            LDR		R1, =LEDR_PATTERN		// put LEDR pattern into R3
            LDR		R3, [R1]
            CMP R2,#0
            BEQ TOCENTRE
            B TOOUTSIDE

TOCENTRE:		AND R10, R3, #0b11111 // Extract the right 5 bits
                LSL R10, R10, #1 // Shift the right bits left(in)
                AND R11, R3, #0b1111100000 // Extract left 5 bits
                ROR R11, R11, #1 // Shit the left bits right(in)
                ORR R3, R10, R11 // Put shifted values back together
                AND R12, R3, #0b10000
                CMP R12, #0x00000010 // Check to see if left side is on inside boundary
				BNE DONE_SWEEP

C_O:			MOV		R2, #1					// change direction to outside

TOOUTSIDE:
            AND R10, R3, #0b11111 // Extract right 5 bits
            ROR R10, R10, #1 // Shift them right(out)
            AND R11, R3, #0b1111100000 // Extract left 5 bits
            LSL R11, R11, #1 // Shift them left(out)
            ORR R3, R10, R11 // Put shifted values back into LED register
            AND R12, R3, #1 // Extract left most bit of LED
            CMP R12, #0x00000001 // Check to see if left side is on outside boundary
            BNE DONE_SWEEP

O_C:			MOV		R2, #0					// change direction to centre
				B			TOCENTRE

DONE_SWEEP:
				STR		R2, [R0]					// put shifting direction back into memory
				STR		R3, [R1]					// put LEDR pattern back onto stack
	
END_TIMER_ISR:
				MOV		PC, LR
