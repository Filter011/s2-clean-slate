; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; loadZoneBlockMaps

; Loads block and bigblock mappings for the current Zone.

loadZoneBlockMaps:
	moveq	#0,d0
	move.b	(Current_Zone).w,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lea	(LevelArtPointers).l,a2
	lea	(a2,d0.w),a2
	move.l	a2,-(sp)
	addq.w	#4,a2
	move.l	#$FFFFFF,d0	; pointer to block mappings
	and.l	(a2)+,d0
	movea.l	d0,a0
	lea	(Block_Table).w,a1
	jsr	(KosPlusDec).w	; load block maps
	cmpi.b	#hill_top_zone,(Current_Zone).w
	bne.s	+
	lea	(Block_Table+$980).w,a1
	lea	(BM16_HTZ).l,a0
	jsr	(KosPlusDec).w	; patch for Hill Top Zone block map
+
	move.l	#$FFFFFF,d0	; pointer to chunk mappings
	and.l	(a2)+,d0
	movea.l	d0,a0
	lea	(Chunk_Table).l,a1
	jsr	(KosPlusDec).w
	bsr.s	loadLevelLayout
	movea.l	(sp)+,a2	; zone specific pointer in LevelArtPointers
	addq.w	#4,a2
	moveq	#0,d0
	move.b	(a2),d0	; PLC2 ID
	beq.s	+
	move.l	a2,-(sp)
	jsr	(LoadPLC).w
	movea.l	(sp)+,a2
+
	addq.w	#4,a2
	moveq	#0,d0
	move.b	(a2),d0	; palette ID
	jmp	(PalLoad_Now).w

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


loadLevelLayout:
	moveq	#0,d0
	move.w	(Current_ZoneAndAct).w,d0
	ror.b	#1,d0
	lsr.w	#5,d0
	lea	(Off_Level).l,a0
	movea.l	(a0,d0.w),a0
	lea	(Level_Layout).w,a1
	jmp	(KosPlusDec).w
; End of function loadLevelLayout