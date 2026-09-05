; ---------------------------------------------------------------------------
; Sonic pattern loading subroutine
; ---------------------------------------------------------------------------

; loc_1B848:
LoadSonicDynPLC:
	moveq	#0,d0
	move.b	mapping_frame(a0),d0	; load frame number
; loc_1B84E:
LoadSonicDynPLC_Part2:
	cmp.b	(Sonic_LastLoadedDPLC).w,d0
	beq.s	return_1B89A
	move.b	d0,(Sonic_LastLoadedDPLC).w
	lea	(MapRUnc_Sonic).l,a2
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	subq.w	#1,d5
	bmi.s	return_1B89A
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Sonic),d4
    if AssumeSourceAddressInBytes
	move.l	#ArtUnc_Sonic,d6
    else
	move.l	#dmaSource(ArtUnc_Sonic),d6
    endif
; loc_1B86E:
SPLC_ReadEntry:
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	d1,-(sp)
	move.b	(sp)+,d3
	andi.w	#$F0,d3
	addi.w	#$10,d3
	andi.w	#$FFF,d1
    if AssumeSourceAddressInBytes
	lsl.l	#5,d1
    else
	lsl.l	#4,d1
    endif
	add.l	d6,d1
	move.w	d4,d2
	add.w	d3,d4
	add.w	d3,d4
	jsr	(QueueDMATransfer).w
	dbf	d5,SPLC_ReadEntry	; repeat for number of entries

return_1B89A:
	rts
