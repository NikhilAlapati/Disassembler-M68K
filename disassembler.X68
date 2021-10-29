*-----------------------------------------------------------
* Title      : M68K Dissesembler
* Written by : Nikhil Alapati, Mohamed Alturfi, William Simcox, Andy Tran
*-----------------------------------------------------------
* Project Plan Steps
* Take Input and store it in their respective variables. (COMPLETE)
* Store "pointer" to starting memory address (from input) into Address Register 6 . (COMPLETE)
* Read and store the first instruction (WORD size) (into data register?) (COMPLETE)
* Read the first 4 bits of the instruction to determine the command entered. (COMPLETE)
* Sub routine Branch to respective command group (COMPLETE)
* AND DONE (COMPLETE)

* C = Count/Register
* D = Data (Immediate Data)
* I = "Immediate/Register" bit (0 = immediate, 1 = register)
* L = Displacement
* M = Mode
* P = Op-Mode
* R = Register
* S = Size
* X = Direction of Transfer

*======ADDRESSING MODES======*
* Dn        000
* An        001
* (An)      010
* #<data>   111 R=100
* (An) +    011
* - (An)    100
* (xxx).W   111 R=000
* (xxx).L   111 R=001
*=========SIZE FIELD=========*
* ByteOP    (00 for NOT, ADDQ, LSL/LSR, ROL/ROR) + (01 for MOVE, MOVEA)
* WordOP    (01 for NOT, ADDQ, LSL/LSR, ROL/ROR) + (11 for MOVE, MOVEA)
* LongOP    (10 for NOT, ADDQ, LSL/LSR, ROL/ROR) + (10 for MOVE, MOVEA)
* WordTR    0
* LongTR    1
*==========DR FIELD==========*
* RtoM      0 (Rotate right)
* MtoR      1 (Rotate left)
*==========MOVEM MASK========*
* A7 A6 A5 A4 A3 A2 A1 A0 D7 D6 D5 D4 D3 D2 D1 D0
* 15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0

* D0 D1 D2 D3 D4 D5 D6 D7 A0 A1 A2 A3 A4 A5 A6 A7 
* 15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0

*============================*
* MOVE  00 SS RRR MMM MMM RRR (COMPLETE)      
* MOVEA 00 SS RRR 001 MMM RRR (COMPLETE)
*============================*
* NOT   0100 0110 SS MMM RRR (COMPLETE)
* LEA   0100 RRR1 11 MMM RRR (COMPELTE)
* NOP   0100 1110 0111 0001 (COMPLETE)
* RTS   0100 1110 0111 0101 (COMPLETE)
* JSR   0100 1110 10 MMM RRR (COMPLETE)
* MOVEM 0100 1X00 1S MMM RRR (COMPLETE)
*============================*
* ADDQ  0101 DDD 0 SS MMM RRR (COMPLETE)
*============================*
* BGT   0110 1110 LLLLLLLL (COMPLETE)
* BLE   0110 1111 LLLLLLLL (COMPLETE)
* BEQ   0110 0111 LLLLLLLL (COMPLETE)
* BRA   0110 0000 LLLLLLLL (COMPLETE)
*============================*
* MOVEQ 0111 RRR 0 DDDDDDDD (COMPLETE)
*============================*
* OR    1000 RRR PPP MMM RRR (COMPLETE)
*============================*
* SUB   1001 RRR PPP MMM RRR (COMPLETE)
*============================*
* AND   1100 RRR PPP MMM RRR (COMPLETE)
*============================*
* ADD   1101 RRR PPP MMM RRR (COMPLETE)
* ADDA  1101 RRR PPP MMM RRR (COMPLETE)
*============================*
* LSL   1110 CCC X SS I 01 RRR (COMPLETE)
* LSR   1110 CCC X SS I 01 RRR (COMPLETE)
* ASL   1110 CCC X SS I 00 RRR (COMPLETE)
* ASR   1110 CCC X SS I 00 RRR (COMPLETE)
* ROL   1110 CCC X SS I 11 RRR (COMPLETE)
* ROR   1110 CCC X SS I 11 RRR (COMPLETE)
*============================*
*  X       X      X     X     X     X     X      X      X            X            X           X           X                X
* MOVE - MOVEA - NOT - LEA - NOP - RTS - JSR - MOVEM - ADDQ - BGT/BLE/BEQ/BRA - MOVEQ - OR/SUB/AND/ADD - ADDA - LSL/LSR/ASL/ASR/ROL/ROR

START:	    ORG    $1000      

* Getting user input *  
WELCOME
    LEA     FormatMessage,A1    * This line loads FormatMessage into A1 
    MOVE.B  #14,D0              * This line moves Trap Task 14 to Display Messages
    TRAP    #15
INPUT1
    LEA     StartingMessage,A1  * This line loads StartingMessage into A1 
    MOVE.B  #14,D0              * This line moves Trap Task 14 to Display Messages
    TRAP    #15
	
    LEA     KeyboardInput,A1
    MOVE.B  #2,D0               * This gets user input
    TRAP    #15

    CLR.L   D0                  * Clears D0
    CLR.L   D1                  * Clears D1
    
    JSR     CONVERT             * Jumps to ASCII to Hex Converter Subroutine
    BTST.L  #0,D2               * Check to see if input is odd
    BNE     INPUT1ODD           * Display odd input error

    MOVE.L  D2,StartingAddress  * Moves final result into variable
    BRA     INPUT2

INPUT1ODD
    LEA     InvalidInputMsg,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     INPUT1

INPUT2            
    LEA     EndingMessage, A1   * This line loads EndingMessage into A1 
    MOVE.B  #14,D0              * This line moves Trap Task 14 to Display Messages
    TRAP    #15
    
    LEA     KeyboardInput,A1
    MOVE.B  #2, D0              * This gets user input
    TRAP    #15
     
    CLR.L   D0                  * Clears D0
    CLR.L   D1                  * Clears D1
    CLR.L   D2                  * Clears D2
     
    JSR     CONVERT             * Jumps to ASCII to Hex Converter Subroutine
    BTST.L  #0,D2               * Check to see if input is odd
    BNE     INPUT2ODD           * Display odd input error
    
    MOVE.L  D2,EndingAddress    * Moves final result into variable

    CMP.L   StartingAddress,D2
    BLT     INPUT2LOWER

    MOVEA.L StartingAddress,A0  * Copy StartingAddress to A0

    MOVE.B  #25,D5              * Main loop counter
    BRA     MAINLOOP

INPUT2LOWER
    LEA     InvalidAddress,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     INPUT2

INPUT2ODD
    LEA     InvalidInputMsg,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     INPUT2

MAINLOOP
    CLR.L   D1                  * Clears D1
    CMPA.L  EndingAddress,A0
    BGT     DONE

    CMP.B   #0,D5
    BEQ     PROMPTNEXT
    SUBQ.B  #1,D5

	JSR     CLRMRS              * Clear stored Modes and Registers
    MOVE.B  #0,IsInvalid

    MOVE.L  A0,InsAddress       * Copy instruction's address into InsAddress to print later
    MOVE.W  (A0)+,D3            * Copy instruction's 16bits into D3 and increments memory pointer
    MOVE.W  D3,StoredData       * Moves 16bits in a variable

    JSR     CMPGROUPS           * Go to group compare

    LEA     TXTFULLTAB,A1       * This line loads an empty text
    MOVE.B  #13,D0              * This line moves Trap Task 13 to move to next line
    TRAP    #15
    
    BRA     MAINLOOP

PROMPTNEXT
    LEA     NextPageMessage,A1  * Prints Prompt to view next 25 lines of code
    MOVE.B  #14,D0
    TRAP    #15
CPROMPTNEXT
    MOVE.B  #5,D0
    TRAP    #15

    CMP.B   #$D,D1              * Check if Input is an Enter Key
    BNE     CPROMPTNEXT         * Continue to read inputs until the key is "Enter"
    MOVE.B  #25,D5              * Displays another 25 lines
    BRA     MAINLOOP

DONE
    LEA     FinalMessage,A1     * Prints End of Program message
    MOVE.B  #14,D0
    TRAP    #15
LDONE
    LEA     EndingPrompt,A1     * Prints prompt for next step (disassemble more OR exit)
    MOVE.B  #14,D0
    TRAP    #15

    LEA     KeyboardInput,A1  
    MOVE.B  #2,D0               * This gets user input
    TRAP    #15

    CMP.B   #$59,KeyboardInput  * KeyboardInput = Y
    BEQ     WELCOME
    CMP.B   #$79,KeyboardInput  * KeyboardInput = y
    BEQ     WELCOME
    CMP.B   #$4E,KeyboardInput  * KeyboardInput = N
    BEQ     CDONE
    CMP.B   #$6E,KeyboardInput  * KeyboardInput = n
    BEQ     CDONE
    BNE     LDONE
CDONE
    SIMHALT   
*==========================INPUT CONVERSION=============================*
CONVERT	
    MOVE.B  (A1)+,D0            * Stores the first byte of input into D0 and moves to the next input byte
    JSR     CHECKER             * Check for Letter or Number to convert
   
    BRA     APPEND              * Appends Hex to Final Hex String
*=======================================================================*
CHECKER
    CMP.B   #$39,D0             * Checks to see if input is a number
    BLE     ISNUMBER            * If true, branch to ISNUMBER which converts numbers    
    BRA     ISLETTER            * Else, branch to ISLETTER which converts letters 
*=======================================================================*
APPEND
    ADD.L   D0,D1               * Append onto D1
    CLR.L   D0                  * Clears D0
APPENDHELPER
    * BASE CASE *
    CMPI.B  #0,(A1)             * Checks contents of A1 to check for ending address
    BEQ     BREAK               * If true, break

    LSL.L   #4,D1               * Advance onto next byte (Making space for new input)
    BRA     CONVERT             * Loop back
*=======================================================================*
BREAK 
    MOVE.L  D1,D2               * Move final result into D2
    RTS                         * Breaks out of subroutine (goes back to CONVERTER)
*=======================================================================*
ISLETTER
    SUBI.B  #$37,D0
    CMP.B   #$2A,D0
    BLT     APPEND
    SUBI.B  #$20,D0
    BRA     APPEND
*=======================================================================*  
ISNUMBER 
    SUBI.B  #$30,D0
    BRA     APPEND  
*==========================END OF INPUT CONVERSION======================*   
*==========================START OF COMMAND GROUP SUBROUTINES===========*
* Reads next bits of a command *
RDBITS
    CLR.L   D7
    CLR.L   D4
    MOVE.B  BitsToRead,D7      
LRDBITS
    CMP.B   #0,D7               * LOOP COUNTER
    BEQ     RETURN              

    LSL.W   #1,D4               * Left shifts to make space for new bit
    LSL.W   #1,D3               * Shift by one bit to get the MSB to the carry bit
    
    BCS     SET1                * Compares carry bit, if 1 then branch to SET1 subroutine
    SUBI.B  #1,D7
    JMP     LRDBITS             * Loops back to LRDBITS
SET1
    ADD.W   #%0001,D4           * Adds 1 to the final destination (D4)
    SUBI.B  #1,D7
    JMP     LRDBITS             * Loops back to LRDBITS
CMPGROUPS                       * Compares the first 4 bits of instruction 
	MOVE.B  #4,BitsToRead       * Passing in how many bits to read into RDBITS
    JSR     RDBITS              * Jumps to subroutine that gets the first 4 bits and stores it in D4
	
    CMP.W   #%0000,D4           * Compares to 0000
    BEQ     PRTDATA             * If true, Goes to PRTDATA

    CMP.W   #%0100,D4           * Compares to check if D4 is less than 0100 
    BLT     CMPMOVE             * If true, Goes to CMPMOVE (MOVE and MOVEA)
    BEQ     CMP0100             * If true, Goes to CMP0100 (NOP, RTS, NOT, MOVEM, JSR, LEA)

    CMP.W   #%0101,D4           * Compares to check if D4 is equal to 0101
    BEQ     CHKADDQ             * If true, Goes to CHKADDQ (ADDQ)

    CMP.W   #%0110,D4           * Compares to check if D4 is equal to 0110
    BEQ     CMP0110             * If true, Goes to CMP0110 (Branches)

    CMP.W   #%0111,D4           * Compares to check if D4 is equal to 0111
    BEQ     CHKMOVEQ            * If true, Goes to CMP0111 (MOVEQ)
    
    CMP.W   #%1000,D4           * Compares to check if D4 is equal to 1000
    BEQ     CMPOSAAA            * If true, Goes to CMPOSAAA (OR)
    
    CMP.W   #%1001,D4           * Compares to check if D4 is equal to 1001
    BEQ     CMPOSAAA            * If true, Goes to CMPOSAAA (SUB)

    CMP.W   #%1100,D4           * Compares to check if D4 is equal to 1100
    BEQ     CMPOSAAA            * If true, Goes to CMPOSAAA (AND)

    CMP.W   #%1101,D4           * Compares to check if D4 is equal to 1101
    BEQ     CMPOSAAA            * If true, Goes to CMPOSAAA (ADDs)

    CMP.W   #%1110,D4           * Compares to check if D4 is equal to 1110
    BEQ     CMP1110             * If true, Goes to CMP1110 (Shifts and Rotates)
    BNE     PRTDATA             * If not equal to any of the above, Goes to PRTDATA
*================These are cluster compares for each subgroup============*   
CMPMOVE
	MOVE.B  D4,SS				* MOVES THE LAST 2 BITS OF D4 INTO SS
	
	MOVE.B  #3,BitsToRead       * Reads next 3 bits in MOVE(A) which is RRRD
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRD             * Move instruction mode into RRRD
	
	MOVE.B  #3,BitsToRead       * Reads next 3 bits in MOVE(A) which is MMMD
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMD             * Move instruction mode into MMMD
	
	MOVE.B  #3,BitsToRead       * Reads next 3 bits in MOVE(A) which is MMMS
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMS             * Move instruction mode into MMMS
	
	MOVE.B  #3,BitsToRead       * Reads next 3 bits in MOVE(A) which is RRRS
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRS             * Move instruction mode into RRRS
	
	CMP.B   #%001,MMMD			* Checks for MOVE vs MOVEA
	BEQ		CHKMOVEA            * Goes to MOVEA if Mode is 001
	BNE		CHKMOVE             * Else, its a MOVE
CMP0100                  
    BTST.L  #$0C,D3             * Compares the 8th bit to check if LEA
    BNE     CHKLEA              * If zero bit is clear, branch to CHKLEA

    MOVE.B  #4,BitsToRead
    JSR     RDBITS              * Get the next 4 bits

    CMP.W   #%0110,D4           * Compares to check if D4 is equal to 0110
    BEQ     CHKNOT              * If true, Goes to CHKNOT 

    CMP.W   #%1000,D4           * Compares to check if D4 is equal to 1000
    BEQ     CHKMOVEM2           * If true, Goes to CHKMOVEM 

    CMP.W   #%1100,D4           * Compares to check if D4 is equal to 1100
    BEQ     CHKMOVEM1           * If true, Goes to CHKMOVEM 

    CMP.W   #%1110,D4           * Compares to check if D4 is equal to 1110
    BEQ     CHKNRJ              * If true, Goes to CHKNRJ where N is NOP R is RTS and J is JSR
    BNE     PRTDATA             * If not equal to any of the above, Goes to PRTDATA   
CMP0110
    MOVE.B  #4,BitsToRead       * Reads next 4 bits
    JSR     RDBITS              * Get the next 4 bits stores them in D4
    MOVE.B  D4,BranchType

    CMP.B   #%1110,D4           * Compares to check if D4 is equal to 1110
    BEQ     CHKBRA              * If true, Goes to CHKBRA
    CMP.B   #%1111,D4           * Compares to check if D4 is equal to 1111
    BEQ     CHKBRA              * If true, Goes to CHKBRA
    CMP.B   #%0111,D4           * Compares to check if D4 is equal to 0111
    BEQ     CHKBRA              * If true, Goes to CHKBRA
    CMP.B   #%0000,D4           * Compares to check if D4 is equal to 1000
    BEQ     CHKBRA              * If true, Goes to CHKBRA
    BNE     PRTDATA             * If not equal to any of the above, Goes to PRTDATA
CMPOSAAA
    MOVE.B  D4,SwitchBits       * Store first 4 bits of instruction to compare later

    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRT             * Store the register in RRRT
    
    MOVE.B  #1,BitsToRead       * Reading next bit
    JSR     RDBITS              * Reading DR
    MOVE.B  D4,XBit             * Storing in XBit

    MOVE.B  #2,BitsToRead       * Reads next 2 bits SS
    JSR     RDBITS              * Get the next 2 bits stores them in D4
    MOVE.B  D4,SS               * Stores size into SS

    MOVE.B  #%001,MMMT
    CMP.B   #%11,SS
    BEQ     CHKADDA

    MOVE.B  #%000,MMMT
    JSR     CHKXBIT
    
    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMT             * Store the mode in MMMT

    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRT             * Store the mode in RRRT

    MOVE.B  #7,CmdIndex
    JSR     CHKTEMP
    CMP.B   #$F,TempMode        * If TempMode is invalid
    BEQ     PRTDATA           	* Print DATA instead
    CMP.B   #$E,TempMode        * If TempMode is invalid EA
    BEQ     SETINVEA           	* 

    CMP.B   #%1000,SwitchBits
    BEQ     CHKORAND
    CMP.B   #%1001,SwitchBits
    BEQ     CHKSUBADD
    CMP.B   #%1100,SwitchBits
    BEQ     CHKORAND
    CMP.B   #%1101,SwitchBits
    BEQ     CHKSUBADD
CMP1110
    MOVE.B  #3,BitsToRead       * Reading next 3 bits
    JSR     RDBITS              * Reading COUNT/REGISTER
    MOVE.B  D4,RRRS             * Storing in RRRS

    MOVE.B  #1,BitsToRead       * Reading next bit
    JSR     RDBITS              * Reading DR
    MOVE.B  D4,XBit             * Storing in XBit
    
    MOVE.B  #2, BitsToRead      * Reading next 2 bits
    JSR     RDBITS              * Reading SIZE
    MOVE.B  D4, SS              * Storing in SS
    CMP.B   #%11,D4             * Checking if size is 11

    BEQ     CMP1110EA           * If 11, then it's 1110 EA

    MOVE.B  #1, BitsToRead      * Reading next bit
    JSR     RDBITS              * Reading i/r
    MOVE.B  D4,IRBit            * Storing in IRBit
    
    MOVE.B  #2, BitsToRead      * Reading next 2 bits
    JSR     RDBITS              * Reading SwitchBits
    MOVE.B  D4, SwitchBits      * Stores it in SwitchBits
    JMP     PRTLSLR
    *CMP.B   #%01, D4           * Comparing to check if 01
    *BEQ     PRTLSLR            * Jump to CHKLSLR
    *CMP.B   #%00, D4           * Comparing to check if 00
	*BEQ     CHKASLR            * Jump to CHKASLR
    *CMP.B   #%11, D4           * Comparing to check if 11
    *BEQ     CHKROLR            * Jump to CHKROLR
    *BNE     PRTDATA            * If none then print DATA
CMP1110EA
    CMP.B   #%000, RRRS         * Comparing to check if 00
	BEQ     CCMP110EA           * Jump to CCMP110EA
    CMP.B   #%011, RRRS         * Comparing to check if 11
    BEQ     CCMP110EA           * Jump to CCMP110EA
    CMP.B   #%001, RRRS         * Comparing to check if 10
    BEQ     CCMP110EA           * Jump to CCMP110EA
    BNE     PRTDATA             * 10 is invalid so print data
CCMP110EA
    MOVE.B  #3,BitsToRead       * Reading next 3 bits
    JSR     RDBITS              * Reading EA MODE
    MOVE.B  D4,MMMD             * Storing in MMMD

    MOVE.B  #3,BitsToRead       * Reading next 3 bits
    JSR     RDBITS              * Reading register for EA
    MOVE.B  D4,RRRD             * Storing in RRRD
    
    MOVE.B  #9,CmdIndex
    JSR     CHKDST
    CMP.B   #$F,DstMode         * If DstMode is invalid
    BEQ     PRTDATA           	* Print DATA instead
    CMP.B   #$E,DstMode         * If DstMode is invalid EA
    BEQ     SETINVEA          	* 
    CMP.B   #$0,DstMode         * If DstMode is invalid
    BEQ     SETINVEA           	* 
    CMP.B   #$1,DstMode         * If DstMode is invalid
    BEQ     SETINVEA           	* 
    CMP.B   #$B,DstMode         * If DstMode is invalid
    BEQ     SETINVEA           	* 

    BRA PRTLSLREA

*================These are sub compares for each subgroup============*
*--------------------------------MOVE--------------------------------* 
CHKMOVE
    MOVE.B  #0,CmdIndex         
	JSR		CHKSRC				* Check Source Mode
	JSR		CHKDST				* Check Destination Mode
	
	CMP.B   #$F,SrcMode         * If SrcMode is invalid
    BEQ     PRTDATA           	* Print DATA instead

    CMP.B   #$F,DstMode         * If DstMode is invalid
    BEQ     PRTDATA           	* 

    CMP.B   #$E,SrcMode         * If SrcMode is invalid EA
    BEQ     SETINVEA           	* 

    CMP.B   #$E,DstMode         * If DstMode is invalid EA
    BEQ     SETINVEA           	* 
	
    CMP.B   #$1,DstMode         * If DstMode is 001 = 'An'
    BEQ     SETINVEA           	* 

	CMP.B   #$B,DstMode         * If DstMode is 111 + 100 = #<data>
    BEQ     SETINVEA           	*  
    BRA     PRTMOVE
*--------------------------------MOVEA-------------------------------* 
CHKMOVEA
	CMP.B 	#%01,SS				* MOVEA size cannot be Byte
	BEQ		PRTDATA				* Print DATA instead
	
    MOVE.B  #1,CmdIndex         
	JSR		CHKSRC				* Check Source Mode
	JSR		CHKDST				* Check Destination Mode
	
	CMP.B   #$F,SrcMode         * If SrcMode is invalid
    BEQ     PRTDATA           	* Print DATA instead

    CMP.B   #$E,SrcMode         * If SrcMode is invalid EA
    BEQ     SETINVEA           	* 

	CMP.B   #$1,DstMode         * If DstMode is 001 = 'An'
    BEQ     PRTMOVEA          	* Print MOVEA 
	BRA		PRTDATA				* Print DATA instead
*--------------------------------LEA---------------------------------* 
CHKLEA
    MOVE.B  #3,BitsToRead       * Reads next 3 bits in LEA which is RRRD
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRD             * Stores RRRD

    MOVE.B  #3,BitsToRead       * Reads next 3 bits in LEA which should be 1 11
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    CMP.B   #7,D4               * if mode = 111 = continue
    BNE     PRTDATA             * Print Data instead

    MOVE.B  #3,BitsToRead       * Reads next 3 bits in LEA which is MMMS
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMS             * 

    MOVE.B  #3,BitsToRead       * Reads next 3 bits in LEA which is RRRS
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRS             * 
    
    MOVE.B  #3,CmdIndex         
	JSR		CHKSRC				* Check Source Mode
	
	CMP.B   #$F,SrcMode         * If SrcMode is invalid
    BEQ     PRTDATA           	* Print DATA instead
	
	CMP.B   #$2,SrcMode         * If SrcMode is 010 = '(An)'
    BEQ     PRTLEA           	* Print LEA
	
	CMP.B   #$7,SrcMode         * If SrcMode is 111 + 000 = (XXX).W
    BEQ     PRTLEA           	* Print LEA
	
	CMP.B   #$8,SrcMode         * If SrcMode is 111 + 001 = (XXX).L
    BEQ     PRTLEA           	* Print LEA
	BRA		SETINVEA
*--------------------------------NOT---------------------------------* 
CHKNOT
    MOVE.B  #2,BitsToRead       * Reads next 2 bits in NOT which is SS
    JSR     RDBITS              * Get the next 2 bits stores them in D4
    MOVE.B  D4,SS               * Stores size into SS
    
    CMP.B   #%11,D4             * Compare the size bits to 00, 01, 10 (b,w,l)
    BEQ     PRTDATA             * Else, If 11 or 00 print data (invalid)
    
    MOVE.B  #3,BitsToRead       * Reads next 3 bits in NOT which is MMMD
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMD             * Move destination mode into MMMD

    MOVE.B  #3,BitsToRead       * Reads next 3 bits in NOT which is RRRD
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRD             * Move destination register into RRRD
    
    MOVE.B  #2,CmdIndex 
	JSR		CHKDST				* Check Destination Mode

	CMP.B   #$F,DstMode         * If DstMode is invalid
    BEQ     PRTDATA           	* Print DATA instead

    CMP.B   #$E,DstMode         * If DstMode is invalid EA
    BEQ     SETINVEA           	* 
	
	CMP.B   #$1,DstMode         * If DstMode is 001 = 'An'
    BEQ     SETINVEA           	* 
	
	CMP.B   #$B,DstMode         * If DstMode is 111 + 100 = #<data>
    BEQ     SETINVEA           	* 
	BRA		PRTNOT
*----------------------------NOP RTS JSR-----------------------------*
CHKNRJ
    MOVE.B  #2,BitsToRead
    JSR     RDBITS              * Reads the next 2 bits
    
    CMP.B   #%01,D4             * Checks for 01 (NOP or RTS)
    BEQ     CHKNR               * If true, branch to NR 

    CMP.B   #%10,D4             * Checks for 10 (JSR)
    BEQ     CHKJSR              * If true, branch to JSR size checke
    BNE     PRTDATA             * Else, If 11 or 00 print data (invalid)
*------------------------------NOP RTS-------------------------------*
CHKNR
    CMP.W   #$C400,D3           * Checks for NOP
    BEQ     PRTNOP              * If true, then go to NOP

    CMP.W   #$D400,D3           * Checks for RTS 
    BEQ     PRTRTS              * If true, then go to RTS 
    BNE     PRTDATA             * If not equal to any of the above, Goes to PRTDATA 
*--------------------------------JSR---------------------------------*
CHKJSR
    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
	MOVE.B  D4,MMMD
	
	MOVE.B  #3,BitsToRead       * Read next 3 bits (register bits) 
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRD             * Moves the 3 bits into register variable (to print correct size)
	
    MOVE.B  #4,CmdIndex 
	JSR		CHKDST				* Check Destination Mode
	
    CMP.B   #$F,DstMode         * If DstMode is invalid
    BEQ     PRTDATA           	* Print DATA instead   

	CMP.B   #$2,DstMode         * If DstMode is 010 = '(An)'
    BEQ     PRTJSR           	* Print JSR
	
	CMP.B   #$7,DstMode         * If DstMode is 111 + 000 = (XXX).W
    BEQ     PRTJSR           	* Print JSR
	
	CMP.B   #$8,DstMode         * If DstMode is 111 + 001 = (XXX).L
    BEQ     PRTJSR           	* Print JSR
	BRA		SETINVEA 
*-------------------------------MOVEM--------------------------------*
CHKMOVEM1
    MOVE.B  #1,XBit
CHKMOVEM2
    MOVE.B  #1,BitsToRead        
    JSR     RDBITS              * Get the next 1 bit stores them in D4
    CMP.B   #%1,D4              * Next bit has to be 1
    BNE     PRTDATA             * If not, print data

    MOVE.B  #1,BitsToRead        
    JSR     RDBITS              * Get the next 1 bit stores them in D4
    MOVE.B  D4,SBit             * Save size bit into SBit

    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMT             * Store the mode in MMMT

    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRT             * Store the mode in RRRT

    MOVE.B  #5,CmdIndex
    JSR     CHKTEMP
    JSR     CHKXBIT

    CMP.B   #$F,TempMode        * If TempMode is invalid
    BEQ     PRTDATA           	* Print DATA instead

    CMP.B   #$E,TempMode        * If TempMode is invalid EA
    BEQ     SETINVEA          	* 

    CMP.B   #$2,TempMode        * If TempMode is 010 = '(An)'
    BEQ     PRTMOVEM           	

    CMP.B   #$7,TempMode        * If TempMode is 111 + 000 = (XXX).W
    BEQ     PRTMOVEM           	 

    CMP.B   #$8,TempMode        * If TempMode is 111 + 001 = (XXX).L
    BEQ     PRTMOVEM           	 
               
    CMP.B   #$4,DstMode         * If DstMode is 100 = '-(An)'
    BEQ     PRTMOVEM           	 

    CMP.B   #$3,SrcMode         * If SrcMode is 011 = '(An)+'
    BEQ     PRTMOVEM           	 
    BRA     SETINVEA
*--------------------------------ADDQ--------------------------------*
CHKADDQ
	MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
	MOVE.B  D4,DDD
    
	JSR		FRMTDDD             * Format Data
	
	MOVE.B  #1,BitsToRead        
    JSR     RDBITS              * Get the next 1 bit stores them in D4
	CMP.B   #0,D4				* If not equal to 0
	BNE		PRTDATA				* Print data instead
	
	MOVE.B  #2,BitsToRead       * Reads next 2 bits which is SS
    JSR     RDBITS              * Get the next 2 bits stores them in D4
    MOVE.B  D4,SS               * Stores size into SS
	CMP.B 	#%11,SS				* Size cannot be #%11
	BEQ		PRTDATA				* Print DATA instead
	
	MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
	MOVE.B  D4,MMMD
	
	MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
	MOVE.B  D4,RRRD
	
    MOVE.B  #6,CmdIndex
	JSR		CHKDST				* Check Destination Mode
	
	CMP.B   #$F,DstMode         * If DstMode is invalid
    BEQ     PRTDATA           	* Print DATA instead 

    CMP.B   #$E,DstMode         * If DstMode is invalid EA
    BEQ     SETINVEA           	* 
	
	CMP.B   #$B,DstMode         * If DstMode is 111 + 100 = #<data>
    BEQ     SETINVEA           	* Print DATA instead
	BRA		PRTADDQ
*--------------------------BGT BLE BEQ BRA---------------------------*
CHKBRA
    MOVE.B  #8,BitsToRead        
    JSR     RDBITS              * Get the next 8 bits stores them in D4

    JSR     CHK00FF             * Check to see if 8-bit displacement is #$00 or #$FF

    ADD.L   InsAddress,D4
    ADD.L   #2,D4

    BRA     PRTBRA
CHK00FF
    CMP.B   #$00,D4             * If 8-bit displacement is #$00
    BEQ     RDWORD              * Read 16-bit displacement

    CMP.B   #$FF,D4             * If 8-bit displacement is #$FF
    BEQ     RDLONG              * Read 32-bit displacement
    RTS
*--------------------------------MOVEQ-------------------------------* 
CHKMOVEQ
    MOVE.B  #3,BitsToRead       * Reads next 3 bits
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRD             * Moves register value to RRRD

    MOVE.B  #1,BitsToRead       * Reads the next bit into D4
    JSR     RDBITS              
    CMP.B   #0,D4               * If not equal to 0
    BNE     PRTDATA             * Print data instead

    MOVE.B  #8,BitsToRead       * Reads next 8 bits
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,DDDDDDDD         * Moves data value to DDDDDDDD

    BRA     PRTMOVEQ
*-------------------------------OR, AND------------------------------* 
CHKORAND
    CMP.B   #$1,TempMode        * If TempMode is invalid
    BEQ     SETINVEA           	* 
    BRA     PRTOSAA
*------------------------------SUB, ADD------------------------------*
CHKSUBADD
    CMP.B   #%00,SS
    BNE     CCHKSUBADD
    CMP.B   #$1,TempMode        * If TempMode is invalid
    BEQ     SETINVEA           	* 
CCHKSUBADD
    BRA     PRTOSAA
*-------------------------------ADDA---------------------------------* 
CHKADDA
    CMP.B   #%1101,SwitchBits   
    BNE     PRTDATA

    MOVE.B  #%01,SS             * Set size in SS by checking XBit
    CMP.B   #%0,XBit
    BEQ     CCHKADDA
    MOVE.B  #%10,SS
CCHKADDA
    MOVE.B  RRRT,RRRD           * Set Temp register to Destination
    MOVE.B  MMMT,MMMD           * Set mode Destination to 'An'
    MOVE.B  #$1,DstMode

    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,MMMS             * Store the mode in MMMS

    MOVE.B  #3,BitsToRead        
    JSR     RDBITS              * Get the next 3 bits stores them in D4
    MOVE.B  D4,RRRS             * Store the mode in RRRS

    MOVE.B  #8,CmdIndex
    JSR     CHKSRC
    CMP.B   #$F,SrcMode         * If TempMode is invalid
    BEQ     PRTDATA           	* Print DATA instead
    CMP.B   #$E,SrcMode         * If TempMode is invalid EA
    BEQ     SETINVEA           	* 
    BRA     PRTADDA
*=================Check modes and registers================*
* Valid(0, 1, 2, 3, 4, 7, 8, B):Invalid(5, 6, 9, A, [F])
*--------------------------Temp----------------------------* 
CHKTEMP
	MOVE.B  #$F,TempMode
	
	CMP.B   #7,MMMT             * if mode = 111 = either word or long depending on register 
    BEQ     CHKTREG             * Checks registers

	CMP.B   #5,MMMT             * if mode = 101 = (d16,An)
    BEQ     RCHKTEMP           	* 
	
	CMP.B   #6,MMMT             * if mode = 110 = (d8,An,Xn)
    BEQ     RCHKTEMP           	* 
	
	MOVE.B  MMMT,TempMode
	RTS
CHKTREG
	CMP.B   #2,RRRT             * if RRRT = 010 = (d16,PC)
    BEQ     RCHKTEMP    

    CMP.B   #3,RRRT             * if RRRT = 011 = (d8,PC,Xn)
    BEQ     RCHKTEMP
	
	CMP.B   #5,RRRT             * if RRRT = 101
    BEQ     RETURN
	
	MOVE.B  MMMT,TempMode
	CLR.L   D6
	MOVE.B  RRRT,D6
	ADD.B   D6,TempMode
    RTS
RCHKTEMP
    MOVE.B  #$E,TempMode
    RTS
*-------------------------Source---------------------------* 
CHKSRC
	MOVE.B  #$F,SrcMode
	
	CMP.B   #7,MMMS             * if mode = 111 = either word or long depending on register 
    BEQ     CHKSREG             * Checks registers

	CMP.B   #5,MMMS             * if mode = 101 = (d16,An)
    BEQ     RCHKSRC           	*  
	
	CMP.B   #6,MMMS             * if mode = 110 = (d8,An,Xn)
    BEQ     RCHKSRC           	* 
	
	MOVE.B  MMMS,SrcMode
	RTS
CHKSREG
	CMP.B   #2,RRRS             * if RRRS = 010
    BEQ     RCHKSRC    

    CMP.B   #3,RRRS             * if RRRS = 011
    BEQ     RCHKSRC
	
	CMP.B   #5,RRRS             * if RRRS = 101
    BGE     RETURN
	
	MOVE.B  MMMS,SrcMode
	CLR.L   D6
	MOVE.B  RRRS,D6
	ADD.B   D6,SrcMode
    RTS
RCHKSRC
    MOVE.B  #$E,SrcMode
    RTS
*-----------------------Destination------------------------* 	
CHKDST
	MOVE.B  #$F,DstMode
	
	CMP.B   #7,MMMD             * if mode = 111 = either word or long depending on register 
    BEQ     CHKDREG             * Checks registers
	
	CMP.B   #5,MMMD             * if mode = 101 = (d16,An)
    BEQ     RCHKDST           	* Print DATA instead 
	
	CMP.B   #6,MMMD             * if mode = 110 = (d8,An,Xn)
    BEQ     RCHKDST           	* Print DATA instead
	
	MOVE.B  MMMD,DstMode
	RTS
CHKDREG
	CMP.B   #2,RRRD             * if RRRD = 010
    BEQ     RCHKDST    

    CMP.B   #3,RRRD             * if RRRD = 011
    BEQ     RCHKDST
	
	CMP.B   #5,RRRD             * if RRRD = 101
    BGE     RETURN
	
	MOVE.B  MMMD,DstMode
	CLR.L   D6
	MOVE.B  RRRD,D6
	ADD.B   D6,DstMode
    RTS
RCHKDST
    MOVE.B  #$E,DstMode
    RTS
*---------------------------XBit---------------------------* 		
CHKXBIT
    CMP.B   #%0,XBit
    BEQ     TMP2DST             * Set Temp register and mode to Destination
    BNE     TMP2SRC             * Set Temp register and mode to Source
    RTS                         * Just in case it fails
TMP2DST
    MOVE.B  RRRT,RRRD
    MOVE.B  MMMT,MMMD
    JSR     CHKDST
    RTS
TMP2SRC
    MOVE.B  RRRT,RRRS
    MOVE.B  MMMT,MMMS
    JSR     CHKSRC
    RTS
*=====================General Printers=====================*      
*---------------------Spaces and Tabs----------------------* 
PRTSPACES                       * Print D7 number of space characters
    CLR     D1
CPRTSPACES
    CMP.B   #0,D7
    BEQ     RETURN
    MOVE.B  #6,D0
    MOVE.B  #$20,D1             * Space character
    TRAP    #15
    SUBI.B  #1,D7
    BRA     CPRTSPACES
*-------------------Long Addresses/Data--------------------* 
PRTLONG
    CLR     D1                  * Clears registers
    CLR     D7

    CMP.L   #$F,D6              * Check current memory address
    BLE     PRTZ7
    CMP.L   #$FF,D6
    BLE     PRTZ6
    CMP.L   #$FFF,D6
    BLE     PRTZ5
    CMP.L   #$FFFF,D6
    BLE     PRTZ4
    CMP.L   #$FFFFF,D6
    BLE     PRTZ3
    CMP.L   #$FFFFFF,D6
    BLE     PRTZ2
    CMP.L   #$FFFFFFF,D6
    BLE     PRTZ1
	BRA		PRTZ
PRTZ7
    MOVE.B  #7,D7
    BRA     PRTZ
PRTZ6
    MOVE.B  #6,D7
    BRA     PRTZ
PRTZ5
    MOVE.B  #5,D7
    BRA     PRTZ
PRTZ4
    MOVE.B  #4,D7
    BRA     PRTZ
PRTZ3
    MOVE.B  #3,D7
    BRA     PRTZ
PRTZ2
    MOVE.B  #2,D7
    BRA     PRTZ
PRTZ1
    MOVE.B  #1,D7
    BRA     PRTZ
PRTZ
    CMP.B   #0,D7
    BEQ     CPRTLONG
    MOVE.B  #$30,D1
    MOVE.B  #6,D0
    TRAP    #15
    SUBI.B  #1,D7
    BRA     PRTZ
CPRTLONG
    MOVE.L  D6,D1               * This line loads D6 (address) into D1
    MOVE.B  #16,D2              * This loads base into D2 (base 16 hex)
    MOVE.B  #15,D0              * This line moves Trap Task 15 to Display Messages
    TRAP    #15
    RTS
*--------------------Word Addresses/Data-------------------*  
PRTWORD
    CLR     D1                  * Clears registers
    CLR     D7

    CMP.L   #$F,D6              * Check current memory address
    BLE     PRTWZ3
    CMP.L   #$FF,D6
    BLE     PRTWZ2
    CMP.L   #$FFF,D6
    BLE     PRTWZ1
	BRA		PRTWZ
PRTWZ3
    MOVE.B  #3,D7
    BRA     PRTWZ
PRTWZ2
    MOVE.B  #2,D7
    BRA     PRTWZ
PRTWZ1
    MOVE.B  #1,D7
    BRA     PRTWZ
PRTWZ
    CMP.B   #0,D7               * Base Case: Breaks to CPRTWORD when loop is done
    BEQ     CPRTWORD
    
    MOVE.B  #$30,D1
    MOVE.B  #6,D0
    TRAP    #15
    SUBI.B  #1,D7
    BRA     PRTWZ
CPRTWORD
    MOVE.L  D6,D1               * This line loads D6 (address) into D1
    MOVE.B  #16,D2              * This loads base into D2 (base 16 hex)
    MOVE.B  #15,D0              * This line moves Trap Task 15 to Display Messages
    TRAP    #15
    RTS
*--------------------Byte Addresses/Data-------------------*
PRTBYTE
    CLR     D1                  * Clears registers
    CLR     D7

    CMP.L   #$F,D6              * Check current memory address
    BLE     PRTBZ1              
    BRA     PRTBZ               * Else, go to PRTBZ
PRTBZ1
    MOVE.B  #1,D7
    BRA     PRTBZ
PRTBZ                           
    CMP.B   #0,D7               * Base Case: Breaks to CPRTBYTE when loop is done
    BEQ     CPRTBYTE
    
    MOVE.B  #$30,D1             * Moves a zero into D1 (TRAP TASK 6 reads from D)
    MOVE.B  #6,D0               
    TRAP    #15

    SUBI.B  #1,D7               * Decrememnt loop
    BRA     PRTBZ               * Branch to Loop
CPRTBYTE
    MOVE.L  D6,D1               * This line loads D6 (address) into D1
    MOVE.B  #16,D2              * This loads base into D2 (base 16 hex)
    MOVE.B  #15,D0              * This line moves Trap Task 15 to Display Messages
    TRAP    #15

    RTS
*===================Instruction Printers===================* 
*--------------------------------LSL/R-------------------------------* 
PRTLSLREA
    MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)  
    
    CMP.B   #%000, RRRS         * Comparing to check if 00
	BEQ     PRTASLTEXT          * Jump to PRTASLTEXT
    CMP.B   #%011, RRRS         * Comparing to check if 11
    BEQ     PRTROLTEXT          * Jump to PRTROLTEXT
    CMP.B   #%001, RRRS         * Comparing to check if 10
    BNE     PRTDATA             * 10 is invalid so print data

    CMP.B   #%1,Xbit
    BNE     PRTLSREATEXT
    LEA     TXTLSL,A1         	* Prints LSL
    MOVE.B  #14,   D0
    TRAP    #15
CONTINUEPRTLSLREA
    MOVE.B  #5,D7               * 5 spaces to be printed
    JSR     PRTSPACES           * Jump to prtspaces to print the space 5 times
    
    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CLR.L   D6
    MOVE.B  RRRD,D6
    JSR     PRTDST
    MOVE.B  #0, XBit
    MOVE.B  #0, SwitchBits
    RTS
PRTLSREATEXT
    LEA     TXTLSR,A1         	* Prints LSR
    MOVE.B  #14,   D0
    TRAP    #15
    BRA     CONTINUEPRTLSLREA

PRTASLTEXT
    CMP.B   #%0,Xbit
    BEQ     PRTASRTEXT          * Prints ASR
    LEA     TXTASL,A1         	* Prints ASL
    MOVE.B  #14,   D0
    TRAP    #15
CONTINUEPRTASLTEXT
    CMP.B   #%11, SS
    BEQ     CONTINUEPRTLSLREA 
    CMP.B   #%0,IRBit
    BEQ     CONTINUEPRTLSLRCCC
    BRA     CONTINUEPRTLSLRRRR

PRTASRTEXT
    LEA     TXTASR,A1         	* Prints ASR
    MOVE.B  #14,   D0
    TRAP    #15
    BRA     CONTINUEPRTASLTEXT

PRTROLTEXT
    CMP.B   #%0,Xbit
    BEQ     PRTRORTXT
    LEA     TXTROL,A1         	* Prints ROL
    MOVE.B  #14,   D0
    TRAP    #15
CONTINUEPRTROLTEXT
    CMP.B   #%11, SS
    BEQ     CONTINUEPRTLSLREA 
    CMP.B   #%0,IRBit
    BEQ     CONTINUEPRTLSLRCCC
    BRA     CONTINUEPRTLSLRRRR
PRTRORTXT
    LEA     TXTROR,A1         	* Prints ASR
    MOVE.B  #14,   D0
    TRAP    #15
    BRA CONTINUEPRTROLTEXT
PRTLSLR
    MOVE.B  #3,BitsToRead       * Reading next 3 bits
    JSR     RDBITS              * Reading DEST REGISTER
    MOVE.B  D4,RRRD             * Storing in RRRD
    CMP.B   #%0,IRBit           * Checking if i/r bit is 0
    BEQ     PRTLSLRCCC          * If 0 then shift CCC 1-8 bits
    BNE     PRTLSLRRRR          * Else then shifts RRR

PRTLSLRCCC
    MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)    
    
    CMP.B   #%00, SwitchBits    * Comparing to check if 00
	BEQ     PRTASLTEXT          * Jump to CHKASLR
    CMP.B   #%11, SwitchBits    * Comparing to check if 11
    BEQ     PRTROLTEXT          * Jump to CHKROLR
    
    CMP.B   #%1,Xbit
    BNE     PRTLSRTEXT          * Checks X bit again to see if to print LSL or LSR
    
    LEA     TXTLSL,A1         	* Prints LSL
    MOVE.B  #14,   D0
    TRAP    #15
CONTINUEPRTLSLRCCC
    JSR     PRTSS               * Prints size (SS)
    MOVE.B  #3,D7               * 3 spaces to be printed
    JSR     PRTSPACES           * Jump to prtspaces to print the space 3 times
    
    MOVE.B  RRRS,DDD            * Moving RRRS to DDD 
    JSR     FRMTDDD             * Function to change it so that if the value is 000 then it changes it to 8 for printing
    
    CLR.L   D6                  
    MOVE.B  DDD,D6              * Moves the data number into D6 to be printed
    JSR     PRTHASHDS           * Prints hash and dollar sign
    JSR     PRTBYTE             * Prints the data number from D6

    JSR PRTCOMMA
    CLR.L D6
    MOVE.B  RRRD, D6            * Prints the destination data register
    JSR PRTEA0
    MOVE.B  #0, XBit
    MOVE.B  #0, MMMD
    MOVE.B  #0, MMMS
    MOVE.B  #0, SwitchBits
    RTS

PRTLSRTEXT
    LEA     TXTLSR,A1         	* Prints LSR
    MOVE.B  #14,   D0
    TRAP    #15
    CMP.B   #%0,IRBit
    BNE     CONTINUEPRTLSLRRRR
    BRA     CONTINUEPRTLSLRCCC
PRTLSLRRRR
    MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)
    
    CMP.B   #%00, SwitchBits    * Comparing to check if 00
	BEQ     PRTASLTEXT          * Jump to CHKASLR
    CMP.B   #%11, SwitchBits    * Comparing to check if 11
    BEQ     PRTROLTEXT          * Jump to CHKROLR
    CMP.B   #%10, SwitchBits    * Comparing to check if 10
    BEQ     PRTDATA             * 10 is invalid so print data

    CMP.B   #%1,Xbit
    BNE     PRTLSRTEXT          * Checks X bit again to see if to print LSL or LSR
    LEA     TXTLSL,A1         	* Prints LSL
    MOVE.B  #14,   D0
    TRAP    #15
CONTINUEPRTLSLRRRR
    JSR     PRTSS               * Prints size (SS)
    MOVE.B  #3,D7               * 3 spaces to be printed
    JSR     PRTSPACES           * Jump to prtspaces to print the space 3 times

    CLR.L D6
    MOVE.B  RRRS, D6            * Prints the source data register
    JSR PRTEA0

    JSR PRTCOMMA
    CLR.L D6
    MOVE.B  RRRD, D6            * Prints the destination data register
    JSR PRTEA0
    MOVE.B  #0, XBit
    MOVE.B  #0, MMMD
    MOVE.B  #0, MMMS
    MOVE.B  #0, SwitchBits
    RTS
*--------------------------MOVE----------------------------*
PRTMOVE
	MOVE.L  InsAddress,D6       * Moves Instruction to D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)    
	
	LEA     TXTMOVE,A1         	* Prints MOVE
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     PRTMSS              * Prints MOVE Size
    MOVE.B  #2,D7               * Print 1 space (MOVE.S--)
    JSR     PRTSPACES 

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA
	
	CLR.L   D6                  
    MOVE.B  RRRS,D6             * Set 'n' = RRRS
    JSR     PRTMSRC				* Print Source (MOVE/MOVEA)
	
	JSR     PRTCOMMA
	
	CLR.L   D6                  
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTMDST				* Print Destination (MOVE/MOVEA)
	RTS
*--------------------------MOVEA---------------------------*
PRTMOVEA
	MOVE.L  InsAddress,D6       * Moves Instruction to D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)    
	
	LEA     TXTMOVEA,A1         * Prints MOVEA
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     PRTMSS              * Prints MOVEA Size
    MOVE.B  #1,D7               * Print 1 space (MOVEA.S-)
    JSR     PRTSPACES 
	
    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

	CLR.L   D6                  
    MOVE.B  RRRS,D6             * Set 'n' = RRRS
    JSR     PRTMSRC				* Print Source (MOVE/MOVEA)
	
	JSR     PRTCOMMA
	
	CLR.L   D6
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTEA1              * Print 'An'
	RTS
*--------------------------MOVEQ---------------------------*
PRTMOVEQ
	MOVE.L  InsAddress,D6       * Moves Instruction to D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)    
	
	LEA     TXTMOVEQ,A1         * Prints MOVEQ
    MOVE.B  #14,D0
    TRAP    #15
     
    MOVE.B  #3,D7               * Print 3 spaces (MOVEQ---)
    JSR     PRTSPACES 

    CLR.L   D6
    MOVE.B  DDDDDDDD,D6
    JSR     PRTHASH
    JSR     CHKTXTNEG           * Checks if value is negative
    JSR     PRTDS   
    JSR     PRTBYTE             * Print Byte Data
    
	JSR     PRTCOMMA
	
	CLR.L   D6
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTEA0              * Print 'Dn'
    
	RTS
*---------------------------NOT----------------------------*   
PRTNOT
    MOVE.L  InsAddress,D6       * 
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)    

    LEA     TXTNOT,A1           * Prints NOT
    MOVE.B  #14,D0
    TRAP    #15
	
    JSR     PRTSS               * Print SS
    MOVE.B  #3,D7               * Print 5 spaces (NOT.S---)
    JSR     PRTSPACES

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CLR.L   D6                  
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTDST              * Print Destination
    RTS
*---------------------------LEA----------------------------*   
PRTLEA
    MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)    

    LEA     TXTLEA,A1           * Prints LEA
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #5,D7               * Print 5 spaces (LEA-----)
    JSR     PRTSPACES 

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CLR.L   D6                  
    MOVE.B  RRRS,D6             * Set 'n' = RRRS
    JSR     PRTSRC				* Print Source

    JSR     PRTCOMMA
	
	CLR.L   D6
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTEA1              * Print 'An'
    RTS
*---------------------------JSR----------------------------*  
PRTJSR
    MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    LEA     TXTJSR,A1           * Prints JSR
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #5,D7               * Print 5 spaces (JSR-----)
    JSR     PRTSPACES 

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CLR.L   D6                  
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTDST              * Print Destination
    RTS
*---------------------------NOP----------------------------*  
PRTNOP
    MOVE.L  InsAddress,D6
    JSR     PRTLONG
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    LEA     TXTNOP,A1
    MOVE.B  #14,D0
    TRAP    #15

    RTS
*---------------------------RTS----------------------------*  
PRTRTS
    MOVE.L  InsAddress,D6
    JSR     PRTLONG
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)
    
    LEA     TXTRTS,A1
    MOVE.B  #14,D0
    TRAP    #15

    RTS
*-------------------------MOVEM---------------------------*  
PRTMOVEM
    MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    LEA     TXTMOVEM,A1         * Prints MOVEM
    MOVE.B  #14,D0
    TRAP    #15

    JSR     PRTSBIT             * Prints Size (MOVEM.W or MOVEM.L)                       
    MOVE.B  #1,D7               * Print 1 space (MOVEM.S-)
    JSR     PRTSPACES

    CLR.L   D4
    MOVE.W  (A0)+,D4            * Move list mask into D4 

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CMP.B   #%0,XBit            * If X bit is 0 Register -> Memory
    BEQ     PRTLTOM             * 
    BNE     PRTMTOL             * Else, Memory -> register
PRTLTOM
    JSR     PRTMLIST
    JSR     PRTCOMMA

    CLR.L   D6
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTDST              * Print Destination EA
    MOVE.B  #0,ListActive
    MOVE.B  #0,XBit
    RTS
PRTMTOL
    CLR.L   D6
    MOVE.B  RRRS,D6             * Set 'n' = RRRS
    JSR     PRTSRC              * Print Source EA

    JSR     PRTCOMMA
    JSR     PRTMLIST
    MOVE.B  #0,ListActive
    MOVE.B  #0,XBit
    RTS
PRTMLIST
    MOVE.B  #16,D7              * Set Loop counter for list printing
    CMP.B   #$4,DstMode         * Check for predecrement as mode
    BEQ     PRTMLIST2           * Print reverse list (D0 -> A7) if predecrement
    BNE     PRTMLIST1           * Else print regular list (A7 -> D0)
PRTMLIST1                       * When mask Address - Register
    CMP.B   #$0,D7              * Checks to see if loop counter D7 == 0
    BEQ     RETURN                 * If at end of loop RTS
    SUBQ.B  #1,D7               * Else, Decrement loop counter
    BTST.L  D7,D4               * Check bit D7 (starts at 15) of D4 (current instruction)
    BEQ     PRTMLIST1           * Checks if bit is zero, if true loop back
    JSR     PRTL1EA             * JSR to PRTL1EA when bit is 1 (print the register/address)
    BRA     PRTMLIST1
PRTL1EA                         
    CMP.B   #%1,ListActive
    BNE     CPRTL1EA
    JSR     PRTSLASH
CPRTL1EA
    MOVE.B  #%1,ListActive
    MOVE.B  D7,D6               * Pass in D7 into PRTEA1 through D6 
    CMP.B   #$7,D6              * If <= 7 (to get 'n' of 'Dn') 
    BLE     APRTL1EA            * Print 'Dn'
    SUBQ.B  #$8,D6              * Else, subtract 8 (to get 'n' of 'An')
    JSR     PRTEA1              * Print 'An'
    RTS
APRTL1EA
    JSR     PRTEA0
    RTS
PRTMLIST2                       * When mask Register - Address
    CMP.B   #$0,D7              * Checks to see if loop counter D7 == 0
    BEQ     RETURN              * If at end of loop Return
    SUBQ.B  #1,D7               * Else, Decrement loop counter
    BTST.L  D7,D4               * Check bit D7 (starts at 15) of D4 (current instruction)
    BEQ     PRTMLIST2           * Checks if bit is zero, if true loop back
    JSR     PRTL2EA             * JSR to PRTL1EA when bit is 1 (print the register/address)
    BRA     PRTMLIST2
PRTL2EA
    CMP.B   #%1,ListActive
    BNE     CPRTL2EA
    JSR     PRTSLASH
CPRTL2EA
    MOVE.B  #%1,ListActive                         
    MOVE.B  D7,D6               * D6 = [00001111]
    CMP.B   #$7,D6              * If <= 7 (to get 'n' of 'An')
    BLE     APRTL2EA
    SUBQ.B  #$8,D6              * D6 = [1111 1001]
    NOT.B   D6
    SUBI.B  #$F8,D6
    JSR     PRTEA0
    RTS
APRTL2EA
    NOT.B   D6
    SUBI.B  #$F8,D6
    JSR     PRTEA1
    RTS
*--------------------------ADDQ---------------------------*  
PRTADDQ
	MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    LEA     TXTADDQ,A1          * Prints ADDQ
    MOVE.B  #14,D0
    TRAP    #15
	
	JSR     PRTSS              	* Prints Size
    MOVE.B  #2,D7               * Print 2 spaces (ADDQ.S--)
    JSR     PRTSPACES

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA
	
	JSR     PRTHASHDS           * Prints "#$"
	CLR.L   D6
	MOVE.B  DDD,D6
	JSR		PRTBYTE				* Print DDD

	JSR		PRTCOMMA

    CLR.L   D6                  
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTDST              * Print Destination
    RTS
*---------------------BGT BLE BEQ BRA---------------------*
PRTBRA
	MOVE.L  InsAddress,D6
    JSR     PRTLONG             * Print address
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    JSR     PRTBranchType       * Prints BGT, BLE, BEQ, or BRA

    MOVE.B  #5,D7               * Print 5 spaces (Bxx-----)
    JSR     PRTSPACES

	JSR     PRTDS               * Prints "$"
	CLR.L   D6
	MOVE.L  D4,D6
	JSR		PRTLONG				* Print Destination Address of Branch
    RTS
PRTBranchType
    CMP.B   #%1110,BranchType   * Compares to check if BranchType is equal to 1110
    BEQ     PRTTXTBGT           * If true, Goes to PRTTXTBGT
    CMP.B   #%1111,BranchType   * Compares to check if BranchType is equal to 1111
    BEQ     PRTTXTBLE           * If true, Goes to PRTTXTBLE
    CMP.B   #%0111,BranchType   * Compares to check if BranchType is equal to 0111
    BEQ     PRTTXTBEQ           * If true, Goes to PRTTXTBEQ
    CMP.B   #%0000,BranchType   * Compares to check if BranchType is equal to 1000
    BEQ     PRTTXTBRA           * If true, Goes to PRTTXTBRA
    RTS
PRTTXTBGT
    LEA     TXTBGT,A1           * Prints BGT
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTTXTBLE
    LEA     TXTBLE,A1           * Prints BLE
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTTXTBEQ
    LEA     TXTBEQ,A1           * Prints BEQ
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTTXTBRA
    LEA     TXTBRA,A1           * Prints BRA
    MOVE.B  #14,D0
    TRAP    #15
    RTS
*---------------------OR SUB AND ADD----------------------* 
PRTOSAA
    MOVE.L  InsAddress,D6
    JSR     PRTLONG     
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    JSR     PRTOSAAType         * Prints OR, SUB, AND, or ADD. Prints size and spaces

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CMP.B   #%0,XBit            * If X bit is 0 (EA -> Register)
    BEQ     PRTETOR             * 
    BNE     PRTRTOE             * Else, (Register -> EA)
PRTETOR
    MOVE.B  MMMT,MMMS
    MOVE.B  RRRT,RRRS
    CLR.L   D6
    MOVE.B  RRRS,D6             * Set 'n' = RRRD
    MOVE.B  TempMode,SrcMode
    JSR     PRTSRC              * Print Source EA

    JSR     PRTCOMMA

    CLR.L   D6
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTDST              * Print Destination EA
    MOVE.B  #0,ListActive
    MOVE.B  #0,XBit
    RTS
PRTRTOE
    CLR.L   D6
    MOVE.B  RRRS,D6             * Set 'n' = RRRS
    JSR     PRTSRC              * Print Source EA

    JSR     PRTCOMMA

    MOVE.B  MMMT,MMMD
    MOVE.B  RRRT,RRRD
    CLR.L   D6
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    MOVE.B  TempMode,DstMode
    JSR     PRTDST              * Print Destination EA
    MOVE.B  #0,ListActive
    MOVE.B  #0,XBit
    RTS
PRTOSAAType
    CMP.B   #%1000,SwitchBits   * Compares to check if BranchType is equal to 1000
    BEQ     PRTTXTOR            * If true, Goes to PRTTXTOR
    CMP.B   #%1001,SwitchBits   * Compares to check if BranchType is equal to 1001
    BEQ     PRTTXTSUB           * If true, Goes to PRTTXTSUB
    CMP.B   #%1100,SwitchBits   * Compares to check if BranchType is equal to 1100
    BEQ     PRTTXTAND           * If true, Goes to PRTTXTAND
    CMP.B   #%1101,SwitchBits   * Compares to check if BranchType is equal to 1101
    BEQ     PRTTXTADD           * If true, Goes to PRTTXTADD
    RTS
PRTTXTOR
    LEA     TXTOR,A1            * Prints OR
    MOVE.B  #14,D0
    TRAP    #15

    JSR     PRTSS               * Print SS
    MOVE.B  #4,D7               * Print 4 spaces (OR.S----)
    JSR     PRTSPACES 

    RTS
PRTTXTSUB
    LEA     TXTSUB,A1           * Prints SUB
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     PRTSS               * Print SS
    MOVE.B  #3,D7               * Print 3 spaces (SUB.S---)
    JSR     PRTSPACES 

    RTS
PRTTXTAND
    LEA     TXTAND,A1           * Prints AND
    MOVE.B  #14,D0
    TRAP    #15

    JSR     PRTSS               * Print SS
    MOVE.B  #3,D7               * Print 3 spaces (AND.S---)
    JSR     PRTSPACES 

    RTS
PRTTXTADD
    LEA     TXTADD,A1           * Prints ADD
    MOVE.B  #14,D0
    TRAP    #15

    JSR     PRTSS               * Print SS
    MOVE.B  #3,D7               * Print 3 spaces (ADD.S---)
    JSR     PRTSPACES 

    RTS
*--------------------------ADDA---------------------------*
PRTADDA
    MOVE.L  InsAddress,D6
    JSR     PRTLONG     
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    LEA     TXTADDA,A1          * Prints "ADDA"
    MOVE.B  #14,D0
    TRAP    #15

    JSR     PRTSS               * Print SS
    MOVE.B  #2,D7               * Print 2 spaces (ADDA.S--)
    JSR     PRTSPACES

    CMP.B   #1,IsInvalid
    BEQ     PRTINVEA

    CLR.L   D6                  
    MOVE.B  RRRS,D6             * Set 'n' = RRRS
    JSR     PRTSRC
    
    JSR     PRTCOMMA

    CLR.L   D6                  
    MOVE.B  RRRD,D6             * Set 'n' = RRRD
    JSR     PRTDST
    RTS
*--------------------------DATA---------------------------*  
PRTDATA
    MOVE.L  InsAddress,D6
    JSR     PRTLONG     
    JSR     PRTFULLTAB          * Prints a full tab (8 spaces)

    LEA     TXTDATA,A1          * Prints "DATA"
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.B  #4,D7               * Print 4 spaces (DATA----)
    JSR     PRTSPACES

    JSR     PRTHASHDS           * Prints "#$"
    
    CLR.L   D6
    MOVE.W  StoredData,D6       * Moves StoredData into D6 for formatted printing
    JSR     PRTWORD

    RTS
*--------------------Invalid Address----------------------*
* This function is called when an EA for a OP code is invalid
SETINVEA
    MOVE.B  #1,IsInvalid        * Moves 1 into IsInvalid
    CMP.B   #0,CmdIndex         * If CmdIndex is 0 then its a move
    BEQ     PRTMOVE

    CMP.B   #1,CmdIndex         * If its 1 then MOVEA
    BEQ     PRTMOVEA

    CMP.B   #2,CmdIndex         * If its 2 then NOT
    BEQ     PRTNOT

    CMP.B   #3,CmdIndex         * If its 3 then LEA
    BEQ     PRTLEA

    CMP.B   #4,CmdIndex         * If its 4 then JSR
    BEQ     PRTJSR

    CMP.B   #5,CmdIndex         * If its 5 then MOVEM
    BEQ     PRTMOVEM

    CMP.B   #6,CmdIndex         * If its 6 then ADDQ
    BEQ     PRTADDQ

    CMP.B   #7,CmdIndex         * If its 7 then OR, SUB, AND, and ADD
    BEQ     PRTOSAA

    CMP.B   #8,CmdIndex         * If its 8 then ADDA
    BEQ     PRTADDA

    CMP.B   #9,CmdIndex         * If its 9 then LSL, LSR, ASL, ASR, ROL, and ROR
    BEQ     PRTLSLREA

PRTINVEA
    LEA     TXTINVEA,A1         * Prints "Invalid EA" TEXT
    MOVE.B  #14,D0
    TRAP    #15
    RTS
*==============Print Effective Address Format==============*
PRTEA0
	CLR.L	D1
    MOVE.B  #$44,D1             * Print "D"
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.B  D6,D1               * Print register number
    MOVE.B  #16,D2              * This loads base into D2 (base 16 hex)
    MOVE.B  #15,D0 
    TRAP    #15

    RTS
PRTEA1
	CLR.L	D1
    MOVE.B  #$41,D1             * Print "A"
    MOVE.B  #6,D0
    TRAP    #15

    MOVE.B  D6,D1               * Print register number
    MOVE.B  #16,D2              * This loads base into D2 (base 16 hex)
    MOVE.B  #15,D0 
    TRAP    #15
    
    RTS
PRTEA2
	CLR.L	D1
    MOVE.B  #$28,D1             * Print "("
    MOVE.B  #6,D0
    TRAP    #15

    JSR     PRTEA1              * Prints 'An'

    MOVE.B  #$29,D1             * Print ")"
    MOVE.B  #6,D0
    TRAP    #15
    
    RTS
PRTEA3
    JSR     PRTEA2              * Prints '(An)'
    MOVE.B  #$2B,D1             * Print '+'
    MOVE.B  #6,D0               
    TRAP    #15
    
    RTS
PRTEA4
    MOVE.B  #$2D,D1             * Print '-'
    MOVE.B  #6,D0
    TRAP    #15
    JSR     PRTEA2              * Prints '(An)'
    
    RTS
PRTEA7               			* Prints (XXX).W
    JSR     PRTDS               * Prints "$"
    MOVE.W  (A0)+,D6            * Copy NOT.W address into D6 and increments memory pointer
    JSR     PRTWORD
	RTS
PRTEA8               			* Prints (XXX).L
    JSR     PRTDS               * Prints "$"
    MOVE.L  (A0)+,D6            * Copy NOT.L address into D6 and increments memory pointer
    JSR     PRTLONG
	RTS
PRTEA11                        	* Prints Data based on size bits (EXCEPT MOVE and MOVEA)
    CMP.B   #%00,SS
    BEQ     PRTEADB
    CMP.B   #%01,SS
    BEQ     PRTEADW
    CMP.B   #%10,SS
    BEQ     PRTEADL
PRTEAM11                        * Prints Data based on size bits (MOVE and MOVEA ONLY)
    CMP.B   #%01,SS
    BEQ     PRTEADB
    CMP.B   #%11,SS
    BEQ     PRTEADW
    CMP.B   #%10,SS
    BEQ     PRTEADL
PRTEADB
    JSR     PRTHASHDS           * Prints "#$"
    CLR.L   D6
    MOVE.W  (A0)+,D6            * Copy Byte Data at Address in A0 into D6 and increments memory pointer
    JSR     PRTBYTE
    RTS
PRTEADW
    JSR     PRTHASHDS           * Prints "#$"
    CLR.L   D6
    MOVE.W  (A0)+,D6            * Copy Word Data at Address in A0 into D6 and increments memory pointer
    JSR     PRTWORD
    RTS
PRTEADL
    JSR     PRTHASHDS           * Prints "#$"
    CLR.L   D6
    MOVE.L  (A0)+,D6            * Copy Long Data at Address in A0 into D6 and increments memory pointer
    JSR     PRTLONG
    RTS
CHKTXTNEG
    CMP.B   #128,D6             * Checks if value is = 128 (meaning that its -128)
    BEQ     PRTTXTNEG
       
    CMP.B   #128,D6             * Checks if value is > 128 (meaning that its negative)
    BHI     NOTTXTNEG
    RTS        
NOTTXTNEG
    NOT.B   D6
    ADDQ.B  #1,D6
PRTTXTNEG  
    LEA     TXTNEG,A1           * Prints '-'
    MOVE.B  #14,D0              
    TRAP    #15
    RTS
*====================Indirect Commands=====================* 
RETURN
    RTS
PRTCOMMA
    LEA     TXTCOMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTDS
    LEA     TXTDS,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTFULLTAB
    LEA     TXTFULLTAB,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTHASH
    LEA     TXTHASH,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTHASHDS
    LEA     TXTHASH,A1
    MOVE.B  #14,D0
    TRAP    #15

    LEA     TXTDS,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTSLASH
    LEA     TXTSLASH,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
RDWORD
    CLR     D4
    MOVE.W  (A0)+,D4
    RTS
RDLONG
    CLR     D4
    MOVE.L  (A0)+,D4
    RTS
FRMTDDD
    CMP.B   #0,DDD
    BNE     RETURN
	MOVE.B  #8,DDD
	RTS
CLRMRS
    MOVE.B  #0,MMMS
	MOVE.B  #0,RRRS
	MOVE.B  #0,MMMD
	MOVE.B  #0,RRRD
    MOVE.B  #0,MMMT
	MOVE.B  #0,RRRT
    RTS
*------------------------.B-.W-.L-------------------------*
PRTSBIT							* W-0, L-1
    CMP.B   #%0,SBit
    BEQ     PRTSS1

    CMP.B   #%1,SBit
    BEQ     PRTSS2
    RTS 
PRTMSS							* B-01, W-11, L-10
    CMP.B   #%01,SS
    BEQ     PRTSS0

    CMP.B   #%11,SS
    BEQ     PRTSS1

    CMP.B   #%10,SS
    BEQ     PRTSS2
    RTS                         
PRTSS							* B-00, W-01, L-10
    CMP.B   #%00,SS
    BEQ     PRTSS0

    CMP.B   #%01,SS
    BEQ     PRTSS1

    CMP.B   #%10,SS
    BEQ     PRTSS2
    RTS                         
PRTSS0
    LEA     TXTBYTE,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTSS1
    LEA     TXTWORD,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
PRTSS2
    LEA     TXTLONG,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
*--------------------Select Source EA---------------------*
PRTMSRC							* Linked to PRTSRC
	CMP.B  	#$B,SrcMode
	BEQ		PRTEAM11
PRTSRC
	CMP.B  	#$0,SrcMode
	BEQ		PRTEA0
	
	CMP.B  	#$1,SrcMode
	BEQ		PRTEA1
	
	CMP.B  	#$2,SrcMode
	BEQ		PRTEA2
	
	CMP.B  	#$3,SrcMode
	BEQ		PRTEA3
	
	CMP.B  	#$4,SrcMode
	BEQ		PRTEA4
	
	CMP.B  	#$7,SrcMode
	BEQ		PRTEA7
	
	CMP.B  	#$8,SrcMode
	BEQ		PRTEA8
	
	CMP.B  	#$B,SrcMode
	BEQ		PRTEA11
	RTS							* In case of failure
*-----------------Select Destination EA-------------------*
PRTMDST							* Linked to PRTDST
	CMP.B  	#$B,DstMode
	BEQ		PRTEAM11
PRTDST							
	CMP.B  	#$0,DstMode
	BEQ		PRTEA0
	
	CMP.B  	#$1,DstMode
	BEQ		PRTEA1
	
	CMP.B  	#$2,DstMode
	BEQ		PRTEA2
	
	CMP.B  	#$3,DstMode
	BEQ		PRTEA3
	
	CMP.B  	#$4,DstMode
	BEQ		PRTEA4
	
	CMP.B  	#$7,DstMode
	BEQ		PRTEA7
	
	CMP.B  	#$8,DstMode
	BEQ		PRTEA8
	
	CMP.B  	#$B,DstMode
	BEQ		PRTEA11
	RTS							* In case of failure
*=================Variables and Constants==================*   
* User Messages *
FormatMessage	    DC.B 'Addresses must be in (########) format w/o parentheses',CR,LF
                    DC.B 'where each # is a single hex digit (e.g. C0685730).',CR,LF
                    DC.B 'Maximum 8 hexadecimal digits allowed for an address.',CR,LF,LF,0   *Messages*
StartingMessage	    DC.B 'ENTER STARTING ADDRESS:',0
EndingMessage	    DC.B 'ENTER ENDING ADDRESS:',0
InvalidInputMsg     DC.B 'Please enter a valid address. (Must be an even number)',CR,LF,0
InvalidAddress      DC.B 'Ending address cant be less than Starting address. Please try again.',CR,LF,0
NextPageMessage     DC.B CR,LF,'Press the "Enter" key to view next page',CR,LF,0
FinalMessage        DC.B CR,LF,'End of Program Reached',0
EndingPrompt        DC.B CR,LF,'Disassemble another program? (Y/N): ',0
TXTINVEA            DC.B 'Invalid EA',0

* Opcodes *
TXTMOVE             DC.B 'MOVE',0
TXTMOVEA            DC.B 'MOVEA',0
TXTNOT              DC.B 'NOT',0
TXTLEA              DC.B 'LEA',0
TXTNOP              DC.B 'NOP',0
TXTRTS              DC.B 'RTS',0
TXTJSR              DC.B 'JSR',0
TXTMOVEM            DC.B 'MOVEM',0
TXTADDQ             DC.B 'ADDQ',0
TXTBGT              DC.B 'BGT',0
TXTBLE              DC.B 'BLE',0
TXTBEQ              DC.B 'BEQ',0
TXTBRA              DC.B 'BRA',0
TXTMOVEQ            DC.B 'MOVEQ',0
TXTOR               DC.B 'OR',0
TXTSUB              DC.B 'SUB',0
TXTAND              DC.B 'AND',0
TXTADD              DC.B 'ADD',0
TXTADDA             DC.B 'ADDA',0
TXTLSL              DC.B 'LSL',0
TXTLSR              DC.B 'LSR',0
TXTASL              DC.B 'ASL',0
TXTASR              DC.B 'ASR',0
TXTROL              DC.B 'ROL',0
TXTROR              DC.B 'ROR',0
TXTDATA             DC.B 'DATA',0

TXTBYTE             DC.B '.B',0
TXTWORD             DC.B '.W',0
TXTLONG             DC.B '.L',0
TXTDS               DC.B '$',0
TXTPCNT             DC.B '%',0
TXTHASH             DC.B '#',0
TXTCOMMA            DC.B ',',0
TXTNEG              DC.B '-',0
TXTSLASH            DC.B '/',0
TXTFULLTAB          DC.B '        ',0

StartingAddress     DC.L    0
InsAddress          DC.L    0
SrcAddress          DC.L    0
DstAddress          DC.L    0
EndingAddress       DC.L    0
StoredData          DC.W    0
BitsToRead          DC.B    0
MMMS                DC.B    0
MMMD                DC.B    0
RRRS                DC.B    0
RRRD                DC.B    0
DDD					DC.B    0
DDDDDDDD            DC.B    0
SS                  DC.B    0
SwitchBits          DC.B    0
SrcMode             DC.B    0
DstMode             DC.B    0
TempMode            DC.B    0
BranchType          DC.B    0 
XBit                DC.B    0
SBit                DC.B    0
MultipleAnd         DC.B    0
IRBit               DC.B    0
RRRT                DC.B    0
MMMT                DC.B    0
ListActive          DC.B    0
KeyboardInput       DC.B    0
CmdIndex            DC.B    0
IsInvalid           DC.B    0

CR                  EQU     $0D              * ASCII code for Carriage Return
LF                  EQU     $0A              * ASCII code for Line Feed
    
                    END    START        



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
