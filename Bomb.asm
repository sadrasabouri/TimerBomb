.ORG 0X0000				;	Start Address
JMP MAIN 

;================================================================
;					Terminal_Input_Section
;================================================================
.ORG 0X001A				;	Interrupt Service Routine (ISR) Address - Terminal Input
CBI UCSRA, RXC			;	Clear USART Receive Complete flag -  new message recived
IN R25, UDR				;	Mov USART buffer to R25
CPI R25, 0X0D     	;	Carriage Return (newline) ASCII CODE	
   BRNE THOUSANDS		;	If inputed char wasn't Enter
CALL COMPARE 			;  	Check wheter the inputed code is correct or not
RETI						;	Return from interrupt

THOUSANDS:				;	When thousands of code inputted
CPI R29, 0X00			;	If R29 is not 0: (We already have got thousands)
   BRNE HUNDREDS		;		Goto HUNDREDS , else:
MOV R21, R25			;	Move inputted char to R21 (thousands of code)
INC R29					;	Increase R29
RETI						;	Return from interrupt

HUNDREDS:				;	When hundreds of code inputted
CPI R29, 0X01			;	If R29 is not 1: (We already have got hundreds)
   BRNE TENS			;		Goto TENS, else:
MOV R22, R25			;	Move inputted char to R22 (hundred of code)
INC R29					;	Increase R29
RETI						;	Return from interrupt

TENS:					   ;	When tens of code inputted
CPI R29, 0X02			;	If R29 is not 2: (We already have got tens)
   BRNE ONES			;		Goto ONES, else:
MOV R23, R25			;	Move inputted char to R23 (tens of code)
INC R29					;	Increase R29
RETI						;	Return from interrupt

ONES:					   ;	When ones of code inputted
CPI R29, 0X03			;	If R29 is not 3: (we already have got ones)
   BRNE THOUSANDS		;		Goto Thousands, else: (Looping condition)
MOV R24, R25			;	Move inputted char to R24
LDI R29, 0X00			;	Clear R29 - Ready for next code
RETI						;	Return from interrupt

COMPARE:				   ;	Check if inputted code is correct or not (Accepted code = 9697)
   CHECK1: 
      CPI R21, 0X39	;	If first of code is 9
	 BREQ CHECK2		;		Goto CHECK2, else:
      CBI PORTA, 2	; 	The code was wrong - Burst
      RET
   CHECK2: 
      CPI R22, 0X36	;	If second of code is 6
	 BREQ CHECK3		;		Goto CHECK3, else:
      CBI PORTA, 2	; 	The code was wrong - Burst
      RET
   CHECK3: 
      CPI R23, 0X39	;	If third of code is 9
	 BREQ CHECK4		;		Goto CHECK4, else:
      CBI PORTA, 2	; 	The code was wrong - Burst
      RET
   CHECK4: 
      CPI R24, 0X37	;	If forth of code is 7
	 BREQ CORRECT		;		Goto CORRECT, else:
      CBI PORTA, 2	; 	The code was wrong - Burst
      RET

   CORRECT:
      CBI PORTA, 3 	; 	The code was correct - Defused
RET

;================================================================
;						Main_Code
;================================================================
.ORG 0X00FF
MAIN:
   LDI R29, 0X00		; 	R29 = code state counter
   SEI					; 	Set global interrupt
   SBI PORTA, 2 		; 	PortA.2 = flag to check wheter the bomb is burst or not 
   SBI PORTA, 3 		; 	PortA.3 = flag to check wheter the bomb is defused or not

   ;	-------------------	Assigning pins to be (in/out)put		-------------------	;
   LDI R20, 0XFF 		; 	R20  = a temp Register (All ports output)
   OUT DDRC, R20 		; 	Port C is output
   LDI R20, 0XFF		;	R20  = a temp Register (All ports output)
   OUT DDRA, R20 		;  	Port A is output
   LDI R20, 0X01		;	R20  = a temp Register (Pin0 is input)
   OUT PIND, R20 		; 	PortD.0 is input
   
   ;	-------------------------	Initialization the LCD 	--------------------------	;
   LDI R20, 0X38		; 	Function Set = 8-bit, 2 Line, 5×7 Dots
   CALL CMND
   LDI R20, 0X01		; 	Clear display (also clear DDRAM content)
   CALL CMND
   LDI R20, 0X0C 		; 	Display on Cursor off
   CALL CMND
   
   ;	-------------------------	Initialization the UART	--------------------------	;
   LDI R20, 0X33		; 	9600 Baud Rate
   OUT UBRRL, R20		;	UART Baud Rate Register Lower 
   LDI R20, 0X00		; 	9600 Baud Rate
   OUT UBRRH, R20		;	UART Baud Rate Register Higher
   LDI R20, 0X94 		; 	RX Complete Interrupt Enable, Receiver Enable, 1Byte character
   OUT UCSRB, R20		;	USART Control and Status Register B configured
   LDI R20, 0X86 		; 	Select Register UCSRC, 1Byte character
   OUT UCSRC, R20		;	USART Control and Status Register C configured

   ;	-------------------------Setting_the_LCD_to_00:01:00--------------------------	;
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X3A		;	= :
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X31		;	= 1
   CALL DISP
   LDI R20, 0X3A		;	= :
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   CALL DELAY1 		; 	1 Second Delay
   
   ;	-------------------------Setting_the_LCD_to_00:00:59-------------------------	;
   LDI R20, 0X01 		; 	Clear Display (also clear DDRAM content)
   CALL CMND
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X3A		;	= :
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X30		;	= 0
   CALL DISP
   LDI R20, 0X3A		;	= :
   CALL DISP
   LDI R20, 0X35		;	= 5
   CALL DISP
   LDI R20, 0X39		;	= 9
   CALL DISP
   CALL DELAY1 		; 	1 Second Delay
   LDI R20, 0X10		;	Move cursor left
   CALL CMND
   
   ;	-------------------------		Timer_Start		-------------------------	;
   LDI R27, 0X35 		; 	50 s
   LDI R26, 0X39 		; 	+9 s = 59s timer
    TENS_TIMER:
	ONES_TIMER:
	 SBIS PORTA, 2 	; 	Check if the the bomb is bursted or not
	    JMP BURST		;	If so Goto BURST
	 SBIS PORTA, 3 	; 	Check if the bomb is defused or not
	    JMP DEFUSE		;	If so Goto DEFUSE
	 DEC R26 			; 	Decrease # of seconds
	 MOV R20, R26 		;	Move number of remaining seconds to temp 
	 CALL DISP			;	Display it
	 CALL DELAY1 		; 	1 Second Delay
	 LDI R20, 0X10 	;  	Move cursor left a character
	 CALL CMND
	 CPI R26, 0X30 	; 	Check if # ones is zero
	    BRNE ONES_TIMER	;	If it is not go back to ONES_TIMER, else:
	 CPI R27, 0X30 	; 	Check if # tens is zero
	    BREQ BURST		;	If it is not goto BURST, else:
	LDI R26, 0X39 		; 	Refresh # ones of seconds
	MOV R20, R26		;	Move # ones to temp
	CALL DISP
	LDI R20, 0X10		; 	Move cursor left a character
	CALL CMND
	LDI R20, 0X10		; 	Move cursor left a character
	CALL CMND
	DEC R27 				; 	Decrease # tens of seconds 
	MOV R20, R27		;	Move number of tens of seconds to temp
	CALL DISP
	CALL DELAY1 		; 	1 second delay
   JMP TENS_TIMER		; 	1 minute is over and no code was entered so the bomb is going to burst

   
;================================================================
;						Other_Subroutines
;================================================================
STUCK: 
JMP STUCK				;	Jump to itselt and stuck here

BURST:
   CBI PORTA, 2		;	Clear PortA.2 - Turn on BURST LED
   LDI R20, 0X01 		; 	Clear Display (also clear DDRAM content)
   CALL CMND
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X38		;	= 8
   CALL DISP
   LDI R20, 0X38		;	= 8
   CALL DISP
   LDI R20, 0X3A		;	= :
   CALL DISP
   LDI R20, 0X38		;	= 8
   CALL DISP
   LDI R20, 0X38		;	= 8
   CALL DISP
   LDI R20, 0X3A		;	= :
   CALL DISP
   LDI R20, 0X38		;	= 8
   CALL DISP
   LDI R20, 0X38		;	= 8
   CALL DISP
   JMP STUCK

DEFUSE:
   CBI PORTA, 3		;	Clear PortA.3 - Turn on DEFUSED LED
   LDI R20, 0X01 		; 	Clear Display (also clear DDRAM content)
   CALL CMND
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X20		;	Move cursor to right
   CALL DISP
   LDI R20, 0X44		;	= D
   CALL DISP
   LDI R20, 0X65		;	= E
   CALL DISP
   LDI R20, 0X66		;	= F
   CALL DISP
   LDI R20, 0X75		;	= U
   CALL DISP
   LDI R20, 0X73		;	= S
   CALL DISP
   LDI R20, 0X65		;	= E
   CALL DISP
   LDI R20, 0X64		;	= D
   CALL DISP
   JMP STUCK

DELAY1:					;	Make 1s of delay
   LDI R16, 0X00 		; 	R16 is used for comparing with values of R17-R19 to zero
   LDI R17, 0X20
      LOOP1: LDI R18, 0XFF
	 LOOP2: LDI R19, 0XF4
	    LOOP3: DEC R19 
	    CP R19, R16 	; 	Compare R19 to R16 (0X00)
	       BRNE LOOP3 ; 	Jump to LOOP3 if R19 is not equal to zero
	 DEC R18
	 CP R18, R16
	    BRNE LOOP2
   DEC R17
   CP R17, R16
      BRNE LOOP1
RET

DISP:					   ;	Display Character On LCD
   OUT PORTC, R20		;	Put R20 on PortC
   SBI PORTA, 1		;	RS = 1
   SBI PORTA, 0		;	E = 1
   CBI PORTA, 0		;	E = 0
   CALL DELAY2			;	Tiny delay for accepting changes
RET

CMND:					   ;	Send Commands to LCD
   OUT PORTC, R20		;	Put R20 on PortC
   CBI PORTA, 1		;	RS = 0
   SBI PORTA, 0		;	E = 1
   CBI PORTA, 0		;	E = 0
   CALL DELAY2			;	Tiny delay for accepting changes
RET

DELAY2:					;	Tiny delay for accepting changes from LCD
   LDI R16, 0X00 		; 	R16 is used for comparing with values of R17-R19 with zero
   LDI R17, 0X01
      WAIT1: LDI R18, 0X0F
	 WAIT2: LDI R19, 0XFF
	    WAIT3: DEC R19 
	    CP R19, R16 	; 	Compare R19 with R16 (0X00)
	       BRNE WAIT3 ; 	Jump to LOOP3 if R19 is not equal to zero
	 DEC R18
	 CP R18, R16
	    BRNE WAIT2
   DEC R17
   CP R17, R16
      BRNE WAIT1
RET
