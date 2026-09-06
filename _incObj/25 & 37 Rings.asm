; ----------------------------------------------------------------------------
; Object 25 - A ring (usually only placed through placement mode)
; ----------------------------------------------------------------------------
; Obj_Ring:
Obj25:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj25_Index(pc,d0.w),d1
	jmp	Obj25_Index(pc,d1.w)
; ===========================================================================
; Obj_25_subtbl:
Obj25_Index:	offsetTable
		offsetTableEntry.w Obj25_Init		; 0
		offsetTableEntry.w Obj25_Animate	; 2
		offsetTableEntry.w Obj25_Collect	; 4
		offsetTableEntry.w Obj25_Sparkle	; 6
		offsetTableEntry.w Obj25_Delete		; 8
; ===========================================================================
; Obj_25_sub_0:
Obj25_Init:
	addq.b	#2,routine(a0)
	move.w	x_pos(a0),objoff_32(a0)
	move.l	#Obj25_MapUnc_12382,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Ring,1,0),art_tile(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.w	#2*$80,priority(a0)
	move.b	#$47,collision_flags(a0)
	move.b	#8,width_pixels(a0)
; Obj_25_sub_2:
Obj25_Animate:
	move.w	objoff_32(a0),d0
	bra.w	MarkObjGone2
; ===========================================================================
; Obj_25_sub_4:
Obj25_Collect:
	addq.b	#2,routine(a0)
	move.b	#0,collision_flags(a0)
	move.w	#1*$80,priority(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Ring_sparkles,1,0),obGfx(a0)
	bsr.s	CollectRing
; Obj_25_sub_6:
Obj25_Sparkle:
	lea	Ani_Ring(pc),a1
	bsr.w	AnimateSprite
	bra.w	DisplaySprite
; ===========================================================================
; BranchTo4_DeleteObject
Obj25_Delete:
	bra.w	DeleteObject

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_11FC2:
CollectRing:
CollectRing_Sonic:
	cmpi.w	#999,(Rings_Collected).w ; did Sonic collect 999 or more rings?
	bhs.s	CollectRing_1P		; if yes, branch
	addq.w	#1,(Rings_Collected).w	; add 1 to the number of collected rings

CollectRing_1P:
	moveq	#SndID_Ring,d0		; prepare to play the ring sound
	cmpi.w	#999,(Ring_count).w	; does the player 1 have 999 or more rings?
	bhs.s	JmpTo_PlaySound2	; if yes, play the ring sound
	addq.w	#1,(Ring_count).w	; add 1 to the ring count
	ori.b	#1,(Update_HUD_rings).w	; set flag to update the ring counter in the HUD

	cmpi.w	#100,(Ring_count).w	; does the player 1 have less than 100 rings?
	blo.s	JmpTo_PlaySound2	; if yes, play the ring sound
	bset	#1,(Extra_life_flags).w	; test and set the flag for the first extra life
	beq.s	+			; if it was clear before, branch
	cmpi.w	#200,(Ring_count).w	; does the player 1 have less than 200 rings?
	blo.s	JmpTo_PlaySound2	; if yes, play the ring sound
	bset	#2,(Extra_life_flags).w	; test and set the flag for the second extra life
	bne.s	JmpTo_PlaySound2	; if it was set before, play the ring sound
+
	addq.b	#1,(Life_count).w	; add 1 to the life count
	addq.b	#1,(Update_HUD_lives).w	; add 1 to the displayed life count
	moveq	#MusID_ExtraLife,d0	; prepare to play the extra life jingle
	jmp	(PlayMusic).w

JmpTo_PlaySound2 ; JmpTo
	jmp	(PlaySound2).w
; End of function CollectRing

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 37 - Scattering rings (generated when Sonic is hurt and has rings)
; ----------------------------------------------------------------------------
; Sprite_12078:
Obj37:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj37_Index(pc,d0.w),d1
	jmp	Obj37_Index(pc,d1.w)
; ===========================================================================
; Obj_37_subtbl:
Obj37_Index:	offsetTable
		offsetTableEntry.w Obj37_Init		; 0
		offsetTableEntry.w Obj37_Main		; 2
		offsetTableEntry.w Obj37_Collect	; 4
		offsetTableEntry.w Obj37_Sparkle	; 6
		offsetTableEntry.w Obj37_Delete		; 8
; ===========================================================================
; Obj_37_sub_0:
Obj37_Init:
	movea.l	a0,a1
	moveq	#0,d5
	move.w	(Ring_count).w,d5
	moveq	#$20,d0
	cmp.w	d0,d5
	blo.s	+
	move.w	d0,d5
+
	subq.w	#1,d5
	move.w	#$288,d4
	bra.s	+
; ===========================================================================

-	bsr.w	AllocateObject
	bne.w	+++
+
	move.b	#ObjID_LostRings,id(a1) ; load obj37
	addq.b	#2,routine(a1)
	move.b	#8,y_radius(a1)
	move.b	#8,x_radius(a1)
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
	move.l	#Obj25_MapUnc_12382,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_Ring_loss,1,0),art_tile(a1)
	move.b	#1<<render_flags.on_screen|1<<render_flags.level_fg,render_flags(a1)
	move.w	#3*$80,priority(a1)
	move.b	#$47,collision_flags(a1)
	move.b	#8,width_pixels(a1)
	tst.w	d4
	bmi.s	+
	move.w	d4,d0
	jsr	(CalcSine).w
	move.w	d4,d2
	lsr.w	#8,d2
	asl.w	d2,d0
	asl.w	d2,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.b	#$10,d4
	bcc.s	+
	subi.w	#$80,d4
	bcc.s	+
	move.w	#$288,d4
+
	move.w	d2,x_vel(a1)
	move.w	d3,y_vel(a1)
	neg.w	d2
	neg.w	d4
	dbf	d5,-
+
	moveq	#SndID_RingSpill,d0
	jsr	(PlaySound2).w
	move.w	#0,(Ring_count).w
	move.b	#$80,(Update_HUD_rings).w
	move.b	#0,(Extra_life_flags).w
	move.b	#-1,(Ring_spill_anim_counter).w

; Obj_37_sub_2:
Obj37_Main:
	bsr.w	ObjectMove
	addi.w	#$18,y_vel(a0)
	bmi.s	loc_121B8
	move.b	(Vint_runcount+3).w,d0
	add.b	d7,d0
	andi.b	#7,d0
	bne.s	loc_121B8
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.s	loc_121B8
	jsr	(RingCheckFloorDist).l
	tst.w	d1
	bpl.s	loc_121B8
	add.w	d1,y_pos(a0)
	move.w	y_vel(a0),d0
	asr.w	#2,d0
	sub.w	d0,y_vel(a0)
	neg.w	y_vel(a0)

loc_121B8:
	tst.b	(Ring_spill_anim_counter).w
	beq.s	Obj37_Delete
	move.w	(Camera_Max_Y_pos).w,d0
	addi.w	#screen_height,d0
	cmp.w	y_pos(a0),d0
	blo.s	Obj37_Delete
	bra.w	DisplaySprite
; ===========================================================================
; Obj_37_sub_4:
Obj37_Collect:
	addq.b	#2,routine(a0)
	move.b	#0,collision_flags(a0)
	move.w	#1*$80,priority(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Ring_sparkles,1,0),obGfx(a0)
	bsr.w	CollectRing
; Obj_37_sub_6:
Obj37_Sparkle:
	addq.b	#2,routine(a0)

	lea	Ani_Ring(pc),a1
	bsr.w	AnimateSprite
	bra.w	DisplaySprite
; ===========================================================================
; BranchTo5_DeleteObject
Obj37_Delete:
	bra.w	DeleteObject
