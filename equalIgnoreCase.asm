############################################
# Data Segment
# messages 
############################################  
	.data
input_msg1:
	.asciiz	"Enter the first string: "
input_msg2:
	.asciiz	"Enter the second string: "
input_str1:
	.space 48
input_str2:
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
	la	$a0, input_msg1		# load the first input message
	jal	print_str		# print the input prompt
	
	la	$a0, input_str1		# load the space for the first string into register	
	addi	$a1, $zero, 48  	# the length of the string is 48
	jal	read_str		# read the input
	add	$s0, $a0, $zero		
	
	
	la	$a0, input_msg2		# load the second input message
	jal	print_str		# print the input prompt

	la	$a0, input_str2		# load the space for the second string into register
	addi	$a1, $zero, 48		# the length of the string is 48
	jal	read_str		# read the input
	add	$s1, $a0, $zero		
	
	add	$a0, $s0, $zero		# save second string address for compare
	add	$a1, $s1, $zero		# save second string address for compare
	jal	equalIgnoreCase	
	
	add	$a0, $v0, $zero		# prepare the cmp result for printing
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
# $a0: memory address of the str1. 
# $a1: memory address of the str2. 
# $v0:(+)negative integer if the str1 comes first, 
#     (-)positive integer if the str2 comes first, 
#     0 if both strings are equal.
##############################################  	
equalIgnoreCase:									
	# 1.call toUpperCase for str1
	# 2.call toUpperCase for str2
	# 3.compare str1 str2
	
	addi $s0,$a0,0 #Store arguments to $s registers
	addi $s1,$a1,0
	
	addi $sp,$sp,-4 #Get a storage from stack
	sw $ra, 0($sp) #Store old $ra to stack
	
	addi $a0,$s0,0 #First call toLowerCase
	jal toLowerCase
	
	
	addi $a0,$s1,0 #Second call toLowerCase
	jal toLowerCase
	

	#For each char in strings
loop2:
	lb $t2, 0($s0) #Get first strings char at $s0
	lb $t3, 0($s1) #Get second strings char at $s1
    
	bne $t2,$t3, case2 #If chars are not equal go to case2
	addi $s0, $s0, 1 #Get next char address
	addi $s1, $s1, 1
	beq $t2,0,case1 #If chars are equal go to case1
	beq $t3,0,case1
	j loop2 #Loops
case1:
	addi $v0,$0,0 #Since they are equal, return 0
	j ex
case2: 
	sub $v0,$t3,$t2 #They are not equal, return accordingly
ex:
	lw $ra, 0($sp) #Get old $ra value from stack
	addi $sp,$sp,4 #Remove added storage from stack
	jr	$ra			# jump back to main

##############################################
# toLowerCase Routine
# $a0: memory address of the string to be made LowerCase. 
##############################################
toLowerCase:	
						
	addi $t0,$a0,0 #Add parameter of address of char to temp register
	addi $t4,$0,65 #Ascii code for 'A'
	addi $t5,$0,90 #Ascii code for 'Z'
	
loop:
	lb $t1, 0($t0) # Get addressed char of string
	beq $t1, 0, exit2 #If char is last char of string, go to exit2
	blt $t1, $t4, case #If char is not UpperCase letter.
	bgt $t1, $t5, case #If char is not UpperCase letter.
	addi $t1, $t1, 32 #Char is an UpperCase letter, so make it LowerCase
	sb $t1, 0($t0) #Store LowerCase char letter onto same address with UpperCase one. 

case: 
	addi $t0, $t0, 1 #Get address of next char in string
	j loop 
exit2:
	jr	$ra # $v0 has the required value.

