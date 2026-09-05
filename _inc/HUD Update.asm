; ---------------------------------------------------------------------------
; Subroutine to draw the HUD
; ---------------------------------------------------------------------------

hud_letter_num_tiles = 2
hud_letter_vdp_delta = vdpCommDelta(tiles_to_bytes(hud_letter_num_tiles))

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_40804:
BuildHUD:
	tst.w	(Ring_count).w
	beq.s	+	; blink ring count if it's 0
	moveq	#0,d4
	btst	#3,(Level_frame_counter+1).w
	bne.s	++	; only blink on certain frames
	cmpi.b	#9,(Timer_minute).w	; should the minutes counter blink?
	bne.s	++	; if not, branch
	addq.w	#2,d4	; set mapping frame time counter blink
	bra.s	++
+
	moveq	#0,d4
	btst	#3,(Level_frame_counter+1).w
	bne.s	+	; only blink on certain frames
	addq.w	#1,d4	; set mapping frame for ring count blink
	cmpi.b	#9,(Timer_minute).w
	bne.s	+
	addq.w	#2,d4	; set mapping frame for double blink
+
	move.w	#spriteScreenPositionX(16),d0	; set X pos
	move.w	#spriteScreenPositionYCentered(24),d1	; set Y pos
	lea	HUD_MapUnc_40A9A(pc),a1
	move.w	#make_art_tile(ArtTile_ArtNem_HUD,0,1),d5	; set art tile and flags
	add.w	d4,d4
	adda.w	(a1,d4.w),a1
	move.w	(a1)+,d4
	subq.w	#1,d4
	bmi.s	+
	jmp	(BuildSpr_Normal).l	; draw frame
+
	rts
; End of function BuildHUD
; ===========================================================================

; sprite mappings for the HUD
; uses the art in VRAM from $D940 - $FC00
HUD_MapUnc_40A9A:	include "mappings/sprite/hud_a.asm"

; ---------------------------------------------------------------------------
; Add points subroutine
; subroutine to add to Player 1's score
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_40D06:
AddPoints:
	move.b	#1,(Update_HUD_score).w
	lea	(Score).w,a3
	add.l	d0,(a3)	; add d0*10 to the score
	move.l	#999999,d1
	cmp.l	(a3),d1	; is #999999 higher than the score?
	bhi.s	+	; if yes, branch
	move.l	d1,(a3)	; set score to #999999
+
	move.l	(a3),d0
	cmp.l	(Next_Extra_life_score).w,d0
	blo.s	+	; rts
	addi.l	#5000,(Next_Extra_life_score).w
	addq.b	#1,(Life_count).w
	addq.b	#1,(Update_HUD_lives).w
	moveq	#MusID_ExtraLife,d0
	jmp	(PlayMusic).w
; ===========================================================================
+	rts
; End of function AddPoints

; ---------------------------------------------------------------------------
; Subroutine to update the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_40D8A:
HudUpdate:
	lea	(VDP_data_port).l,a6
	tst.w	(Debug_mode_flag).w	; is debug mode on?
	bne.w	loc_40E9A	; if yes, branch
	tst.b	(Update_HUD_score).w	; does the score need updating?
	beq.s	Hud_ChkRings	; if not, branch
	clr.b	(Update_HUD_score).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Score),VRAM,WRITE),d0	; set VRAM address
	move.l	(Score).w,d1	; load score
	bsr.w	Hud_Score
; loc_40DBA:
Hud_ChkRings:
	tst.b	(Update_HUD_rings).w	; does the ring counter need updating?
	beq.s	Hud_ChkTime	; if not, branch
	bpl.s	loc_40DC6
	bsr.w	Hud_InitRings

loc_40DC6:
	clr.b	(Update_HUD_rings).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Rings),VRAM,WRITE),d0
	moveq	#0,d1
	move.w	(Ring_count).w,d1
	bsr.w	Hud_Rings
; loc_40DDA:
Hud_ChkTime:
	tst.b	(Update_HUD_timer).w	; does the time need updating?
	beq.s	Hud_ChkLives	; if not, branch
	tst.w	(Game_paused).w	; is the game paused?
	bne.s	Hud_ChkLives	; if yes, branch
	lea	(Timer).w,a1
	cmpi.l	#(9<<(8*2))|(59<<(8*1))|(59<<(8*0)),(a1)+	; is the time 9.59?
	beq.w	loc_40E84	; if yes, branch
	addq.b	#1,-(a1)
	cmpi.b	#60,(a1)
	blo.s	Hud_ChkLives
	clr.b	(a1)
	addq.b	#1,-(a1)
	cmpi.b	#60,(a1)
	blo.s	+
	clr.b	(a1)
	addq.b	#1,-(a1)
	cmpi.b	#9,(a1)
	blo.s	+
	move.b	#9,(a1)
+
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Minutes),VRAM,WRITE),d0
	moveq	#0,d1
	move.b	(Timer_minute).w,d1
	bsr.w	Hud_Mins
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Seconds),VRAM,WRITE),d0
	moveq	#0,d1
	move.b	(Timer_second).w,d1
	bsr.w	Hud_Secs
; loc_40E38:
Hud_ChkLives:
	tst.b	(Update_HUD_lives).w	; does the lives counter need updating?
	beq.s	Hud_ChkBonus	; if not, branch
	clr.b	(Update_HUD_lives).w
	bsr.w	Hud_Lives
; loc_40E46:
Hud_ChkBonus:
	tst.b	(Update_Bonus_score).w	; do time/ring bonus counters need updating?
	beq.s	Hud_End	; if not, branch
	clr.b	(Update_Bonus_score).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Bonus_Score),VRAM,WRITE),(VDP_control_port).l
	moveq	#0,d1
	move.w	(Total_Bonus_Countdown).w,d1
	bsr.w	Hud_TimeRingBonus
	moveq	#0,d1
	move.w	(Bonus_Countdown_1).w,d1	 ; load time bonus
	bsr.w	Hud_TimeRingBonus
	moveq	#0,d1
	move.w	(Bonus_Countdown_2).w,d1	 ; load ring bonus
	bsr.w	Hud_TimeRingBonus
	moveq	#0,d1
	move.w	(Bonus_Countdown_3).w,d1	 ; load perfect bonus
	bra.w	Hud_TimeRingBonus
; return_40E82:
Hud_End:
	rts
; ===========================================================================

loc_40E84:
	clr.b	(Update_HUD_timer).w
	lea	(MainCharacter).w,a0 ; a0=character
	movea.l	a0,a2
	bsr.w	KillCharacter
	move.b	#1,(Time_Over_flag).w
	rts
; ===========================================================================

loc_40E9A:
	bsr.w	HudDb_XY
	tst.b	(Update_HUD_rings).w
	beq.s	loc_40EBE
	bpl.s	loc_40EAA
	bsr.w	Hud_InitRings

loc_40EAA:
	clr.b	(Update_HUD_rings).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Rings),VRAM,WRITE),d0

	moveq	#0,d1
	move.w	(Ring_count).w,d1
	bsr.w	Hud_Rings

loc_40EBE:
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Seconds),VRAM,WRITE),d0
	moveq	#0,d1
	move.b	(Sprite_count).w,d1
	bsr.w	Hud_Secs
	tst.b	(Update_HUD_lives).w
	beq.s	loc_40EDC
	clr.b	(Update_HUD_lives).w
	bsr.w	Hud_Lives

loc_40EDC:
	tst.b	(Update_Bonus_score).w
	beq.s	loc_40F18
	clr.b	(Update_Bonus_score).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Bonus_Score),VRAM,WRITE),(VDP_control_port).l
	moveq	#0,d1
	move.w	(Total_Bonus_Countdown).w,d1
	bsr.w	Hud_TimeRingBonus
	moveq	#0,d1
	move.w	(Bonus_Countdown_1).w,d1
	bsr.w	Hud_TimeRingBonus
	moveq	#0,d1
	move.w	(Bonus_Countdown_2).w,d1
	bsr.w	Hud_TimeRingBonus
	moveq	#0,d1
	move.w	(Bonus_Countdown_3).w,d1
	bsr.w	Hud_TimeRingBonus

loc_40F18:
	tst.w	(Game_paused).w
	bne.s	return_40F4E
	lea	(Timer+4).w,a1
	addq.b	#1,-(a1)
	cmpi.b	#60,(a1)
	blo.s	return_40F4E
	clr.b	(a1)
	addq.b	#1,-(a1)
	cmpi.b	#60,(a1)
	blo.s	return_40F4E
	clr.b	(a1)
	addq.b	#1,-(a1)
	cmpi.b	#9,(a1)
	blo.s	return_40F4E
	move.b	#9,(a1)

return_40F4E:
	rts
; End of function HudUpdate


; ---------------------------------------------------------------------------
; Subroutine to initialize ring counter on the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_4105A:
; Hud_LoadZero:
Hud_InitRings:
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Rings),VRAM,WRITE),(VDP_control_port).l
	lea	Hud_TilesRings(pc),a2
	moveq	#(Hud_TilesBase_End-Hud_TilesRings)-1,d2
	bra.s	loc_41090

; ---------------------------------------------------------------------------
; Subroutine to load uncompressed HUD patterns ("E", "0", colon)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_4106E:
Hud_Base:
	lea	(VDP_data_port).l,a6
	bsr.w	Hud_Lives
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Score_E),VRAM,WRITE),(VDP_control_port).l
	lea	Hud_TilesBase(pc),a2
	moveq	#(Hud_TilesBase_End-Hud_TilesBase)-1,d2

loc_41090:
	lea	Art_Hud(pc),a1

loc_41094:
	moveq	#bytesToLcnt(tiles_to_bytes(hud_letter_num_tiles)),d1
	move.b	(a2)+,d0
	bmi.s	loc_410B0
	ext.w	d0
	lsl.w	#5,d0
	lea	(a1,d0.w),a3

loc_410A4:
	move.l	(a3)+,(a6)
	dbf	d1,loc_410A4

loc_410AA:
	dbf	d2,loc_41094
	rts
; ===========================================================================

loc_410B0:
	move.l	#0,(a6)
	dbf	d1,loc_410B0
	bra.s	loc_410AA
; End of function Hud_Base

; ===========================================================================

	charset	' ',$FF
	charset	'0',0
	charset	'1',2
	charset	'2',4
	charset	'3',6
	charset	'4',8
	charset	'5',$A
	charset	'6',$C
	charset	'7',$E
	charset	'8',$10
	charset	'9',$12
	charset	':',$14
	charset	'E',$16

; byte_410D4:
Hud_TilesBase:
	dc.b "E      0"
	dc.b "0:00"
; byte_410E0:
; Hud_TilesZero:
Hud_TilesRings:
	dc.b "  0"
Hud_TilesBase_End

	charset
	even

; ---------------------------------------------------------------------------
; Subroutine to load debug mode numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_410E4:
HudDb_XY:
	move.l	#vdpComm(tiles_to_bytes(ArtTile_HUD_Score_E),VRAM,WRITE),(VDP_control_port).l
	move.w	(Camera_X_pos).w,d1
	swap	d1
	move.w	(MainCharacter+x_pos).w,d1
	bsr.s	HudDb_XY2
	move.w	(Camera_Y_pos).w,d1
	swap	d1
	move.w	(MainCharacter+y_pos).w,d1
; loc_41104:
HudDb_XY2:
	moveq	#8-1,d6
	lea	(Art_Text).l,a1
; loc_4110C:
HudDb_XYLoop:
	rol.w	#4,d1
	move.w	d1,d2
	andi.w	#$F,d2
	cmpi.w	#$A,d2
	blo.s	loc_4111E
	addq.w	#7,d2

loc_4111E:
	lsl.w	#5,d2
	lea	(a1,d2.w),a3
    rept tiles_to_longwords(1)
	move.l	(a3)+,(a6)
    endm
	swap	d1
	dbf	d6,HudDb_XYLoop
	rts
; End of function HudDb_XY

; ---------------------------------------------------------------------------
; Subroutine to load rings numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_4113C:
Hud_Rings:
	lea	Hud_100(pc),a2
	moveq	#Hud_100.loop_counter,d6
	bra.s	Hud_LoadArt
; End of function Hud_Rings

; ---------------------------------------------------------------------------
; Subroutine to load score numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_41146:
Hud_Score:
	lea	Hud_100000(pc),a2
	moveq	#Hud_100000.loop_counter,d6
; loc_4114E:
Hud_LoadArt:
	moveq	#0,d4
	lea	Art_Hud(pc),a1
; loc_41154:
Hud_ScoreLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

loc_41158:
	sub.l	d3,d1
	bcs.s	loc_41160
	addq.w	#1,d2
	bra.s	loc_41158
; ===========================================================================

loc_41160:
	add.l	d3,d1
	tst.w	d2
	beq.s	loc_4116A
	moveq	#1,d4

loc_4116A:
	tst.w	d4
	beq.s	loc_41198
	lsl.w	#6,d2
	move.l	d0,4(a6)
	lea	(a1,d2.w),a3
    rept tiles_to_longwords(hud_letter_num_tiles)
	move.l	(a3)+,(a6)
    endm

loc_41198:
	addi.l	#hud_letter_vdp_delta,d0
	dbf	d6,Hud_ScoreLoop
	rts
; End of function Hud_Score

; ===========================================================================
; ---------------------------------------------------------------------------
; for HUD counter
; ---------------------------------------------------------------------------
hud_counter macro {INTLABEL},number
__LABEL__ label *
.loop_counter = int(log(number)) ; Total digits minus one.
	dc.l number
    endm
					; byte_411FC:
Hud_100000:	hud_counter 100000	; byte_41200:
Hud_10000:	hud_counter 10000	; byte_41204:
Hud_1000:	hud_counter 1000	; byte_41208:
Hud_100:	hud_counter 100		; byte_4120C:
Hud_10:		hud_counter 10		; byte_41210:
Hud_1:		hud_counter 1

; ---------------------------------------------------------------------------
; Subroutine to load time numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_41214:
Hud_Mins:
	lea	Hud_1(pc),a2
	moveq	#Hud_1.loop_counter,d6
	bra.s	loc_41222
; ===========================================================================
; loc_4121C:
Hud_Secs:
	lea	Hud_10(pc),a2
	moveq	#Hud_10.loop_counter,d6

loc_41222:
	moveq	#0,d4
	lea	Art_Hud(pc),a1
; loc_41228:
Hud_TimeLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

loc_4122C:
	sub.l	d3,d1
	bcs.s	loc_41234
	addq.w	#1,d2
	bra.s	loc_4122C
; ===========================================================================

loc_41234:
	add.l	d3,d1
	tst.w	d2
	beq.s	loc_4123E
	moveq	#1,d4

loc_4123E:
	lsl.w	#6,d2
	move.l	d0,4(a6)
	lea	(a1,d2.w),a3
    rept tiles_to_longwords(hud_letter_num_tiles)
	move.l	(a3)+,(a6)
    endm
	addi.l	#hud_letter_vdp_delta,d0
	dbf	d6,Hud_TimeLoop
	rts
; End of function Hud_Mins

; ---------------------------------------------------------------------------
; Subroutine to load time/ring bonus numbers patterns
; ---------------------------------------------------------------------------

; ===========================================================================
; loc_41274:
Hud_TimeRingBonus:
	lea	Hud_1000(pc),a2
	moveq	#Hud_1000.loop_counter,d6
	moveq	#0,d4
	lea	Art_Hud(pc),a1
; loc_41280:
Hud_BonusLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

loc_41284:
	sub.l	d3,d1
	bcs.s	loc_4128C
	addq.w	#1,d2
	bra.s	loc_41284
; ===========================================================================

loc_4128C:
	add.l	d3,d1
	tst.w	d2
	beq.s	loc_41296
	moveq	#1,d4

loc_41296:
	tst.w	d4
	beq.s	Hud_ClrBonus
	lsl.w	#6,d2
	lea	(a1,d2.w),a3
    rept tiles_to_longwords(hud_letter_num_tiles)
	move.l	(a3)+,(a6)
    endm

loc_412C0:
	dbf	d6,Hud_BonusLoop ; repeat 3 more times
	rts
; ===========================================================================
; loc_412C6:
Hud_ClrBonus:
	moveq	#bytesToLcnt(tiles_to_bytes(hud_letter_num_tiles)),d5
; loc_412C8:
Hud_ClrBonusLoop:
	move.l	#0,(a6)
	dbf	d5,Hud_ClrBonusLoop
	bra.s	loc_412C0

; ---------------------------------------------------------------------------
; Subroutine to load uncompressed lives counter patterns (Tails)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_412E2:
Hud_Lives:
	move.l	#vdpComm(tiles_to_bytes(ArtTile_ArtNem_life_counter_lives),VRAM,WRITE),d0
	moveq	#0,d1
	move.b	(Life_count).w,d1

loc_412EE:
	lea	Hud_10(pc),a2
	moveq	#Hud_10.loop_counter,d6
	moveq	#0,d4
	lea	Art_LivesNums(pc),a1
; loc_412FA:
Hud_LivesLoop:
	move.l	d0,4(a6)
	moveq	#0,d2
	move.l	(a2)+,d3
-	sub.l	d3,d1
	bcs.s	loc_4130A
	addq.w	#1,d2
	bra.s	-
; ===========================================================================

loc_4130A:
	add.l	d3,d1
	tst.w	d2
	beq.s	loc_41314
	moveq	#1,d4

loc_41314:
	tst.w	d4
	beq.s	Hud_ClrLives

loc_41318:
	lsl.w	#5,d2
	lea	(a1,d2.w),a3
    rept 8
	move.l	(a3)+,(a6)
    endm

loc_4132E:
	addi.l	#hud_letter_vdp_delta,d0
	dbf	d6,Hud_LivesLoop ; repeat 1 more time
	rts
; ===========================================================================
; loc_4133A:
Hud_ClrLives:
	tst.w	d6
	beq.s	loc_41318
	moveq	#7,d5
; loc_41340:
Hud_ClrLivesLoop:
	move.l	#0,(a6)
	dbf	d5,Hud_ClrLivesLoop
	bra.s	loc_4132E
; End of function Hud_Lives
