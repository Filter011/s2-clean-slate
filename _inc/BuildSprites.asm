; ---------------------------------------------------------------------------
; Subroutine to convert mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

BuildSprites:
		moveq	#80-1,d7
		moveq	#0,d6
		lea	(Object_Display_Lists).w,a5
		lea	(Camera_X_pos_copy).w,a3
		lea	(Sprite_Table).w,a6 ; set address for sprite table
		tst.b	(Level_started_flag).w
		beq.s	BuildPriorityLoop
		jsr	(BuildHUD).l
		bsr.w	BuildRings

BuildPriorityLoop:
		tst.w	(a5)	; are there objects left to draw?
		beq.w	BuildNextPriority	; if not, branch
		lea	2(a5),a4

BuildObjectLoop:
		movea.w	(a4)+,a0	; load object ID
;		tst.b	id(a0)
;		beq.w	BuildSprites_NextObj
;		tst.l	mappings(a0)
;		beq.w	BuildSprites_NextObj
		andi.b	#$7F,render_flags(a0)
		move.b	render_flags(a0),d6
		move.w	x_pos(a0),d0
		move.w	y_pos(a0),d1
		btst	#6,d6		; is the multi-draw flag set?
		bne.w	Build_1AE58	; if it is, branch
		btst	#2,d6		; get drawing coordinates
		beq.s	BuildDrawObject	; branch if 0 (screen coordinates)
		moveq	#0,d2
		move.b	width_pixels(a0),d2
		sub.w	(a3),d0
		move.w	d0,d3
		add.w	d2,d3
		bmi.s	BuildSprites_NextObj	; left edge out of bounds
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3
		bge.s	BuildSprites_NextObj	; right edge out of bounds
		addi.w	#128,d0		; VDP sprites start at 128px
		sub.w	4(a3),d1
		btst	#4,d6
		beq.s	BuildAssumeHeight
		move.b	y_radius(a0),d2
		add.w	d2,d1
		and.w	(Screen_Y_wrap_value).w,d1
		move.w	d2,d3
		add.w	d2,d2
		addi.w	#224,d2
		cmp.w	d2,d1
		bhs.s	BuildSprites_NextObj
		addi.w	#128,d1		; VDP sprites start at 128px
		sub.w	d3,d1
		bra.s	BuildDrawObject

BuildAssumeHeight:
		addi.w	#128,d1
		and.w	(Screen_Y_wrap_value).w,d1
		cmpi.w	#-32+128,d1
		blo.s	BuildSprites_NextObj
		cmpi.w	#32+128+224,d1
		bhs.s	BuildSprites_NextObj

BuildDrawObject:
		ori.b	#$80,render_flags(a0)		; set object as visible
		tst.w	d7
		bmi.s	BuildSprites_NextObj
		movea.l	mappings(a0),a1
		moveq	#0,d4
		btst	#5,d6		; is static mappings flag on?
		bne.s	BuildDrawFrame	; if yes, branch
		move.b	mapping_frame(a0),d4
		add.w	d4,d4
		adda.w	(a1,d4.w),a1	; get mappings frame address
		move.w	(a1)+,d4	; number of sprite pieces
		subq.w	#1,d4
		bmi.s	BuildSprites_NextObj

BuildDrawFrame:
		move.w	art_tile(a0),d5
		bsr.w	BuildSpr_Draw	; write data from sprite pieces to buffer

BuildSprites_NextObj:
		subq.w	#2,(a5)		; number of objects left
		bne.w	BuildObjectLoop

BuildNextPriority:
		lea	$80(a5),a5
		cmpa.l	#Object_Display_Lists_End,a5
		blo.w	BuildPriorityLoop
		move.w	d7,d6
		bmi.s	loc_1AE18
		moveq	#0,d0

loc_1AE10:
		move.w	d0,(a6)
		addq.w	#8,a6
		dbf	d7,loc_1AE10

loc_1AE18:
		subi.w	#80-1,d6
		neg.w	d6
		move.b	d6,(Sprite_count).w
		rts
; End of function BuildSprites

; ---------------------------------------------------------------------------

Build_1AE58:
		moveq	#0,d2
		move.b	mainspr_width(a0),d2
		sub.w	(a3),d0
		move.w	d0,d3
		add.w	d2,d3
		bmi.s	BuildSprites_NextObj
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3
		bge.s	BuildSprites_NextObj
		addi.w	#128,d0
		btst	#4,d6
		beq.s	.assumeheight
		sub.w	4(a3),d1
		move.b	mainspr_height(a0),d2
		add.w	d2,d1
		and.w	(Screen_Y_wrap_value).w,d1
		move.w	d2,d3
		add.w	d2,d2
		addi.w	#224,d2
		cmp.w	d2,d1
		bhs.s	BuildSprites_NextObj
		addi.w	#128,d1
		sub.w	d3,d1
		bra.s	Build_1AEE4

	.assumeheight:
		sub.w	4(a3),d1
		addi.w  #128,d1
		and.w	(Screen_Y_wrap_value).w,d1
		cmpi.w	#-32+128,d1
		blo.w	BuildSprites_NextObj
		cmpi.w	#32+128+224,d1
		bhs.w	BuildSprites_NextObj

Build_1AEE4:
		ori.b	#$80,render_flags(a0)
		tst.w	d7
		bmi.w	BuildSprites_NextObj
		move.w	art_tile(a0),d5
		movea.l	mappings(a0),a2
		moveq	#0,d4
		move.b	mainspr_mapframe(a0),d4
		beq.s	Build_1AF1C
		add.w	d4,d4
		lea	(a2),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	Build_1AF1C
		move.w	d6,d3
		bsr.w	sub_1B070
		move.w	d3,d6
		tst.w	d7
		bmi.w	BuildSprites_NextObj

Build_1AF1C:
		moveq	#0,d3
		move.b	mainspr_childsprites(a0),d3
		subq.w	#1,d3
		bcs.w	BuildSprites_NextObj
		lea	subspr_data(a0),a0

Build_1AF2A:
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		btst	#2,d6
		beq.s	Build_1AF46
		sub.w	(a3),d0
		addi.w	#128,d0
		sub.w	4(a3),d1
		addi.w	#128,d1
		and.w	(Screen_Y_wrap_value).w,d1

Build_1AF46:
		addq.w	#1,a0
		moveq	#0,d4
		move.b	(a0)+,d4
		add.w	d4,d4
		lea	(a2),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	Build_1AF62
		move.w	d6,-(sp)
		bsr.w	sub_1B070
		move.w	(sp)+,d6

Build_1AF62:
		tst.w	d7
		dbmi	d3,Build_1AF2A
		bra.w	BuildSprites_NextObj

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Draw:
		lsr.b	#1,d6
		bcs.s	BuildSpr_FlipX
		lsr.b	#1,d6
		bcs.w	BuildSpr_FlipY
; End of function BuildSpr_Draw


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Normal:
		move.b	(a1)+,d2	; get y-offset
		ext.w	d2
		add.w	d1,d2		; add y-position
		move.w	d2,(a6)+	; write to buffer
		move.b	(a1)+,(a6)+	; write sprite size
		addq.w	#1,a6		; increase sprite counter
		move.w	(a1)+,d2	; get art tile
		add.w	d5,d2		; add art tile offset
		move.w	d2,(a6)+	; write to buffer
		move.w	(a1)+,d2	; get x-offset
		add.w	d0,d2		; add x-position
		andi.w	#$1FF,d2	; keep within 512px
		bne.s	.writeX
		addq.w	#1,d2

	.writeX:
		move.w	d2,(a6)+	; write to buffer
		subq.w	#1,d7
		dbmi	d4,BuildSpr_Normal	; process next sprite piece
		rts
; End of function BuildSpr_Normal

; ===========================================================================

BuildSpr_FlipX:
		lsr.b	#1,d6		; is object also y-flipped?
		bcs.s	BuildSpr_FlipXY	; if yes, branch

	.loop:
		move.b	(a1)+,d2	; y position
		ext.w	d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,d6	; size
		move.b	d6,(a6)+
		addq.w	#1,a6		; link
		move.w	(a1)+,d2	; art tile
		add.w	d5,d2
		eori.w	#$800,d2	; toggle flip-x in VDP
		move.w	d2,(a6)+	; write to buffer
		move.w	(a1)+,d2	; get x-offset
		neg.w	d2		; negate it
		move.b	byte_D238(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		andi.w	#$1FF,d2	; keep within 512px
		bne.s	.writeX
		addq.w	#1,d2

	.writeX:
		move.w	d2,(a6)+	; write to buffer
		subq.w	#1,d7
		dbmi	d4,.loop		; process next sprite piece
		rts
; ---------------------------------------------------------------------------
byte_D238:	dc.b   8,  8,  8,  8
		dc.b $10,$10,$10,$10
		dc.b $18,$18,$18,$18
		dc.b $20,$20,$20,$20
; ===========================================================================

BuildSpr_FlipXY:
		move.b	(a1)+,d2	; get y-offset
		ext.w	d2
		neg.w	d2		; negate y-offset
		move.b	(a1),d6		; get size
		move.b	byte_D290(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2	; add y-position
		move.w	d2,(a6)+	; write to buffer
		move.b	(a1)+,d6	; size
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2	; art tile
		add.w	d5,d2
		eori.w	#$1800,d2	; toggle flip-y in VDP
		move.w	d2,(a6)+
		move.w	(a1)+,d2	; x-position
		neg.w	d2
		move.b	byte_D238(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	.writeX
		addq.w	#1,d2

	.writeX:
		move.w	d2,(a6)+	; write to buffer
		subq.w	#1,d7
		dbmi	d4,BuildSpr_FlipXY	; process next sprite piece
		rts
; ---------------------------------------------------------------------------
byte_D290:	dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
; ===========================================================================

BuildSpr_FlipY:
		move.b	(a1)+,d2	; calculated flipped y
		ext.w	d2
		neg.w	d2
		move.b	(a1)+,d6
		move.b	d6,2(a6)
		move.b	byte_D290(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		move.w	d2,(a6)+	; write to buffer
		addq.w	#2,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1000,d2	; toggle flip-y in VDP
		move.w	d2,(a6)+
		move.w	(a1)+,d2	; calculate flipped x
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	.writeX
		addq.w	#1,d2

	.writeX:
		move.w	d2,(a6)+	; write to buffer
		subq.w	#1,d7
		dbmi	d4,BuildSpr_FlipY	; process next sprite piece
		rts

; =============== S U B R O U T I N E =======================================


sub_1B070:
		lsr.b	#1,d6
		bcs.s	Build_1B0C2
		lsr.b	#1,d6
		bcs.w	Build_1B19C

Build_1B07A:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B0BA
		cmpi.w	#$160,d2
		bhs.s	Build_1B0BA
		move.w	d2,(a6)+
		move.b	(a1)+,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B0B2
		cmpi.w	#$1C0,d2
		bhs.s	Build_1B0B2
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,Build_1B07A
		rts
; ---------------------------------------------------------------------------

Build_1B0B2:
		subq.w	#6,a6
		dbf	d4,Build_1B07A
		rts
; ---------------------------------------------------------------------------

Build_1B0BA:
		addq.w	#5,a1
		dbf	d4,Build_1B07A
		rts
; ---------------------------------------------------------------------------

Build_1B0C2:
		lsr.b	#1,d6
		bcs.s	Build_1B12C

Build_1B0C6:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B114
		cmpi.w	#$160,d2
		bhs.s	Build_1B114
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$800,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1B11C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B10C
		cmpi.w	#$1C0,d2
		bhs.s	Build_1B10C
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,Build_1B0C6
		rts
; ---------------------------------------------------------------------------

Build_1B10C:
		subq.w	#6,a6
		dbf	d4,Build_1B0C6
		rts
; ---------------------------------------------------------------------------

Build_1B114:
		addq.w	#5,a1
		dbf	d4,Build_1B0C6
		rts
; ---------------------------------------------------------------------------
byte_1B11C:	dc.b   8,  8,  8,  8
		dc.b $10,$10,$10,$10
		dc.b $18,$18,$18,$18
		dc.b $20,$20,$20,$20
; ---------------------------------------------------------------------------

Build_1B12C:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1),d6
		move.b	byte_1B18C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B184
		cmpi.w	#$160,d2
		bhs.s	Build_1B184
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1800,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1B11C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B17C
		cmpi.w	#$1C0,d2
		bhs.s	Build_1B17C
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,Build_1B12C
		rts
; ---------------------------------------------------------------------------

Build_1B17C:
		subq.w	#6,a6
		dbf	d4,Build_1B12C
		rts
; ---------------------------------------------------------------------------

Build_1B184:
		addq.w	#5,a1
		dbf	d4,Build_1B12C
		rts
; ---------------------------------------------------------------------------
byte_1B18C:	dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
; ---------------------------------------------------------------------------

Build_1B19C:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1)+,d6
		move.b	d6,2(a6)
		move.b	byte_1B18C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B1EC
		cmpi.w	#$160,d2
		bhs.s	Build_1B1EC
		move.w	d2,(a6)+
		addq.w	#2,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1000,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		cmpi.w	#$60,d2
		bls.s	Build_1B1E4
		cmpi.w	#$1C0,d2
		bhs.s	Build_1B1E4
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,Build_1B19C
		rts
; ---------------------------------------------------------------------------

Build_1B1E4:
		subq.w	#6,a6
		dbf	d4,Build_1B19C
		rts
; ---------------------------------------------------------------------------

Build_1B1EC:
		addq.w	#4,a1
		dbf	d4,Build_1B19C
		rts
; End of function sub_1B070