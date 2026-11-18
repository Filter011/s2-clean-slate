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
	lea	(LevelArtPointers).l,a3
	lea	(a3,d0.w),a3
	move.l	a3,-(sp)

	move.l	#$FFFFFF,d0	; 8x8 tile pointer
	and.l	(a3)+,d0
	movea.l	d0,a0
	lea	(Chunk_Table).l,a1
	bsr.w	KosPlusDec
	move.w	a1,d3
	cmpi.b	#hill_top_zone,(Current_Zone).w
	bne.s	+
	lea	(ArtKos_HTZ).l,a0
	lea	(Chunk_Table+tiles_to_bytes(ArtTile_ArtKos_NumTiles_HTZ_Main)).l,a1
	bsr.w	KosPlusDec	; patch for HTZ
	move.w	#tiles_to_bytes(ArtTile_ArtKos_NumTiles_HTZ),d3
+
	cmpi.b	#wing_fortress_zone,(Current_Zone).w
	bne.s	+
	lea	(ArtKos_WFZ).l,a0
	lea	(Chunk_Table+tiles_to_bytes(ArtTile_ArtKos_NumTiles_WFZ_Main)).l,a1
	bsr.w	KosPlusDec	; patch for WFZ
	move.w	#tiles_to_bytes(ArtTile_ArtKos_NumTiles_WFZ),d3
+
	cmpi.b	#death_egg_zone,(Current_Zone).w
	bne.s	+
	move.w	#tiles_to_bytes(ArtTile_ArtKos_NumTiles_DEZ),d3
+
	move.w	d3,d7
	andi.w	#$FFF,d3
	lsr.w	#1,d3
	rol.w	#4,d7
	andi.w	#$F,d7

-	move.w	d7,d2
	moveq	#12,d0
	lsl.w	d0,d2
	move.l	#$FFFFFF,d1
	move.w	d2,d1
    if AssumeSourceAddressInBytes=0
	lsr.l	#1,d1
    endif
	bsr.w	QueueDMATransfer
	move.w	d7,-(sp)
	move.l	#Vint_TitleCard,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	move.w	(sp)+,d7
	move.w	#$800,d3
	dbf	d7,-

	move.l	#$FFFFFF,d0	; pointer to block mappings
	and.l	(a3)+,d0
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
	and.l	(a3)+,d0
	movea.l	d0,a0
	lea	(Chunk_Table).l,a1
	jsr	(KosPlusDec).w
	move.w	(Current_ZoneAndAct).w,d0
	ror.b	#1,d0
	lsr.w	#5,d0
	lea	(Off_Level).l,a0
	movea.l	(a0,d0.w),a0
	lea	(Level_Layout).w,a1
	jsr	(KosPlusDec).w
	movea.l	(sp)+,a3	; zone specific pointer in LevelArtPointers
	addq.w	#4,a3
	moveq	#0,d0
	move.b	(a3),d0	; PLC2 ID
	beq.s	+
	jsr	(LoadPLC).w
+
	addq.w	#4,a3
	moveq	#0,d0
	move.b	(a3),d0	; palette ID
	jmp	(PalLoad_Now).w