ArraySize   EQU	0x18							;Array size = 24 (6, each 4 bytes)

		AREA     My_Array, DATA, READWRITE		;Defined area will be placed to the data memory
		ALIGN	
f_array SPACE    ArraySize						;Allocate space from memory for f
f_end

		AREA copy_array, code, readonly			;Defined area will be placed to the code memory
		ENTRY
		THUMB
		ALIGN 
__main	FUNCTION
		EXPORT __main
			
		LDR		r3,=ArraySize					;Load array size
		MOVS 	r0,#0							;i=0 as index value for array
		MOVS	r1,#0							;counter = 0 used as factorial index
		MOVS	r6,#1							;temp = 1
		LDR 	r5,=f_array						;Load start address of the allocated space for f
		B		EXECUTE							; jump to function			
stop	B stop									;Infinite loop

			
EXECUTE 
		STR		r6,[r5,#0]						;for i<2, f_array[0] = 1
loop	CMP		r0,r3							;Check i<array_size
		BGE		stop							;if not stop
		adds 	r0,r0,#4						;i=i+4 for word
		adds	r1,r1,#1						;counter++ for factorial
		MOVS	r4,r0							;temp1 = i
		SUBS	r4,r4,#4						;temp1 = temp1-1
		LDR		r6,[r5,r4]						;temp2 = f_array[i-1]
		MULS	r6, r1, r6						;temp2 = temp2*i
		STR 	r6,[r5,r0]						;f_array[i] = temp2
		
		B		loop							;back to loop

		
		ALIGN
		ENDFUNC
		END


