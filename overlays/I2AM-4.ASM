
; I2AM-4.ASM - AMPRO "Little Board" overlay file for IMP - 06/01/87
;
;	 Z80 DART and 8430 CTC timer and 4.000 MHz clock
;
; This overlay adapts the IMP modem program to the AMPRO Series 100
; computer with the Z80 DART serial port "B" and the Z80 CTC baud rate
; generator.
;
; Important:  This computer does not use a clock that divides
;	      to the exact baud rate desired.  For instance,
;	      2400 bps comes out 2403.846 Hz.  A 1.9968 xtal
;	      would be needed.	9600 bps is actually 9615.385 Hz.
;
;
;	      CTS and RTS are used with the AMPRO computer as
;	      it does not support DTR or DCD - however it puts
;	      CTS on pin 20 which historically holds the DTR.
;	      Just be sure to drop CTS to hang up the phone.
;
;	      You will need to use the following wiring circuit:
;
;			Modem	   Ampro
;			-----	   -----
;			pin 2	   pin 3
;			pin 3	   pin 2
;			pin 7	   pin 7
;			pin 8	   pin 20
;			pin 20	   pin 5
;
; The Ampro DB-25 connector is shown wired per factory standards.
;
;-----------------------------------------------------------------------
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
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
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP.COM,I2AM-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.			- Irv Hoff
;
; 08/22/86  Added 'A' channel, up to 38400 bps	- Irv Hoff
; 11/05/85  Added 9600 pbs, etc.		- Irv Hoff
; 10/27/85  Written to work with IMP		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
ACHNL	EQU	NO		; 'A' channel, normally used for CRT
BCHNL	EQU	YES		; 'B' channel, normally used for modem
;
;
; Values shown are for a Z80 DART
;
;	 Channel		  A	 B
;	 Data port		 80h	88h
;	 Control port		 84h	8Ch
;	 CTC port		 40h	50h
;	 Maximum speed		77600	9600
;
;
	 IF	ACHNL
CHNL	EQU	80H
CTC	EQU	40H
	 ENDIF			; ACHNL
;
	 IF	BCHNL
CHNL	EQU	88H
CTC	EQU	50H
	 ENDIF			; BCHNL
;
;
PORT	EQU	CHNL	; Your base data port
MDCTL1	EQU	PORT+4	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	01H	; Modem receive ready
MDSND	EQU	04H	; Modem send ready bit
MDTXE	EQU	01H	; Modem send buffer empty, holding buffer empty
;
BRPORT	EQU	CTC	; Baud rate generator port (CTC)
;
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H	; ^[ = Escape
BELL	EQU	'G'-40H	; ^G = Bell character
LF	EQU	'J'-40H	; ^J = Linefeed
NEXTRY	EQU	'K'-40H	; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H	; ^M = Carriage return
CLEARSC	EQU	'Z'-40H	; ^Z = Clear screen, command mode only
EOFCHAR	EQU	'Z'-40H	; ^Z = End of file
;
;
;-----------------------------------------------------------------------
;
;
	ORG	0100H
;
;
	DS	3	; Skip the data area below
;
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	 DB	6	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	YES	; Yes=2400 bps highest speed			104H
HS1200:	 DB	NO	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	'*'	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			;   default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Yes=default to CRC checking			112H
IGNRCTL: DB	YES	; Yes=CTL-chars above ^M not displayed		113H
;.....
;
;
EXTCHR:	 DB	'['-40H	; ESC = preceeds local control character	114H
EXITCHR: DB	'E'	; Exit character				115H
FILESND: DB	'F'	; Send file when in terminal mode		116H
NOCONCT: DB	'N'	; Disconnect from phone line			117H
LOGCHR:	 DB	'L'	; Send logon					118H
LSTCHR:	 DB	'P'	; Toggle printer				119H
UNSAVCH: DB	'R'	; Close input text buffer			11AH
SAVECHR: DB	'Y'	; Open input text buffer			11BH
CLEARS:	 DB	'Z'	; Clears screen, terminal mode			11CH
BRKCHR:	 DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	NO	; YES if no DTR and need ATH0 to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: MVI	A,10H		; Register 0, reset interrupts		11FH
	  OUT	MDCTL1		;					121H
	  IN	MDCTL1		;					123H
	  RET			; IN modem control port 		125H
	  DB	0,0,0		; Spares if needed			126H
;
I$MDTXE:  MVI	A,11H		; Select read register 1		129H
	  OUT	MDCTL1		;					12BH
	  IN	MDCTL1		;					12DH
	  RET			;					12FH
	  DB	0,0,0		;					130H
;
I$MDDATP: IN	MDDATP		;					137H
	  RET			;					139H
	  DB	0,0,0,0,0,0,0	; Spares if needed			13AH

O$MDDATP: OUT	MDDATP		;					13DH
	  RET			; OUT modem data port			13FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
;.....
;
;
A$MDRCV:  ANI	MDRCV		;					147H
	  RET			;					149H
;
C$MDRCV:  CPI	MDRCV		;					14AH
	  RET			;					14CH
;
A$MDSND:  ANI	MDSND		;					14DH
	  RET			;					14FH
;
C$MDSND:  CPI	MDSND		;					150H
	  RET			;					152H
;
A$MDTXE:  ANI	MDTXE		;					153H
	  RET			;					155H
;
C$MDTXE:  CPI	MDTXE		;					156H
	  RET			;					158H
;.....
;
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:RET			;					159H
	  DB	0,0		;					15AH
;.....
;
;
; Jump vectors needed by each overlay
;
J$GOODBYE:JMP	GOODBYE		; Disconnects modem by dropping DTR	15CH
J$INITMOD:JMP	INITMOD		; Initializes modem, autosets baudrate	15FH
J$STUPR:  JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:  JMP	SYSVR		; Signon message			165H
;.....
;
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA: DS	3		; 1200 bps "AT" string			168H
J$STRNG1: DS	3		; 2400 bps "AT" string			16BH
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
;
J$CMDSPL: DS	3		; Allows entry of baudrate on CMD line	16EH
J$CRLF:	  DS	3		; Turns up one new line on display	171H
J$DIAL:	  DS	3		; Start of dialing routine		174H
J$DSCONT: DS	3		; Terminates modem use			177H
J$GOLST:  DS	3		; Printer routine, needed by Apple //e	17AH
J$ILPRT:  DS	3		; Prints an inline string, 0 to end	17DH
J$INBUF:  DS	3		; Stores a keybd string for comparison	180H
J$INLNCP: DS	3		; Inline "compare strings" routine	183H
J$INMDM:  DS	3		; Max .1 sec wait for modem character	186H
J$RCVRSP: DS	3		; For 3801 I/O use (TV-803)		189H
J$SNDCHR: DS	3		; Sends a character to the modem	18CH
J$SNDSTR: DS	3		; Sends a string to the modem, $ to end 18FH
J$TIMER:  DS	3		; .1 second timer (amount in 'B' reg.)	192H
J$BREAK:  JMP	SENDBRK		; Break routine 			195H
J$NEW2:	  DB	0,0,0		; For future needs			198H
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	  DB	0		; For manual selection flag		19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	  JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;.....
;
;
LOGPTR:	  DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7H
	  DB	'Version for the Ampro Little Board ' ; 		1AAH
	  DB	'using Port 88H',CR,LF,0
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
LOGON:	DB	'This is an Ampro Little Board computer. ',CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,5
	OUT	MDCTL1		; Send to the status port
	MVI	A,0F8H		; DTR normal, send break tone
	JMP	GOODBYE1	; Go send the break tone
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the modem.
;
GOODBYE:
	MVI	A,5
	OUT	MDCTL1		; Send to the status port
	MVI	A,78H		; Turn off DTR and send break tone
;
GOODBYE1:
	OUT	MDCTL1
	MVI	B,3		; Delay 300 ms
	CALL	J$TIMER
	MVI	A,5
	OUT	MDCTL1
	MVI	A,0E8H		; Restore normal, 8 bits, DTR on, etc.
	OUT	MDCTL1
	RET
;.....
;
;
; Sets CTC for baud rate.
;
INITMOD:
	MVI	A,0		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,18H		; Reset the Z8SIO chip
	OUT	MDCTL1		; Send to the status port
	MVI	A,4		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,44H		; 16x, 2-stop, no parity  (44=1,4C=2)
	OUT	MDCTL1		; Send to the status port
	MVI	A,3		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,0C1H		; Enable receive section
	OUT	MDCTL1		; Send to the status port
	MVI	A,5		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,0EAH		; DTR, RTS, 8-bits, enable send section
	OUT	MDCTL1		; Send to the status port
;
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 9600'
;
	 IF	ACHNL
	DB	', 19200, 38400'
	 ENDIF			; ACHNL
;
	DB	'): ',0
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
;
	 IF	ACHNL
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
	CALL	J$INLNCP
	DB	'38400',0
	JNC	OK38400
	 ENDIF			; ACHNL
;
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1		; MSPEED 300 baud value
	LXI	H,BD300		; Get 300 bps parameters in 'HL'
	JMP	LOADBD		; Go load them
;
OK1200:	MVI	A,5
	LXI	H,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset to maximum auto-speed
	MVI	A,6
	LXI	H,BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	LXI	H,BD9600
	JMP	LOADBD
;
	 IF	ACHNL
OK19200:MVI	A,9
	LXI	H,BD19200
	JMP	LOADBD
;
OK38400:MVI	A,9
	LXI	H,BD38400
	 ENDIF			; ACHNL
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baud rate
	MOV	A,H		; Command word
	OUT	BRPORT
	MOV	A,L		; Baudrate
	OUT	BRPORT
	RET
;.....
;
;
; Table of baud rate parameters
;
	 IF	ACHNL
BD300	EQU	0700H		; 76800/300 (first half is CTC command)
BD1200	EQU	0740H		; 76800/1200
BD2400	EQU	0720H		; 76800/2400
BD9600	EQU	4740H		; 614,400/9600
BD19200	EQU	4720H		; 614,400/19200
BD38400	EQU	4710H		; 614,400/38400
	 ENDIF			; ACHNL
;
	 IF	BCHNL
BD300	EQU	0734H		; 15600/300 (first half is CTC command)
BD1200	EQU	4768H		; 124800/1200
BD2400	EQU	4734H		; 124800/2400
BD9600	EQU	470DH		; 124800/9600
	 ENDIF			; BCHNL
;
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
