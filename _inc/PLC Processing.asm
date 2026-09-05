; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; Subroutine to load pattern load cues (aka to queue pattern load requests)
; ---------------------------------------------------------------------------

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;         (or hacker) is responsible for making sure that no more than
;         16 load requests are copied into the buffer.
;         _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of Plc_Buffer, the limit becomes (Plc_Buffer_Only_End-Plc_Buffer)/6)

; sub_161E: PLCLoad: AddPLC:
LoadPLC:
	lea	(ArtLoadCues).l,a6		; load PLC list address
	add.w	d0,d0
	adda.w	(a6,d0.w),a6		; jump to relevant PLC
	move.w	(a6)+,d6	; get length of PLC
	bmi.s	.skip

.loop:
	movea.l	(a6)+,a1
	move.w	(a6)+,d2
	bsr.w	Queue_KosPlus_Module
	dbf	d6,.loop	; repeat for length of PLC

.skip:
	rts
; End of function LoadPLC


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Queue pattern load requests, but clear the PLQ first

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;         (or hacker) is responsible for making sure that no more than
;         16 load requests are copied into the buffer.
;         _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of Plc_Buffer, the limit becomes (Plc_Buffer_Only_End-Plc_Buffer)/6)
; sub_1650:
LoadPLC2:
	lea	(ArtLoadCues).l,a6		; load PLC list address
	add.w	d0,d0
	adda.w	(a6,d0.w),a6		; jump to relevant PLC
	bsr.s	ClearPLC
	move.w	(a6)+,d6	; get length of PLC
	bmi.s	.skip

.loop:
	movea.l	(a6)+,a1
	move.w	(a6)+,d2
	bsr.w	Queue_KosPlus_Module
	dbf	d6,.loop	; repeat for length of PLC

.skip:
	rts
; End of function LoadPLC2


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Clear the pattern load queue ($FFF680 - $FFF700)

ClearPLC:
	clearRAM KosPlus_decomp_queue_count,KosPlus_module_queue_end

	rts
; End of function ClearPLC