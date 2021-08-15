ArraySize   EQU	0xFA0		;LIMIT*4
AR		EQU 0x3E8	;LIMIT	
	
					AREA     My_Array, DATA, READWRITE		;Defined area will be placed to the data memory
					ALIGN	
primeNumbers_array  SPACE    ArraySize						;Allocate space from memory for primeNumbers
primeNumbers_end
isPrimeNumber_array  SPACE    ArraySize						;Allocate space from memory for isPrimeNumber
isPrimeNumber_end

		AREA copy_array, code, readonly			;Defined area will be placed to the code memory
		ENTRY
		THUMB
		ALIGN 
__main	FUNCTION
		EXPORT __main
			
		MOVS 	r0,#0							;i=0 as index value for arrays
		MOVS	r1,#1							;counter = 0 for loop
		MOVS	r2,#0
		MOVS	r3,#0
		LDR		r4,=AR							;fillin the array
		LDR 	r5,=primeNumbers_array			;Load start address of the allocated space for primeNumbers
		LDR 	r6,=isPrimeNumber_array			;Load start address of the allocated space for isPrimeNumber

		B		SIEVE							;jump to function			
stop	B stop									;Infinite loop

			
SIEVE 	LDR		r4,=AR						
		CMP		r1,r4							;check if i<LIMIT
		BGE 	jump0							;if not jump
		MOVS	r4,#0
		STR		r4,[r5,r0]						;primeNumbers[i] = 0
		STR		r4,[r6,r0]						;isPrimeNumber[i] = 1
		ADDS	r0,r0,#4						;increase array index for prime Numbers
		ADDS	r1,r1,#1						;increase index
		B		SIEVE							;branch to beginning
jump0	MOVS	r7,#1							;set i = 1;
jump1	MOVS	r1,r7
		ADDS	r7,r7,#1						;i = i + 1
		MOVS	r2,#0
loop1	ADDS	r0,r0,#4						;increase i for array index
		ADDS	r1,r1,#1						;increase counter for loop
		MULS	r1,r1,r1						;i = i^2
		LDR		r4,=AR						
		CMP		r1,r4							;check if i^2<limit
		BGE		FINISH							;if not,loop1
		LDR		r4,[r6,r0]						;temp= isPrime[i]
		CMP		r4,#0							;check if isPrime[i] = true
		BEQ		jump2							;branch if equal
		B		jump1							;if not, loop1
jump2	ADDS	r2,r2,r1						;temp += i^2
		B		jump3
loop2	LDR		r4,=AR						
		CMP		r2,r4							;check if j < limit
		BGE		jump1							;if not loop1
		ADDS	r2,r2,r7						;temp += i
jump3	MOVS	r1,r7							;i = initial value
		MOVS	r3,r2
		MOVS	r4,#4
		MULS	r3,r4,r3						;move to related index
		MOVS	r4,#1
		STR		r4,[r6,r3]						;isPrimeNumber[i] = false	
		ADDS	r0,r0,#4
		B		loop2
FINISH	MOVS 	r0,#8							;i=0 as index value for arrays
		MOVS	r1,#1							;counter = 2 for loop
		MOVS	r3,#0
jump4	LDR		r4,=AR						
		CMP		r1,r4							;for i<limit
		BGE		stop2							;if not stop
		LDR		r4,[r6,r0]						;temp= isPrime[i]
		ADDS	r0,r0,#4						;index for array
		ADDS	r1,r1,#1						;counter for loop		
		CMP		r4,#0							;check if prime
		BNE		jump4							;if not loop again
		STR		r1,[r5,r3]						;if yes isPrime[index] = i
		ADDS	r3,r3,#4						;increase isPrime index
		B		jump4
stop2	B	 stop2
		
		ALIGN
		ENDFUNC
		END


