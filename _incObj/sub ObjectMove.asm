; ---------------------------------------------------------------------------
; Subroutine to make an object move and fall downward increasingly fast
; This moves the object horizontally and vertically
; and also applies gravity to its speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_16380: ObjectFall:
ObjectMoveAndFall:
	addi.w	#$38,y_vel(a0)	; increase vertical speed (apply gravity)
; End of function ObjectMoveAndFall
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ---------------------------------------------------------------------------
; Subroutine translating object speed to update object position
; This moves the object horizontally and vertically
; but does not apply gravity to it
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_163AC: SpeedToPos:
ObjectMove:
	movem.w	x_vel(a0),d0/d2	; load horizontal speed
	asl.l	#8,d0	; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(a0)	; add to x-axis position	; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
	asl.l	#8,d2	; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d2,y_pos(a0)	; add to y-axis position	; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
	rts
; End of function ObjectMove
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
