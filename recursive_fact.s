ArraySize   EQU	0x18							;Array size = 24 (index*4)

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
		ADDS	r3,r3,#4
		MOVS 	r0,#0							;i=0 as index value for array
		MOVS	r1,#0							;counter = 0 used as factorial index
		MOVS	r2,#2
		MOVS	r6,#1
		MOVS	r7,#0
		LDR 	r5,=f_array						;Load start address of the allocated space for f
		BL		EXECUTE							;Initial jump to function
loop	CMP		r0,r3							;Check i<array_size
		BGE		stop							;if not stop
		STR 	r6,[r5,r0]						;f_array[i] = temp2
		adds 	r0,r0,#4						;i=i+4 for word
		MOVS 	r1,r7
		adds	r1,r1,#1						;counter++ for factorial
		MOVS	r7,r1
		MOVS	r6,#1
		BL		EXECUTE
		B 		loop				
stop	B stop									;Infinite loop
		ALIGN
		ENDFUNC
			
EXECUTE PROC
		CMP		r1,r2							;check if i<2
		BLT		loop							;if yes return 		
		MOVS	r4,r0							;temp1 = i
		SUBS	r4,r4,#4						;temp1 = temp1-1
		MULS	r6, r1, r6						;temp2 = temp2*i
		SUBS	r1,r1,#1						; i = i-1
		BL		EXECUTE							;return r6
		BX LR
		ALIGN
		ENDP
		

		
		END
			
		


