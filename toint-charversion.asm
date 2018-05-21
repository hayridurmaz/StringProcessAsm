############################################
# Data Segment
# messages 
############################################  

	.data
input_msg:
	.asciiz	"Enter an integer as a string (from -2^31 + 1 to 2^31 - 1): "
output_msg:
	.asciiz "The integer: "
input_str:
	.space 32

############################################
# Text Segment
############################################  
############################################
# Main Routine 		   	
############################################  
	.text
main:
	# read an integer as a string
	la	$a0, input_msg		
	jal	print_str		
	la	$a0, input_str		
	addi	$a1, $zero, 32		# the length of the string
	jal	scan_str		# read the input

	# $a0 contains the address of the string. 
	# return the integer in $v0. 
	
	jal	toInteger
	# Save the returned integer in $s0.
	add	$s0, $zero, $v0
	
	
	la	$a0, output_msg
	jal	print_str 		# print output_msg
	add	$a0, $zero, $s0		# ready to print the integer
	jal	print_int		# print integer

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

scan_str:				# address of str in $a0, 
					# length is in $a1.
	addi	$v0, $zero, 8		# system code for read_str
	syscall
	jr 	$ra
	
	
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
        li $t5, 45 #ascii number of minus. '-'
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
        #mul $v0, $v0, 10    # multiply value by 10 in each iteration of the loop to get proper digit value
        add $v0, $v0, $t1   # $v0 = $v0 x 10 + digit

        #addiu $t0, $t0, 1   # increase pointer of string by 1 to get next char in the string
        #lb $t1, ($t0)       # load next byte to $t1

        #bne $t1, $0, PLUS   # branch if not end of string
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
        #mul $v0, $v0, 10    # multiply value by 10 in each iteration of the loop to get proper digit value
        sub $v0, $v0, $t1    # $v0 = $v0 x 10 + digit

        #addiu $t0, $t0, 1   # increase pointer of string by 1 to get next char in the string
        #lb $t1, ($t0)       # load next byte to $t1

        #bne $t1, $0, MINUSmain   # branch if not end of string
        jr $ra          # return integer value
        
    	EXITloop: 
        #li $v0, -1      # return -1 in $v0
        jr $ra          # return integer value 
        
   	EXITnull:
   	jr $ra
