; ---------------------------------------------------------------------------
; Moduled KosPlusinski decompression queue.
; For format explanation see https://segaretro.org/KosPlusinski_compression
;
; This version is slightly optimized compared to S3&K version.
; Also, it uses the faster KosPlusinski compressor internally.
; ---------------------------------------------------------------------------
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
; OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
; ---------------------------------------------------------------------------
; FUNCTION:
; 	Queue_KosPlus_Module
;
; DESCRIPTION
; 	Adds a KosPlusinski Moduled archive to the module queue
;
; INPUT:
; 	a1	Source address
; 	d2	Destination address in VRAM
; ---------------------------------------------------------------------------
; FUNCTION:
;	Process_KosPlus_Module_Queue
;
; DESCRIPTION:
; 	Processes the first module on the queue
; ---------------------------------------------------------------------------
; FUNCTION:
; 	Queue_KosPlus
;
; DESCRIPTION
; 	Adds KosPlusinski-compressed data to the decompression queue
;
; INPUT:
; 	a1	Compressed data address
; 	a2	Decompression destination in RAM
; ---------------------------------------------------------------------------
; FUNCTION:
; 	Set_KosPlus_Bookmark
;
; DESCRIPTION
; 	Checks if V-int occured in the middle of KosPlusinski queue processing
; 	and stores the location from which processing is to resume if it did
; ---------------------------------------------------------------------------
; FUNCTION:
; 	Process_KosPlus_Queue
;
; DESCRIPTION
; 	Processes the first entry in the KosPlusinski decompression queue
; ---------------------------------------------------------------------------
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
Queue_KosPlus:
	move.w	(KosPlus_decomp_queue_count).w,d0
	addq.w	#1,(KosPlus_decomp_queue_count).w
	lsl.w	#3,d0								; multiply by 8
	lea	(KosPlus_decomp_queue).w,a3
	adda.w	d0,a3
	move.l	a1,(a3)+							; store source
	move.l	a2,(a3)+							; store destination
	rts
; End of function Queue_KosPlus
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
Process_KosPlus_Module_Queue:
	tst.w	(KosPlus_modules_left).w
	beq.s	.done
	bmi.s	.decompressionStarted
	movea.l	(KosPlus_module_queue).w,a1
	lea	(KosPlus_decomp_buffer).w,a2
	bsr.s	Queue_KosPlus				; add current module to decompression queue
	ori.w	#$8000,(KosPlus_modules_left).w	; and set bit to signify decompression in progress
.done:
	rts
; ---------------------------------------------------------------------------
.decompressionStarted:
	tst.w	(KosPlus_decomp_queue_count).w
	bne.s	.done					; branch if the decompression isn't complete

	; otherwise, DMA the decompressed data to VRAM
	andi.w	#$7F,(KosPlus_modules_left).w
	move.w	#$800,d3
	subq.w	#1,(KosPlus_modules_left).w
	bne.s	.skip	; branch if it isn't the last module
	move.w	(KosPlus_last_module_size).w,d3

.skip:
	move.w	(KosPlus_module_destination).w,d2
	move.w	d2,d0
	add.w	d3,d0
	add.w	d3,d0
	move.w	d0,(KosPlus_module_destination).w	; set new destination
	move.l	(KosPlus_decomp_source).w,(KosPlus_module_queue).w	; set new source
    if AssumeSourceAddressInBytes
	move.l	#(KosPlus_decomp_buffer)&$FFFFFF,d1
    else
	move.l	#dmaSource(KosPlus_decomp_buffer),d1
    endif
	move.w	sr,-(sp)
	disableInts								; Mask off interrupts
	bsr.w	QueueDMATransfer
	enableInts
	move.w	(sp)+,sr
	tst.w	(KosPlus_modules_left).w
	bne.s	.exit					; return if this wasn't the last module
	; otherwise, shift all entries up
	lea	(KosPlus_module_queue).w,a0
	lea	(KosPlus_module_queue+6).w,a1
	rept bytesToXcnt(KosPlus_module_queue_end-KosPlus_module_queue,8)
		move.l	(a1)+,(a0)+										; otherwise, shift all entries up
		move.l	(a1)+,(a0)+
	endr

	if bytesToXcnt(KosPlus_module_queue_end-KosPlus_module_queue,8)&2
		move.w	(a1)+,(a0)+
	endif
	moveq	#0,d0
	move.l	d0,(a0)+				; and mark the last slot as free
	move.w	d0,(a0)+
	move.l	(KosPlus_module_queue).w,d0
	beq.s	.exit					; return if the queue is now empty
	movea.l	d0,a1
	move.w	(KosPlus_module_destination).w,d2
	bra.s	Process_KosPlus_Module_Queue_Init
; ---------------------------------------------------------------------------
.exit:
	rts
; End of function Process_KosPlus_Module_Queue
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
Queue_KosPlus_Module:
	lea	(KosPlus_module_queue).w,a2
	tst.l	(a2)	; is the first slot free?
	beq.s	Process_KosPlus_Module_Queue_Init	; if it is, branch

.findFreeSlot:
	addq.w	#6,a2	; otherwise, check next slot
	tst.l	(a2)
	bne.s	.findFreeSlot

	move.l	a1,(a2)+	; store source address
	move.w	d2,(a2)+	; store destination VRAM address
	rts
; End of function Queue_KosPlus_Module
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; Initializes processing of the first module on the queue
; ---------------------------------------------------------------------------
Process_KosPlus_Module_Queue_Init:
	move.w	(a1)+,d3				; get uncompressed size
	move.w	d3,d0
	lsr.w	#1,d3
	rol.w	#4,d0
	andi.w	#$1F,d0					; get number of complete modules
	move.w	d0,(KosPlus_modules_left).w
	andi.w	#$7FF,d3				; get size of last module in words
	bne.s	.gotleftover			; branch if it's non-zero
	subq.w	#1,(KosPlus_modules_left).w	; otherwise decrement the number of modules
	move.w	#$800,d3				; and take the size of the last module to be $800 words

.gotleftover:
	move.w	d3,(KosPlus_last_module_size).w
	move.w	d2,(KosPlus_module_destination).w
	move.l	a1,(KosPlus_module_queue).w
	addq.w	#1,(KosPlus_modules_left).w	; store total number of modules
	rts
; End of function Process_KosPlus_Module_Queue_Init

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
Set_KosPlus_Bookmark:
	tst.w	(KosPlus_decomp_queue_count).w
	bpl.s	.done					; branch if a decompression wasn't in progress
	move.l	$42(sp),d0				; check address V-int is supposed to rte to
	cmpi.l	#Process_KosPlus_Queue.Main,d0
	blo.s	.done
	cmpi.l	#Process_KosPlus_Queue.Done,d0
	bhs.s	.done
	move.l	d0,(KosPlus_decomp_bookmark).w
	move.l	#Backup_KosPlus_Registers,$42(sp)	; force V-int to rte here instead if needed

.done:
	rts
; End of function Set_KosPlus_Bookmark

; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
Process_KosPlus_Queue:
	tst.w	(KosPlus_decomp_queue_count).w
	beq.s	Set_KosPlus_Bookmark.done
	bpl.s	.Main
	movem.w	(KosPlus_decomp_stored_Wregisters).w,d0/d2/d4-d7
	movem.l	(KosPlus_decomp_stored_Lregisters).w,a0-a1/a5
	move.l	(KosPlus_decomp_bookmark).w,-(sp)
	move.w	(KosPlus_decomp_stored_SR).w,-(sp)
	rtr

.Main:
	ori.w	#$8000,(KosPlus_decomp_queue_count).w	; set sign bit to signify decompression in progress
	movem.l	(KosPlus_decomp_source).w,a0-a1

	include "_inc/KosinskiPlus Internal.asm"

	movem.l	a0-a1,(KosPlus_decomp_source).w
	andi.w	#$7FFF,(KosPlus_decomp_queue_count).w	; clear decompression in progress bit
	subq.w	#1,(KosPlus_decomp_queue_count).w
	beq.s	.Done								; branch if there aren't any entries remaining in the queue
	lea	(KosPlus_decomp_queue).w,a0
	lea	(KosPlus_decomp_queue+8).w,a1				; otherwise, shift all entries up

	rept bytesToXcnt(KosPlus_decomp_queue_end-KosPlus_decomp_queue,8)
		move.l	(a1)+,(a0)+										; otherwise, shift all entries up
		move.l	(a1)+,(a0)+
	endr

.Done:
	rts
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; Backs up current state for later restoration.
; ---------------------------------------------------------------------------
Backup_KosPlus_Registers:
	move.w	sr,(KosPlus_decomp_stored_SR).w
	movem.w	d0/d2/d4-d7,(KosPlus_decomp_stored_Wregisters).w
	movem.l	a0-a1/a5,(KosPlus_decomp_stored_Lregisters).w
	rts
; ===========================================================================

