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
pink: .word 0xd67ca9
orange: .word 0xe6962e
white: .word 0xffffff
colors: .word 0xd67ca9, 0xe6962e, 0xffffff
pill:.space 8
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
    
left:
#uses $t0, $t1
down:
	lw $t0, pill #gets the location of one half of the pill
	lw $t1, ($t0) #gets the color at that location
	lw $t2, pill+4 #gets the location of the second half of the pill
	lw $t3, ($t0) #gets the color at that location
	#paints old black
	li $t4, 0 	#loads black into t4
	sw $t4, ($t0)	#stores black in the bitmap at t0
	sw $t4, ($t2)	#stores black in the bitmap at t1
	
	#new loaction (I am calculating it now because I need to store it later)
	addi $t0, $t0, 256
	addi $t2, $t2, 256
	
	#sets new colors
	sw $t1, ($t0)
	sw $t3, ($t2)
	
	#stores new location in pill array 
	sw $t0, pill
	sw $t2, pill+4
	j game_loop
right:
rotate:
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
# $a2, the color
# $a3, the other color
draw_pill:
	sw $a2, ($a0)
	sw $a3, ($a1)
	
end_function: #end function general
jr $ra

quit:
	li $v0, 10                      # Quit gracefully
	syscall

