	.include "address_map_arm.s"
 /*
 * This program demonstrates the use of interrupts using the KEY and timer ports. It
 * 	1. displays a sweeping red light on LEDR, which moves left and right
 * 	2. stops/starts the sweeping motion if KEY3 is pressed
 * Both the timer and KEYs are handled via interrupts
 */
			.text
			.global	_start
_start:
MOV R0, #0b10010         //IRQ mode
MSR CPSR,R0
LDR SP, =0x20000        //stack pointer for IRQ mode
MOV R0,#0b10011         //SVC mode
MSR CPSR,R0
LDR SP, =0x40000

			BL			CONFIG_GIC				// configure the ARM generic interrupt controller
			BL			CONFIG_PRIV_TIMER		// configure the MPCore private timer
			BL			CONFIG_KEYS				// configure the pushbutton KEYs
MSR CPSR,#0b00010011    //. . . enable ARM processor interrupts . . .
LDR R6, =0xFF200000     // red LED base address


MAIN:
			LDR		R4, LEDR_PATTERN		// LEDR pattern; modified by timer ISR
			STR 		R4, [R6] 				// write to red LEDs
			B 			MAIN

/* Configure the MPCore private timer to create interrupts every 1/10 second */
CONFIG PRIV TIMER:
			LDR		R0, =0xFFFEC600 		// Timer base address
LDR    R1, =50000000                // Set timer to 0.1s
STR    R1, [R0]                    // Specify number to count down from
MOV    R1, #0b111                    // I = 1 (enable interrupts), A = 1 (auto-reload), E (start timer)
STR    R1, [R0, #8]
			MOV 		PC, LR 					// return

/* Configure the KEYS to generate an interrupt */
CONFIG KEYS:
			LDR 		R0, =0xFF200050 		// KEYs base address
MOV    R1, #0b1000                    // Look for when KEY3 is pressed
STR    R1, [R0, #0x8]                // Store in interrupt mask register
			MOV 		PC, LR 					// return

			.global	LEDR_DIRECTION
LEDR_DIRECTION:
			.word 	0							// 0 means means moving to centre; 1 means moving to outside

			.global	LEDR_PATTERN
LEDR_PATTERN:
			.word 	0x201	// 1000000001
