; ----------------------------------------------------------------------------
; Object 66 - Yellow spring walls from MTZ
; ----------------------------------------------------------------------------
; Sprite_26F58:
Obj66:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj66_Index(pc,d0.w),d1
	jmp	Obj66_Index(pc,d1.w)
; ===========================================================================
; off_26F66:
Obj66_Index:	offsetTable
		offsetTableEntry.w Obj66_Init	; 0
		offsetTableEntry.w Obj66_Main	; 2
; ===========================================================================
; loc_26F6A:
Obj66_Init:
	addq.b	#2,routine(a0)
	move.l	#Obj66_MapUnc_27120,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Powerups,0,1),art_tile(a0)
	ori.b	#1<<render_flags.level_fg,render_flags(a0)
	move.b	#8,width_pixels(a0)
	move.w	#4*$80,priority(a0)
	move.b	#$40,y_radius(a0)
	move.b	subtype(a0),d0
	lsr.b	#4,d0
	andi.b	#7,d0
	move.b	d0,mapping_frame(a0)
	beq.s	Obj66_Main
	move.b	#$80,y_radius(a0)
; loc_26FAE:
Obj66_Main:
	moveq	#$13,d1
	moveq	#0,d2
	move.b	y_radius(a0),d2
	move.w	d2,d3
	addq.w	#1,d3
	move.w	x_pos(a0),d4
	lea	(MainCharacter).w,a1 ; a1=character
	moveq	#p1_standing_bit,d6
	jsr	(SolidObject_Always_SingleCharacter).l
	cmpi.b	#1,d4
	bne.s	loc_26FF6
	btst	#status.player.in_air,status(a1)
	beq.s	loc_26FF6
	move.b	status(a0),d1
	move.w	x_pos(a0),d0
	sub.w	x_pos(a1),d0
	bcs.s	+
	eori.b	#1<<status.player.x_flip,d1
+
	andi.b	#1<<status.player.x_flip,d1
	bne.s	loc_26FF6
	bsr.s	loc_27042

loc_26FF6:
	move.w	x_pos(a0),d0
	andi.w	#$FF80,d0
	sub.w	(Camera_X_pos_coarse).w,d0
	cmpi.w	#$280,d0
	bhi.s	JmpTo33_DeleteObject
	tst.w	(Debug_placement_mode).w
	beq.s	+	; rts
	jmp	(DisplaySprite).l
+
	rts

JmpTo33_DeleteObject ; JmpTo
	jmp	(DeleteObject).l
; ===========================================================================
loc_27042:
    if gameRevision>0
	; REV00 didn't prevent the player from bouncing if they were hurt or dead
	cmpi.b	#4,routine(a1)
	blo.s	loc_2704C
	rts
    endif
; ===========================================================================

loc_2704C:
	move.w	objoff_30(a0),x_vel(a1)
	move.w	#-$800,x_vel(a1)
	move.w	#-$800,y_vel(a1)
	bset	#status.player.x_flip,status(a1)
	btst	#status.npc.x_flip,status(a0)
	bne.s	+
	bclr	#status.player.x_flip,status(a1)
	neg.w	x_vel(a1)
+
	move.w	#$F,move_lock(a1)
	move.w	x_vel(a1),inertia(a1)
	btst	#status.player.rolling,status(a1)
	bne.s	+
	move.b	#AniIDSonAni_Walk,anim(a1)
+
	move.b	subtype(a0),d0
	bpl.s	+
	move.w	#0,y_vel(a1)
+
	btst	#0,d0
	beq.s	loc_270DC
	move.w	#1,inertia(a1)
	move.b	#1,flip_angle(a1)
	move.b	#AniIDSonAni_Walk,anim(a1)
	move.b	#1,flips_remaining(a1)
	move.b	#8,flip_speed(a1)
	btst	#1,d0
	bne.s	+
	move.b	#3,flips_remaining(a1)
+
	btst	#status.player.x_flip,status(a1)
	beq.s	loc_270DC
	neg.b	flip_angle(a1)
	neg.w	inertia(a1)

loc_270DC:
	andi.b	#$C,d0
	cmpi.b	#4,d0
	bne.s	+
	move.b	#$C,top_solid_bit(a1)
	move.b	#$D,lrb_solid_bit(a1)
+
	cmpi.b	#8,d0
	bne.s	+
	move.b	#$E,top_solid_bit(a1)
	move.b	#$F,lrb_solid_bit(a1)
+
	bclr	#p1_pushing_bit,status(a0)
	bclr	#p2_pushing_bit,status(a0)
	bclr	#status.player.pushing,status(a1)
	moveq	#SndID_Spring,d0
	jmp	(PlaySound).w
