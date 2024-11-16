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


lw $t1 , purple # $ t 1 = r e d
lw $t2 , blue  # $ t 2 = g r e e n
lw $t3 , pink # $ t 3 = b l u e
lw $t0 , ADDR_DSPL # $ t 0 = b a s e a d d r e s s f o r d i s p l a y
sw $t1, 0 ($t0) # p a i n t t h e f i r s t u n i t ( i . e . , top− l e f t ) r e d
sw $t2 , 4 ($t0) # p a i n t t h e s e c o n d u n i t on t h e f i r s t row g r e e n
sw $t3 , 128 ($t0) # p a i n t t h e f i r s t u n i t on t h e s e c o n d row b l u e
# . . .
    # Run the game.
main:
    # Initialize the game
    # set parameters to draw a gray vertical line  
    #     
    

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)	
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop


# $a0, starting register
# $a1, length of line
# $a2, color
draw_horizontal:
	sll $t0, $a1, 10  #multiply $a1 by 4 (sll 2) for branch condition
	
	draw_pixel: #loop
	beq $t1, #end loop if register = starting register + 4*a1
	#update register to be drawn
	#put color in register
jr $ra


# $a0, starting register
# $a1, length of line
# $a2, color
draw_vertical:
	#multiply $a1 by 512 (sll 9) for branch condition
	#loop
	#end loop if register = starting register + 512*length of line
	#update register to be drawn
	#put color in register
jr $ra
