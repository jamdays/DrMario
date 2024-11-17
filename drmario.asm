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
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
bottle_color: .word 0x97bdcc
blue: .word 0x362880
pink: .word 0xd67ca9
orange: .word 0xe6962e
white: .word 0xffffff
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
    # set parameters to draw a purple horizontal line    
    lw $a0, ADDR_DSPL
    addi $a0, $a0, 7792 # 256*30 + 4*28
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
    lw $a0, ADDR_DSPL
    addi $a0, $a0, 8568 # 256*30 + 4*30
    addi $a1, $a0, 4
    
    jal draw_pill_ow   	
    
    
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)	
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
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

# $a0, location of first half
# $a1, location of second half
# uses $t0
draw_pill_pw:
	lw $t0, pink
	sw $t0, ($a0)
	lw $t0, white
	sw $t0, ($a1)
	j end_function
draw_pill_ow:
	lw $t0, orange
	sw $t0, ($a0)
	lw $t0, white
	sw $t0, ($a1)
	j end_function
draw_pill_po:
	lw $t0, pink
	sw $t0, ($a0)
	lw $t0, orange
	sw $t0, ($a1)
	j end_function

end_function: #end function general
jr $ra
