; ----------------------------------------------------------------------------
; Object 2E - Monitor contents (code for power-up behavior and rising image)
; ----------------------------------------------------------------------------

Obj2E:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj2E_Index(pc,d0.w),d1
	jmp	Obj2E_Index(pc,d1.w)
; ===========================================================================
; off_12862:
Obj2E_Index:	offsetTable
		offsetTableEntry.w Obj2E_Init	; 0
		offsetTableEntry.w Obj2E_Raise	; 2
		offsetTableEntry.w Obj2E_Wait	; 4
; ===========================================================================
; Object initialization. Called if routine counter == 0.
; loc_12868:
Obj2E_Init:
	addq.b	#2,routine(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Powerups,0,1),art_tile(a0)
	move.b	#1<<render_flags.static_mappings|1<<render_flags.level_fg,render_flags(a0)
	move.w	#3*$80,priority(a0)
	move.b	#8,width_pixels(a0)
	move.w	#-$300,y_vel(a0)
	moveq	#0,d0
	move.b	anim(a0),d0

loc_128C6:			; Determine correct mappings offset.
	addq.b	#1,d0
	move.b	d0,mapping_frame(a0)
	movea.l	#Obj26_MapUnc_12D36,a1
	add.b	d0,d0
	adda.w	(a1,d0.w),a1
	addq.w	#2,a1
	move.l	a1,mappings(a0)
; loc_128DE:
Obj2E_Raise:
	bsr.s	+
	bra.w	DisplaySprite

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

+
	tst.w	y_vel(a0)	; is icon still floating up?
	bpl.s	+		; if not, branch
	addi.w	#$18,y_vel(a0)	; reduce upward speed
	bra.w	ObjectMove	; update position
; ---------------------------------------------------------------------------

+
	addq.b	#2,routine(a0)
	move.w	#$1D,anim_frame_duration(a0)
	movea.w	parent(a0),a1 ; a1=character
	lea	(Monitors_Broken).w,a2
	moveq	#0,d0
	move.b	anim(a0),d0
	add.w	d0,d0
	move.w	Obj2E_Types(pc,d0.w),d0
	jmp	Obj2E_Types(pc,d0.w)
; End of function

; ===========================================================================
Obj2E_Types:	offsetTable
		offsetTableEntry.w robotnik_monitor	; 0 - Static
		offsetTableEntry.w sonic_1up		; 1 - Sonic 1-up
		offsetTableEntry.w sonic_1up		; 2 - Tails 1-up
		offsetTableEntry.w robotnik_monitor	; 3 - Robotnik
		offsetTableEntry.w super_ring		; 4 - Super Ring
		offsetTableEntry.w super_shoes		; 5 - Speed Shoes
		offsetTableEntry.w shield_monitor	; 6 - Shield
		offsetTableEntry.w invincible_monitor	; 7 - Invincibility
		offsetTableEntry.w teleport_monitor	; 8 - Teleport
		offsetTableEntry.w qmark_monitor	; 9 - Question mark
; ===========================================================================
; ---------------------------------------------------------------------------
; Robotnik Monitor
; hurts the player
; ---------------------------------------------------------------------------
; badnik_monitor:
robotnik_monitor:
	addq.w	#1,(a2)
	bra.w	Touch_ChkHurt2
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic 1up Monitor
; gives Sonic an extra life, or Tails in a 'Tails alone' game
; ---------------------------------------------------------------------------
sonic_1up:
	addq.w	#1,(Monitors_Broken).w
	addq.b	#1,(Life_count).w
	addq.b	#1,(Update_HUD_lives).w
	moveq	#MusID_ExtraLife,d0
	jmp	(PlayMusic).w	; Play extra life music
; ===========================================================================
; ---------------------------------------------------------------------------
; Super Ring Monitor
; gives the player 10 rings
; ---------------------------------------------------------------------------
super_ring:
	addq.w	#1,(a2)

	lea	(Ring_count).w,a2
	lea	(Update_HUD_rings).w,a3
	lea	(Extra_life_flags).w,a4
	lea	(Rings_Collected).w,a5
+
	addi.w	#10,(a5)
	cmpi.w	#999,(a5)
	blo.s	+
	move.w	#999,(a5)

+	; give player 10 rings and max out at 999
	addi.w	#10,(a2)
	cmpi.w	#999,(a2)
	blo.s	+
	move.w	#999,(a2)

+
	ori.b	#1,(a3)
	cmpi.w	#100,(a2)
	blo.s	+		; branch, if player has less than 100 rings
	bset	#1,(a4)		; set flag for first 1up
	beq.w	sonic_1up	; branch, if not yet set
	cmpi.w	#200,(a2)
	blo.s	+		; branch, if player has less than 200 rings
	bset	#2,(a4)		; set flag for second 1up
	beq.w	sonic_1up	; branch, if not yet set
+
	moveq	#SndID_Ring,d0
	jmp	(PlaySound).w
; ===========================================================================
; ---------------------------------------------------------------------------
; Super Sneakers Monitor
; speeds the player up temporarily
; ---------------------------------------------------------------------------
super_shoes:
	addq.w	#1,(a2)
	bset	#status_secondary.speed_shoes,status_secondary(a1)	; give super sneakers status
	move.w	#$4B0,speedshoes_time(a1)
	tst.w	(Player_mode).w	; is player using Tails?
	bne.s	super_shoes_Tails	; if yes, branch
	move.w	#$C00,(Sonic_top_speed).w	; set stats
	move.w	#$18,(Sonic_acceleration).w
	move.w	#$80,(Sonic_deceleration).w
	bra.s	+
; ---------------------------------------------------------------------------
;loc_12A10:
super_shoes_Tails:
	move.w	#$C00,(Tails_top_speed).w
	move.w	#$18,(Tails_acceleration).w
	move.w	#$80,(Tails_deceleration).w
+
	move.w	#MusID_SpeedUp,d0
	jmp	(PlayMusic).w	; Speed up tempo
; ===========================================================================
; ---------------------------------------------------------------------------
; Shield Monitor
; gives the player a shield that absorbs one hit
; ---------------------------------------------------------------------------
shield_monitor:
	addq.w	#1,(a2)
	bset	#status_secondary.shield,status_secondary(a1)	; give shield status
	moveq	#SndID_Shield,d0
	jsr	(PlaySound).w
	move.b	#ObjID_Shield,(Sonic_Shield+id).w ; load Obj38 (shield) at $FFFFD180
	move.w	a1,(Sonic_Shield+parent).w
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Invincibility Monitor
; makes the player temporarily invincible
; ---------------------------------------------------------------------------
invincible_monitor:
	addq.w	#1,(a2)
	tst.b	(Super_Sonic_flag).w	; is Sonic super?
	bne.s	++	; rts		; if yes, branch
	bset	#status_secondary.invincible,status_secondary(a1)	; give invincibility status
	move.w	#20*60,invincibility_time(a1) ; 20 seconds
	tst.b	(Current_Boss_ID).w	; don't change music during boss battles
	bne.s	+
	cmpi.b	#12,air_left(a1)	; or when drowning
	bls.s	+
	moveq	#MusID_Invincible,d0
	jsr	(PlayMusic).w
+
	move.b	#ObjID_InvStars,(Sonic_InvincibilityStars+id).w ; load Obj35 (invincibility stars) at $FFFFD200
	move.w	a1,(Sonic_InvincibilityStars+parent).w
+
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Teleport Monitor
; swaps both players around
; ---------------------------------------------------------------------------
;loc_12AA6:
teleport_monitor:
	addq.w	#1,(a2)
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; '?' Monitor
; doesn't actually do anything other than increase the player's monitor score
; ---------------------------------------------------------------------------
qmark_monitor:
	addq.w	#1,(a2)
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Holds icon in place for a while, then destroys it
; ---------------------------------------------------------------------------
;loc_12CC2:
Obj2E_Wait:
	subq.w	#1,anim_frame_duration(a0)
	bmi.w	DeleteObject
	bra.w	DisplaySprite
