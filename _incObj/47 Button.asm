; ----------------------------------------------------------------------------
; Object 47 - Button
; ----------------------------------------------------------------------------
; Sprite_24CF4:
Obj47:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj47_Index(pc,d0.w),d1
	jmp	Obj47_Index(pc,d1.w)
; ===========================================================================
; off_24D02:
Obj47_Index:	offsetTable
		offsetTableEntry.w Obj47_Init	; 0
		offsetTableEntry.w Obj47_Main	; 2
; ===========================================================================
; loc_24D06:
Obj47_Init:
	addq.b	#2,routine(a0)
	move.l	#Obj47_MapUnc_24D96,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Button,0,0),art_tile(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.b	#$10,width_pixels(a0)
	move.w	#4*$80,priority(a0)
	addq.w	#4,y_pos(a0)
; loc_24D32:
Obj47_Main:
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.s	BranchTo_JmpTo12_MarkObjGone
	moveq	#$1B,d1
	moveq	#4,d2
	moveq	#5,d3
	move.w	x_pos(a0),d4
	jsr	(SolidObject).l
	move.b	#0,mapping_frame(a0)
	move.b	subtype(a0),d0
	andi.w	#$F,d0
	lea	(ButtonVine_Trigger).w,a3
	lea	(a3,d0.w),a3
	moveq	#0,d3
	btst	#6,subtype(a0)
	beq.s	+
	moveq	#7,d3
+
	move.b	status(a0),d0
	andi.b	#standing_mask,d0
	bne.s	+
	bclr	d3,(a3)
	bra.s	BranchTo_JmpTo12_MarkObjGone
; ===========================================================================
+
	tst.b	(a3)
	bne.s	+
	moveq	#SndID_Blip,d0
	jsr	(PlaySound).w
+
	bset	d3,(a3)
	move.b	#1,mapping_frame(a0)

BranchTo_JmpTo12_MarkObjGone ; BranchTo
	jmp	(MarkObjGone).l
