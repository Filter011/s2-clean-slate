; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

;sub_C258:
InitCameraValues:
	tst.b	(Last_star_pole_hit).w	; was a star pole hit yet?
	bne.s	+			; if yes, branch
	move.w	d0,(Camera_BG_Y_pos).w
	move.w	d0,(Camera_BG2_Y_pos).w
	move.w	d0,(Camera_BG3_Y_pos).w
	move.w	d1,(Camera_BG_X_pos).w
	move.w	d1,(Camera_BG2_X_pos).w
	move.w	d1,(Camera_BG3_X_pos).w
+
	move.w	(Current_ZoneAndAct).w,d2
	ror.b	#1,d2
	lsr.w	#5,d2
	movea.l	InitCam_Index(pc,d2.w),a0
	jmp	(a0)
; End of function InitCameraValues

; ===========================================================================
; off_C296:
InitCam_Index: zoneOrderedOffsetTable 4,2
	zoneTableEntry.l InitCam_EHZ_HTZ	; EHZ1
	zoneTableEntry.l InitCam_EHZ_HTZ	; EHZ2
	zoneTableEntry.l InitCam_Null	; Zone 1 Act 1
	zoneTableEntry.l InitCam_Null	; Zone 1 Act 2
	zoneTableEntry.l InitCam_Null	; WZ1
	zoneTableEntry.l InitCam_Null	; WZ2
	zoneTableEntry.l InitCam_Null	; Zone 3 Act 1
	zoneTableEntry.l InitCam_Null	; Zone 3 Act 2
	zoneTableEntry.l InitCam_Std	; MTZ1
	zoneTableEntry.l InitCam_Std	; MTZ2
	zoneTableEntry.l InitCam_Std	; MTZ3
	zoneTableEntry.l InitCam_Std	; MTZ4
	zoneTableEntry.l InitCam_Null	; WFZ1
	zoneTableEntry.l InitCam_Null	; WFZ2
	zoneTableEntry.l InitCam_EHZ_HTZ	; HTZ1
	zoneTableEntry.l InitCam_EHZ_HTZ	; HTZ2
	zoneTableEntry.l InitCam_HPZ	; HPZ1
	zoneTableEntry.l InitCam_HPZ	; HPZ2
	zoneTableEntry.l InitCam_Null	; Zone 9 Act 1
	zoneTableEntry.l InitCam_Null	; Zone 9 Act 2
	zoneTableEntry.l InitCam_OOZ	; OOZ1
	zoneTableEntry.l InitCam_OOZ	; OOZ2
	zoneTableEntry.l InitCam_MCZ	; MCZ1
	zoneTableEntry.l InitCam_MCZ	; MCZ2
	zoneTableEntry.l InitCam_CNZ	; CNZ1
	zoneTableEntry.l InitCam_CNZ	; CNZ2
	zoneTableEntry.l InitCam_CPZ	; CPZ1
	zoneTableEntry.l InitCam_CPZ	; CPZ2
	zoneTableEntry.l InitCam_Null	; DEZ1
	zoneTableEntry.l InitCam_Null	; DEZ2
	zoneTableEntry.l InitCam_ARZ	; ARZ1
	zoneTableEntry.l InitCam_ARZ	; ARZ2
	zoneTableEntry.l InitCam_SCZ	; SCZ1
	zoneTableEntry.l InitCam_SCZ	; SCZ2
    zoneTableEnd
; ===========================================================================
;loc_C2B8:
InitCam_EHZ_HTZ:
	moveq	#0,d2
	move.l	d2,(Camera_BG_X_pos).w
	move.l	d2,(Camera_BG_Y_pos).w
	move.l	d2,(Camera_BG2_Y_pos).w
	move.l	d2,(Camera_BG3_Y_pos).w
	lea	(TempArray_LayerDef).w,a2
	move.l	d2,(a2)+
	move.l	d2,(a2)+
	move.l	d2,(a2)+

InitCam_Null:
	rts
; ===========================================================================
;loc_C2E4:
InitCam_Std:
	asr.w	#2,d0
	move.w	d0,(Camera_BG_Y_pos).w
	asr.w	#3,d1
	move.w	d1,(Camera_BG_X_pos).w
	rts
; ===========================================================================
; Hidden_Palace_Zone_BG:
InitCam_HPZ:
	asr.w	#1,d0
	move.w	d0,(Camera_BG_Y_pos).w
	moveq	#0,d2
	move.l	d2,(Camera_BG_X_pos).w
	rts
; ===========================================================================
;loc_C322:
InitCam_OOZ:
	lsr.w	#3,d0
	addi.w	#$50,d0
	move.w	d0,(Camera_BG_Y_pos).w
	moveq	#0,d2
	move.l	d2,(Camera_BG_X_pos).w
	rts
; ===========================================================================
;loc_C332:
InitCam_MCZ:
	moveq	#0,d2
	move.l	d2,(Camera_BG_X_pos).w
	tst.b	(Current_Act).w
	bne.s	+
	divu.w	#3,d0
	subi.w	#$140,d0
	move.w	d0,(Camera_BG_Y_pos).w
	rts
; ===========================================================================
+
	divu.w	#6,d0
	subi.w	#$10,d0
	move.w	d0,(Camera_BG_Y_pos).w
	rts
; ===========================================================================
;loc_C364:
InitCam_CNZ:
InitCam_SCZ:
	moveq	#0,d2
	move.l	d2,(Camera_BG_X_pos).w
	move.l	d2,(Camera_BG_Y_pos).w
	rts
; ===========================================================================
;loc_C372:
InitCam_CPZ:
	lsr.w	#2,d0
	move.w	d0,(Camera_BG_Y_pos).w
	lsr.w	#1,d1
	move.w	d1,(Camera_BG2_X_pos).w
	lsr.w	#2,d1
	move.w	d1,(Camera_BG_X_pos).w
	rts
; ===========================================================================
;loc_C38C:
InitCam_ARZ:
	tst.b	(Current_Act).w
	beq.s	+
	subi.w	#$E0,d0
	lsr.w	#1,d0
	move.w	d0,(Camera_BG_Y_pos).w
	bra.s	loc_C3A6
; ===========================================================================
+
	subi.w	#$180,d0
	move.w	d0,(Camera_BG_Y_pos).w

loc_C3A6:
	muls.w	#$119,d1
	asr.l	#8,d1
	move.w	d1,(Camera_BG_X_pos).w
	move.w	d1,(Camera_ARZ_BG_X_pos).w
	moveq	#0,d2
	move.w	d2,(Camera_BG_X_pos+2).w
	move.w	d2,(Camera_ARZ_BG_X_pos+2).w
	move.l	d2,(Camera_BG2_Y_pos).w
	move.l	d2,(Camera_BG3_Y_pos).w
	rts