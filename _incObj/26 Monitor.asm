; ----------------------------------------------------------------------------
; Object 26 - Monitor
;
; The power-ups themselves are handled by the next object. This just does the
; monitor collision and graphics.
; ----------------------------------------------------------------------------
; Obj_Monitor:
Obj26:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj26_Index(pc,d0.w),d1
	jmp	Obj26_Index(pc,d1.w)
; ===========================================================================
; obj_26_subtbl:
Obj26_Index:	offsetTable
		offsetTableEntry.w Obj26_Init			; 0
		offsetTableEntry.w Obj26_Main			; 2
		offsetTableEntry.w Obj26_Break			; 4
		offsetTableEntry.w Obj26_Animate		; 6
		offsetTableEntry.w BranchTo2_MarkObjGone	; 8
; ===========================================================================
; obj_26_sub_0: Obj_26_Init:
Obj26_Init:
	addq.b	#2,routine(a0)
	move.b	#$E,y_radius(a0)
	move.b	#$E,x_radius(a0)
	move.l	#Obj26_MapUnc_12D36,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Powerups,0,0),art_tile(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.w	#3*$80,priority(a0)
	move.b	#$F,width_pixels(a0)

	lea	(Object_Respawn_Table).w,a2
	moveq	#0,d0
	move.b	respawn_index(a0),d0
	beq.s	+
	bclr	#7,Obj_respawn_data-Object_Respawn_Table(a2,d0.w)
	btst	#0,Obj_respawn_data-Object_Respawn_Table(a2,d0.w)	; if this bit is set it means the monitor is already broken
	beq.s	+
	move.b	#8,routine(a0)	; set monitor to 'broken' state
	move.b	#$B,mapping_frame(a0)
	rts
; ---------------------------------------------------------------------------
+
	move.b	#$46,collision_flags(a0)
	move.b	subtype(a0),anim(a0)	; subtype = icon to display
;obj_26_sub_2:
Obj26_Main:
	move.b	routine_secondary(a0),d0
	beq.s	SolidObject_Monitor
	; only when secondary routine isn't 0
	; make monitor fall
	bsr.w	ObjectMoveAndFall
	jsr	(ObjCheckFloorDist).l
	tst.w	d1			; is monitor in the ground?
	bpl.s	SolidObject_Monitor	; if not, branch
	add.w	d1,y_pos(a0)		; move monitor out of the ground
	clr.w	y_vel(a0)
	clr.b	routine_secondary(a0)	; stop monitor from falling
; loc_1271C:
SolidObject_Monitor:
	moveq	#$1A,d1	; monitor's width
	moveq	#$F,d2
	moveq	#$10,d3
	move.w	x_pos(a0),d4
	lea	(MainCharacter).w,a1 ; a1=character
	moveq	#p1_standing_bit,d6
	movem.l	d1-d4,-(sp)
	bsr.w	SolidObject_Monitor_Sonic
	movem.l	(sp)+,d1-d4

Obj26_Animate:
	lea	Ani_obj26(pc),a1
	bsr.w	AnimateSprite

BranchTo2_MarkObjGone ; BranchTo
	bra.w	MarkObjGone

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; sub_12756:
SolidObject_Monitor_Sonic:
	btst	d6,status(a0)			; is Sonic standing on the monitor?
	bne.s	Obj26_ChkOverEdge		; if yes, branch
	cmpi.b	#AniIDSonAni_Roll,anim(a1)		; is Sonic spinning?
	bne.w	SolidObject_cont		; if not, branch
	rts
; End of function SolidObject_Monitor_Sonic

; ---------------------------------------------------------------------------
; Checks if the player has walked over the edge of the monitor.
; ---------------------------------------------------------------------------
;loc_12782:
Obj26_ChkOverEdge:
	move.w	d1,d2
	add.w	d2,d2
	btst	#status.player.in_air,status(a1)	; is the character in the air?
	bne.s	+		; if yes, branch
	; check, if character is standing on
	move.w	x_pos(a1),d0
	sub.w	x_pos(a0),d0
	add.w	d1,d0
	bmi.s	+	; branch, if character is behind the left edge of the monitor
	cmp.w	d2,d0
	blo.s	Obj26_CharStandOn	; branch, if character is not beyond the right edge of the monitor
+
	; if the character isn't standing on the monitor
	bclr	#status.player.on_object,status(a1)	; clear 'on object' bit
	bset	#status.player.in_air,status(a1)	; set 'in air' bit
	bclr	d6,status(a0)	; clear 'standing on' bit for the current character
	moveq	#0,d4
	rts
; ---------------------------------------------------------------------------
;loc_127B2:
Obj26_CharStandOn:
	move.w	d4,d2
	bsr.w	MvSonicOnPtfm
	moveq	#0,d4
	rts
; ===========================================================================
;obj_26_sub_4:
Obj26_Break:
	move.b	status(a0),d0
	andi.b	#standing_mask|pushing_mask,d0	; is someone touching the monitor?
	beq.s	Obj26_SpawnIcon	; if not, branch
	move.b	d0,d1
	andi.b	#p1_standing|p1_pushing,d1	; is it the main character?
	beq.s	Obj26_SpawnIcon		; if not, branch
	andi.b	#~(1<<status.player.on_object|1<<status.player.pushing),(MainCharacter+status).w
	ori.b	#1<<status.player.in_air,(MainCharacter+status).w	; prevent Sonic from walking in the air

;loc_127EC:
Obj26_SpawnIcon:
	clr.b	status(a0)
	addq.b	#2,routine(a0)
	move.b	#0,collision_flags(a0)
	bsr.w	AllocateObject
	bne.s	Obj26_SpawnSmoke
	move.b	#ObjID_MonitorContents,id(a1) ; load obj2E
	move.w	x_pos(a0),x_pos(a1)	; set icon's position
	move.w	y_pos(a0),y_pos(a1)
	move.b	anim(a0),anim(a1)
	move.w	parent(a0),parent(a1)	; parent gets the item
;loc_1281E:
Obj26_SpawnSmoke:
	bsr.w	AllocateObject
	bne.s	+
	move.b	#ObjID_Explosion,id(a1) ; load obj27
	addq.b	#2,routine(a1)
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
+
	lea	(Object_Respawn_Table).w,a2
	moveq	#0,d0
	move.b	respawn_index(a0),d0
	beq.s	+
	bset	#0,Obj_respawn_data-Object_Respawn_Table(a2,d0.w)	; mark monitor as destroyed
+
	move.b	#$A,anim(a0)
	bra.w	DisplaySprite
