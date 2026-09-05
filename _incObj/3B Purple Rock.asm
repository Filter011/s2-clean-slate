; ----------------------------------------------------------------------------
; Object 3B - Purple rock (leftover from S1)
; ----------------------------------------------------------------------------
; Sprite_15CC8:
Obj3B:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj3B_Index(pc,d0.w),d1
	jmp	Obj3B_Index(pc,d1.w)
; ===========================================================================
; off_15CD6:
Obj3B_Index:	offsetTable
		offsetTableEntry.w Obj3B_Init	; 0
		offsetTableEntry.w Obj3B_Main	; 2
; ===========================================================================
; loc_15CDA:
Obj3B_Init:
	addq.b	#2,routine(a0)
	move.l	#Obj3B_MapUnc_15D2E,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_GHZ_Purple_Rock,3,0),art_tile(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.b	#$13,width_pixels(a0)
	move.w	#4*$80,priority(a0)
; loc_15D02:
Obj3B_Main:
	moveq	#$1B,d1
	moveq	#$10,d2
	moveq	#$10,d3
	move.w	x_pos(a0),d4
	bsr.w	SolidObject
	move.w	x_pos(a0),d0
	andi.w	#$FF80,d0
	sub.w	(Camera_X_pos_coarse).w,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	bra.w	DisplaySprite
