; ----------------------------------------------------------------------------
; Object BE - Lateral cannon (temporary platform that pops in/out) from WFZ
; ----------------------------------------------------------------------------
; Sprite_3BD7A:
ObjBE:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	ObjBE_Index(pc,d0.w),d1
	jmp	ObjBE_Index(pc,d1.w)
; ===========================================================================
; off_3BD88:
ObjBE_Index:	offsetTable
		offsetTableEntry.w ObjBE_Init	;  0
		offsetTableEntry.w loc_3BDA2	;  2
		offsetTableEntry.w loc_3BDC6	;  4
		offsetTableEntry.w loc_3BDD4	;  6
		offsetTableEntry.w loc_3BDC6	;  8
		offsetTableEntry.w loc_3BDF4	; $A
; ===========================================================================
; loc_3BD94:
ObjBE_Init:
	moveq	#0,d0
	move.b	#($41<<1),d0
	bsr.w	LoadSubObject_Part2
	bra.w	loc_3B77E
; ===========================================================================

loc_3BDA2:
	move.b	(Vint_runcount+3).w,d0
	andi.b	#$F0,d0
	cmp.b	subtype(a0),d0
	beq.s	+
	jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
+
	addq.b	#2,routine(a0)
	clr.b	anim(a0)
	move.w	#$A0,objoff_2A(a0)
	jmp	(MarkObjGone).l
; ===========================================================================

loc_3BDC6:
	lea	Ani_objBE(pc),a1
	jsr	(AnimateSprite).l
	jmp	(MarkObjGone).l
; ===========================================================================

loc_3BDD4:
	subq.w	#1,objoff_2A(a0)
	beq.s	+
	bsr.s	loc_3BE04
	jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
+
	addq.b	#2,routine(a0)
	move.b	#1,anim(a0)
	bsr.w	loc_3B7BC
	jmp	(MarkObjGone).l
; ===========================================================================

loc_3BDF4:
	move.b	#2,routine(a0)
	move.w	#$40,objoff_2A(a0)
	jmp	(MarkObjGone).l
; ===========================================================================

loc_3BE04:
	move.b	mapping_frame(a0),d0
	cmpi.b	#3,d0
	beq.s	+
	cmpi.b	#4,d0
	bne.w	loc_3B7BC
+
	move.w	x_pos(a0),-(sp)
	moveq	#$23,d1
	moveq	#$18,d2
	moveq	#$19,d3
	move.w	(sp)+,d4
	jmp	(PlatformObject).l
; ===========================================================================
; off_3BE2C:
ObjBE_SubObjData:
	subObjData ObjBE_MapUnc_3BE46,make_art_tile(ArtTile_ArtNem_WfzGunPlatform,3,1),1<<render_flags.level_fg,4,$18,0
