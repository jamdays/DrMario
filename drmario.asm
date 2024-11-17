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
purple: .word 0x8d07e0
blue: .word 0x362880
pink: .word 0xd67ca9
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
    addi $a0, $a0, 3448 # 256*13 + 4*30
    li $a1, 3
    lw $a2, purple
    jal draw_down
    li $a1, 5
    jal draw_left
    li $a1, 20
    jal draw_down
    li $a1, 14
    jal draw_right
    li $a1, 20
    jal draw_up
    li $a1, 5
    jal draw_left
    li $a1, 4
    jal draw_up	
    

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)	
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop

#lines 64 - 89 for drawing lines
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
	sll $t0, $a1, 8 #multiply $a1 by 256 (sll 8) for branch condition
	add $t1, $a0, $t0 # add to find the ending register
	li $a1, 256 #draw_pixels will update register by 256 (a1 is not needed anymore)
	j draw_pixels #loop

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

end_function: #end function general
jr $ra