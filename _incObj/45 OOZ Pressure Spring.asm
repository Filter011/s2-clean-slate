; ----------------------------------------------------------------------------
; Object 45 - Pressure spring from OOZ
; ----------------------------------------------------------------------------
obj45_strength = objoff_30
obj45_frame = objoff_32
obj45_original_x_pos = objoff_34

; Sprite_240F8:
Obj45:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj45_Index(pc,d0.w),d1
	jsr	Obj45_Index(pc,d1.w)
	jmp	(MarkObjGone).l
; ===========================================================================
; off_2410A:
Obj45_Index:	offsetTable
		offsetTableEntry.w Obj45_Init		; 0
		offsetTableEntry.w Obj45_Vertical	; 2
		offsetTableEntry.w Obj45_Horizontal	; 4
; ===========================================================================
; loc_24110:
Obj45_Init:
	; Much of this object's code is copied from the spring object, Obj41.
	addq.b	#2,routine(a0)
	move.l	#Obj45_MapUnc_2451A,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_PushSpring,2,0),art_tile(a0)
	ori.b	#1<<render_flags.level_fg,render_flags(a0)
	move.b	#16,width_pixels(a0)
	move.w	#4*$80,priority(a0)
	move.b	subtype(a0),d0
	lsr.w	#3,d0
	andi.w	#2,d0
	move.w	Obj45_InitRoutines(pc,d0.w),d0
	jmp	Obj45_InitRoutines(pc,d0.w)
; ===========================================================================
; off_24146:
Obj45_InitRoutines: offsetTable
	offsetTableEntry.w Obj45_InitVertical
	offsetTableEntry.w Obj45_InitHorizontal
; ===========================================================================
;loc_2414A:
Obj45_InitHorizontal:
	move.b	#4,routine(a0)
	move.b	#1,anim(a0)
	move.b	#$A,mapping_frame(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_PushSpring,2,0),art_tile(a0)
	move.b	#20,width_pixels(a0)
	move.w	x_pos(a0),obj45_original_x_pos(a0)
;loc_2416E:
Obj45_InitVertical:
	move.b	subtype(a0),d0
	andi.w	#2,d0
	move.w	Obj45_Strengths(pc,d0.w),obj45_strength(a0)
	rts
; ===========================================================================
;word_24182:
Obj45_Strengths:
	dc.w -$1000	; Strong
	dc.w  -$A00	; Weak
; ===========================================================================
; loc_24186:
Obj45_Vertical:
	; Is a player stood on this object?
	move.b	status(a0),d0
	andi.b	#standing_mask,d0
	bne.s	loc_2419C
	; No; release the spring.
	tst.b	obj45_frame(a0)
	beq.s	loc_241A8
	subq.b	#1,obj45_frame(a0)
	bra.s	loc_241A8
; ===========================================================================

loc_2419C:
	; Yes; compress the spring.
	cmpi.b	#9,obj45_frame(a0)
	beq.s	Obj45_LaunchCharacterVertical
	addq.b	#1,obj45_frame(a0)

loc_241A8:
	; Handle solidity.
	moveq	#0,d3
	move.b	obj45_frame(a0),d3
	move.b	d3,mapping_frame(a0)
	add.w	d3,d3
	moveq	#27,d1
	moveq	#20,d2
	move.w	x_pos(a0),d4
	jmp	(SolidObject45).l
; ===========================================================================
; loc_241C6:
Obj45_LaunchCharacterVertical:
	lea	(MainCharacter).w,a1
	moveq	#p1_standing_bit,d6

loc_241D4:
	; If this isn't the character that's stood on this object, then return.
	bclr	d6,status(a0)
	beq.w	return_24278
	; Launch the character into the air.
	move.w	obj45_strength(a0),y_vel(a1)
	bset	#status.player.in_air,status(a1)
	bclr	#status.player.on_object,status(a1)
	move.b	#AniIDSonAni_Spring,anim(a1)
	move.b	#2,routine(a1)
	; Clear the character's X velocity if the high bit of the subtype is set.
	move.b	subtype(a0),d0
	bpl.s	loc_24206
	move.w	#0,x_vel(a1)

loc_24206:
	btst	#0,d0
	beq.s	loc_24246
	; Make the character flip.
	move.w	#1,inertia(a1)
	move.b	#1,flip_angle(a1)
	move.b	#AniIDSonAni_Walk,anim(a1)
	move.b	#0,flips_remaining(a1)
	move.b	#4,flip_speed(a1)
	; If this is a strong spring, then make the character flip twice.
	btst	#1,d0
	bne.s	loc_24236
	move.b	#1,flips_remaining(a1)

loc_24236:
	; Correct some details to account for the character's direction.
	btst	#status.player.x_flip,status(a1)
	beq.s	loc_24246
	neg.b	flip_angle(a1)
	neg.w	inertia(a1)

loc_24246:
	; Handle plane-switching.
	andi.b	#$C,d0
	cmpi.b	#4,d0
	bne.s	loc_2425C
	move.b	#$C,top_solid_bit(a1)
	move.b	#$D,lrb_solid_bit(a1)

loc_2425C:
	cmpi.b	#8,d0
	bne.s	loc_2426E
	move.b	#$E,top_solid_bit(a1)
	move.b	#$F,lrb_solid_bit(a1)

loc_2426E:
	moveq	#SndID_Spring,d0
	jmp	(PlaySound).w
; ===========================================================================

return_24278:
	rts
; ===========================================================================
; loc_2427A:
Obj45_Horizontal:
	move.b	#0,objoff_36(a0)
	moveq	#31,d1
	moveq	#12,d2
	moveq	#13,d3
	move.w	x_pos(a0),d4
	lea	(MainCharacter).w,a1 ; a1=character
	moveq	#p1_standing_bit,d6
	jsr	(SolidObject_Always_SingleCharacter).l
	cmpi.w	#1,d4
	bne.s	loc_242C0
	move.b	status(a0),d1
	move.w	x_pos(a0),d2
	sub.w	x_pos(a1),d2
	bcs.s	loc_242B6
	eori.b	#1<<status.player.x_flip,d1

loc_242B6:
	andi.b	#1<<status.player.x_flip,d1
	bne.s	loc_242C0
	bsr.w	loc_2433C

loc_242C0:
	tst.b	objoff_36(a0)
	bne.s	return_2433A
	move.w	obj45_original_x_pos(a0),d0
	cmp.w	x_pos(a0),d0
	beq.s	return_2433A
	bhs.s	loc_2431C
	subq.b	#4,mapping_frame(a0)
	subq.w	#4,x_pos(a0)
	cmp.w	x_pos(a0),d0
	blo.s	loc_24336
	move.b	#$A,mapping_frame(a0)
	move.w	obj45_original_x_pos(a0),x_pos(a0)
	bra.s	loc_24336
; ===========================================================================

loc_2431C:
	subq.b	#4,mapping_frame(a0)
	addq.w	#4,x_pos(a0)
	cmp.w	x_pos(a0),d0
	bhs.s	loc_24336
	move.b	#$A,mapping_frame(a0)
	move.w	obj45_original_x_pos(a0),x_pos(a0)

loc_24336:
	bra.w	Obj45_LaunchCharacterHorizontal

return_2433A:
	rts
; ===========================================================================

loc_2433C:
	btst	#status.npc.x_flip,status(a0)
	beq.s	loc_24378
	btst	#status.player.x_flip,status(a1)
	bne.w	return_243CE
	tst.w	d0
	bne.s	loc_2435E
	tst.w	inertia(a1)
	beq.s	return_243CE
	bpl.s	loc_243C8
	rts
; ===========================================================================

loc_2435E:
	move.w	obj45_original_x_pos(a0),d0
	addi.w	#$12,d0
	cmp.w	x_pos(a0),d0
	beq.s	loc_243C8
	addq.w	#1,x_pos(a0)
	moveq	#1,d0
	move.w	#$40,d1
	bra.s	loc_243A6
; ===========================================================================

loc_24378:
	btst	#status.player.x_flip,status(a1)
	beq.s	return_243CE
	tst.w	d0
	bne.s	loc_2438E
	tst.w	inertia(a1)
	bmi.s	loc_243C8
	rts
; ===========================================================================

loc_2438E:
	move.w	obj45_original_x_pos(a0),d0
	subi.w	#$12,d0
	cmp.w	x_pos(a0),d0
	beq.s	loc_243C8
	subq.w	#1,x_pos(a0)
	moveq	#-1,d0
	moveq	#-$40,d1

loc_243A6:
	add.w	d0,x_pos(a1)
	move.w	d1,inertia(a1)
	move.w	#0,x_vel(a1)
	move.w	obj45_original_x_pos(a0),d0
	sub.w	x_pos(a0),d0
	bcc.s	loc_243C0
	neg.w	d0

loc_243C0:
	addi.w	#$A,d0
	move.b	d0,mapping_frame(a0)

loc_243C8:
	move.b	#1,objoff_36(a0)

return_243CE:
	rts
; ===========================================================================
; loc_243D0:
Obj45_LaunchCharacterHorizontal:
	move.b	status(a0),d0
	andi.b	#pushing_mask,d0
	beq.w	return_244D0
	lea	(MainCharacter).w,a1 ; a1=character
	moveq	#p1_pushing_bit,d6

loc_243EA:
	bclr	d6,status(a0)
	beq.w	return_244D0
	move.w	obj45_original_x_pos(a0),d0
	sub.w	x_pos(a0),d0
	bcc.s	loc_243FE
	neg.w	d0

loc_243FE:
	addi.w	#$A,d0
	lsl.w	#7,d0
	neg.w	d0
	move.w	d0,x_vel(a1)
	subq.w	#4,x_pos(a1)
	bset	#status.player.x_flip,status(a1)
	btst	#status.npc.x_flip,status(a0)
	bne.s	loc_2442C
	bclr	#status.player.x_flip,status(a1)
	addq.w	#8,x_pos(a1)
	neg.w	x_vel(a1)

loc_2442C:
	move.w	#$F,move_lock(a1)
	move.w	x_vel(a1),inertia(a1)
	btst	#status.player.rolling,status(a1)
	bne.s	loc_24446
	move.b	#AniIDSonAni_Walk,anim(a1)

loc_24446:
	; Clear the character's Y velocity if the high bit of the subtype is set.
	move.b	subtype(a0),d0
	bpl.s	loc_24452
	move.w	#0,y_vel(a1)

loc_24452:
	btst	#0,d0
	beq.s	loc_24492
	; Make the character flip.
	move.w	#1,inertia(a1)
	move.b	#1,flip_angle(a1)
	move.b	#AniIDSonAni_Walk,anim(a1)
	move.b	#1,flips_remaining(a1)
	move.b	#8,flip_speed(a1)
	btst	#1,d0
	bne.s	loc_24482
	; If this is a strong spring, then make the character flip four times.
	move.b	#3,flips_remaining(a1)

loc_24482:
	; Correct some details to account for the character's direction.
	btst	#status.player.x_flip,status(a1)
	beq.s	loc_24492
	neg.b	flip_angle(a1)
	neg.w	inertia(a1)

loc_24492:
	; Handle plane-switching.
	andi.b	#$C,d0
	cmpi.b	#4,d0
	bne.s	loc_244A8
	move.b	#$C,top_solid_bit(a1)
	move.b	#$D,lrb_solid_bit(a1)

loc_244A8:
	cmpi.b	#8,d0
	bne.s	loc_244BA
	move.b	#$E,top_solid_bit(a1)
	move.b	#$F,lrb_solid_bit(a1)

loc_244BA:
	bclr	#status.player.pushing,status(a1)
	move.b	#AniIDSonAni_Run,prev_anim(a1)	; Force character's animation to restart
	moveq	#SndID_Spring,d0
	jmp	(PlaySound).w
; ===========================================================================

return_244D0:
	rts
