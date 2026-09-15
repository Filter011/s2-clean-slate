; ---------------------------------------------------------------------------
; Animation script - Tails
; ---------------------------------------------------------------------------
; off_1D038:
TailsAniData:		offsetTable
			offsetTableEntry.w TailsAni_Walk	;  0 ;   0
			offsetTableEntry.w TailsAni_Run		;  1 ;   1
			offsetTableEntry.w TailsAni_Roll	;  2 ;   2
			offsetTableEntry.w TailsAni_Push	;  3 ;   3
			offsetTableEntry.w TailsAni_Wait	;  4 ;   4
			offsetTableEntry.w TailsAni_Balance	;  5 ;   5
			offsetTableEntry.w TailsAni_LookUp	;  6 ;   6
			offsetTableEntry.w TailsAni_Duck	;  7 ;   7
			offsetTableEntry.w TailsAni_Spindash	;  8 ;   8
			offsetTableEntry.w TailsAni_Dummy1	;  9 ;   9
			offsetTableEntry.w TailsAni_Dummy2	; 10 ;  $A
			offsetTableEntry.w TailsAni_Dummy3	; 11 ;  $B
			offsetTableEntry.w TailsAni_Stop	; 12 ;  $C
			offsetTableEntry.w TailsAni_Float	; 13 ;  $D
			offsetTableEntry.w TailsAni_Float2	; 14 ;  $E
			offsetTableEntry.w TailsAni_Spring	; 15 ;  $F
			offsetTableEntry.w TailsAni_Hang	; 16 ; $10
			offsetTableEntry.w TailsAni_Blink	; 17 ; $11
			offsetTableEntry.w TailsAni_Blink2	; 18 ; $12
			offsetTableEntry.w TailsAni_Hang2	; 19 ; $13
			offsetTableEntry.w TailsAni_Bubble	; 20 ; $14
			offsetTableEntry.w TailsAni_DeathBW	; 21 ; $15
			offsetTableEntry.w TailsAni_Drown	; 22 ; $16
			offsetTableEntry.w TailsAni_Death	; 23 ; $17
			offsetTableEntry.w TailsAni_Hurt	; 24 ; $18
			offsetTableEntry.w TailsAni_Hurt2	; 25 ; $19
			offsetTableEntry.w TailsAni_Slide	; 26 ; $1A
			offsetTableEntry.w TailsAni_Blank	; 27 ; $1B
			offsetTableEntry.w TailsAni_Dummy4	; 28 ; $1C
			offsetTableEntry.w TailsAni_Dummy5	; 29 ; $1D
TailsAni_HaulAss_ptr:	offsetTableEntry.w TailsAni_HaulAss	; 30 ; $1E
TailsAni_Fly_ptr:	offsetTableEntry.w TailsAni_Fly		; 31 ; $1F
TailsAni_FlyUp_ptr:	offsetTableEntry.w TailsAni_Fly			; 32 ; $20 (duplicate)
TailsAni_Carry_ptr:	offsetTableEntry.w TailsAni_Carry		; 33 ; $21
TailsAni_CarryUp_ptr:	offsetTableEntry.w TailsAni_CarryUp		; 34 ; $22
TailsAni_Tired_ptr:	offsetTableEntry.w TailsAni_Tired		; 35 ; $23
TailsAni_CarryTired_ptr:	offsetTableEntry.w TailsAni_CarryTired	; 36 ; $24
TailsAni_Swim_ptr:	offsetTableEntry.w TailsAni_Swim		; 37 ; $25
TailsAni_SwimUp_ptr:	offsetTableEntry.w TailsAni_SwimUp		; 38 ; $26
TailsAni_SwimCarry_ptr:	offsetTableEntry.w TailsAni_SwimCarry		; 39 ; $27
TailsAni_SwimTired_ptr:	offsetTableEntry.w TailsAni_SwimTired		; 40 ; $28

TailsAni_Walk:	dc.b $FF,$10,$11,$12,$13,$14,$15, $E, $F,$FF
TailsAni_Run:	dc.b $FF,$2E,$2F,$30,$31,$FF,$FF,$FF,$FF,$FF
TailsAni_Roll:	dc.b   1,$48,$47,$46,$FF
TailsAni_Push:	dc.b $FD,$63,$64,$65,$66,$FF,$FF,$FF,$FF,$FF
TailsAni_Wait:	dc.b   7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,  2,  1,  1,  1
		dc.b   1,  1,  1,  1,  1,  3,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
		dc.b   6,  7,  8,  7,  8,  7,  8,  7,  8,  7,  8,  6,$FE,$1C
TailsAni_Balance:	dc.b   9,$69,$69,$6A,$6A,$69,$69,$6A,$6A,$69,$69,$6A,$6A,$69,$69,$6A
			dc.b $6A,$69,$69,$6A,$6A,$69,$6A,$FF
TailsAni_LookUp:	dc.b $3F,  4,$FF
TailsAni_Duck:		dc.b $3F,$5B,$FF
TailsAni_Spindash:	dc.b   0,$60,$61,$62,$FF
TailsAni_Dummy1:	dc.b $3F,$82,$FF
TailsAni_Dummy2:	dc.b   7,  8,  8,  9,$FD,  5
TailsAni_Dummy3:	dc.b   7,  9,$FD,  5
TailsAni_Stop:		dc.b   7,$67,$68,$67,$68,$FD,  0
TailsAni_Float:		dc.b   9,$6E,$73,$FF
TailsAni_Float2:	dc.b   9,$6E,$6F,$70,$71,$72,$FF
TailsAni_Spring:	dc.b   3,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$FD,  0
TailsAni_Hang:		dc.b   5,$6C,$6D,$FF
TailsAni_Blink:		dc.b  $F,  1,  2,  3,$FE,  1
TailsAni_Blink2:	dc.b  $F,  1,  2,$FE,  1
TailsAni_Hang2:		dc.b $13,$85,$86,$FF
TailsAni_Bubble:	dc.b  $B,$74,$74,$12,$13,$FD,  0
TailsAni_DeathBW:	dc.b $20,$5D,$FF
TailsAni_Drown:		dc.b $2F,$5D,$FF
TailsAni_Death:		dc.b   3,$5D,$FF
TailsAni_Hurt:		dc.b   3,$5D,$FF
TailsAni_Hurt2:		dc.b   3,$5C,$FF
TailsAni_Slide:		dc.b   9,$6B,$5C,$FF
TailsAni_Blank:		dc.b $77,  0,$FD,  0
TailsAni_Dummy4:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF
TailsAni_Dummy5:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,$FF
TailsAni_HaulAss:	dc.b $FF,$32,$33,$FF
			dc.b $FF,$FF,$FF,$FF,$FF,$FF
TailsAni_Fly:		dc.b	$3F, $8B, $FF
TailsAni_Carry:		dc.b	$3F, $8C, $FF
TailsAni_CarryUp:	dc.b	$3F, $8D, $FF
TailsAni_Tired:		dc.b	$B, $8E, $8F, $FF
TailsAni_CarryTired:	dc.b	$B, $90, $91, $FF
TailsAni_Swim:		dc.b	7, $92, $93, $94, $95, $96, $FF
TailsAni_SwimUp:	dc.b	3, $92, $93, $94, $95, $96, $FF
TailsAni_SwimCarry:	dc.b	4, $97, $98, $FF
TailsAni_SwimTired:	dc.b	$B, $99, $9A, $9B, $9A, $FF
	even
