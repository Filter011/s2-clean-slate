; ---------------------------------------------------------------------------
; Subroutine to move the water or oil surface sprites to where the screen is at
; (the closest match I could find to this subroutine in Sonic 1 is Obj1B_Action)
; ---------------------------------------------------------------------------

; sub_44E4:
UpdateWaterSurface:
	tst.b	(Water_flag).w
	beq.s	++	; rts
	move.w	(Camera_X_pos).w,d1
	move.b	(Ctrl_1_Press).w,d0 ; is Start button pressed?
	andi.b	#button_start_mask,d0
	bne.s	+
	btst	#0,(Level_frame_counter+1).w
	beq.s	+
	addi.w	#$20,d1
+		; match obj x-position to screen position
	move.w	d1,d0
	addi.w	#$60,d0
	move.w	d0,(WaterSurface1+x_pos).w
	addi.w	#$120,d1
	move.w	d1,(WaterSurface2+x_pos).w
+
	rts
; End of function UpdateWaterSurface


; ---------------------------------------------------------------------------
; Subroutine to do special water effects
; ---------------------------------------------------------------------------
; sub_450E: ; LZWaterEffects:
WaterEffects:
	tst.b	(Water_flag).w	; does level have water?
	beq.s	NonWaterEffects	; if not, branch
	tst.b	(Deform_lock).w
	bne.s	MoveWater
	cmpi.b	#6,(MainCharacter+routine).w	; is player dead?
	bhs.s	MoveWater			; if yes, branch
	bsr.w	DynamicWater
; loc_4526: ; LZMoveWater:
MoveWater:
	clr.b	(Water_fullscreen_flag).w
	moveq	#0,d0
	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w	; is level ARZ?
	beq.s	+		; if yes, branch
	move.b	(Oscillating_Data).w,d0
	lsr.w	#1,d0
+
	add.w	(Water_Level_2).w,d0
	move.w	d0,(Water_Level_1).w
		; calculate distance between water surface and top of screen
	move.w	(Water_Level_1).w,d0
	sub.w	(Camera_Y_pos).w,d0
	bhs.s	+
	tst.w	d0
	bpl.s	+
	move.b	#screen_height-1,(Hint_counter_reserve+1).w	; H-INT every 224th scanline
	move.b	#1,(Water_fullscreen_flag).w
+
	cmpi.w	#screen_height-1,d0
	blo.s	+
	move.w	#screen_height-1,d0
+
	move.b	d0,(Hint_counter_reserve+1).w	; H-INT every d0 scanlines
; loc_456A:
NonWaterEffects:
	cmpi.b	#oil_ocean_zone,(Current_Zone).w	; is the level OOZ?
	bne.s	+			; if not, branch
	bsr.w	OilSlides		; call oil slide routine
+
	cmpi.b	#wing_fortress_zone,(Current_Zone).w	; is the level WFZ?
	bne.s	+			; if not, branch
	bra.w	WindTunnel		; call wind and block break routine
+
	rts
; End of function WaterEffects

; ===========================================================================
WaterHeight: zoneOrderedTable 2,2
	zoneTableEntry.w  $600, $600	; EHZ
	zoneTableEntry.w  $600, $600	; Zone 1
	zoneTableEntry.w  $600, $600	; WZ
	zoneTableEntry.w  $600, $600	; Zone 3
	zoneTableEntry.w  $600, $600	; MTZ1,2
	zoneTableEntry.w  $600, $600	; MTZ3
	zoneTableEntry.w  $600, $600	; WFZ
	zoneTableEntry.w  $600, $600	; HTZ
	zoneTableEntry.w  $600, $600	; HPZ
	zoneTableEntry.w  $600, $600	; Zone 9
	zoneTableEntry.w  $600, $600	; OOZ
	zoneTableEntry.w  $600, $600	; MCZ
	zoneTableEntry.w  $600, $600	; CNZ
	zoneTableEntry.w  $600, $710	; CPZ
	zoneTableEntry.w  $600, $600	; DEZ
	zoneTableEntry.w  $410, $510	; ARZ
	zoneTableEntry.w  $600, $600	; SCZ
    zoneTableEnd

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_45A4: ; LZDynamicWater:
DynamicWater:
	move.w	(Current_ZoneAndAct).w,d0
	ror.b	#1,d0
	lsr.w	#5,d0
	movea.l	Dynamic_water_routine_table(pc,d0.w),a0
	jsr	(a0)
	moveq	#0,d1
	move.b	(Water_on).w,d1
	move.w	(Water_Level_3).w,d0
	sub.w	(Water_Level_2).w,d0
	beq.s	++	; rts
	bcc.s	+
	neg.w	d1
+
	add.w	d1,(Water_Level_2).w
+
	rts
; End of function DynamicWater

; ===========================================================================
Dynamic_water_routine_table: zoneOrderedOffsetTable 4,2
	; EHZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; Zone 1
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; WZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; Zone 3
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; MTZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; MTZ
	zoneTableEntry.l DynamicWaterNull ; Act 3
	zoneTableEntry.l DynamicWaterNull ; Act 4
	; WFZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; HTZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; HPZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; Zone 9
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; OOZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; MCZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; CNZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; CPZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterCPZ2 ; Act 2
	; DEZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; ARZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
	; SCZ
	zoneTableEntry.l DynamicWaterNull ; Act 1
	zoneTableEntry.l DynamicWaterNull ; Act 2
    zoneTableEnd
; ===========================================================================
; return_45F8:
DynamicWaterNull:
	rts
; ===========================================================================
; loc_45FA:
DynamicWaterCPZ2:
	cmpi.w	#$1DE0,(Camera_X_pos).w
	blo.s	+	; rts
	move.w	#$510,(Water_Level_3).w
+	rts
