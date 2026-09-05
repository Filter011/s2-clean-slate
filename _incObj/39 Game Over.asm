; ----------------------------------------------------------------------------
; Object 39 - Game/Time Over text
; ----------------------------------------------------------------------------
; Sprite_13F74:
Obj39: ; (screen-space obj)
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj39_Index(pc,d0.w),d1
	jmp	Obj39_Index(pc,d1.w)
; ===========================================================================
Obj39_Index:	offsetTable
		offsetTableEntry.w Obj39_Init		; 0
		offsetTableEntry.w Obj39_SlideIn	; 2
		offsetTableEntry.w Obj39_Wait		; 4
; ===========================================================================
; loc_13F88:
Obj39_Init:
	tst.w	(KosPlus_modules_left).w
	beq.s	+
	rts		; wait until the art is loaded
; ---------------------------------------------------------------------------
+
	addq.b	#2,routine(a0)
	move.w	#spriteScreenPositionX(-48),x_pixel(a0)
	btst	#0,mapping_frame(a0)
	beq.s	+
	move.w	#spriteScreenPositionX(screen_width+48),x_pixel(a0)
+
	move.w	#spriteScreenPositionYCentered(0),y_pixel(a0)
	move.l	#Obj39_MapUnc_14C6C,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Game_Over,0,1),art_tile(a0)
	move.b	#0,render_flags(a0)
	move.w	#0,priority(a0)
; loc_13FCC:
Obj39_SlideIn:
	moveq	#16,d1
	cmpi.w	#spriteScreenPositionXCentered(0),x_pixel(a0)
	beq.s	Obj39_SetTimer
	blo.s	+
	neg.w	d1
+
	add.w	d1,x_pixel(a0)
	bra.w	DisplaySprite
; ===========================================================================
; loc_13FE2:
Obj39_SetTimer:
	move.w	#$2D0,anim_frame_duration(a0)
	addq.b	#2,routine(a0)
	bra.w	DisplaySprite
; ===========================================================================
; loc_13FEE:
Obj39_Wait:
	btst	#0,mapping_frame(a0)
	bne.s	Obj39_Display
	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	bne.s	Obj39_Dismiss
	tst.w	anim_frame_duration(a0)
	beq.s	Obj39_Dismiss
	subq.w	#1,anim_frame_duration(a0)
	bra.w	DisplaySprite
; ===========================================================================
; loc_14014:
Obj39_Dismiss:
	tst.b	(Time_Over_flag).w
	bne.s	Obj39_TimeOver
	move.b	#GameModeID_SegaScreen,(Game_Mode).w ; => SegaScreen
	bra.s	Obj39_Check2PMode
; ===========================================================================
; loc_14034:
Obj39_TimeOver:
	clr.l	(Saved_Timer).w
	move.w	#1,(Level_Inactive_flag).w
; loc_1403E:
Obj39_Check2PMode:
; BranchTo17_DisplaySprite
Obj39_Display:
	bra.w	DisplaySprite
