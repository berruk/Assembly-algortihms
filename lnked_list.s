;*******************************************************************************
;@file				Main.s
;@project		    Microprocessor Systems Term Project
;@date
;
;@PROJECT GROUP
;@groupno			43
;@member1			Resul Levent Kuru
;@member2			Berru Karakas
;@member3			Huseyin Berkay Kuran
;@member4			Ahmet Alper Yilmaz
;@member5			Ilya Mustafa Nuhi
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20							;Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4				;Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2				;Allocable data area
													;Each allocation table has 32 Cell
													;Each Cell Has 2 word (Value + Address)
													;Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32					;Allocable data area
													;Each allocation table has 32 Cell
													;Each Cell Has 1 word (Value)
													;Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3				;Log Array Size
													;Each log contains 3 word
													;16 bit for index
													;8 bit for error_code
													;8 bit for operation
													;32 bit for data
													;32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4							;Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4							;Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4							;Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4							;Allocate #4 byte area to store the index of the error log array.
PROGRAM_STATUS  SPACE    4							;Allocate #4 byte to store program status.
													;0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							
STCTRL        	EQU 	0xE000E010					;Control Register
STRELOAD        EQU    	0xE000E014					;Reload Register
STCURRENT       EQU 	0xE000E018					;Current Register 24 Bit
LOAD_VAL        EQU 	0x0000D27F					;Value to check for timer interrupt

;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE					;Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE				;Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE					;Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE				;Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT 	__main
				BL		Clear_Alloc					;Call Clear Allocation Function.
				BL 		Clear_ErrorLogs				;Call Clear ErrorLogs Function.
				BL		Init_GlobVars				;Call Initiate Global Variable Function.
				BL		SysTick_Init				;Call Initialize System Tick Timer Function.
				LDR 	R0, =PROGRAM_STATUS			;Load Program Status Variable Addresses.
LOOP			LDR 	R1, [R0]					;Load Program Status Variable.
				CMP		R1, #2						;Check If Program finished.
				BNE 	LOOP						;Go to loop If program do not finish.
STOP			B		STOP						;Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
				EXPORT	SysTick_Handler
				PUSH 	{LR}
				LDR  	R1, =TICK_COUNT    			;Loading address of GlobVar TICK_COUNT into R1
				LDR  	R0,[R1]						;Loading content of TICK_COUNT into R0
				MOVS	R5,R0						;Moving the content of TICK_COUNT to R5
				ADDS 	R5, R5, #1					;Incrementing TICK_COUNT
				STR	 	R5,[R1]						;Storing new TICK_COUNT value to address of TICK_COUNT
				LSLS 	R0,#2						;Multiplying it with 4 for getting the exact address in IN_DATA_FLAG and IN_DATA
				LDR  	R2, =IN_DATA_FLAG  			;Loading address of GlobVar IN_DATA_FLAG into R2
				LDR  	R2, [R2, R0]				;R2 = Operation		
				LDR		R3, =IN_DATA				;Loading address of GlobVar IN_DATA into R3
				LDR  	R3, [R3, R0]				;R3 = Data
				CMP	 	R2, #0						;Comparison
				BEQ  	LinkRemove					;If R = 0 go to Remove function				
				CMP  	R2, #1						;Comparison
				BEQ  	LinkInsert					;If R = 1 go to Insert function
				CMP  	R2, #2						;Comparison
				BEQ  	LinkLL2A					;If R = 2 go to LinkedList2Arr function
				CMP  	R2, #2						;Comparing operation value with 2
				BGT		noop						;If operation code is greater than 2, error code is 6		
continue		LSRS	R0,#2						;Multiplying it with 4 for WriteErrorLog purposes
				BL		GetNow						;Link to GetNow function for getting time value
				BL		WriteErrorLog				;Link to WriteErrorLog function for writing errors
				LDR		R5,=PROGRAM_STATUS			;Loading address of PROGRAM_STATUS
				LDR		R5,[R5]						;Loading content at the address of PROGRAM_STATUS
				CMP		R5,#2						;Comparison
				BEQ		stp							;If PROGRAM_STATUS==2, stop the timer
				POP		{PC}						;Returning the link that is at the top of the stack
LinkRemove		BL 		Remove						;Link to Remove function
				B		continue
LinkInsert		BL 		Insert						;Link to Insert function
				B		continue
LinkLL2A		BL 		LinkedList2Arr				;Link to LinkedList2Arr function
				LDR		R5,=PROGRAM_STATUS			;Loading address of PROGRAM_STATUS
				MOVS	R6,#2						;PROGRAM_STATUS = 2 ( All data operations finished )
				STR		R6,[R5]						;Storing the PROGRAM_STATUS value
				B		continue
noop			MOVS	R1,#6						;Write 6 to error code ( Operation is not found ) 
				B		continue
stp				BL		SysTick_Stop				;Link to SysTick_Stop function
				POP		{PC}								
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------															
				LDR    	R1,=STCTRL					;Loading address of GlobVar STCTRL into R1
                LDR 	R2,[R1]						;Loading content of STCTRL into R2
                MOVS 	R2,#0						;Clearing R2
                STR 	R2,[R1]						;Storing the cleared value to STCTRL
                LDR 	R2,=LOAD_VAL				;Loading address of GlobVar STCTRL into R1
                STR 	R2,[R1,#4]					;Storing the cleared value to STRELOAD
                STR 	R2,[R1,#8]					;Storing the cleared value to STCURRENT
                MOVS 	R4,#0x3						;Changing TICKINT and ENABLE flags for starting the timer
                STR    	R4,[R1]						;Storing the correspondant value to STCURRENT
				LDR		R5,=PROGRAM_STATUS			;Loading address of PROGRAM_STATUS
				MOVS 	R6,#1						;PROGRAM_STATUS = 1 ( Timer started )
				STR		R6,[R5]						;Storing the PROGRAM_STATUS value
                BX 		LR	
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR		R1,=STCTRL					;Loading address of GlobVar STCTRL into R1
				MOVS	R0,#0						;Changing TICKINT and ENABLE flags for stopping the timer
				STR		R0,[R1]						;Storing the changed value to STCTRL
				BX		LR
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				LDR  	R4,=AT_MEM					;Loading address of AT_MEM into R4
				MOVS 	R2, #0						;0 value for clearing memory
				MOVS 	R3, #0						;Index( Offset )
				LDR		R5,	=AT_SIZE				;Loading value of AT_SIZE into R5
clearloop    	CMP 	R3, R5						;Comparing
				BGE 	back						;If index is greater than or equal to allocation table size, break the loop
				STR 	R2,[R4,R3]					;Storing 0 value in the given index of allocation table
				ADDS 	R3,R3,#4					;Index = Index + 4 ( Since we are storing 4 byte words )
				B    	clearloop					;Loop
back        	BX 		LR
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				LDR  	R4,=LOG_MEM					;Loading address of LOG_MEM into R4
				MOVS 	R2, #0						;0 value for clearing memory
				MOVS 	R3, #0						;Index( Offset )
				LDR		R5,	=LOG_ARRAY_SIZE			;Loading value of LOG_ARRAY_SIZE into R5
clearloop2  	CMP 	R3, R5						;Comparing;If index is greater than or equal to log array size
				BGE 	back2						;If index is greater than or equal to log array size, break the loop
				STR 	R2,[R4,R3]					;Storing 0 value in the given index of log memory
				ADDS 	R3,R3,#4					;Index = Index + 4 ( Since we are storing 4 byte words )
				B    	clearloop2					;Loop
back2       	BX 		LR				
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------															
				LDR  	R1, =TICK_COUNT   			;Loading address of GlobVar TICK_COUNT into R1
				MOVS 	R0,#0						;0 value for clearing memory
				STR  	R0, [R1] 					;Storing the clear value to TICK_COUNT
				LDR  	R1, =FIRST_ELEMENT   		;Loading address of GlobVar FIRST_ELEMENT into R1
				MOVS 	R0,#0						;0 value for clearing memory
				STR  	R0, [R1]					;Storing the clear value to FIRST_ELEMENT
				LDR  	R1, =INDEX_INPUT_DS   		;Loading address of GlobVar INDEX_INPUT_DS into R1
				MOVS 	R0,#0						;0 value for clearing memory
				STR  	R0, [R1] 					;Storing the clear value to INDEX_INPUT_DS
				LDR  	R1, =INDEX_ERROR_LOG  		;Loading address of GlobVar INDEX_ERROR_LOG into R1
				MOVS 	R0,#0						;0 value for clearing memory
				STR  	R0, [R1]					;Storing the clear value to INDEX_ERROR_LOG
				LDR  	R1, =PROGRAM_STATUS   		;Loading address of GlobVar PROGRAM_STATUS into R1
				MOVS 	R0,#0						;0 value for clearing memory
				STR  	R0, [R1]					;Storing the clear value to PROGRAM_STATUS
				BX 		LR
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN Malloc Handler >>> ----------------------	
				LDR 	R1,=AT_MEM					;Loading address of AT_MEM into R1
				LDR		R2,=DATA_MEM				;Loading address of DATA_MEM into R2
				MOVS	R3,#0						;Moving index value into R3
loop			LDR		R5,	=AT_SIZE				;Loading value of AT_SIZE into R2
				CMP		R3,R5						;Comparing index with AT_SIZE 
				BEQ		nospace		
				LDR		R5,[R1,R3]					;Temp = AT_MEM at index
				MOVS 	R7, #1    					;R7 = 1	using this to check with bit is available by shifting it to left each iteration
				MOVS 	R0, #0    					;R0 = 0 (i) starting index for the inner loop
innloop 		MOVS 	R6,R5
				ANDS 	R6, R6, R7 					;R6 = R5 & R7, R6 is the rightmost bit of R5 first
				CMP 	R6, #0						;If R6 is 0, that means current bit we are checking is 0
				BEQ 	r_add						;So we can allocate that memory
				PUSH	{R6}
				LDR		R6, =0x80000000
				CMP 	R7, R6						;Compare R7 with 2^31 to not shift any further since every line is 32 bit
				POP		{R6}
				BEQ 	loopc 						;All bits are full, continue outer loop
				LSLS 	R7,#1    					;R7 *= 2
				ADDS 	R0, R0, #1 					;i++	( byte by byte )
				B 		innloop
loopc			ADDS 	R3,R3,#4					;Index++ ( 4 byte each iteration )
				B		loop
r_add			ADDS	R5,R5,R7					;Update the free space
				STR		R5,[R1,R3]					;Saving it to the allocation table
				LSLS	R3,#5						;Multiplying R3 with 32 because every index corresponds to 1 line which is 32 bits
				ADDS	R0,R0,R3					;Adding it to the inner index, this is now our index in data memory
				LSLS	R0,#3						;Every index corresponds to 8 byte(64 bit) of data, R0 is now our offset
				ADDS	R0,R0,R2					;Adding offset to data memory, R0 is the return value now
				MOVS	R1,#0						;No error	
				BX 		LR
nospace 		MOVS 	R1,#1						;Make error code 1 ( there is no allocable area )
				BX		LR
;//-------- <<< USER CODE END Malloc Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R6 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				;R6 is removed and its the address
				LDR		R1,=AT_MEM
				LDR		R2,=DATA_MEM
				SUBS 	R6,R6,R2					;Offset
				LSRS	R6,#3						;Index in the allocation table	in bits
				MOVS	R5,R6
				LSRS	R5,#5						;Outer index( Table line number ) = r5
				MOVS	R4,R5
				LSLS	R4,#5
				SUBS	R4,R6,R4					;Inner index( From 32 bits in the line ) = r4
				LDR		R6,[R1,R5]					;Load the line
				MOVS 	R3,#1						;Load 1
				LSLS	R3,R4						;Shifting 1  `r4` number of times
				SUBS	R6,R6,R3					;Changing the bit by substracting 
				STR		R6,[R1,R5]					;Storing the new allocation table line
				BX 		LR
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R3 <- The data to insert
;@return    R1 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------		
				MOVS 	R4,R3						;Temp = Data	R3 is the data from the IN_DATA
				PUSH	{R0,R2,R3,LR}				;Pushing these registers because they will get used in the handler 	
				BL		Malloc						;Allocate memory
				CMP		R1,#0
				BNE		mall_err
				STR		R4,[R0]						;Writing data to returned address
				LDR  	R1, =FIRST_ELEMENT  		;Getting first_element pointers addrss
				LDR		R6,	[R1]
				LDR  	R5, [R1] 					;Getting what's on the address
				CMP 	R5,#0						;Checking if it is equal to null
				BNE		compare						;If not
				STR  	R0, [R1] 					;Writing to first element pointer
				ADDS 	R0,R0,#4					;Getting to the address field
				MOVS	R7,#0
				STR		R7,[R0]						;Making the address field null
				MOVS	R1,#0						;Making error code 0 ( No error )
				POP		{R0,R2,R3,PC}				;Continue		
compare			LDR		R5,[R5]						;R5 -> first element's data
				B		J		
loop2			CMP		R5,R4						;Duplication error if equal
				BEQ		dup_err				
				MOVS	R7,R6
				ADDS	R6,R6,#4					;Moving to address place
				LDR		R5,[R6]						;Getting to the next node's address	
				CMP		R5,#0						;Checking if the address points to null
				BEQ		add_tail
				MOVS	R6,R5						;Loading next address
				LDR		R5,[R5]						;Getting next nodes data
J				CMP		R5,R4						;Checking if current>new			
				BLE		loop2
				B		decision		
add_tail		STR		R0,[R6]						;Writing new data's address, adding to tail
				ADDS 	R0,R0,#4					;Getting to the new node's address field
				MOVS	R7,#0
				STR		R7,[R0]						;Making the address field null
				MOVS	R1,#0						;Making error code 0 ( No error )
				POP		{R0,R2,R3,PC}
			
decision		LDR  	R1, =FIRST_ELEMENT  		;Getting FIRST_ELEMENT pointer's address
				LDR		R5,[R1]						;Getting the head
				CMP		R6,R5						;If not head
				BNE		between	
				MOVS	R3,R0						;New data's address
				ADDS	R3,R3,#4					;New data's address place
				STR		R5,[R3]						;Writing previous head
				STR		R0,[R1]						;Making new data the head
				MOVS	R1,#0						;Making error code 0 ( No error )
				POP		{R0,R2,R3,PC}
	
between			MOVS	R5,R0						;New data's address
				ADDS	R5,R5,#4					;New data's address place
				STR		R6,[R5]						;Writing next datas address to news address place
				ADDS	R7,R7,#4
				STR		R0,[R7]						;Writing new datas address
				MOVS	R1,#0						;Make error code 0 ( No error )
				POP		{R0,R2,R3,PC}

mall_err		POP		{R0,R2,R3,PC}

dup_err			MOVS	R1,#2						;Make error code 2 ( Same data is in the array )
				POP		{R0,R2,R3,PC}

;//-------- <<< USER CODE END Insert Function >>> ------------------------					
			ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R3 <- the data to delete
;@return    R1 <- Error Code
Remove		FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------
				PUSH	{R0,R2,R3,LR}
				MOVS	R4,#0		
				LDR  	R1, =FIRST_ELEMENT    		;Getting head pointer's address
				LDR  	R1,[R1]			  	  		;Getting head node's address
				CMP		R1,#0				  		;Comparing head with NULL
				BEQ		empty						;EMPTY LIST
loopr			LDR		R2,[R1]				 		;Getting head node's value
				CMP	 	R2,R3				 		;Comparing current value with value to be removed
				BEQ	 	r					  		;If yes, found
				ADDS 	R1,R1,#4			  		;Moving to current node's address place
				MOVS	R7,R1				  		;Keeping prev node's address places address
				LDR		R1,[R1]				  		;Getting the address value at the address place
				CMP		R1,#0				  		;If null, no such data
				BEQ		notfound					;DATA NOT FOUND
				B		loopr		
r				LDR  	R0, =FIRST_ELEMENT    		;Getting pointer to head nodes address	
				LDR		R0,[R0]				  		;Getting head node's address
				MOVS	R6,R1	
				CMP		R1,R0				  		;If to be removed's address is the same
				BEQ		fromhead
				ADDS	R1,R1,#4			 		;To be removed's pointer 
				LDR		R2,[R1]				  		;Getting value
				CMP		R2,#0				  		;If NULL
				BEQ		fromtail
				SUBS	R7,R7,#4			 		;Moving value's address
				STR		R1,[R7]				  		;Making previous node point to next node
				BL		Free
				MOVS	R1,#0						;Making error code 0 ( no error )
				POP		{R0,R2,R3,PC}
fromhead		ADDS	R1,R1,#4					;Moving to address place
				LDR		R3,[R1]						;Getting next nodes address
				LDR  	R0, =FIRST_ELEMENT    		;Getting pointer to head nodes address	
				STR     R3,[R0]						;Making it new head
				BL		Free
				MOVS	R1,#0						;Making error code 0 ( no error )
				POP		{R0,R2,R3,PC}
fromtail    	MOVS	R5,#0
				STR		R5,[R7]						;Making prev node point null
				BL		Free
				MOVS	R1,#0						;Making error code 0 ( no error )
				POP		{R0,R2,R3,PC}
empty			MOVS	R1,#3						;Making error code 3 ( The linked list is empty )
				POP		{R0,R2,R3,PC}
notfound		MOVS	R1,#4						;Making error code 4 ( The element is not found )
				POP		{R0,R2,R3,PC}

			
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R1 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------			
				PUSH	{R0,R2,R3}
				LDR  	R1, =FIRST_ELEMENT  		;Loading start address of the allocated space for Head pointer
				LDR		R2,	=ARRAY_MEM				;Loading start address of the allocated space for Array
				MOVS	R3,	#0						;Index for the clear array operation
				MOVS	R4, #0						;0 value to fill array with 0's
				LDR		R5, =ARRAY_SIZE				;R5=ARRAY_SIZE's value
arrayclear		CMP		R3,R5						;Compare index with array size
				BEQ		c							;If index is equal to array size,continue to the linkedlist2arr operations
				STR		R4,[R2,R3]					;Store R4( 0 ) in the array memory respective to index
				ADDS	R3,R3,#4					;Index = index+4 ( 4 byte )
				B		arrayclear					;Loop the cleararray
c				LDR		R3,[R1]						;Getting head node's address
				MOVS	R5,R3						;Head node's address
				CMP		R5,#0						;Checking if pointer equals to null
				BEQ		list_empty					;If yes, error
				LDR		R4,[R3]						;Getting head node's value
				STR		R4,[R2]						;Write to array
				ADDS	R5,R5,#4					;Head node's address place
				MOVS    R3,R5
				LDR     R5,[R5]
				CMP     R5,#0                		;Checking if pointer null
				BEQ     finish                		;If yes, finish
				MOVS    R5,R3
loop3			LDR		R4,[R5]						;Address of next node
				MOVS	R5,R4	
				LDR		R4,[R4]						;Value of next node
				ADDS	R2,R2,#4					;Moving array's index
				STR		R4,[R2]						;Write to array
				ADDS	R5,R5,#4					;Address place 
				LDR		R3,[R5]
				CMP		R3,#0						;Checking if pointer null
				BEQ		finish
				B		loop3
			
list_empty		MOVS 	R1,#5						;Making error code 5 ( The linked list is empty )
				POP		{R0,R2,R3}
				BX		LR
			
finish			MOVS 	R1,#0						;Making error code 0 ( no error )
				POP		{R0,R2,R3}
				BX		LR
;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
;@param     R4 -> Timestamp
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				LDR		R7,=LOG_MEM					;Loading address of LOG_MEM into R7 
				MOVS	R5,R0						;Moving index value into R5
				MOVS	R6,#12						;Loading correspondant byte value into R6
				MULS	R5,R6,R5					;Multiplying index value with the length of each log( 12 byte )
				STRH	R0,[R7,R5]					;Storing index
				ADDS	R5,#2						;Shifting the offset accordingly ( 2 byte )
				STRB	R1,[R7,R5]					;Storing error code	
				ADDS	R5,#1						;Shifting the offset accordingly ( 1 byte )
				STRB	R2,[R7,R5]					;Storing operation code
				ADDS	R5,#1						;Shifting the offset accordingly ( 1 byte )
				STR		R3,[R7,R5]					;Storing data
				ADDS	R5,#4						;Shifting the offset accordingly ( 4 byte )
				STR		R4,[R7,R5]					;Storing timestamp
				BX		LR
				
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R4 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------
				PUSH	{R0,R1,R2,R3}
				LDR		R1, =TICK_COUNT				;Getting the address of TICK_COUNT
				LDR		R0, =842					;Writing the value of period of the system tick timer
				LDR		R4, [R1]					;Getting the content of tick_count
				MULS	R4,R0,R4					;Multiplying TICK_COUNT with period
				LDR		R1, =STRELOAD				;Getting the address of STRELOAD
				LDR		R5,[R1]						;Writing the content of STRELOAD
				LDR 	R7,[R1,#4]					;Writing the content of STCURRENT
				SUBS	R5,R5,R7					;Subtracting STCURRENT from STRELOAD to get the difference
				LSRS	R5,#6						;Dividing by 64 to get the µs value since the clock frequency is equal to 64MHz	
				ADDS	R4,R4,R5					;Adding TICK_COUNT and difference for getting exact value
				POP		{R0,R1,R2,R3}
				BX		LR							;Return
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

