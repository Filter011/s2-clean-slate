; ---------------------------------------------------------------------------
; Subroutine to fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_23C6: Pal_FadeTo:
Pal_FadeFromBlack:
	move.w	#$3F,(Palette_fade_range).w
	moveq	#0,d0
	lea	(Normal_palette).w,a0
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0
	moveq	#0,d1
	move.b	(Palette_fade_length).w,d0
; loc_23DE: Pal_ToBlack:
.palettewrite:
	move.w	d1,(a0)+
	dbf	d0,.palettewrite	; fill palette with $000 (black)

	moveq	#$15,d4

.nextframe:
	move.w	d4,-(sp)
	move.b	#VintID_Fade,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	bsr.s	.UpdateAllColours
	move.w	(sp)+,d4
	dbf	d4,.nextframe

	rts
; End of function Pal_FadeFromBlack

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------
; sub_23FE: Pal_FadeIn:
.UpdateAllColours:
	; Update above-water palette
	moveq	#0,d0
	lea	(Normal_palette).w,a0
	lea	(Target_palette).w,a1
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0
	adda.w	d0,a1

	move.b	(Palette_fade_length).w,d0

.nextcolour:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour

	tst.b	(Water_flag).w
	beq.s	.skipunderwater
	; Update underwater palette
	moveq	#0,d0
	lea	(Underwater_palette).w,a0
	lea	(Underwater_target_palette).w,a1
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0
	adda.w	d0,a1

	move.b	(Palette_fade_length).w,d0

.nextcolour2:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour2

.skipunderwater:
	rts

; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------
; sub_243E: Pal_AddColor:
.UpdateColour:
	move.w	(a1)+,d2
	move.w	(a0),d3
	cmp.w	d2,d3
	beq.s	.updatenone

;.updateblue:
	move.w	d3,d1
	addi.w	#$200,d1	; increase blue value
	cmp.w	d2,d1		; has blue reached threshold level?
	bhi.s	.updategreen	; if yes, branch
	move.w	d1,(a0)+	; update palette
	rts

; loc_2454: Pal_AddGreen:
.updategreen:
	move.w	d3,d1
	addi.w	#$20,d1		; increase green value
	cmp.w	d2,d1
	bhi.s	.updatered
	move.w	d1,(a0)+	; update palette
	rts

; loc_2462: Pal_AddRed:
.updatered:
	addq.w	#2,(a0)+	; increase red value
	rts

; loc_2466: Pal_AddNone:
.updatenone:
	addq.w	#2,a0
	rts


; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_246A: Pal_FadeFrom:
Pal_FadeToBlack:
	move.w	#$3F,(Palette_fade_range).w

	moveq	#$15,d4

.nextframe:
	move.w	d4,-(sp)
	move.b	#VintID_Fade,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	bsr.s	.UpdateAllColours
	move.w	(sp)+,d4
	dbf	d4,.nextframe

	rts
; End of function Pal_FadeToBlack

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------
; sub_248A: Pal_FadeOut:
.UpdateAllColours:
	; Update above-water palette
	moveq	#0,d0
	lea	(Normal_palette).w,a0
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0

	move.b	(Palette_fade_length).w,d0
.nextcolour:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour

	; Notice how this one lacks a check for
	; if Water_flag is set, unlike Pal_FadeFromBlack?

	; Update underwater palette
	moveq	#0,d0
	lea	(Underwater_palette).w,a0
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0

	move.b	(Palette_fade_length).w,d0
.nextcolour2:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour2

	rts

; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------
; sub_24B8: Pal_DecColor:
.UpdateColour:
	move.w	(a0),d2
	beq.s	.updatenone
;.updatered:
	move.w	d2,d1
	andi.w	#$E,d1
	beq.s	.updategreen
	subq.w	#2,(a0)+	; decrease red value
	rts

; loc_24C8: Pal_DecGreen:
.updategreen:
	move.w	d2,d1
	andi.w	#$E0,d1
	beq.s	.updateblue
	subi.w	#$20,(a0)+	; decrease green value
	rts

; loc_24D6: Pal_DecBlue:
.updateblue:
	move.w	d2,d1
	andi.w	#$E00,d1
	beq.s	.updatenone
	subi.w	#$200,(a0)+	; decrease blue value
	rts

; loc_24E4: Pal_DecNone:
.updatenone:
	addq.w	#2,a0
	rts


; ---------------------------------------------------------------------------
; Subroutine to fade in from white
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_24E8: Pal_MakeWhite:
Pal_FadeFromWhite:
	move.w	#$3F,(Palette_fade_range).w
	moveq	#0,d0
	lea	(Normal_palette).w,a0
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0
	move.w	#$EEE,d1

	move.b	(Palette_fade_length).w,d0

.palettewrite:
	move.w	d1,(a0)+
	dbf	d0,.palettewrite

	moveq	#$15,d4

.nextframe:
	move.w	d4,-(sp)
	move.b	#VintID_Fade,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	bsr.s	.UpdateAllColours
	move.w	(sp)+,d4
	dbf	d4,.nextframe

	rts
; End of function Pal_FadeFromWhite

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------
; sub_2522: Pal_WhiteToBlack:
.UpdateAllColours:
	; Update above-water palette
	moveq	#0,d0
	lea	(Normal_palette).w,a0
	lea	(Target_palette).w,a1
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0
	adda.w	d0,a1

	move.b	(Palette_fade_length).w,d0

.nextcolour:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour

	tst.b	(Water_flag).w
	beq.s	.skipunderwater
	; Update underwater palette
	moveq	#0,d0
	lea	(Underwater_palette).w,a0
	lea	(Underwater_target_palette).w,a1
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0
	adda.w	d0,a1

	move.b	(Palette_fade_length).w,d0

.nextcolour2:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour2

.skipunderwater:
	rts

; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------
; sub_2562: Pal_DecColor2:
.UpdateColour:
	move.w	(a1)+,d2
	move.w	(a0),d3
	cmp.w	d2,d3
	beq.s	.updatenone
;.updateblue:
	move.w	d3,d1
	subi.w	#$200,d1	; decrease blue value
	bcs.s	.updategreen
	cmp.w	d2,d1
	blo.s	.updategreen
	move.w	d1,(a0)+
	rts

; loc_257A: Pal_DecGreen2:
.updategreen:
	move.w	d3,d1
	subi.w	#$20,d1	; decrease green value
	bcs.s	.updatered
	cmp.w	d2,d1
	blo.s	.updatered
	move.w	d1,(a0)+
	rts

; loc_258A: Pal_DecRed2:
.updatered:
	subq.w	#2,(a0)+	; decrease red value
	rts

; loc_258E: Pal_DecNone2:
.updatenone:
	addq.w	#2,a0
	rts


; ---------------------------------------------------------------------------
; Subroutine to fade out to white (used when you enter a special stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_2592: Pal_MakeFlash:
Pal_FadeToWhite:
	move.w	#$3F,(Palette_fade_range).w

	moveq	#$15,d4

.nextframe:
	move.w	d4,-(sp)
	move.b	#VintID_Fade,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	bsr.s	.UpdateAllColours
	move.w	(sp)+,d4
	dbf	d4,.nextframe

	rts
; End of function Pal_FadeToWhite

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------
; sub_25B2: Pal_ToWhite:
.UpdateAllColours:
	; Update above-water palette
	moveq	#0,d0
	lea	(Normal_palette).w,a0
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0

	move.b	(Palette_fade_length).w,d0

.nextcolour:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour

	; Notice how this one lacks a check for
	; if Water_flag is set, unlike Pal_FadeFromWhite?

	; Update underwater palette
	moveq	#0,d0
	lea	(Underwater_palette).w,a0
	move.b	(Palette_fade_start).w,d0
	adda.w	d0,a0

	move.b	(Palette_fade_length).w,d0

.nextcolour2:
	bsr.s	.UpdateColour
	dbf	d0,.nextcolour2

	rts

; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------
; sub_25E0: Pal_AddColor2:
.UpdateColour:
	move.w	(a0),d2
	cmpi.w	#$EEE,d2
	beq.s	.updatenone
;.updatered:
	move.w	d2,d1
	andi.w	#$E,d1
	cmpi.w	#$E,d1
	beq.s	.updategreen
	addq.w	#2,(a0)+	; increase red value
	rts

; loc_25F8: Pal_AddGreen2:
.updategreen:
	move.w	d2,d1
	andi.w	#$E0,d1
	cmpi.w	#$E0,d1
	beq.s	.updateblue
	addi.w	#$20,(a0)+	; increase green value
	rts

; loc_260A: Pal_AddBlue2:
.updateblue:
	move.w	d2,d1
	andi.w	#$E00,d1
	cmpi.w	#$E00,d1
	beq.s	.updatenone
	addi.w	#$200,(a0)+	; increase blue value
	rts

; loc_261C: Pal_AddNone2:
.updatenone:
	addq.w	#2,a0
	rts
; End of function Pal_AddColor2

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_2712: PalLoad1:
PalLoad_ForFade:
	lea	(PalPointers).l,a1
	lsl.w	#3,d0
	adda.w	d0,a1
	movea.l	(a1)+,a2
	movea.w	(a1)+,a3
	lea	Target_palette-Normal_palette(a3),a3

	move.w	(a1)+,d7
-	move.l	(a2)+,(a3)+
	dbf	d7,-

	rts
; End of function PalLoad_ForFade


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_272E: PalLoad2:
PalLoad_Now:
	lea	(PalPointers).l,a1
	lsl.w	#3,d0
	adda.w	d0,a1
	movea.l	(a1)+,a2
	movea.w	(a1)+,a3

	move.w	(a1)+,d7
-	move.l	(a2)+,(a3)+
	dbf	d7,-

	rts
; End of function PalLoad_Now


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_2746: PalLoad3_Water:
PalLoad_Water_Now:
	lea	(PalPointers).l,a1
	lsl.w	#3,d0
	adda.w	d0,a1
	movea.l	(a1)+,a2
	movea.w	(a1)+,a3
	lea	-(Normal_palette-Underwater_palette)(a3),a3

	move.w	(a1)+,d7
-	move.l	(a2)+,(a3)+
	dbf	d7,-

	rts
; End of function PalLoad_Water_Now


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_2764: PalLoad4_Water:
PalLoad_Water_ForFade:
	lea	(PalPointers).l,a1
	lsl.w	#3,d0
	adda.w	d0,a1
	movea.l	(a1)+,a2
	movea.w	(a1)+,a3
	lea	-(Normal_palette-Underwater_target_palette)(a3),a3

	move.w	(a1)+,d7
-	move.l	(a2)+,(a3)+
	dbf	d7,-

	rts
; End of function PalLoad_Water_ForFade
