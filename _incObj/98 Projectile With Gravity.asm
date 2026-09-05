; ----------------------------------------------------------------------------
; Object 98 - Projectile with optional gravity (EHZ coconut, CPZ spiny, etc.)
; ----------------------------------------------------------------------------
; Sprite_376E8:
Obj98:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj98_Index(pc,d0.w),d1
	jmp	Obj98_Index(pc,d1.w)
; ===========================================================================
; off_376F6: Obj98_States:
Obj98_Index:	offsetTable
		offsetTableEntry.w Obj98_Init	; 0
		offsetTableEntry.w Obj98_Main	; 2
; ===========================================================================
; loc_376FA:
Obj98_Init: ;;
	bra.w	LoadSubObject
; ===========================================================================
; loc_376FE:
Obj98_Main:
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.w	JmpTo65_DeleteObject
	movea.l	objoff_2A(a0),a1
	jsr	(a1)	; dynamic call! to Obj98_NebulaBombFall, Obj98_TurtloidShotMove, Obj98_CoconutFall, Obj98_CluckerShotMove, Obj98_SpinyShotFall, or Obj98_WallTurretShotMove, assuming the code hasn't been changed
	jmp	(MarkObjGone).l

; ===========================================================================
; for obj99
; loc_37710:
Obj98_NebulaBombFall:
	bchg	#palette_bit_0,art_tile(a0) ; bypass the animation system and make it blink
	jmp	(ObjectMoveAndFall).l

; ===========================================================================
; for obj9A
; loc_3771A:
Obj98_TurtloidShotMove:
	jsr	(ObjectMove).l
	lea	Ani_TurtloidShot(pc),a1
	jmp	(AnimateSprite).l

; ===========================================================================
; for obj9D
; loc_37728:
Obj98_CoconutFall:
	addi.w	#$20,y_vel(a0) ; apply gravity (less than normal)
	jmp	(ObjectMove).l

; ===========================================================================
; for objAE
; loc_37734:
Obj98_CluckerShotMove:
	jsr	(ObjectMove).l
	lea	Ani_CluckerShot(pc),a1
	jmp	(AnimateSprite).l

; ===========================================================================
; for objA6
; loc_37742:
Obj98_SpinyShotFall:
	addi.w	#$20,y_vel(a0) ; apply gravity (less than normal)
	jsr	(ObjectMove).l
	lea	Ani_SpinyShot(pc),a1
	jmp	(AnimateSprite).l

; ===========================================================================
; for objB8
; loc_37756:
Obj98_WallTurretShotMove:
	jsr	(ObjectMove).l
	lea	Ani_WallTurretShot(pc),a1
	jmp	(AnimateSprite).l
