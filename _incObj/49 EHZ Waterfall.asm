; ----------------------------------------------------------------------------
; Object 49 - Waterfall from EHZ
; ----------------------------------------------------------------------------
; Sprite_20B9E:
Obj49:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj49_Index(pc,d0.w),d1
	jmp	Obj49_Index(pc,d1.w)
; ===========================================================================
; off_20BAC:
Obj49_Index:	offsetTable
		offsetTableEntry.w Obj49_Init	; 0
		offsetTableEntry.w Obj49_ChkDel	; 2
; ===========================================================================
; loc_20BB0: Obj49_Main:
Obj49_Init:
	addq.b	#2,routine(a0)
	move.l	#Obj49_MapUnc_20C50,mappings(a0)
	move.w	#ArtTile_ArtNem_Waterfall|palette_line_1,art_tile(a0)
	move.b	#1<<render_flags.level_fg|1<<render_flags.explicit_height,render_flags(a0)
	move.b	#$20,width_pixels(a0)
	move.w	#0,priority(a0)
	move.b	#$80,y_radius(a0)
; loc_20BEA:
Obj49_ChkDel:
	moveq	#-$80,d0
	and.w	x_pos(a0),d0
	sub.w	(Camera_X_pos_coarse).w,d0
	cmpi.w	#$280,d0
	bhi.w	JmpTo18_DeleteObject
	move.w	x_pos(a0),d1
	move.w	d1,d2
	moveq	#$40,d3
	sub.w	d3,d1
	add.w	d3,d2
	move.b	subtype(a0),d4
	clr.b	mapping_frame(a0)
	move.w	(MainCharacter+x_pos).w,d0
	cmp.w	d1,d0
	blo.s	loc_20C36
	cmp.w	d2,d0
	bhs.s	loc_20C36
	move.b	#1,mapping_frame(a0)

loc_20C36:
	add.b	d4,mapping_frame(a0)
	jmp	(DisplaySprite).l