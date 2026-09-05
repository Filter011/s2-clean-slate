; ----------------------------------------------------------------------------
; Object 12 - Emerald from Hidden Palace Zone (unused)
; ----------------------------------------------------------------------------
; Sprite_2031C:
Obj12:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj12_Index(pc,d0.w),d1
	jmp	Obj12_Index(pc,d1.w)
; ===========================================================================
; off_2032A
Obj12_Index:	offsetTable
		offsetTableEntry.w Obj12_Init	; 0
		offsetTableEntry.w Obj12_Main	; 2
; ===========================================================================
; loc_2032E:
Obj12_Init:
	addq.b	#2,routine(a0)
	move.l	#Obj12_MapUnc_20382,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_HPZ_Emerald,3,0),art_tile(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.b	#$20,width_pixels(a0)
	move.w	#4*$80,priority(a0)
; loc_20356:
Obj12_Main:
	moveq	#$20,d1
	moveq	#$10,d2
	moveq	#$10,d3
	move.w	x_pos(a0),d4
	bsr.w	SolidObject
	move.w	x_pos(a0),d0
	andi.w	#$FF80,d0
	sub.w	(Camera_X_pos_coarse).w,d0
	cmpi.w	#$280,d0
	bhi.s	JmpTo16_DeleteObject
	jmp	(DisplaySprite).l

JmpTo16_DeleteObject ; JmpTo
	jmp	(DeleteObject).l