############################################
# Data Segment
# messages 
############################################  
	.data
input_msg:
	.asciiz	"Enter the expression: "
output_msg:
	.asciiz	"Result: "
input_str:
	.space 48
newline:
	.asciiz "\n"
		
############################################
# Text Segment
# routines
############################################  
############################################
# Main Routine 		   	
############################################  
	.text
main:
	la	$a0, input_msg		# load the first input message
	jal	print_str		# print the input prompt
	
	la	$a0, input_str		# load the space for the first string into register	
	addi	$a1, $zero, 48  	# the length of the string is 48
	jal	read_str		# read the input
	add	$s0, $a0, $zero		
	
	jal evaluate
	add	$t0, $v0, $zero	
	
	la	$a0, output_msg		# load the result message
	jal	print_str		# print the input prompt
	
	add	$a0, $t0, $zero		# prepare the result for printing
	jal	print_int		# print it
	
	addi	$a0, $zero, '\n'	# print a newline
	j	exit			# exit
exit:
	addi	$v0, $zero, 10		# system code for exit
	syscall				# exit gracefully

############################################
# I/O Routines
############################################
print_str:				# $a0 has string to be printed
	addi	$v0, $zero, 4		# system code for print_str
	syscall				# print it
	jr 	$ra			# return
	
print_int:				# $a0 has number to be printed
	addi	$v0, $zero, 1		# system code for print_int
	syscall
	jr 	$ra

read_str:				# address of str in $a0, 	
					# length is in $a1.
	addi	$v0, $zero, 8		# system code for read_str
	syscall
	jr 	$ra
	
##############################################
# equalIgnoreCase Routine	   
# $a0: memory address of the str. 
# $v0:result of evaluation
##############################################  	
evaluate:
	addi $sp,$sp,-4 #Get a storage from stack
	sw $ra, 0($sp) #Store old $ra to stack
	
	add $s0, $a0, $0   # copy pointer of string to the $s0
#	addi $t1, $0, 32  # ascii code for space
	
	
doWhile:
	lb $t1,0($s0) #Load next number or character.
	beq $t1,10,exitWhile #If end of line, exit loop.
	beq $t1,32,space #If next char is a space, branch accordingly.
	j notSpace #If not space.
space:
	addiu $s0,$s0,1	#Increment by 1 address of current char.
	j doWhile #Go head of loop
notSpace:
	addiu $a0,$s0,0	# add address to argument register to send to toInteger procedure.
	addi $s1,$t1,0 #Store ascii value in $s1 register
	jal toInteger #go toInteger procedure.
	beq $v0,0, notANum #If toInteger returns 0, it is not a num, branch accordingly.
Num:
	addi $sp,$sp,-4 #If it is num, store it on stack!
	sw $v0,0($sp) 
	addi $t6,$v0,0	#Store number
	addi $t7,$0,0	#Store a counter
	decimalPlaces:  #Understand how many decimal Place does number have, so that address of char on string is incremented accordingly.
		div $t6,$t6,10 
		addi $t7,$t7,1
		beq $t6,0,exitInnerLoop
		j decimalPlaces
	exitInnerLoop:	
	add $s0,$s0,$t7
	j doWhile
notANum: #If not a num, branch accordingly.
	beq $s1,43,summation
	beq $s1,45,subtraction
	beq $s1,47,division
	beq $s1,42,multipication
	addiu $s0,$s0,1
	j doWhile
summation:
	lw $t2,0($sp) #Load 2 numbers from stack.
	addi $sp,$sp,4
	lw $t3,0($sp)
	addi $sp,$sp,4
	add $t4,$t3,$t2 #Add them.
	addi $sp,$sp,-4
	sw $t4,0($sp) #Store result on stack
	addi $s0,$s0,1 #Increment address
	j doWhile #Go to head of loop.
subtraction:
	lw $t2,0($sp)
	addi $sp,$sp,4
	lw $t3,0($sp)
	addi $sp,$sp,4
	sub $t4,$t3,$t2 #Subtract them.
	addi $sp,$sp,-4
	sw $t4,0($sp)
	addi $s0,$s0,1
	j doWhile
division:
	lw $t2,0($sp)
	addi $sp,$sp,4
	lw $t3,0($sp)
	addi $sp,$sp,4
	div $t4,$t3,$t2 #Divide them.
	addi $sp,$sp,-4
	sw $t4,0($sp)
	addi $s0,$s0,1
	j doWhile
multipication:
	lw $t2,0($sp)
	addi $sp,$sp,4
	lw $t3,0($sp)
	addi $sp,$sp,4
	mult $t3,$t2 #Multiply them.
	mflo $t4 #Read result of multipication from LO register!
	addi $sp,$sp,-4
	sw $t4,0($sp)
	addi $s0,$s0,1
	j doWhile
exitWhile:

	lw $v0,0($sp) 
	lw $ra, 4($sp) #Get old $ra value from stack
	addi $sp,$sp,8 #Remove added storage from stack
	jr	$ra	# jump back to main

##############################################
# toUpperCase Routine
##############################################
toLowerCase:					



	jr	$ra			# $v0 has the required value.
	
##############################################
# toInteger Routine	   
# $a0 : memory address of the string str. 
# $v0 : a 32-bit 2?s complement binary integer
##############################################  	
toInteger:	
	# TODO				
	# 1. check for sign (negative vs positive)
	li $v0, 0   # initialize value $v=0
        add $t0, $a0, $0   # copy pointer of string to the $t0
        lbu $t1, ($t0)   # load 1 byte which is a single character from meory addres of the string to the $t1
        beq $t1, $0, EXITnull # If first loaded byte is end of the string then exit  
        li $t5, 45
        beq $t1, $t5, MINUS
        bne $t1, $t5, PLUS

	# 2. check for digits 0-9 	

    	PLUS: 
    	addi $t1, $t1, -48 # convert from ascii to digit
    	slti $t2, $t1, 0 # check wheter loaded char is less than 0. $t1 < 0
        bne $0, $t2, EXITloop   
        
        slti $t2, $t1, 10 # check wheter loaded char is greater than 9. $t1 > 0
        beq $0, $t2, EXITloop   

        subu $t1, $t1, $0  # Convert loaded char to integer and store is $t1
        mul $v0, $v0, 10    # multiply value by 10 in each iteration of the loop to get proper digit value
        add $v0, $v0, $t1   # $v0 = $v0 x 10 + digit

        addiu $t0, $t0, 1   # increase pointer of string by 1 to get next char in the string
        lb $t1, ($t0)       # load next byte to $t1

        bne $t1, $0, PLUS   # branch if not end of string
        jr $ra          # return integer value
        
	MINUS: 
	addiu $t0, $t0, 1   # increase pointer of string by 1 to get next char in the string
	lbu $t1, ($t0)   # load 1 more byte from meory addres of the string to get the second char after the minus sign to the $t1
    	MINUSmain:
    	addi $t1, $t1, -48 # convert from ascii to digit
    	slti $t2, $t1, 0 # check wheter loaded char is less than 0. $t1 < 0
        bne $0, $t2, EXITloop   
        
        slti $t2, $t1, 10 # check wheter loaded char is greater than 9. $t1 > 0
        beq $0, $t2, EXITloop   

        subu $t1, $t1, $0  # Convert loaded char to integer and store is $t1
        mul $v0, $v0, 10    # multiply value by 10 in each iteration of the loop to get proper digit value
        sub $v0, $v0, $t1    # $v0 = $v0 x 10 + digit

        addiu $t0, $t0, 1   # increase pointer of string by 1 to get next char in the string
        lb $t1, ($t0)       # load next byte to $t1

        bne $t1, $0, MINUSmain   # branch if not end of string
        jr $ra          # return integer value
        
    	EXITloop: 
        #li $v0, -1      # return -1 in $v0
        jr $ra          # return integer value 
        
   	EXITnull:
   	jr $ra
