; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_164F4:
DisplaySprite:
	lea	(Object_Display_Lists).w,a1
	adda.w	priority(a0),a1
	move.w	(a1),d0
	addq.b	#2,d0
	bmi.s	.return
	move.w	d0,(a1)
	move.w	a0,(a1,d0.w)

.return:
	rts
; End of function DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_16512:
DisplaySprite2:
	lea	(Object_Display_Lists).w,a2
	adda.w	priority(a1),a2
	move.w	(a2),d0
	addq.b	#2,d0
	bmi.s	.return
	move.w	d0,(a2)
	move.w	a1,(a2,d0.w)

.return:
	rts
; End of function DisplaySprite2

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; and d0 is already priority*$80
; ---------------------------------------------------------------------------

; loc_16530:
DisplaySprite3:
	lea	(Object_Display_Lists).w,a1
	adda.w	d0,a1
	move.w	(a1),d0
	addq.b	#2,d0
	bmi.s	.return
	move.w	d0,(a1)
	move.w	a0,(a1,d0.w)

.return:
	rts
