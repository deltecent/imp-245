
; I218-4.ASM  -  MicroMint SB180 overlay file for IMP  -  06/01/87
;
;		  HD64180 On-chip ASCII Port 0
;
;     This version handles 6 ZMHz, 9 MHz or 12 MHz clock speed
;
; This file adapts the MicroMint SB180 computer to IMP.COM.  This com-
; puter was featured in the September and October 1985 issues of BYTE
; magazine in Ciarcia's Circuit Cellar.  The SB180 is an extremely com-
; pact (4" by 7") single board computer with 2 serial ports, 1 parallel
; printer port, 5"/8" disk controller, and 256K RAM as well as an expan-
; ion port for SASI/SCSI controllers, etc.  It utilizes the new Hitachi
; HD64180 CMOS CPU, a VLSI chip with memory management, serial, DMA and
; timer functions on-chip. It's instruction set is upwardly compatible
; with the Z80.
;
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.	Some special HD64180 instructions are used, but any nor-
; mal 8080 or Z80 assembler may be used.
;
; Many terminals will clear the screen with a CTL-Z.  If yours does, put
; a 1AH at CLEAR: (010AH).  Many terminals use two characters, the first
; normally an ESC.  For example, ESC *.  In this case put '*' at CLEAR:
; (The ESC will automatically be typed with no CTL-character present.)
; If you don't know what your terminal uses, put a 0 at CLEAR: and IMP
; will scroll up 24 blank lines to clear the CRT for things like MENU,
; looking at the function key table, typing CTL-Z in command mode, etc.
;
; Use the "SET" command to change the baudrate when desired.  The value
; at MSPEED controls the baudrate when the program is first called up.
;
; TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ZAS.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP.COM,I2MM-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  After being advised by Steven Mendelson that 6 MHz, 9MHz and
;    v4     12 MHz versions are available, I called MicroMint and got
;	    the baud rate data for all those from Ken Davidson.
;					- Irv Hoff
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;    v3     IMP245 to use it.
;
; 03/27/86  Modest changes to standardize appearance with other similar
;    v2     overlays, other minor changes.  Renamed to I2MM to avoid
;	    conflict with I2SB for Intertec Super Brain computer.
;					- Irv Hoff
;
; 08/19/85  First version for the MicroMint SB180.
;    v1 				- Max Southall
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Select one of the following for your computer board
;
CLK6	EQU	YES		; Yes if using 6 MHz clock
CLK9	EQU	NO		; Yes if using 9 MHz clock
CKL12	EQU	NO		; Yes if using 12 MHz clock
;
;
; Values shown are for a HD64180
;
PORT	EQU	00H		; Your base port (data or status)
MDCTL1	EQU	PORT+4		; Modem status port
MDDATIN EQU	PORT+8		; Modem data in port
MDDATOUT EQU	PORT+6		; Modem data out port
MDRCV	EQU	80H		; Modem receive ready
MDSND	EQU	02H		; Modem send ready bit
MDTXE	EQU	02H		; Modem send buffer empty, holding buffer empty
;
BAUDRP	EQU	PORT+2		; HD64180 Port 0 ^B
;
IN0	EQU	38EDH		; Special Hitachi op code pair for 'A' reg.
OUT0	EQU	39EDH		; Special Hitachi op code pair for 'A' reg.
;
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H		; ^[ = Escape
BELL	EQU	'G'-40H		; ^G = Bell character
LF	EQU	'J'-40H		; ^J = Linefeed
NEXTRY	EQU	'K'-40H		; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H		; ^M = Carriage return
CLEARSC EQU	'Z'-40H		; ^Z = Clears screen, command mode only
EOFCHAR EQU	'Z'-40H		; ^Z = End of file
;
;
	ORG	0100H
;
;
	DS	3		; Skip the data area below
;
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	DB	5		; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
				; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	DB	NO		; Yes=2400 bps highest speed			104H
HS1200:	DB	YES		; Yes=1200 bps highest speed			105H
RACAL:	DB	NO		; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM:DB	YES		; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	DB	NO		; Reserved for special modems			108H
RESVD2:	DB	NO		; Reserved for special modems			109H
;
;
CLEAR:	DB	1AH		; Clear screen character (ESC not needed)	10AH
;
	 IF	CLK6
CLOCK:	DB	60		; Clock speed in MHz x10, 25.5 MHz max. 	10BH
	 ENDIF			; CLK6
	 IF	CLK9
CLOCK:	DB	90		; Clock speed in MHz x10, 25.5 MHz max. 	10BH
	 ENDIF			; CLK9
	 IF	CLK12
CLOCK:	DB	120		; Clock speed in MHz x10, 25.5 MHz max. 	10BH
	 ENDIF			; CLK12

				; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	DB	2		; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
				;   default time to send character in ter-
				;   minal mode file transfer for slow BBS
CRDLY:	DB	2		; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
				;   default time for extra wait after CRLF
				;   in terminal mode file transfer
NOFCOL:	DB	5		; Number of directory columns shown		10EH
TCHPUL:	DB	'T'		; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:	DB	NO		; Yes=add LF after CR to send file in terminal	110H
				;   mode (normally added by remote echo)
CONVRUB:DB	YES		; Yes=convert rub to backspace			111H
CRCDFLT:DB	YES		; Yes=default to CRC checking			112H
IGNRCTL:DB	YES		; Yes=CTL-chars above ^M not displayed		113H
;.....
;
;
EXTCHR:	DB	'['-40H		; ESC = preceeds local control character	114H
EXITCHR:DB	'E'		; Exit character				115H
FILESND:DB	'F'		; Send file when in terminal mode		116H
NOCONCT:DB	'N'		; Disconnect from phone line			117H
LOGCHR:	DB	'L'		; Send logon					118H
LSTCHR:	DB	'P'		; Toggle printer				119H
UNSAVCH:DB	'R'		; Close input text buffer			11AH
SAVECHR:DB	'Y'		; Open input text buffer			11BH
CLEARS:	DB	'Z'		; Clears screen, terminal mode			11CH
BRKCHR:	DB	'Q'		; Send a break tone				11DH
NODTR:	DB	NO		; YES if no DTR and need ATH0 to disconnect	11EH
;......
;
;
; Handles in/out ports for data and status
;
I$MDCTL1:
	DW	IN0		; 					11FH
	DB	MDCTL1		; 					121H
	DW	IN0		; 					122H
	DB	MDCTL1		; 					124H
	RET			; 					125H
	DB	0,0,0		; 					126H
;
I$MDTXE:DW	IN0		; 					129H
	DB	MDCTL1		; 					12BH
	DW	IN0		; 					12CH
	DB	MDCTL1		; 					12EH
	RET			; 					13FH
	DB	0,0,0		; 					130H
;
I$MDDATP:
	DW	IN0		; 					133H
	DB	MDDATIN		; 					135H
	RET			; 					136H
	DB	0,0,0,0,0,0	; 					137H
;
O$MDDATP:
	DW	OUT0		; 					13DH
	DB	MDDATOUT	; 					13FH
	RET			; OUT modem data port			140H
	DB	0,0,0,0,0,0	; Spares if needed			141H
;.....
;
;
A$MDRCV:ANI	MDRCV		; 					147H
	RET			; 					149H
;
C$MDRCV:CPI	MDRCV		; 					14AH
	RET			; 					14CH
;
A$MDSND:ANI	MDSND		; 					14DH
	RET			; 					14FH
;
C$MDSND:CPI	MDSND		; 					150H
	RET			; 					152H
;
A$MDTXE:ANI	MDTXE		; 					153H
	RET			; 					155H
;
C$MDTXE:CPI	MDTXE		; 					156H
	RET			; 					158H
;.....
;
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:
	RET			; 					159H
	DB	0,0		; 					15AH
;.....
;
;
; Jump vectors needed by each overlay
;
J$GOODBYE:
	JMP	GOODBYE		; Disconnects modem by dropping DTR	15CH
J$INITMOD:
	JMP	INITMOD		; Initializes modem, autosets baudrate	15FH
J$STUPR:JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:JMP	SYSVR		; Signon message			165H
;.....
;
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA:
	DS	3		; 1200 bps "AT" string			168H
J$STRNG1:
	DS	3		; 2400 bps "AT" string			16BH
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
;
J$CMDSPL:
	DS	3		; Allows entry of baudrate on CMD line	16EH
J$CRLF:	DS	3		; Turns up one new line on display	171H
J$DIAL:	DS	3		; Start of dialing routine		174H
J$DSCONT:
	DS	3		; Terminates modem use			177H
J$GOLST:DS	3		; Printer routine, needed by Apple //e	17AH
J$ILPRT:DS	3		; Prints an inline string, 0 to end	17DH
J$INBUF:DS	3		; Stores a keybd string for comparison	180H
J$INLNCP:
	DS	3		; Inline "compare strings" routine	183H
J$INMDM:DS	3		; Max .1 sec wait for modem character	186H
J$RCVRSP:
	DS	3		; For 3801 I/O use (TV-803)		189H
J$SNDCHR:
	DS	3		; Sends a character to the modem	18CH
J$SNDSTR:
	DS	3		; Sends a string to the modem, $ to end 18FH
J$TIMER:DS	3		; .1 second timer (amount in 'B' reg.)	192H
J$BREAK:JMP	SENDBRK		; Break routine 			195H
J$NEW2:	DB	0,0,0		; For future needs			198H
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	DB	0		; For manual selection flag		19BH
J$300:	JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;.....
;
;
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
	DB	'Version for Systech/MicroMint SB180' ; 		1AAH
	DB	CR,LF,0
	RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER).
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; (special character-L).  You can put in several lines.  End with a 0.
;
LOGON:	DB	'This is a SB180 computer...',CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone.  It changes the baudrate to
; 38400 bps then sends enough ASCII null characters to consume 300 ms.
; (A null character is all spacing except for the stop bit.)  At high
; speed this effectively gives a steady break tone.  When finished it
; restores the baudrate to the original speed.
;
SENDBRK:
	 IF	CLK6 OR CLK12
	MVI	A,BD38400	; Select 38,400 bps
	 ENDIF			; CLK6 OR CLK12
;
	 IF	CLK9
	MVI	A,BD19200	; Select 19,200 bps
	 ENDIF			; CLK9
;
	CALL	LOAD1		; Set output for this speed
;
	 IF	CLK6 OR CLK12
	LXI	D,1150		; Will take 300 ms at 38,400 bps
	 ENDIF			; CLK6 OR CLK12
;
	 IF	CLK9
	LXI	D,575		; Will take 300 ms at 19,200 bps
	 ENDIF			; CLK9
;
SEND1:	XRA	A		; ASCII null character
	CALL	J$SNDCHR	; Sends a character to the modem
	DCX	D		; One less to go
	JNZ	SEND1		; If not zero, do another
;
	JMP	INITMOD		; Reset original speed
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the modem.
;
GOODBYE:
	DW	IN0
	DB	PORT
	DW	0E7CBH		; Raise DTR (actually RTS)
	DW	OUT0
	DB	PORT
	MVI	B,3		; Wait for 300 ms
	CALL	J$TIMER
	DW	IN0
	DB	PORT
	DW	0A7CBH		; Reset DTR to normal
	DW	OUT0
	DB	PORT
	RET
;.....
;
;
; Initialization -- sets baudrate
;
INITMOD:
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
	CPI	9
	JZ	OK19200
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
; Setup routine to allow changing modem speed with the SET command.
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input BPS (300, 1200, 2400, 9600, 19200): ',0
	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF
	CALL	J$CRLF
	LXI	D,BAUDBUF+2
;
STUPR2:	CALL	J$INLNCP	; Compare BAUDBUF+2 with chars. below
	DB	'300',0
	JNC	OK300		; Go if got match
	CALL	J$INLNCP
	DB	'1200',0
	JNC	OK1200
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'=> Unknown entry',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1		; MSPEED 300 bps value
	MVI	B,BD300
	JMP	LOADBD
;
OK1200:	MVI	A,5
	MVI	B,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A		; Reset to maximum auto-speed
	STA	MANUAL
	MVI	A,6
	MVI	B,BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	MVI	B,BD9600
	JMP	LOADBD
;
OK19200:MVI	A,9
	MVI	B,BD19200
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MOV	A,B		; Get baudrate byte
;
LOAD1:	LHLD	1		; Get BIOS JMP table start address
	LXI	D,61		; Offset of IOTABLE from BIOS+3
	DAD	D
	PUSH	H
	DW	0E1DDH		; (POP IX)
	DW	77DDH		; Z80 op code
	DB	PORT+2
	DW	OUT0
	DB	BAUDRP
	RET
;.....
;
;
; Baudrate table
;
	 IF	CLK6
BD300	EQU	13
BD1200	EQU	5
BD2400	EQU	4
BD9600	EQU	2
BD19200 EQU	1
BD38400 EQU	0
	 ENDIF			; CLK6
;
	 IF	CLK9
BD300	EQU	38
BD1200	EQU	36
BD2400	EQU	35
BD9600	EQU	33
BD19200 EQU	32
	 ENDIF			; CLK9
;
	 IF	CLK12
BD300	EQU	14
BD1200	EQU	6
BD2400	EQU	5
BD9600	EQU	3
BD19200 EQU	2
BD38400 EQU	1
	 ENDIF			; CLK12
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate prior to 0400H
;
	END
