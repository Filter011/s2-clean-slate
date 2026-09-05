; ----------------------------------------------------------------------------
; Object D3 - Bomb prize from CNZ
; ----------------------------------------------------------------------------
; Note: see object DC (ring prize) for SST entries (casino_prize_*)

; Sprite_2B84C:
ObjD3:
	moveq	#0,d1
	move.w	casino_prize_machine_x_pos(a0),d1
	swap	d1
	move.l	casino_prize_x_pos(a0),d0
	sub.l	d1,d0
	asr.l	#4,d0
	sub.l	d0,casino_prize_x_pos(a0)
	move.w	casino_prize_x_pos(a0),x_pos(a0)
	moveq	#0,d1
	move.w	casino_prize_machine_y_pos(a0),d1
	swap	d1
	move.l	casino_prize_y_pos(a0),d0
	sub.l	d1,d0
	asr.l	#4,d0
	sub.l	d0,casino_prize_y_pos(a0)
	move.w	casino_prize_y_pos(a0),y_pos(a0)
	subq.w	#1,casino_prize_display_delay(a0)
	bne.s	JmpTo28_DisplaySprite
	movea.l	objoff_2A(a0),a1
	subq.w	#1,(a1)
	cmpi.w	#5,(Bonus_Countdown_3).w
	blo.s	+
	clr.w	(Bonus_Countdown_3).w
	moveq	#SndID_HurtBySpikes,d0
	jsr	(PlaySound2).w
+
	tst.w	(Ring_count).w
	beq.s	BranchTo_JmpTo44_DeleteObject
	subq.w	#1,(Ring_count).w
	ori.b	#$81,(Update_HUD_rings).w

BranchTo_JmpTo44_DeleteObject ; BranchTo
	jmp	(DeleteObject).l

JmpTo28_DisplaySprite ; JmpTo
	jmp	(DisplaySprite).l