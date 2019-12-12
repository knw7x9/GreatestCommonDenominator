@ author: Katherine Wilsdon

.text
prompt1: 
	.asciz 	"Find the greatest common denominator between two numbers.\n"
prompt2:
	.asciz	"Please enter a positive integer: "
input1:
	.asciz 	"%u"
prompt3:
	.asciz 	"Please enter another positive integer: "
input2:
	.asciz 	"%u"
output1:
	.asciz 	"%u is the greatest common denominator between  %u and %u.\n"
output_gcd:
	.asciz 	"%u"

.align 2
.global main
.global gcd
.global remainder

.func main
main:
	push 	{fp, lr}
	add 	fp, sp, #4
	sub	sp, sp, #12 
				@ input1: [fp, #-8]
				@ input2: [fp, #-12]
				@ output_gcd: [fp, #-16]
	str	r0, [fp, #-8]
	str 	r1, [fp, #-12]
	str	r2, [fp, #-16]

	ldr 	r0, =prompt1
	bl	printf		@ print purpose of the program
	
	ldr 	r0, =prompt2
	bl 	printf		@ ask  user for input1
	
	ldr 	r0, =input1
	sub 	r1, fp, #8
	bl 	scanf		@ get input1 from user

	ldr 	r0, =prompt3
	bl 	printf		@ ask user for input2
	
	ldr 	r0, =input2
	sub 	r1, fp, #12
	bl 	scanf		@ get input2 from user

	@if comparison
	ldr	r0, [fp, #-8]
	ldr 	r1, [fp, #-12]
	cmp 	r0, r1		@ if input1 < input2, go to main_if_exec
	bge 	main_else_exec	@ if input1 >= input2, go to main_else_exec

main_if_exec:
	
	ldr	r0, [fp, #-12]	@ big_num
	ldr 	r1, [fp, #-8]	@ small_num
	bl 	gcd		@ gcd(int, int)
	str	r3, [fp,#-16]	
	bl 	main_if_else_end

main_else_exec:	
	
	ldr	r0, [fp, #-8]	@ big_num
	ldr 	r1, [fp, #-12]	@ small_num
	bl 	gcd		@ gcd(int, int)	
	str	r3, [fp,#-16]	 
main_if_else_end:
	
	ldr 	r0, =output1
	ldr 	r1, [fp, #-16]
	ldr 	r2, [fp, #-8]
	ldr 	r3, [fp, #-12]
	bl 	printf		@ prints the greatest common denominator

	sub 	sp, fp, #4
	pop	{fp, pc}

.endfunc

.func gcd
gcd:

	push 	{fp, lr}
	add 	fp, sp, #4

	sub 	sp, sp, #4	@ big_num: [fp, #-8]
	str 	r0, [fp, #-8]

	sub 	sp, sp, #4	@ small_num: [fp, #-12]
	str 	r1, [fp, #-12]

				@ int gcd(int n1, int n2) {
				@   if (n2 != 0)
				@     return gcd(n2, n1%n2);
				@   else
				@     return n1;
				@ }	
	
	@if comparison
	ldr 	r0, [fp, #-12]	@ r0 = small_num
	ldr 	r1, =0		@ r1 = 0
	cmp 	r0, r1		@ small_num != 0, go to if_exec		
	beq	gcd_else_exec	@ small_num == 0, go to else_exec
	
gcd_if_exec:
	
	ldr	r0, [fp, #-8]
	ldr 	r1, [fp, #-12]
	bl	remainder	@ go to remainder function
		
	str 	r0, [fp, #-8]	@ store remainder
	ldr	r0, [fp, #-12]
	ldr	r1, [fp, #-8]
	b 	gcd		@ gcd (n2, n1%n2)

gcd_else_exec:
			
	ldr 	r3, [fp, #-8]	@ return greatest common denominator
	sub 	sp, fp, #4
	pop	{fp, pc}

.endfunc

.func remainder
remainder:
	
	push 	{fp, lr}
	add 	fp, sp, #4
	
	sub 	sp, sp, #4	@ number/remainder: [fp, #-8]
	str 	r0, [fp, #-8]

	sub 	sp, sp, #4	@ divisor: [fp, #-12]
	str 	r1, [fp, #-12]
				
				@ while(n>=divisor){
        			@     n -= divisor;
        			@ }

begin_while_loop:
	
	ldr r0, [fp, #-8]	@ number/remainder
	ldr r1, [fp, #-12]	@ divisor
	cmp r0, r1		@ if n >= divisor, go to remainder_if_exec
	blt end_while_loop	@ if n < divisor, got to end_while_loop  
	

remainder_if_exec:
	
	ldr r0, [fp, #-8]	@ number/remainer
	ldr r1, [fp, #-12]	@ divisor
	sub r0, r1		@ n -= divisor
	str r0, [fp, #-8]
	bl begin_while_loop

end_while_loop:	
	
	ldr	r0, [fp, #-8]	@ return remainder
	sub 	sp, fp, #4
	pop	{fp, pc}


.endfunc
