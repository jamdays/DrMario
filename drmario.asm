################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Maximilian Djaya, 1010401744
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    512
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it! (97 a, 115 s, 100 d, 119 w)
ADDR_KBRD:
    .word 0xffff0000
bottle_color: .word 0x97bdcc
blue: .word 0x362880
pink: .word 0xff8ad4
orange: .word 0xffb152
white: .word 0xffffff
colors: .word 0xff8ad4, 0xffb152, 0xffffff
viruses: .word 0xee79c3, 0xeea041, 0xeeeeee
pill:.space 8
rotati:  .word 252
##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main


# . . .
    # Run the game.
main:
    # Initialize the game
    # set parameters to draw a botte 
    lw $a0, ADDR_DSPL
    addi $a0, $a0, 7792 # 256*30 + 4*28, (corner of bottle is 7792 - 4*2 + 256*4) (8808)
    li $a1,2
    lw $a2, bottle_color
    jal draw_down
    li $a1, 1
    jal draw_right
    li $a1, 1
    jal draw_down
    li $a1, 3
    jal draw_left
    li $a1, 18
    jal draw_down
    li $a1, 9
    jal draw_right
    li $a1, 18
    jal draw_up
    li $a1, 3
    jal draw_left
    li $a1, 1
    jal draw_up
    li $a1, 1
    jal draw_right
    li $a1, 3
    jal draw_up
    #done drawing bottle
    
    li $v0, 42 #generate random number for color
    li $a0, 0
    li $a1, 3
    syscall
    sll $t0, $a0, 2
    lw $t1 colors($t0)
    li $v0, 42 #generate random number for color
    li $a0, 0
    li $a1, 3
    syscall
    sll $t0, $a0, 2
    lw $t2 colors($t0)
    lw $a0, ADDR_DSPL
    addi $a0, $a0, 8568 # 256*30 + 4*30
    addi $a1, $a0, 4
    add $a2, $t1, $zero
    add $a3, $t2, $zero
    jal draw_pill
    #current pill pos set to t6, t7
    sw $a0, pill
    sw $a1, pill+4
    li $a2, 4
    jal draw_viruses
    
    
game_loop:
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)	
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
    
keyboard_input:
    lw $a0, 4($t0)              # Load second word from keyboard
    beq $a0, 0x71, quit     	# Check if the key q was pressed
    beq $a0, 97, left 		#if a pressed
    beq $a0, 115, down 		#if s pressed
    beq $a0, 100, right 	#if d pressed
    beq $a0, 119, rotate 	#if w pressed
    li $v0, 1                   # ask system to print $a0
    syscall
    j game_loop
#uses $t0-$t4
left:
	lw $t0, pill #gets the location of one half of the pill
	lw $t1, ($t0) #gets the color at that location
	lw $t2, pill+4 #gets the location of the second half of the pill
	lw $t3, ($t2) #gets the color at that location
	#paints old black
	li $t4, 0 	#loads black into t4
	sw $t4, ($t0)	#stores black in the bitmap at t0
	sw $t4, ($t2)	#stores black in the bitmap at t1
	
	#new loaction (I am calculating it now because I need to store it later)
	addi $t0, $t0, -4
	addi $t2, $t2, -4
	#check collision
	lw $t5, ($t0) #get color at new $t0
	bne $t5, $zero collided_left
	lw $t5, ($t2) #get color at new $t2  
	bne $t5, $zero collided_left
	#sets new colors
	sw $t1, ($t0)
	sw $t3, ($t2)
	
	#stores new location in pill array 
	sw $t0, pill
	sw $t2, pill+4
	j game_loop
#uses $t0-$t4
down:
	lw $t0, pill #gets the location of one half of the pill
	lw $t1, ($t0) #gets the color at that location
	lw $t2, pill+4 #gets the location of the second half of the pill
	lw $t3, ($t2) #gets the color at that location
	#paints old black
	li $t4, 0 	#loads black into t4
	sw $t4, ($t0)	#stores black in the bitmap at t0
	sw $t4, ($t2)	#stores black in the bitmap at t1
	
	#new loaction (I am calculating it now because I need to store it later)
	addi $t0, $t0, 256
	addi $t2, $t2, 256
	#check collision
	lw $t5, ($t0) #get color at new $t0
	bne $t5, $zero collided_down
	lw $t5, ($t2) #get color at new $t2  
	bne $t5, $zero collided_down
	
	#sets new colors
	sw $t1, ($t0)
	sw $t3, ($t2)
	
	#stores new location in pill array 
	sw $t0, pill
	sw $t2, pill+4
	j game_loop
#uses t0-t4
right:
	lw $t0, pill #gets the location of one half of the pill
	lw $t1, ($t0) #gets the color at that location
	lw $t2, pill+4 #gets the location of the second half of the pill
	lw $t3, ($t2) #gets the color at that location
	#paints old black
	li $t4, 0 	#loads black into t4
	sw $t4, ($t0)	#stores black in the bitmap at t0
	sw $t4, ($t2)	#stores black in the bitmap at t1
	
	#new loaction (I am calculating it now because I need to store it later)
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	#check collision
	lw $t5, ($t0) #get color at new $t0
	bne $t5, $zero collided_right
	lw $t5, ($t2) #get color at new $t2  
	bne $t5, $zero collided_right
	
	#sets new colors
	sw $t1, ($t0)
	sw $t3, ($t2)
	
	#stores new location in pill array 
	sw $t0, pill
	sw $t2, pill+4
	j game_loop
#uses t0-t6
rotate:
	lw $t0, pill #gets the location of one half of the pill
	lw $t1, ($t0) #gets the color at that location
	lw $t2, pill+4 #gets the location of the second half of the pill
	lw $t3, ($t2) #gets the color at that location
	#paints old black
	li $t4, 0 	#loads black into t4
	sw $t4, ($t0)	#stores black in the bitmap at t0
	sw $t4, ($t2)	#stores black in the bitmap at t1
	
	lw $t5, rotati
	#new loaction (I am calculating it now because I need to store it later)
	addi $t0, $t0, 0
	add $t2, $t2, $t5
	#check collision
	lw $t7, ($t0) #get color at new $t0
	bne $t7, $zero collided_rotate
	lw $t7, ($t2) #get color at new $t2  
	bne $t7, $zero collided_rotate
	
	# if the last increment was 252 then set it to -260
	li $t6, -260
	beq $t5, 252, continue_rotate
	li $t6, -252
	beq $t5, -260, continue_rotate
	li $t6, 260
	beq $t5, -252, continue_rotate
	li $t6, 252
	beq $t5, 260, continue_rotate
	continue_rotate:
	sw $t6, rotati
	#sets new colors
	sw $t1, ($t0)
	sw $t3, ($t2)
	
	#stores new location in pill array 
	sw $t0, pill
	sw $t2, pill+4
	j game_loop

collided_rotate:
	sub $t2, $t2, $t5
	sw $t1, ($t0)
	sw $t3, ($t2)
	j game_loop
collided_right:
	addi $t0, $t0, -4
	addi $t2, $t2, -4
	sw $t1, ($t0)
	sw $t3, ($t2)
	j game_loop
collided_left:
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	sw $t1, ($t0)
	sw $t3, ($t2)
	j game_loop
collided_down:
	addi $t0, $t0, -256
	addi $t2, $t2, -256
	sw $t1, ($t0)
	sw $t3, ($t2)
	j new_pill
	j game_loop
	
#lines 64 - 89 for drawing lines (USES t0, t1)
# $a0, starting register
# $a1, length of line
# $a2, color
draw_right:
	sll $t0, $a1, 2  #multiply $a1 by 4 (sll 2) for branch condition
	add $t1, $a0, $t0 #add to find ending register 
	li, $a1, 4 #draw_pixels will update register by 4 (a1 is not needed anymore)
	j draw_pixels
	

# $a0, starting register
# $a1, length of line
# $a2, color
draw_down:
	sll $t0, $a1, 8 # multiply $a1 by 256 (sll 8) for branch condition
	add $t1, $a0, $t0 # add to find the ending register
	li $a1, 256  # draw_pixels will update register by 256 (a1 is not needed anymore)
	j draw_pixels # loop

# $a0, starting register
# $a1, length of line
# $a2, color
draw_left:
	sll $t0, $a1, 2  #multiply $a1 by 4 (sll 2) for branch condition
	sub $t1, $a0, $t0 #add to find ending register 
	li, $a1, -4 #draw_pixels will update register by 4 (a1 is not needed anymore)
	j draw_pixels
	

# $a0, starting register
# $a1, length of line
# $a2, color
draw_up:
	sll $t0, $a1, 8 #multiply $a1 by 256 (sll 8) for branch condition
        sub $t1, $a0, $t0 # add to find the ending register
	li $a1, -256 #draw_pixels will update register by 256 (a1 is not needed anymore)
	j draw_pixels #loop
	
# $a1, how much to update the register by
draw_pixels: #loop
	beq $t1, $a0, end_function  #end loop if register = starting register + 4*a1
	sw $a2, ($a0) #put color in register
	add $a0, $a0, $a1 #update register to be drawn
j draw_pixels

new_pill:
    li $v0, 42 #generate random number for color
    li $a0, 0
    li $a1, 3
    syscall
    sll $t0, $a0, 2
    lw $t1 colors($t0)
    li $v0, 42 #generate random number for color
    li $a0, 0
    li $a1, 3
    syscall
    sll $t0, $a0, 2
    lw $t2 colors($t0)
    lw $a0, ADDR_DSPL
    addi $a0, $a0, 8568 # 256*30 + 4*30
    addi $a1, $a0, 4
    add $a2, $t1, $zero
    add $a3, $t2, $zero
    jal draw_pill
    #current pill pos set to pill, and pill+4
    sw $a0, pill
    sw $a1, pill+4
    #reset rotation
    li $t0, 252
    sw $t0, rotati
    j game_loop

# $a2, how many viruses	
draw_viruses:
    	li $v0, 42 #generate random number for color
    	li $a0, 0
    	li $a1, 3
    	syscall
    	sll $t0, $a0, 2
    	lw $t1 viruses($t0)
    	li $v0, 42 #generate random number for column
    	li $a0, 0
    	li $a1, 8
    	syscall
    	sll $t0, $a0, 2		#mult by 4 and store at t0 
    	li $v0, 42 #generate random number for location
    	li $a0, 0
    	li $a1, 12
    	syscall
    	sll $t2, $a0, 8		#mult by 256 and store at t2
    	add $t2, $t2, $t0
    	addi $t2, $t2, 8808
    	lw $t3, ADDR_DSPL
    	add $t2, $t2, $t3
    	lw  $t3, ($t2)
    	bnez $t3 draw_viruses
    	sw $t1, ($t2)
    	addi $a2, $a2, -1
    	bnez $a2 draw_viruses
    	j end_function    	
    	
    	
	
# $a0, location of first half
# $a1, location of second half
# $a2, the color
# $a3, the other color
#uses t0
draw_pill:
	lw $t0, ($a0)
	bnez $t0, quit
	lw $t1, ($a0)
	bnez $t0, quit
	sw $a2, ($a0)
	sw $a3, ($a1)
	
end_function: #end function general
jr $ra

quit:
	li $v0, 10                      # Quit gracefully
	syscall

