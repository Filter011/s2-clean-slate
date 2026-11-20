; ===========================================================================
; ----------------------------------------------------------------------------
; Object 01 - Knuckles
; ----------------------------------------------------------------------------
; Sprite_19F50: Object_Knuckles:
Obj09:
	; a0=character
	tst.w	(Debug_placement_mode).w	; is debug mode being used?
	beq.s	Obj09_Normal			; if not, branch
	jmp	(DebugMode).l
; ---------------------------------------------------------------------------
; loc_19F5C:
Obj09_Normal:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj09_Index(pc,d0.w),d1
	jmp	Obj09_Index(pc,d1.w)
; ===========================================================================
; off_19F6A: Obj09_States:
Obj09_Index:	offsetTable
		offsetTableEntry.w Obj09_Init		;  0
		offsetTableEntry.w Obj09_Control	;  2
		offsetTableEntry.w Obj09_Hurt		;  4
		offsetTableEntry.w Obj09_Dead		;  6
		offsetTableEntry.w Obj09_Gone		;  8
		offsetTableEntry.w Obj09_Respawning	; $A
; ===========================================================================
; loc_19F76: Obj_01_Sub_0: Obj09_Main:
Obj09_Init:
	addq.b	#2,routine(a0)	; => Obj09_Control
	move.b	#$13,y_radius(a0) ; this sets Knuckles's collision height (2*pixels)
	move.b	#9,x_radius(a0)
	move.l	#MapUnc_Knuckles,mappings(a0)
	move.w	#2*$80,priority(a0)
	move.b	#$18,width_pixels(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.w	#$600,(Knuckles_top_speed).w	; set Knuckles's top speed
	move.w	#$C,(Knuckles_acceleration).w	; set Knuckles's acceleration
	move.w	#$80,(Knuckles_deceleration).w	; set Knuckles's deceleration
	tst.b	(Last_star_pole_hit).w
	bne.s	Obj09_Init_Continued
	; only happens when not starting at a checkpoint:
	move.w	#ArtTile_ArtUnc_Sonic,art_tile(a0)
	move.w	#$0C0D,top_solid_bit(a0)	; and lrb_solid_bit
	move.w	x_pos(a0),(Saved_x_pos).w
	move.w	y_pos(a0),(Saved_y_pos).w
	move.w	art_tile(a0),(Saved_art_tile).w
	move.w	top_solid_bit(a0),(Saved_Solid_bits).w

Obj09_Init_Continued:
	moveq	#0,d1
	move.b	d1,flips_remaining(a0)
	move.b	#4,flip_speed(a0)
	move.b	d1,(Super_Sonic_flag).w
	move.b	#30,air_left(a0)
	subi.w	#$20,x_pos(a0)
	addq.w	#4,y_pos(a0)
	move.w	d1,(Sonic_Pos_Record_Index).w

	moveq	#$3F,d2
-	bsr.w	Knuckles_RecordPos
	subq.w	#4,a1
	move.l	d1,(a1)
	dbf	d2,-

	addi.w	#$20,x_pos(a0)
	subq.w	#4,y_pos(a0)

; ---------------------------------------------------------------------------
; Normal state for Knuckles
; ---------------------------------------------------------------------------
; loc_1A030: Obj_01_Sub_2:
Obj09_Control:
	tst.w	(Debug_mode_flag).w	; is debug cheat enabled?
	beq.s	+			; if not, branch
	btst	#button_B,(Ctrl_1_Press).w	; is button B pressed?
	beq.s	+			; if not, branch
	move.w	#1,(Debug_placement_mode).w	; change Knuckles into a ring/item
	clr.b	(Control_Locked).w		; unlock control
	rts
; -----------------------------------------------------------------------
+	tst.b	(Control_Locked).w	; are controls locked?
	bne.s	+			; if yes, branch
	move.w	(Ctrl_1).w,(Ctrl_1_Logical).w	; copy new held buttons, to enable joypad control
+
	btst	#0,obj_control(a0)	; is Knuckles interacting with another object that holds him in place or controls his movement somehow?
	beq.s	+
	clr.b	double_jump_flag(a0)
	bra.s	++
+
	moveq	#1<<status.player.in_air|1<<status.player.rolling,d0	; %0000 %0110
	and.b	status(a0),d0
	move.w	Obj09_Modes(pc,d0.w),d1
	jsr	Obj09_Modes(pc,d1.w)	; run Knuckles's movement control code
+
	cmpi.w	#-$100,(Camera_Min_Y_pos).w	; is vertical wrapping enabled?
	bne.s	+				; if not, branch
	andi.w	#$7FF,y_pos(a0) 		; perform wrapping of Knuckles's y position
+
	bsr.s	Knuckles_Display
	bsr.w	Knuckles_Super
	bsr.w	Knuckles_RecordPos
	bsr.w	Knuckles_Water
	move.b	(Primary_Angle).w,next_tilt(a0)
	move.b	(Secondary_Angle).w,tilt(a0)
	tst.b	(WindTunnel_flag).w
	beq.s	+
	tst.b	anim(a0)
	bne.s	+
	move.b	prev_anim(a0),anim(a0)
+
	bsr.w	Knuckles_Animate
	tst.b	obj_control(a0)
	bmi.s	+
	jsr	(TouchResponse).l
+
	bra.w	LoadKnucklesDynPLC

; ===========================================================================
; secondary states under state Obj09_Control
; off_1A0BE:
Obj09_Modes:	offsetTable
		offsetTableEntry.w Obj09_MdNormal_Checks	; 0 - not airborne or rolling
		offsetTableEntry.w Obj09_MdAir			; 2 - airborne
		offsetTableEntry.w Obj09_MdRoll			; 4 - rolling
		offsetTableEntry.w Obj09_MdJump			; 6 - jumping
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A0C6:
Knuckles_Display:
	move.b	invulnerable_time(a0),d0
	beq.s	Obj09_Display
	subq.b	#1,invulnerable_time(a0)
	lsr.b	#3,d0
	bcc.s	Obj09_ChkInvin
; loc_1A0D4:
Obj09_Display:
	jsr	(DisplaySprite).w
; loc_1A0DA:
Obj09_ChkInvin:		; Checks if invincibility has expired and disables it if it has.
	btst	#status_secondary.invincible,status_secondary(a0)
	beq.s	Obj09_ChkShoes
	tst.w	invincibility_time(a0)
	beq.s	Obj09_ChkShoes	; If there wasn't any time left, that means we're in Super Knuckles mode.
	subq.w	#1,invincibility_time(a0)
	bne.s	Obj09_ChkShoes
	tst.b	(Current_Boss_ID).w	; Don't change music if in a boss fight
	bne.s	Obj09_RmvInvin
	cmpi.b	#12,air_left(a0)	; Don't change music if drowning
	blo.s	Obj09_RmvInvin
	jsr	(PlayLevelMusic).w
;loc_1A106:
Obj09_RmvInvin:
	bclr	#status_secondary.invincible,status_secondary(a0)
; loc_1A10C:
Obj09_ChkShoes:		; Checks if Speed Shoes have expired and disables them if they have.
	btst	#status_secondary.speed_shoes,status_secondary(a0)
	beq.s	Obj09_ExitChk
	tst.w	speedshoes_time(a0)
	beq.s	Obj09_ExitChk
	subq.w	#1,speedshoes_time(a0)
	bne.s	Obj09_ExitChk
	move.w	#$600,(Knuckles_top_speed).w
	move.w	#$C,(Knuckles_acceleration).w
	move.w	#$80,(Knuckles_deceleration).w
	tst.b	(Super_Sonic_flag).w
	beq.s	Obj09_RmvSpeed
	move.w	#$800,(Knuckles_top_speed).w
	move.w	#$18,(Knuckles_acceleration).w
	move.w	#$C0,(Knuckles_deceleration).w
; loc_1A14A:
Obj09_RmvSpeed:
	bclr	#status_secondary.speed_shoes,status_secondary(a0)
	move.w	#MusID_SlowDown,d0	; Slow down tempo
	jmp	(PlayMusic).w
; ---------------------------------------------------------------------------
; return_1A15A:
Obj09_ExitChk:
	rts
; End of subroutine Knuckles_Display

; ---------------------------------------------------------------------------
; Subroutine to record Knuckles's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; loc_1A15C:
Knuckles_RecordPos:
	move.w	(Sonic_Pos_Record_Index).w,d0
	lea	(Sonic_Pos_Record_Buf).w,a1
	lea	(a1,d0.w),a1
	move.w	x_pos(a0),(a1)+
	move.w	y_pos(a0),(a1)+
	addq.b	#4,(Sonic_Pos_Record_Index+1).w

	lea	(Sonic_Stat_Record_Buf).w,a1
	lea	(a1,d0.w),a1
	move.w	(Ctrl_1_Logical).w,(a1)+
	move.w	status(a0),(a1)+ ; Copies `status` AND the byte after it...

	rts
; End of subroutine Knuckles_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Knuckles when he's underwater
; ---------------------------------------------------------------------------

; loc_1A186:
Knuckles_Water:
	tst.b	(Water_flag).w	; does level have water?
	bne.s	Obj09_InWater	; if yes, branch

return_1A18C_K:
	rts
; ---------------------------------------------------------------------------
; loc_1A18E:
Obj09_InWater:
	move.w	(Water_Level_1).w,d0
	cmp.w	y_pos(a0),d0	; is Knuckles above the water?
	bge.s	Obj09_OutWater	; if yes, branch

	bset	#status.player.underwater,status(a0)	; set underwater flag
	bne.s	return_1A18C_K	; if already underwater, branch

	movea.l	a0,a1
	bsr.w	ResumeMusic
	move.b	#ObjID_SmallBubbles,(Sonic_BreathingBubbles+id).w ; load Obj0A (Knuckles's breathing bubbles) at $FFFFD080
	move.b	#$81,(Sonic_BreathingBubbles+subtype).w
	move.l	a0,(Sonic_BreathingBubbles+obj0a_character).w
	move.w	#$300,(Knuckles_top_speed).w
	move.w	#6,(Knuckles_acceleration).w
	move.w	#$40,(Knuckles_deceleration).w
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	#$400,(Knuckles_top_speed).w
	move.w	#$C,(Knuckles_acceleration).w
	move.w	#$60,(Knuckles_deceleration).w
+
	asr.w	x_vel(a0)
	asr.w	y_vel(a0)	; memory operands can only be shifted one bit at a time
	asr.w	y_vel(a0)
	beq.s	return_1A18C_K
	move.w	#(1<<8)|(0<<0),(Sonic_Dust+anim).w	; splash animation
	moveq	#SndID_Splash,d0	; splash sound
	jmp	(PlaySound).w
; ---------------------------------------------------------------------------
; loc_1A1FE:
Obj09_OutWater:
	bclr	#status.player.underwater,status(a0) ; unset underwater flag
	beq.s	return_1A18C_K ; if already above water, branch

	movea.l	a0,a1
	bsr.w	ResumeMusic
	move.w	#$600,(Knuckles_top_speed).w
	move.w	#$C,(Knuckles_acceleration).w
	move.w	#$80,(Knuckles_deceleration).w
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	#$800,(Knuckles_top_speed).w
	move.w	#$18,(Knuckles_acceleration).w
	move.w	#$C0,(Knuckles_deceleration).w
+
	cmpi.b	#4,routine(a0)	; is Knuckles falling back from getting hurt?
	beq.s	+		; if yes, branch
	asl.w	y_vel(a0)
+
	tst.w	y_vel(a0)
	beq.w	return_1A18C
	move.w	#(1<<8)|(0<<0),(Sonic_Dust+anim).w	; splash animation
	movea.l	a0,a1
	bsr.w	ResumeMusic
	cmpi.w	#-$1000,y_vel(a0)
	bgt.s	+
	move.w	#-$1000,y_vel(a0)	; limit upward y velocity exiting the water
+
	moveq	#SndID_Splash,d0	; splash sound
	jmp	(PlaySound).w
; End of subroutine Knuckles_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine Obj09_MdNormal
; Called if Knuckles is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------
; loc_1A26E:
Obj09_MdNormal_Checks:
	bsr.w	Knuckles_CheckSpindash
	bsr.w	Knuckles_Jump
	bsr.w	Player_SlopeResist
	bsr.w	Knuckles_Move
	bsr.w	Knuckles_Roll
	bsr.w	Knuckles_LevelBound
	jsr	(ObjectMove).w
	bsr.w	AnglePos
	bra.w	Player_SlopeRepel
; End of subroutine Obj09_MdNormal
; ===========================================================================
; Start of subroutine Obj09_MdAir
; Called if Knuckles is airborne, but not in a ball (thus, probably not jumping)
; loc_1A2E0: Obj09_MdJump
Obj09_MdAir:
	tst.b	double_jump_flag(a0)
	bne.s	Obj09_MdAir_Gliding
	bsr.w	Knuckles_JumpHeight
	bsr.w	Knuckles_ChgJumpDir
	bsr.w	Knuckles_LevelBound
	jsr	(ObjectMoveAndFall).w
	btst	#status.player.underwater,status(a0)	; is Knuckles underwater?
	beq.s	+		; if not, branch
	subi.w	#$28,y_vel(a0)	; reduce gravity by $28 ($38-$28=$10)
+
	bsr.w	Knuckles_JumpAngle
	bra.w	Knuckles_DoLevelCollision
; End of subroutine Obj09_MdAir

return_3156B8:
	rts

Obj09_MdAir_Gliding:
	bsr.w	Knuckles_GlideSpeedControl
	bsr.w	Knuckles_LevelBound
	jsr	(ObjectMove).w


; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideControl:
	move.b	double_jump_flag(a0),d0
	beq.s	return_3156B8
	cmpi.b	#2,d0
	beq.w	Knuckles_FallingFromGlide
	cmpi.b	#3,d0
	beq.w	Knuckles_Sliding
	cmpi.b	#4,d0
	beq.w	Knuckles_Climbing_Wall
	cmpi.b	#5,d0
	beq.w	Knuckles_Climbing_Onto_Ledge

;Knuckles_NormalGlide:
	; These two lines are not here in S3K.
	move.b	#10,y_radius(a0)
	move.b	#10,x_radius(a0)

	; This function updates 'Gliding_collision_flags'.
	bsr.w	Knuckles_DoLevelCollision2

	btst	#status.player.pushing,(Gliding_collision_flags).w
	bne.w	Knuckles_BeginClimb

	; These two lines are not here in S3K.
	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	btst	#status.player.in_air,(Gliding_collision_flags).w
	beq.s	Knuckles_BeginSlide

	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_A_mask|button_B_mask|button_C_mask,d0
	bne.s	.continueGliding

	; The player has let go of the jump button, so exit the gliding state
	; and enter the falling state.
	move.b	#2,double_jump_flag(a0)
	move.b	#AniIDKnuxAni_FallAfterGlide,anim(a0)
	bclr	#status.player.x_flip,status(a0)
	tst.w	x_vel(a0)
	bpl.s	+
	bset	#status.player.x_flip,status(a0)
+
	; Divide Knuckles' X velocity by 4.
	asr.w	x_vel(a0)
	asr.w	x_vel(a0)

	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	rts
; ---------------------------------------------------------------------------

.continueGliding:
	bra.w	Knuckles_DoGlidingAnimation
; ---------------------------------------------------------------------------

Knuckles_BeginSlide:
	bclr	#status.player.x_flip,status(a0)
	tst.w	x_vel(a0)
	bpl.s	+
	bset	#status.player.x_flip,status(a0)
+
	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	loc_315780

	move.w	inertia(a0),x_vel(a0)
	move.w	#0,y_vel(a0)

	bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_315780:
	move.b	#3,double_jump_flag(a0)
	move.b	#$CC,mapping_frame(a0)
	move.b	#$7F,anim_frame_duration(a0)
	move.b	#0,anim_frame(a0)

	; The drowning countdown uses the dust clouds' VRAM, so don't create
	; dust if Knuckles is drowning.
	cmpi.b	#12,air_left(a0)
	blo.s	+
	; Create dust clouds.
	move.b	#6,(Sonic_Dust+routine).w
	move.b	#$15,(Sonic_Dust+mapping_frame).w
+
	rts
; ---------------------------------------------------------------------------

Knuckles_BeginClimb:
	tst.b	(Disable_wall_grab).w
	bmi.w	.fail

	move.b	lrb_solid_bit(a0),d5
	move.b	double_jump_property(a0),d0
	addi.b	#$40,d0
	bpl.s	.right

;.left:
	bset	#status.player.x_flip,status(a0)

	bsr.w	CheckLeftCeilingDist
	or.w	d0,d1
	bne.s	.checkFloorLeft

	addq.w	#1,x_pos(a0)
	bra.s	.success

.right:
	bclr	#status.player.x_flip,status(a0)

	bsr.w	CheckRightCeilingDist
	or.w	d0,d1
	bne.w	.checkFloorRight
; loc_3157E8:
.success:
	; These two lines aren't here in S3K.
	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	moveq	#SndID_Grab,d0

	; If Hyper Knuckles glides into a wall at a high-enough
	; speed, then make the screen shake and harm all enemies
	; on-screen.
	; This code is leftover and useless in KiS2.
	tst.b	(Super_Sonic_flag).w
	beq.s	.noQuake

	cmpi.w	#$480,inertia(a0)
	blo.s	.noQuake

	nop
	; This is the code that replaced the above 'nop' in S3K.
	;move.w	#$14,(Glide_screen_shake).w
	;bsr.w	HyperAttackTouchResponse
	;moveq	#signextendB(sfx_Thump),d0

.noQuake:
	jsr	(PlaySound).w
	move.w	#0,inertia(a0)
	move.l	#0,x_vel(a0)
	move.b	#4,double_jump_flag(a0)
	move.b	#$B7,mapping_frame(a0)
	move.b	#$7F,anim_frame_duration(a0)
	move.b	#0,anim_frame(a0)
	move.b	#3,double_jump_property(a0)
	; 'x_sub' holds the X coordinate that Knuckles was at when he first
	; latched onto the wall.
	move.w	x_pos(a0),x_sub(a0)
	rts
; ---------------------------------------------------------------------------

.checkFloorLeft:
	; This adds the Y radius to the X coordinate...
	; This appears to be a bug, but, luckily, the X and Y radius are both
	; 10, so this is harmless.
	move.w	x_pos(a0),d3
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	subq.w	#1,d3
; loc_31584A:
.checkFloorCommon:
	move.w	y_pos(a0),d2
	subi.w	#11,d2
	jsr	(ChkFloorEdge_Part3).l

	tst.w	d1
	bmi.s	.fail
	cmpi.w	#12,d1
	bhs.s	.fail
	add.w	d1,y_pos(a0)
	bra.w	.success
; ---------------------------------------------------------------------------
; loc_31586A:
.checkFloorRight:
	; This adds the Y radius to the X coordinate...
	; This appears to be a bug, but, luckily, the X and Y radius are both
	; 10, so this is harmless.
	move.w	x_pos(a0),d3
	move.b	y_radius(a0),d0
	ext.w	d0
	add.w	d0,d3
	addq.w	#1,d3
	bra.s	.checkFloorCommon
; ---------------------------------------------------------------------------
; loc_31587A:
.fail:
	move.b	#2,double_jump_flag(a0)
	move.b	#AniIDKnuxAni_FallAfterGlide,anim(a0)
	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)
	bset	#status.player.in_air,(Gliding_collision_flags).w
	rts
; ---------------------------------------------------------------------------

Knuckles_FallingFromGlide:
	bsr.w	Knuckles_ChgJumpDir

	; Apply gravity.
	addi.w	#$38,y_vel(a0)

	; Fall slower when underwater.
	btst	#status.player.underwater,status(a0)
	beq.s	+
	subi.w	#$28,y_vel(a0)
+
	; This function updates 'Gliding_collision_flags'.
	bsr.w	Knuckles_DoLevelCollision2

	btst	#status.player.in_air,(Gliding_collision_flags).w
	bne.s	.return

	; Knuckles has touched the ground.
	move.w	#0,inertia(a0)
	move.l	#0,x_vel(a0)

	move.b	y_radius(a0),d0
	subi.b	#19,d0
	ext.w	d0
	add.w	d0,y_pos(a0)

	moveq	#SndID_GlideLand,d0
	jsr	(PlaySound).w

	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	+
	bra.w	Knuckles_ResetOnFloor_Part2
+
	bsr.w	Knuckles_ResetOnFloor_Part2
	move.w	#$F,move_lock(a0)
	move.b	#AniIDKnuxAni_LandAfterGlide,anim(a0)
; return_315900:
.return:
	rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_A_mask|button_B_mask|button_C_mask,d0
	beq.s	.getUp

	tst.w	x_vel(a0)
	bpl.s	.goingRight

;.goingLeft:
	addi.w	#$20,x_vel(a0)
	bmi.s	.continueSliding2

	bra.s	.getUp
; ---------------------------------------------------------------------------
; loc_31591C:
.continueSliding2:
	bra.s	.continueSliding
; ---------------------------------------------------------------------------
; loc_31591E:
.goingRight:
	subi.w	#$20,x_vel(a0)
	bpl.s	.continueSliding
; loc_315926:
.getUp:
	move.w	#0,inertia(a0)
	move.l	#0,x_vel(a0)

	move.b	y_radius(a0),d0
	subi.b	#19,d0
	ext.w	d0
	add.w	d0,y_pos(a0)

	bsr.w	Knuckles_ResetOnFloor_Part2

	move.w	#$F,move_lock(a0)
	move.b	#AniIDKnuxAni_ClimbLedge,anim(a0)

	rts
; ---------------------------------------------------------------------------
; loc_315958:
.continueSliding:
	; These two lines aren't here in S3K.
	move.b	#10,y_radius(a0)
	move.b	#10,x_radius(a0)

	bsr.w	Knuckles_DoLevelCollision2

	; Get distance from floor in 'd1', and angle of floor in 'd3'.
	bsr.w	Sonic_CheckFloor

	; If the distance from the floor is suddenly really high, then
	; Knuckles must have slid off a ledge, so make him enter his falling
	; state.
	cmpi.w	#14,d1
	bge.s	.fall

	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)

	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	; Play the sliding sound every 8 frames.
	moveq	#7,d0
	and.b	(Vint_runcount+3).w,d0
	bne.s	+

	moveq	#SndID_GroundSlide,d0
	jmp	(PlaySound).w
+
	rts
; ---------------------------------------------------------------------------
; loc_315988:
.fall:
	move.b	#2,double_jump_flag(a0)
	move.b	#AniIDKnuxAni_FallAfterGlide,anim(a0)

	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	bset	#status.player.in_air,(Gliding_collision_flags).w
	rts
; ---------------------------------------------------------------------------

Knuckles_Climbing_Wall:
	tst.b	(Disable_wall_grab).w
	bmi.w	Knuckles_LetGoOfWall

	; If Knuckles' X coordinate is no longer the same as when he first
	; latched onto the wall, then detach him from the wall. This is
	; probably intended to detach Knuckles from the wall if something
	; physically pushes him away from it.
	move.w	x_pos(a0),d0
	cmp.w	x_sub(a0),d0
	bne.w	Knuckles_LetGoOfWall

	; If an object is now carrying Knuckles, then detach him from the
	; wall.
	btst	#status.player.on_object,status(a0)
	bne.w	Knuckles_LetGoOfWall

	move.w	#0,inertia(a0)
	move.l	#0,x_vel(a0)

	move.l	(Primary_Collision).w,(Collision_addr).w
	cmpi.b	#$D,lrb_solid_bit(a0)
	beq.s	+
	move.l	(Secondary_Collision).w,(Collision_addr).w
+
	move.b	lrb_solid_bit(a0),d5

	; These two lines aren't in S3K.
	move.b	#10,y_radius(a0)
	move.b	#10,x_radius(a0)

	moveq	#0,d1	; Climbing animation delta: make the animation pause.

	btst	#button_up,(Ctrl_1_Held_Logical).w
	beq.w	.notClimbingUp

;.climbingUp:
	; Get Knuckles' distance from the wall in 'd1'.
	move.w	y_pos(a0),d2
	subi.w	#11,d2
	bsr.w	GetDistanceFromWall

	; If the wall is far away from Knuckles, then we must have reached a
	; ledge, so make Knuckles climb up onto it.
	cmpi.w	#4,d1
	bge.w	Knuckles_ClimbUp

	; If Knuckles has encountered a small dip in the wall, then make him
	; stop.
	tst.w	d1
	bne.w	.notMoving

	; Get Knuckles' distance from the ceiling in 'd1'.
	move.b	lrb_solid_bit(a0),d5
	move.w	y_pos(a0),d2
	subq.w	#8,d2
	move.w	x_pos(a0),d3
	bsr.w	CheckCeilingDist_WithRadius

	; Check if Knuckles has room above him.
	tst.w	d1
	bpl.s	.moveUp

	; Knuckles is bumping into the ceiling, so push him out.
	sub.w	d1,y_pos(a0)

	moveq	#1,d1	; Climbing animation delta: make the animation play forwards.
	bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_315A46:
.moveUp:
	subq.w	#1,y_pos(a0)

	; Super Knuckles and Hyper Knuckles climb walls faster.
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	subq.w	#1,y_pos(a0)
+
	moveq	#1,d1	; Climbing animation delta: make the animation play forwards.

	; Don't let Knuckles climb through the level's upper boundary.
	move.w	(Camera_Min_Y_pos).w,d0

	; If the level wraps vertically, then don't bother with any of this.
	cmpi.w	#-$100,d0
	beq.w	.finishMoving

	; Check if Knuckles is over the level's top boundary.
	addi.w	#16,d0
	cmp.w	y_pos(a0),d0
	ble.w	.finishMoving

	; Knuckles is climbing over the level's top boundary: push him back
	; down.
	move.w	d0,y_pos(a0)
	bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_315A76:
.notClimbingUp:
	btst	#button_down,(Ctrl_1_Held_Logical).w
	beq.w	.finishMoving

;.climbingDown:
	; ...I'm not sure what this code is for.
	cmpi.b	#$BD,mapping_frame(a0)
	bne.s	+
	move.b	#$B7,mapping_frame(a0)
	addq.w	#3,y_pos(a0)
	subq.w	#3,x_pos(a0)
	btst	#status.player.x_flip,status(a0)
	beq.s	+
	addq.w	#3*2,x_pos(a0)
+
	; Get Knuckles' distance from the wall in 'd1'.
	move.w	y_pos(a0),d2
	addi.w	#11,d2
	bsr.w	GetDistanceFromWall

	; If Knuckles is no longer against the wall (he has climbed off the
	; bottom of it) then make him let go.
	tst.w	d1
	bne.w	Knuckles_LetGoOfWall

	; Get Knuckles' distance from the floor in 'd1'.
	move.b	top_solid_bit(a0),d5
	move.w	y_pos(a0),d2
	addi.w	#9,d2
	move.w	x_pos(a0),d3
	bsr.w	CheckFloorDist_WithRadius

	; Check if Knuckles has room below him.
	tst.w	d1
	bpl.s	.moveDown

	; Knuckles has reached the floor.
	add.w	d1,y_pos(a0)
	move.b	(Primary_Angle).w,angle(a0)

	move.w	#0,inertia(a0)
	move.l	#0,x_vel(a0)

	bsr.w	Knuckles_ResetOnFloor_Part2

	move.b	#AniIDKnuxAni_Wait,anim(a0)

	rts
; ---------------------------------------------------------------------------
; loc_315AF4:
.moveDown:
	addq.w	#1,y_pos(a0)

	; Super Knuckles and Hyper Knuckles climb walls faster.
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	addq.w	#1,y_pos(a0)
+
	moveq	#-1,d1	; Climbing animation delta: make the animation play backwards.

; loc_315B04:
.finishMoving:
.isMovingUpOrDown:
	; If Knuckles has not moved, skip this.
	tst.w	d1
	beq.s	.notMoving

	; Only animate every 4 frames.
	subq.b	#1,double_jump_property(a0)
	bpl.s	.notMoving
	move.b	#3,double_jump_property(a0)

	; Add delta to animation frame.
	add.b	mapping_frame(a0),d1

	; Make the animation loop.
	cmpi.b	#$B7,d1
	bhs.s	+
	move.b	#$BC,d1
+
	cmpi.b	#$BC,d1
	bls.s	+
	move.b	#$B7,d1
+
	; Apply the frame.
	move.b	d1,mapping_frame(a0)
; loc_315B30:
.notMoving:
	move.b	#$20,anim_frame_duration(a0)
	move.b	#0,anim_frame(a0)

	; These two lines aren't in S3K.
	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	move.w	(Ctrl_1_Held_Logical).w,d0
	andi.w	#button_A_mask|button_B_mask|button_C_mask,d0
	beq.s	.hasNotJumped

	; Knuckles has jumped off the wall.
	move.w	#-$380,y_vel(a0)
	move.w	#$400,x_vel(a0)

	bchg	#status.player.x_flip,status(a0)
	bne.s	+
	neg.w	x_vel(a0)
+
	bset	#status.player.in_air,status(a0)
	move.b	#1,jumping(a0)

	move.b	#14,y_radius(a0)
	move.b	#7,x_radius(a0)

	move.b	#AniIDKnuxAni_Roll,anim(a0)
	bset	#status.player.rolling,status(a0)
	move.b	#0,double_jump_flag(a0)
; return_315B94:
.hasNotJumped:
	rts
; ---------------------------------------------------------------------------

Knuckles_ClimbUp:
	move.b	#5,double_jump_flag(a0)		  ; Climb up to	the floor above	you

	cmpi.b	#$BD,mapping_frame(a0)
	beq.s	+

	move.b	#0,double_jump_property(a0)
	bra.s	Knuckles_DoLedgeClimbingAnimation
+
	rts
; ---------------------------------------------------------------------------
; loc_315BAE:
Knuckles_LetGoOfWall:
	move.b	#2,double_jump_flag(a0)

	move.w	#(AniIDKnuxAni_FallAfterGlide<<8)|AniIDKnuxAni_FallAfterGlide,anim(a0)
	move.b	#$CB,mapping_frame(a0)
	move.b	#7,anim_frame_duration(a0)
	move.b	#1,anim_frame(a0)

	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)

	rts
; End of function Knuckles_GlideControl


; =============== S U B	R O U T	I N E =======================================

; sub_315BDA:
Knuckles_DoLedgeClimbingAnimation:
	moveq	#0,d0
	move.b	double_jump_property(a0),d0
	lea	.frames(pc,d0.w),a1

	move.b	(a1)+,mapping_frame(a0)

	move.b	(a1)+,d0
	ext.w	d0
	btst	#status.player.x_flip,status(a0)
	beq.s	+
	neg.w	d0
+
	add.w	d0,x_pos(a0)

	move.b	(a1)+,d1
	ext.w	d1
	add.w	d1,y_pos(a0)

	move.b	(a1)+,anim_frame_duration(a0)

	addq.b	#4,double_jump_property(a0)
	move.b	#0,anim_frame(a0)
	rts
; End of function Knuckles_DoLedgeClimbingAnimation

; ---------------------------------------------------------------------------
; Strangely, the last frame uses frame $D2. It will never be seen, however,
; because it is immediately overwritten by Knuckles' waiting animation.

; word_315C12:
.frames:
	; mapping_frame, x_pos, y_pos, anim_frame_timer
	dc.b $BD,   3,  -3,   6
	dc.b $BE,   8, -10,   6
	dc.b $BF,  -8, -12,   6
	dc.b $D2,   8,  -5,   6
.framesEnd:

; =============== S U B	R O U T	I N E =======================================

; sub_315C22:
GetDistanceFromWall:
	move.b	lrb_solid_bit(a0),d5
	btst	#status.player.x_flip,status(a0)
	bne.s	.facingLeft

;.facingRight:
	move.w	x_pos(a0),d3
	bra.w	CheckRightWallDist_WithRadius
; ---------------------------------------------------------------------------
; loc_315C36:
.facingLeft:
	move.w	x_pos(a0),d3
	subq.w	#1,d3
	bra.w	CheckLeftWallDist_WithRadius
; End of function GetDistanceFromWall

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Knuckles_GlideControl
; Knuckles_Climbing_Up:
Knuckles_Climbing_Onto_Ledge:
	tst.b	anim_frame_duration(a0)
	bne.s	return_315C7A

	bsr.w	Knuckles_DoLedgeClimbingAnimation

	; Have we reached the end of the ledge-climbing animation?
	cmpi.b	#Knuckles_DoLedgeClimbingAnimation.framesEnd-Knuckles_DoLedgeClimbingAnimation.frames,double_jump_property(a0)
	bne.s	return_315C7A

	; Yes.
	move.w	#0,inertia(a0)
	move.l	#0,x_vel(a0)

	btst	#status.player.x_flip,status(a0)
	beq.s	+
	subq.w	#1,x_pos(a0)
+
	bsr.w	Knuckles_ResetOnFloor_Part2
	move.b	#AniIDKnuxAni_Wait,anim(a0)

return_315C7A:
	rts
; END OF FUNCTION CHUNK	FOR Knuckles_GlideControl

; =============== S U B	R O U T	I N E =======================================

; sub_315C7C:
Knuckles_DoGlidingAnimation:
	move.b	#$20,anim_frame_duration(a0)
	move.b	#0,anim_frame(a0)
	move.w	#(AniIDKnuxAni_Glide<<8)|AniIDKnuxAni_Glide,anim(a0)
	bclr	#status.player.pushing,status(a0)
	bclr	#status.player.x_flip,status(a0)

	; Update Knuckles' frame, depending on where he's facing.
	moveq	#0,d0
	move.b	double_jump_property(a0),d0
	addi.b	#$10,d0
	lsr.w	#5,d0
	move.b	.frames(pc,d0.w),d1
	move.b	d1,mapping_frame(a0)
	cmpi.b	#$C4,d1
	bne.s	+
	bset	#status.player.x_flip,status(a0)
	move.b	#$C0,mapping_frame(a0)
+
	rts
; End of function Knuckles_DoGlidingAnimation

; ---------------------------------------------------------------------------
; byte_315CC2:
.frames:	dc.b $C0, $C1, $C2, $C3, $C4, $C3, $C2, $C1

; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideSpeedControl:
	cmpi.b	#1,double_jump_flag(a0)
	bne.w	.doNotKillspeed

	move.w	inertia(a0),d0
	cmpi.w	#$400,d0
	bhs.s	.mediumSpeed

;.lowSpeed:
	; Increase Knuckles' speed.
	addq.w	#8,d0
	bra.s	.applySpeed
; ---------------------------------------------------------------------------
; loc_315CE2:
.mediumSpeed:
	; If Knuckles is at his speed limit, then don't increase his speed.
	cmpi.w	#$1800,d0
	bhs.s	.applySpeed

	; If Knuckles is turning, then don't increase his speed either.
	move.b	double_jump_property(a0),d1
	andi.b	#$7F,d1
	bne.s	.applySpeed

	; Increase Knuckles' speed.
	addq.w	#4,d0

	; Super Knuckles and Hyper Knuckles glide faster.
	tst.b	(Super_Sonic_flag).w
	beq.s	.applySpeed
	addq.w	#8,d0
; loc_315CFC:
.applySpeed:
	move.w	d0,inertia(a0)

	move.b	double_jump_property(a0),d0
	btst	#button_left,(Ctrl_1_Held_Logical).w
	beq.s	.notHoldingLeft

;.holdingLeft:
	; Playing is holding left.
	cmpi.b	#$80,d0
	beq.s	.notHoldingLeft
	tst.b	d0
	bpl.s	+
	neg.b	d0
+
	addq.b	#2,d0
	bra.s	.setNewTurningValue
; ---------------------------------------------------------------------------
; loc_315D1C:
.notHoldingLeft:
	btst	#button_right,(Ctrl_1_Held_Logical).w
	beq.s	.notHoldingRight

;.holdingRight:
	; Playing is holding right.
	tst.b	d0
	beq.s	.notHoldingRight
	bmi.s	+
	neg.b	d0
+
	addq.b	#2,d0
	bra.s	.setNewTurningValue
; ---------------------------------------------------------------------------
; loc_315D30:
.notHoldingRight:
	move.b	d0,d1
	andi.b	#$7F,d1
	beq.s	.setNewTurningValue
	addq.b	#2,d0
; loc_315D3A:
.setNewTurningValue:
	move.b	d0,double_jump_property(a0)

	move.b	double_jump_property(a0),d0
	jsr	(CalcSine).w
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	move.w	d1,x_vel(a0)

	; Is Knuckles is falling at a high speed, then create a parachute
	; effect, where gliding makes Knuckles fall slower.
	cmpi.w	#$80,y_vel(a0)
	blt.s	.fallingSlow
	subi.w	#$20,y_vel(a0)
	bra.s	.fallingFast
; ---------------------------------------------------------------------------
; loc_315D62:
.fallingSlow:
	; Apply gravity.
	addi.w	#$20,y_vel(a0)
; loc_315D68:
.fallingFast:
	; If Knuckles is above the level's top boundary, then kill his
	; horizontal speed.
	move.w	(Camera_Min_Y_pos).w,d0
	cmpi.w	#-$100,d0
	beq.s	.doNotKillspeed

	addi.w	#$10,d0
	cmp.w	y_pos(a0),d0
	ble.s	.doNotKillspeed

	asr.w	x_vel(a0)
	asr.w	inertia(a0)
; loc_315D88:
.doNotKillspeed:
	cmpi.w	#$60,(Camera_Y_pos_bias).w
	beq.s	.doNotModifyBias
	bhs.s	+
	addq.w	#2*2,(Camera_Y_pos_bias).w
+
	subq.w	#2,(Camera_Y_pos_bias).w
; return_315D9A:
.doNotModifyBias:
	rts
; End of function Knuckles_GlideSpeedControl


; ===========================================================================
; Start of subroutine Obj09_MdRoll
; Called if Knuckles is in a ball, but not airborne (thus, probably rolling)
; loc_1A30A:
Obj09_MdRoll:
	tst.b	pinball_mode(a0)
	bne.s	+
	bsr.w	Knuckles_Jump
+
	bsr.w	Player_RollRepel
	bsr.w	Knuckles_RollSpeed
	bsr.w	Knuckles_LevelBound
	jsr	(ObjectMove).w
	bsr.w	AnglePos
	bra.w	Player_SlopeRepel
; End of subroutine Obj09_MdRoll
; ===========================================================================
; Start of subroutine Obj09_MdJump
; Called if Knuckles is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj09_MdAir, at least at this outer level.
;        Why they gave it a separate copy of the code, I don't know.
; loc_1A330: Obj09_MdJump2:
Obj09_MdJump:
	bsr.w	Knuckles_JumpHeight
	bsr.w	Knuckles_ChgJumpDir
	bsr.w	Knuckles_LevelBound
	jsr	(ObjectMoveAndFall).w
	btst	#status.player.underwater,status(a0)	; is Knuckles underwater?
	beq.s	+		; if not, branch
	subi.w	#$28,y_vel(a0)	; reduce gravity by $28 ($38-$28=$10)
+
	bsr.w	Knuckles_JumpAngle
	bra.w	Knuckles_DoLevelCollision
; End of subroutine Obj09_MdJump

; ---------------------------------------------------------------------------
; Subroutine to make Knuckles walk/run
; ---------------------------------------------------------------------------

; loc_1A35A:
Knuckles_Move:
	move.w	(Knuckles_top_speed).w,d6
	move.w	(Knuckles_acceleration).w,d5
	move.w	(Knuckles_deceleration).w,d4
	_btst	#status_secondary.sliding,status_secondary(a0)
	_bne.w	Obj09_Traction
	tst.w	move_lock(a0)
	bne.w	Obj09_ResetScr
	btst	#button_left,(Ctrl_1_Held_Logical).w	; is left being pressed?
	beq.s	Obj09_NotLeft			; if not, branch
	bsr.w	Knuckles_MoveLeft
; loc_1A382:
Obj09_NotLeft:
	btst	#button_right,(Ctrl_1_Held_Logical).w	; is right being pressed?
	beq.s	Obj09_NotRight			; if not, branch
	bsr.w	Knuckles_MoveRight
; loc_1A38E:
Obj09_NotRight:
	moveq	#$20,d0
	add.b	angle(a0),d0
	andi.b	#$C0,d0		; is Knuckles on a slope?
	bne.w	Obj09_ResetScr	; if yes, branch
	tst.w	inertia(a0)	; is Knuckles moving?
	bne.w	Obj09_ResetScr	; if yes, branch
	bclr	#status.player.pushing,status(a0)
	move.b	#AniIDKnuxAni_Wait,anim(a0)	; use "standing" animation
	btst	#status.player.on_object,status(a0)
	beq.w	Knuckles_Balance
	moveq	#0,d0
	move.b	interact(a0),d0
    if object_size=$40
	lsl.w	#object_size_bits,d0
    else
	mulu.w	#object_size,d0
    endif
	lea	(Object_RAM).w,a1 ; a1=character
	lea	(a1,d0.w),a1 ; a1=object
	_btst	#status.npc.no_balancing,status(a1)
	_bne.w	Knuckles_Lookup
	moveq	#0,d1
	move.b	width_pixels(a1),d1
	move.w	d1,d2
	add.w	d2,d2
	subq.w	#2,d2
	add.w	x_pos(a0),d1
	sub.w	x_pos(a1),d1
	cmpi.w	#2,d1
	blt.s	Knuckles_BalanceOnObjLeft
	cmp.w	d2,d1
	bge.s	Knuckles_BalanceOnObjRight
	bra.w	Knuckles_Lookup
; ---------------------------------------------------------------------------
; balancing checks for when you're on the right edge of an object
; loc_1A410:
Knuckles_BalanceOnObjRight:
	btst	#status.player.x_flip,status(a0)
	bne.s	+
	move.b	#AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
+
	bclr	#0,status(a0)
	move.b	#0,anim_frame_duration(a0)
	move.b	#4,anim_frame(a0)
	move.w	#(AniIDKnuxAni_Balance<<8)|AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the left edge of an object
; loc_1A44E:
Knuckles_BalanceOnObjLeft:
	btst	#status.player.x_flip,status(a0)
	beq.s	+
	move.b	#AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
+
	bset	#0,status(a0)
	move.b	#0,anim_frame_duration(a0)
	move.b	#4,anim_frame(a0)
	move.w	#(AniIDKnuxAni_Balance<<8)|AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the edge of part of the level
; loc_1A48C:
Knuckles_Balance:
	jsr	(ChkFloorEdge).l
	cmpi.w	#$C,d1
	blt.w	Knuckles_Lookup
	cmpi.b	#3,next_tilt(a0)
	bne.s	Knuckles_BalanceLeft
	btst	#status.player.x_flip,status(a0)
	bne.s	+
	move.b	#AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
+
	bclr	#0,status(a0)
	move.b	#0,anim_frame_duration(a0)
	move.b	#4,anim_frame(a0)
	move.w	#(AniIDKnuxAni_Balance<<8)|AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
; ---------------------------------------------------------------------------
Knuckles_BalanceLeft:
	cmpi.b	#3,tilt(a0)
	bne.s	Knuckles_Lookup
	btst	#status.player.x_flip,status(a0)
	beq.s	+
	move.b	#AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
+
	bset	#0,status(a0)
	move.b	#0,anim_frame_duration(a0)
	move.b	#4,anim_frame(a0)
	move.w	#(AniIDKnuxAni_Balance<<8)|AniIDKnuxAni_Balance,anim(a0)
	bra.w	Obj09_ResetScr
; ---------------------------------------------------------------------------
; loc_1A584:
Knuckles_Lookup:
	btst	#button_up,(Ctrl_1_Held_Logical).w	; is up being pressed?
	beq.s	Knuckles_Duck			; if not, branch
	move.b	#AniIDKnuxAni_LookUp,anim(a0)			; use "looking up" animation
	addq.b	#1,look_delay_counter(a0)
	cmpi.b	#120,look_delay_counter(a0)
	blo.s	Obj09_ResetScr_Part2
	move.b	#120,look_delay_counter(a0)
	cmpi.w	#$C8,(Camera_Y_pos_bias).w
	beq.s	Obj09_UpdateSpeedOnGround
	addq.w	#2,(Camera_Y_pos_bias).w
	bra.s	Obj09_UpdateSpeedOnGround
; ---------------------------------------------------------------------------
; loc_1A5B2:
Knuckles_Duck:
	btst	#button_down,(Ctrl_1_Held_Logical).w	; is down being pressed?
	beq.s	Obj09_ResetScr			; if not, branch
	move.b	#AniIDKnuxAni_Duck,anim(a0)			; use "ducking" animation
	addq.b	#1,look_delay_counter(a0)
	cmpi.b	#120,look_delay_counter(a0)
	blo.s	Obj09_ResetScr_Part2
	move.b	#120,look_delay_counter(a0)
	cmpi.w	#8,(Camera_Y_pos_bias).w
	beq.s	Obj09_UpdateSpeedOnGround
	subq.w	#2,(Camera_Y_pos_bias).w
	bra.s	Obj09_UpdateSpeedOnGround

; ===========================================================================
; moves the screen back to its normal position after looking up or down
; loc_1A5E0:
Obj09_ResetScr:
	clr.b	look_delay_counter(a0)
; loc_1A5E6:
Obj09_ResetScr_Part2:
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Obj09_UpdateSpeedOnGround	; if yes, branch.
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; ---------------------------------------------------------------------------
; updates Knuckles's speed on the ground
; ---------------------------------------------------------------------------
; sub_1A5F8:
Obj09_UpdateSpeedOnGround:
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	#$C,d5
+
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_left_mask|button_right_mask,d0 ; is left/right pressed?
	bne.s	Obj09_Traction	; if yes, branch
	move.w	inertia(a0),d0
	beq.s	Obj09_Traction
	bmi.s	Obj09_SettleLeft

; slow down when facing right and not pressing a direction
; Obj09_SettleRight:
	sub.w	d5,d0
	bcc.s	+
	moveq	#0,d0
+
	move.w	d0,inertia(a0)
	bra.s	Obj09_Traction
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_1A624:
Obj09_SettleLeft:
	add.w	d5,d0
	bcc.s	+
	moveq	#0,d0
+
	move.w	d0,inertia(a0)

; increase or decrease speed on the ground
; loc_1A630:
Obj09_Traction:
	move.b	angle(a0),d0
	jsr	(CalcSine).w
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	move.w	d1,x_vel(a0)
	muls.w	inertia(a0),d0
	asr.l	#8,d0
	move.w	d0,y_vel(a0)

; stops Knuckles from running through walls that meet the ground
; loc_1A64E:
Obj09_CheckWallsOnGround:
	moveq	#$3F,d0					; is he standing on a flat surface in any of the four quadrants?
	and.b	angle(a0),d0				; get Sonic's current angle in relation to the floor
	beq.s	.noearlyexit				; if yes, skip the upside-down exit below
	move.b	angle(a0),d0
	addi.b	#$40,d0
	bmi.s	return_1A6BE_K

.noearlyexit:
	move.b	#$40,d1			; Rotate 90 degrees clockwise
	tst.w	inertia(a0)		; Check inertia
	beq.s	return_1A6BE_K	; If not moving, don't do anything
	bmi.s	+				; If negative, branch
	neg.w	d1				; Otherwise, we want to rotate counterclockwise
+
	move.b	angle(a0),d0
	add.b	d1,d0
	move.w	d0,-(sp)
	bsr.w	CalcRoomInFront
	move.w	(sp)+,d0
	tst.w	d1
	bpl.s	return_1A6BE_K
	asl.w	#8,d1
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	loc_1A6BA_K
	cmpi.b	#$40,d0
	beq.s	loc_1A6A8_K
	cmpi.b	#$80,d0
	beq.s	loc_1A6A2_K
	add.w	d1,x_vel(a0)
	move.w	#0,inertia(a0)
	btst	#0,status(a0)
	bne.s	.return
	bset	#5,status(a0)

.return:
	rts
; ---------------------------------------------------------------------------
loc_1A6A2_K:
	sub.w	d1,y_vel(a0)
	rts
; ---------------------------------------------------------------------------
loc_1A6A8_K:
	sub.w	d1,x_vel(a0)
	move.w	#0,inertia(a0)
	btst	#status.player.x_flip,status(a0)
	beq.s	Obj09_CheckWallsOnGround.return
	bset	#status.player.pushing,status(a0)
	rts
; ---------------------------------------------------------------------------
loc_1A6BA_K:
	add.w	d1,y_vel(a0)

return_1A6BE_K:
	rts
; End of subroutine Knuckles_Move


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A6C0:
Knuckles_MoveLeft:
	move.w	inertia(a0),d0
	beq.s	+
	bpl.s	Knuckles_TurnLeft ; if Knuckles is already moving to the right, branch
+
	bset	#status.player.x_flip,status(a0)
	bne.s	+
	bclr	#status.player.pushing,status(a0)
	move.b	#AniIDKnuxAni_Run,prev_anim(a0)	; force walking animation to restart if it's already in-progress
+
	sub.w	d5,d0	; add acceleration to the left
	move.w	d6,d1
	neg.w	d1
	cmp.w	d1,d0	; compare new speed with top speed
	bgt.s	+	; if new speed is less than the maximum, branch
	add.w	d5,d0	; remove this frame's acceleration change
	cmp.w	d1,d0	; compare speed with top speed
	ble.s	+	; if speed was already greater than the maximum, branch
	move.w	d1,d0	; limit speed on ground going left
+
	move.w	d0,inertia(a0)
	move.b	#AniIDKnuxAni_Walk,anim(a0)	; use walking animation
	rts
; ---------------------------------------------------------------------------
; loc_1A6FA:
Knuckles_TurnLeft:
	sub.w	d4,d0
	bcc.s	+
	moveq	#-$80,d0
+
	move.w	d0,inertia(a0)
	moveq	#$20,d1
	add.b	angle(a0),d1
	andi.b	#$C0,d1
	bne.s	return_1A744_K
	cmpi.w	#$400,d0
	blt.s	return_1A744_K
	move.b	#AniIDKnuxAni_Stop,anim(a0)	; use "stopping" animation
	bclr	#status.player.x_flip,status(a0)
	moveq	#SndID_Skidding,d0
	jsr	(PlaySound).w
	cmpi.b	#12,air_left(a0)
	blo.s	return_1A744_K	; if he's drowning, branch to not make dust
	move.b	#6,(Sonic_Dust+routine).w
	move.b	#$15,(Sonic_Dust+mapping_frame).w

return_1A744_K:
	rts
; End of subroutine Knuckles_MoveLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A746:
Knuckles_MoveRight:
	move.w	inertia(a0),d0
	bmi.s	Knuckles_TurnRight	; if Knuckles is already moving to the left, branch
	bclr	#status.player.x_flip,status(a0)
	beq.s	+
	bclr	#status.player.pushing,status(a0)
	move.b	#AniIDKnuxAni_Run,prev_anim(a0)	; force walking animation to restart if it's already in-progress
+
	add.w	d5,d0	; add acceleration to the right
	cmp.w	d6,d0	; compare new speed with top speed
	blt.s	+	; if new speed is less than the maximum, branch
	sub.w	d5,d0	; remove this frame's acceleration change
	cmp.w	d6,d0	; compare speed with top speed
	bge.s	+	; if speed was already greater than the maximum, branch
	move.w	d6,d0	; limit speed on ground going right
+
	move.w	d0,inertia(a0)
	move.b	#AniIDKnuxAni_Walk,anim(a0)	; use walking animation
	rts
; ---------------------------------------------------------------------------
; loc_1A77A:
Knuckles_TurnRight:
	add.w	d4,d0
	bcc.s	+
	move.w	#$80,d0
+
	move.w	d0,inertia(a0)
	moveq	#$20,d1
	add.b	angle(a0),d1
	andi.b	#$C0,d1
	bne.s	return_1A7C4_K
	cmpi.w	#-$400,d0
	bgt.s	return_1A7C4_K
	move.b	#AniIDKnuxAni_Stop,anim(a0)	; use "stopping" animation
	bset	#status.player.x_flip,status(a0)
	moveq	#SndID_Skidding,d0	; use "stopping" sound
	jsr	(PlaySound).w
	cmpi.b	#12,air_left(a0)
	blo.s	return_1A7C4_K	; if he's drowning, branch to not make dust
	move.b	#6,(Sonic_Dust+routine).w
	move.b	#$15,(Sonic_Dust+mapping_frame).w

return_1A7C4_K:
	rts
; End of subroutine Knuckles_MoveRight

; ---------------------------------------------------------------------------
; Subroutine to change Knuckles's speed as he rolls
; ---------------------------------------------------------------------------

; loc_1A7C6:
Knuckles_RollSpeed:
	move.w	(Knuckles_top_speed).w,d6
	add.w	d6,d6
	move.w	(Knuckles_acceleration).w,d5
	asr.w	#1,d5	; natural roll deceleration = 1/2 normal acceleration
	move.w	(Knuckles_deceleration),d4
	asr.w	#2,d4
	_btst	#status_secondary.sliding,status_secondary(a0)
	_bne.w	Obj09_Roll_ResetScr
	tst.w	move_lock(a0)
	bne.s	Knuckles_ApplyRollSpeed
	btst	#button_left,(Ctrl_1_Held_Logical).w	; is left being pressed?
	beq.s	+				; if not, branch
	bsr.w	Knuckles_RollLeft
+
	btst	#button_right,(Ctrl_1_Held_Logical).w	; is right being pressed?
	beq.s	Knuckles_ApplyRollSpeed		; if not, branch
	bsr.w	Knuckles_RollRight

; loc_1A7FC:
Knuckles_ApplyRollSpeed:
	move.w	inertia(a0),d0
	beq.s	Knuckles_CheckRollStop
	bmi.s	Knuckles_ApplyRollSpeedLeft

; Knuckles_ApplyRollSpeedRight:
	sub.w	d5,d0
	bcc.s	+
	moveq	#0,d0
+
	move.w	d0,inertia(a0)
	bra.s	Knuckles_CheckRollStop
; ---------------------------------------------------------------------------
; loc_1A812:
Knuckles_ApplyRollSpeedLeft:
	add.w	d5,d0
	bcc.s	+
	moveq	#0,d0
+
	move.w	d0,inertia(a0)

; loc_1A81E:
Knuckles_CheckRollStop:
	tst.w	inertia(a0)
	bne.s	Obj09_Roll_ResetScr
	tst.b	pinball_mode(a0) ; note: the spindash flag has a different meaning when Knuckles's already rolling -- it's used to mean he's not allowed to stop rolling
	bne.s	Knuckles_KeepRolling
	bclr	#status.player.rolling,status(a0)
	move.b	#$13,y_radius(a0)
	move.b	#9,x_radius(a0)
	move.b	#AniIDKnuxAni_Wait,anim(a0)
	subq.w	#5,y_pos(a0)
	bra.s	Obj09_Roll_ResetScr

; ---------------------------------------------------------------------------
; magically gives Knuckles an extra push if he's going to stop rolling where it's not allowed
; (such as in an S-curve in HTZ or a stopper chamber in CNZ)
; loc_1A848:
Knuckles_KeepRolling:
	move.w	#$400,inertia(a0)
	btst	#status.player.x_flip,status(a0)
	beq.s	Obj09_Roll_ResetScr
	neg.w	inertia(a0)

; resets the screen to normal while rolling, like Obj09_ResetScr
; loc_1A85A:
Obj09_Roll_ResetScr:
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Knuckles_SetRollSpeeds		; if yes, branch
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; loc_1A86C:
Knuckles_SetRollSpeeds:
	move.b	angle(a0),d0
	jsr	(CalcSine).w
	muls.w	inertia(a0),d0
	asr.l	#8,d0
	cmpi.w	#$1000,d0
	ble.s	+
	move.w	#$1000,d0	; limit Sonic's speed rolling right
+
	cmpi.w	#-$1000,d0
	bge.s	+
	move.w	#-$1000,d0	; limit Sonic's speed rolling left
+
	move.w	d0,y_vel(a0)	; set y velocity based on $14 and angle
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	cmpi.w	#$1000,d1
	ble.s	+
	move.w	#$1000,d1	; limit Sonic's speed rolling right
+
	cmpi.w	#-$1000,d1
	bge.s	+
	move.w	#-$1000,d1	; limit Sonic's speed rolling left
+
	move.w	d1,x_vel(a0)	; set x velocity based on $14 and angle
	bra.w	Obj09_CheckWallsOnGround
; End of function Knuckles_RollSpeed


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; loc_1A8A2:
Knuckles_RollLeft:
	move.w	inertia(a0),d0
	beq.s	+
	bpl.s	Knuckles_BrakeRollingRight
+
	bset	#status.player.x_flip,status(a0)
	move.b	#AniIDKnuxAni_Roll,anim(a0)	; use "rolling" animation
	rts
; ---------------------------------------------------------------------------
; loc_1A8B8:
Knuckles_BrakeRollingRight:
	sub.w	d4,d0	; reduce rightward rolling speed
	bcc.s	+
	moveq	#-$80,d0
+
	move.w	d0,inertia(a0)
	rts
; End of function Knuckles_RollLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; loc_1A8C6:
Knuckles_RollRight:
	move.w	inertia(a0),d0
	bmi.s	Knuckles_BrakeRollingLeft
	bclr	#status.player.x_flip,status(a0)
	move.b	#AniIDKnuxAni_Roll,anim(a0)	; use "rolling" animation
	rts
; ---------------------------------------------------------------------------
; loc_1A8DA:
Knuckles_BrakeRollingLeft:
	add.w	d4,d0	; reduce leftward rolling speed
	bcc.s	+
	move.w	#$80,d0
+
	move.w	d0,inertia(a0)
	rts
; End of subroutine Knuckles_RollRight


; ---------------------------------------------------------------------------
; Subroutine for moving Knuckles left or right when he's in the air
; ---------------------------------------------------------------------------

; loc_1A8E8:
Knuckles_ChgJumpDir:
	move.w	(Knuckles_top_speed).w,d6
	move.w	(Knuckles_acceleration).w,d5
	add.w	d5,d5
	move.w	x_vel(a0),d0
	btst	#button_left,(Ctrl_1_Held_Logical).w
	beq.s	+	; if not holding left, branch

	bset	#status.player.x_flip,status(a0)
	sub.w	d5,d0	; add acceleration to the left
	move.w	d6,d1
	neg.w	d1
	cmp.w	d1,d0	; compare new speed with top speed
	bgt.s	+	; if new speed is less than the maximum, branch
	add.w	d5,d0
	cmp.w	d1,d0
	ble.s	+
	move.w	d1,d0	; limit speed in air going left, even if Knuckles was already going faster (speed limit/cap)
+
	btst	#button_right,(Ctrl_1_Held_Logical).w
	beq.s	+	; if not holding right, branch

	bclr	#status.player.x_flip,status(a0)
	add.w	d5,d0	; accelerate right in the air
	cmp.w	d6,d0	; compare new speed with top speed
	blt.s	+	; if new speed is less than the maximum, branch
	sub.w	d5,d0
	cmp.w	d6,d0
	bge.s	+
	move.w	d6,d0	; limit speed in air going right, even if Knuckles was already going faster (speed limit/cap)
; Obj09_JumpMove:
+	move.w	d0,x_vel(a0)

; loc_1A932: Obj09_ResetScr2:
Obj09_Jump_ResetScr:
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Knuckles_JumpPeakDecelerate	; if yes, branch
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; loc_1A944:
Knuckles_JumpPeakDecelerate:
	cmpi.w	#-$400,y_vel(a0)	; is Knuckles moving faster than -$400 upwards?
	blo.s	return_1A972_K		; if yes, return
	move.w	x_vel(a0),d0
	move.w	d0,d1
	asr.w	#5,d1		; d1 = x_velocity / 32
	beq.s	return_1A972_K	; return if d1 is 0
	bmi.s	Knuckles_JumpPeakDecelerateLeft	; branch if moving left

; Knuckles_JumpPeakDecelerateRight:
	sub.w	d1,d0	; reduce x velocity by d1
	bcc.s	+
	moveq	#0,d0
+
	move.w	d0,x_vel(a0)
	rts
;-------------------------------------------------------------
; loc_1A966:
Knuckles_JumpPeakDecelerateLeft:
	sub.w	d1,d0	; reduce x velocity by d1
	bcs.s	+
	moveq	#0,d0
+
	move.w	d0,x_vel(a0)

return_1A972_K:
	rts
; End of subroutine Knuckles_ChgJumpDir
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to prevent Knuckles from leaving the boundaries of a level
; ---------------------------------------------------------------------------

; loc_1A974:
Knuckles_LevelBound:
	move.l	x_pos(a0),d1
	move.w	x_vel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	swap	d1
	move.w	(Camera_Min_X_pos).w,d0
	addi.w	#$10,d0
	cmp.w	d1,d0			; has Knuckles touched the left boundary?
	bhi.s	Knuckles_Boundary_Sides	; if yes, branch
	move.w	(Camera_Max_X_pos).w,d0
	addi.w	#screen_width-24,d0		; screen width - Knuckles's width_pixels
	tst.b	(Current_Boss_ID).w
	bne.s	+
	addi.w	#$40,d0
+
	cmp.w	d1,d0			; has Knuckles touched the right boundary?
	bls.s	Knuckles_Boundary_Sides	; if yes, branch

; loc_1A9A6:
Knuckles_Boundary_CheckBottom:
	move.w	(Camera_Max_Y_pos).w,d0
	move.w	(Camera_Max_Y_pos_target).w,d1
	cmp.w	d0,d1
	blo.s	.skip
	move.w	d1,d0
.skip:
	addi.w	#screen_height,d0
	cmp.w	y_pos(a0),d0		; has Knuckles touched the bottom boundary?
	blt.s	Knuckles_Boundary_Bottom	; if yes, branch
	rts
; ---------------------------------------------------------------------------
Knuckles_Boundary_Bottom: ;;
	movea.l	a0,a2
	jmp	(KillCharacter).l
; ===========================================================================

; loc_1A9BA:
Knuckles_Boundary_Sides:
	move.w	d0,x_pos(a0)
	move.w	#0,2+x_pos(a0) ; subpixel x
	move.w	#0,x_vel(a0)
	move.w	#0,inertia(a0)
	bra.s	Knuckles_Boundary_CheckBottom
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Knuckles to start rolling when he's moving
; ---------------------------------------------------------------------------

; loc_1A9D2:
Knuckles_Roll:
	_btst	#status_secondary.sliding,status_secondary(a0)
	_bne.s	Obj09_NoRoll
	mvabs.w	inertia(a0),d0
	cmpi.w	#$80,d0		; is Knuckles moving at $80 speed or faster?
	blo.s	Obj09_NoRoll	; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_left_mask|button_right_mask,d0 ; is left/right being pressed?
	bne.s	Obj09_NoRoll	; if yes, branch
	btst	#button_down,(Ctrl_1_Held_Logical).w ; is down being pressed?
	bne.s	Obj09_ChkRoll			; if yes, branch
; return_1A9F8:
Obj09_NoRoll:
	rts

; ---------------------------------------------------------------------------
; loc_1A9FA:
Obj09_ChkRoll:
	bset	#status.player.rolling,status(a0)	; is Knuckles already rolling?
	beq.s	Obj09_DoRoll	; if not, branch
	rts

; ---------------------------------------------------------------------------
; loc_1AA04:
Obj09_DoRoll:
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#AniIDKnuxAni_Roll,anim(a0)	; use "rolling" animation
	addq.w	#5,y_pos(a0)
	moveq	#SndID_Roll,d0
	jsr	(PlaySound).w	; play rolling sound
	tst.w	inertia(a0)
	bne.s	return_1AA36_K
	move.w	#$200,inertia(a0)

return_1AA36_K:
	rts
; End of function Knuckles_Roll


; ---------------------------------------------------------------------------
; Subroutine allowing Knuckles to jump
; ---------------------------------------------------------------------------

; loc_1AA38:
Knuckles_Jump:
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0 ; is A, B or C pressed?
	beq.s	return_1AA36_K	; if not, return
	moveq	#0,d0
	move.b	angle(a0),d0
	addi.b	#$80,d0
	bsr.w	CalcRoomOverHead
	cmpi.w	#6,d1			; does Knuckles have enough room to jump?
	blt.s	return_1AA36_K		; if not, branch
	move.w	#$600,d2
	btst	#6,status(a0)	; Test if underwater
	beq.s	+
	move.w	#$300,d2	; set lower jump speed if under
+
	moveq	#0,d0
	move.b	angle(a0),d0
	subi.b	#$40,d0
	jsr	(CalcSine).w
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,x_vel(a0)	; make Knuckles jump (in X... this adds nothing on level ground)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,y_vel(a0)	; make Knuckles jump (in Y)
	bset	#status.player.in_air,status(a0)
	bclr	#status.player.pushing,status(a0)
	addq.l	#4,sp
	st.b	jumping(a0)
	clr.b	stick_to_convex(a0)
	moveq	#SndID_Jump,d0
	jsr	(PlaySound).w	; play jumping sound
	bset	#status.player.rolling,status(a0)
	bne.s	return_1AAE6_K
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#AniIDKnuxAni_Roll,anim(a0)	; use "jumping" animation
	addq.w	#5,y_pos(a0)

return_1AAE6_K:
	rts
; End of function Knuckles_Jump


; ---------------------------------------------------------------------------
; Subroutine letting Knuckles control the height of the jump
; when the jump button is released
; ---------------------------------------------------------------------------

; ===========================================================================
; loc_1AAF0:
Knuckles_JumpHeight:
	tst.b	jumping(a0)	; is Knuckles jumping?
	beq.s	Knuckles_UpVelCap	; if not, branch

	move.w	#-$400,d1
	btst	#status.player.underwater,status(a0)	; is Knuckles underwater?
	beq.s	+		; if not, branch
	move.w	#-$200,d1
+
	cmp.w	y_vel(a0),d1	; is Knuckles going up faster than d1?
	ble.s	Knuckles_CheckGoSuper		; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0 ; is a jump button pressed?
	bne.s	+		; if yes, branch
	move.w	d1,y_vel(a0)	; immediately reduce Knuckles's upward speed to d1
+
	rts
; ---------------------------------------------------------------------------
; loc_1AB22:
Knuckles_UpVelCap:
	tst.b	pinball_mode(a0)	; is Knuckles charging a spindash or in a rolling-only area?
	bne.s	return_1AB36_K		; if yes, return
	cmpi.w	#-$FC0,y_vel(a0)	; is Knuckles moving up really fast?
	bge.s	return_1AB36_K		; if not, return
	move.w	#-$FC0,y_vel(a0)	; cap upward speed

return_1AB36_K:
	rts
; End of subroutine Knuckles_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine called at the peak of a jump that transforms Knuckles into Super Knuckles
; if he has enough rings and emeralds
; ---------------------------------------------------------------------------

; loc_1AB38: test_set_SS:
Knuckles_CheckGoSuper:
	tst.w	(Demo_mode_flag).w	; Don't glide on demos
	bne.w	return_3165D2
	tst.b	double_jump_flag(a0)
	bne.w	return_3165D2
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.w	return_3165D2

	tst.b	(Super_Sonic_flag).w	; is Knuckles already Super?
	bne.s	Knuckles_BeginGlide	; if yes, branch
	cmpi.b	#7,(Emerald_count).w	; does Knuckles have exactly 7 emeralds?
	blo.s	Knuckles_BeginGlide	; if not, branch
	cmpi.w	#50,(Ring_count).w	; does Knuckles have at least 50 rings?
	blo.s	Knuckles_BeginGlide	; if not, branch
	tst.b	(Update_HUD_timer).w	; has Knuckles reached the end of the act?
	bne.s	Knuckles_TurnSuper	; if yes, branch

Knuckles_BeginGlide:
	bclr	#2,status(a0)
	move.b	#10,y_radius(a0)
	move.b	#10,x_radius(a0)
	bclr	#4,status(a0)
	move.b	#1,double_jump_flag(a0)
	addi.w	#$200,y_vel(a0)
	bpl.s	loc_31659E
	move.w	#0,y_vel(a0)

loc_31659E:
	moveq	#0,d1
	move.w	#$400,d0
	move.w	d0,inertia(a0)
	btst	#0,status(a0)
	beq.s	loc_3165B4
	neg.w	d0
	moveq	#-$80,d1

loc_3165B4:
	move.w	d0,x_vel(a0)
	move.b	d1,double_jump_property(a0)
	move.w	#0,angle(a0)
	move.b	#0,(Gliding_collision_flags).w
	bset	#status.player.in_air,(Gliding_collision_flags).w
	bra.w	Knuckles_DoGlidingAnimation

return_3165D2:
	rts

Knuckles_TurnSuper:
	bclr	#status.player.rolling,status(a0)	; Clear bits 2 and 4
	move.b	#$13,y_radius(a0)
	move.b	#9,x_radius(a0)
	move.b	#1,(Super_Knuckles_palette).w
	move.b	#$F,(Palette_timer).w
	move.b	#1,(Super_Sonic_flag).w
	move.w	#60,(Super_Knuckles_frame_count).w
	move.b	#$81,obj_control(a0)
	move.b	#AniIDSupKnuxAni_Transform,anim(a0)			; use transformation animation
	move.b	#ObjID_SuperSonicStars,(SuperSonicStars+id).w ; load Obj7E (Super Knuckles stars object) at $FFFFD040
	move.w	#$800,(Knuckles_top_speed).w
	move.w	#$18,(Knuckles_acceleration).w
	move.w	#$C0,(Knuckles_deceleration).w
	move.w	#0,invincibility_time(a0)
	bset	#status_secondary.invincible,status_secondary(a0)	; make Knuckles invincible
	moveq	#SndID_SuperTransform,d0
	jsr	(PlaySound).w	; Play transformation sound effect.
	moveq	#MusID_SuperSonic,d0
	jmp	(PlayMusic).w	; load the Super Knuckles song and return

; ---------------------------------------------------------------------------
return_1ABA4_K:
	rts
; End of subroutine Knuckles_CheckGoSuper


; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Knuckles
; ---------------------------------------------------------------------------

; loc_1ABA6:
Knuckles_Super:
	tst.b	(Super_Sonic_flag).w	; Ignore all this code if not Super Knuckles
	beq.w	return_1AC3C_K
	tst.b	(Update_HUD_timer).w
	beq.s	Knuckles_RevertToNormal ; ?
	subq.w	#1,(Super_Knuckles_frame_count).w
	bpl.w	return_1AC3C_K
	move.w	#60,(Super_Knuckles_frame_count).w	; Reset frame counter to 60
	tst.w	(Ring_count).w
	beq.s	Knuckles_RevertToNormal
	ori.b	#1,(Update_HUD_rings).w
	cmpi.w	#1,(Ring_count).w
	beq.s	+
	cmpi.w	#10,(Ring_count).w
	beq.s	+
	cmpi.w	#100,(Ring_count).w
	bne.s	++
+
	ori.b	#$80,(Update_HUD_rings).w
+
	subq.w	#1,(Ring_count).w
	bne.s	return_1AC3C_K
; loc_1ABF2:
Knuckles_RevertToNormal:
	move.b	#2,(Super_Knuckles_palette).w	; Remove rotating palette
	move.w	#$28,(Palette_frame).w
	move.b	#0,(Super_Sonic_flag).w
	move.b	#AniIDKnuxAni_Run,prev_anim(a0)	; Force Knuckles's animation to restart
	move.w	#1,invincibility_time(a0)	; Remove invincibility
	move.w	#$600,(Knuckles_top_speed).w
	move.w	#$C,(Knuckles_acceleration).w
	move.w	#$80,(Knuckles_deceleration).w
	btst	#status.player.underwater,status(a0)	; Check if underwater, return if not
	beq.s	return_1AC3C_K
	move.w	#$300,(Knuckles_top_speed).w
	move.w	#6,(Knuckles_acceleration).w
	move.w	#$40,(Knuckles_deceleration).w

return_1AC3C_K:
	rts
; End of subroutine Knuckles_Super

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; loc_1AC3E:
Knuckles_CheckSpindash:
	tst.b	spindash_flag(a0)
	bne.s	Knuckles_UpdateSpindash
	cmpi.b	#AniIDKnuxAni_Duck,anim(a0)
	bne.s	return_1AC8C_K
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.s	return_1AC8C_K
	move.b	#AniIDKnuxAni_Spindash,anim(a0)
	moveq	#SndID_SpindashRev,d0
	jsr	(PlaySound).w
	addq.l	#4,sp
	st.b	spindash_flag(a0)
	clr.w	spindash_counter(a0)
	cmpi.b	#12,air_left(a0)	; if he's drowning, branch to not make dust
	blo.s	+
	move.b	#2,(Sonic_Dust+anim).w
+
	bsr.w	Knuckles_LevelBound
	bra.w	AnglePos

return_1AC8C_K:
	rts
; End of subroutine Knuckles_CheckSpindash


; ---------------------------------------------------------------------------
; Subrouting to update an already-charging spindash
; ---------------------------------------------------------------------------

; loc_1AC8E:
Knuckles_UpdateSpindash:
	move.b	(Ctrl_1_Held_Logical).w,d0
	btst	#button_down,d0
	bne.w	Knuckles_ChargingSpindash

	; unleash the charged spindash and start rolling quickly:
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#AniIDKnuxAni_Roll,anim(a0)
	addq.w	#5,y_pos(a0)	; add the difference between Knuckles's rolling and standing heights
	moveq	#0,d0
	move.b	d0,spindash_flag(a0)
	move.b	spindash_counter(a0),d0
	add.w	d0,d0
	move.w	SpindashSpeeds_K(pc,d0.w),inertia(a0)
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	SpindashSpeedsSuper_K(pc,d0.w),inertia(a0)
+
	; Determine how long to lag the camera for.
	; Notably, the faster Knuckles goes, the less the camera lags.
	; This is seemingly to prevent Knuckles from going off-screen.
	move.w	inertia(a0),d0
	subi.w	#$800,d0 ; $800 is the lowest spin dash speed
	lsr.w	#7,d0
	neg.w	d0
	addi.w	#$20,d0
	move.b	d0,(Horiz_scroll_delay_val).w
	; Back up the position array index for later.
	move.b	(Sonic_Pos_Record_Index+1).w,(Horiz_scroll_delay_val+1).w

	btst	#status.player.x_flip,status(a0)
	beq.s	+
	neg.w	inertia(a0)
+
	bset	#status.player.rolling,status(a0)
	move.b	#0,(Sonic_Dust+anim).w
	moveq	#SndID_SpindashRelease,d0	; spindash zoom sound
	jsr	(PlaySound).w
	bra.s	Obj09_Spindash_ResetScr
; ===========================================================================
; word_1AD0C:
SpindashSpeeds_K:
	dc.w  $800	; 0
	dc.w  $880	; 1
	dc.w  $900	; 2
	dc.w  $980	; 3
	dc.w  $A00	; 4
	dc.w  $A80	; 5
	dc.w  $B00	; 6
	dc.w  $B80	; 7
	dc.w  $C00	; 8
; word_1AD1E:
SpindashSpeedsSuper_K:
	dc.w  $B00	; 0
	dc.w  $B80	; 1
	dc.w  $C00	; 2
	dc.w  $C80	; 3
	dc.w  $D00	; 4
	dc.w  $D80	; 5
	dc.w  $E00	; 6
	dc.w  $E80	; 7
	dc.w  $F00	; 8
; ===========================================================================
; loc_1AD30:
Knuckles_ChargingSpindash:			; If still charging the dash...
	tst.w	spindash_counter(a0)
	beq.s	+
	move.w	spindash_counter(a0),d0
	lsr.w	#5,d0
	sub.w	d0,spindash_counter(a0)
	bcc.s	+
	clr.w	spindash_counter(a0)
+
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.s	Obj09_Spindash_ResetScr
	move.w	#(AniIDKnuxAni_Spindash<<8)|(AniIDKnuxAni_Walk<<0),anim(a0)
	moveq	#SndID_SpindashRev,d0
	jsr	(PlaySound).w
	addi.w	#$200,spindash_counter(a0)
	cmpi.w	#$800,spindash_counter(a0)
	blo.s	Obj09_Spindash_ResetScr
	move.w	#$800,spindash_counter(a0)

; loc_1AD78:
Obj09_Spindash_ResetScr:
	addq.l	#4,sp
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w
	beq.s	loc_1AD8C_K
	bhs.s	+
	addq.w	#4,(Camera_Y_pos_bias).w
+	subq.w	#2,(Camera_Y_pos_bias).w

loc_1AD8C_K:
	bsr.w	Knuckles_LevelBound
	bra.w	AnglePos
; End of subroutine Knuckles_UpdateSpindash

; ---------------------------------------------------------------------------
; Subroutine to return Knuckles's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; loc_1AE4A:
Knuckles_JumpAngle:
	move.b	angle(a0),d0	; get Knuckles's angle
	beq.s	Knuckles_JumpFlip	; if already 0, branch
	bpl.s	loc_1AE5A_K	; if higher than 0, branch

	addq.b	#2,d0		; increase angle
	bcc.s	Knuckles_JumpAngleSet
	moveq	#0,d0
	bra.s	Knuckles_JumpAngleSet
; ===========================================================================

loc_1AE5A_K:
	subq.b	#2,d0		; decrease angle
	bcc.s	Knuckles_JumpAngleSet
	moveq	#0,d0

; loc_1AE60:
Knuckles_JumpAngleSet:
	move.b	d0,angle(a0)
; End of function Knuckles_JumpAngle
	; continue straight to Knuckles_JumpFlip

; ---------------------------------------------------------------------------
; Updates Knuckles's secondary angle if he's tumbling
; ---------------------------------------------------------------------------

; loc_1AE64:
Knuckles_JumpFlip:
	move.b	flip_angle(a0),d0
	beq.s	return_1AEA8_K
	tst.w	inertia(a0)
	bmi.s	Knuckles_JumpLeftFlip
; loc_1AE70:
Knuckles_JumpRightFlip:
	move.b	flip_speed(a0),d1
	add.b	d1,d0
	bcc.s	Knuckles_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	Knuckles_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0
	bra.s	Knuckles_JumpFlipSet
; ===========================================================================
; loc_1AE88:
Knuckles_JumpLeftFlip:
	tst.b	flip_turned(a0)
	bne.s	Knuckles_JumpRightFlip
	move.b	flip_speed(a0),d1
	sub.b	d1,d0
	bcc.s	Knuckles_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	Knuckles_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0
; loc_1AEA4:
Knuckles_JumpFlipSet:
	move.b	d0,flip_angle(a0)

return_1AEA8_K:
	rts
; End of function Knuckles_JumpFlip

; ---------------------------------------------------------------------------
; Subroutine for Knuckles to interact with the floor and walls when he's in the air
; ---------------------------------------------------------------------------

Knuckles_DoLevelCollision2:
	move.l	(Primary_Collision).w,(Collision_addr).w
	cmpi.b	#$C,top_solid_bit(a0)
	beq.s	+
	move.l	(Secondary_Collision).w,(Collision_addr).w
+
	move.b	lrb_solid_bit(a0),d5
	move.w	x_vel(a0),d1
	move.w	y_vel(a0),d2
	jsr	(CalcAngle).w
	subi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$40,d0
	beq.w	Knuckles_HitLeftWall_2
	cmpi.b	#$80,d0
	beq.w	Knuckles_HitCeilingAndWalls_2
	cmpi.b	#$C0,d0
	beq.w	Knuckles_HitRightWall_2
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	bset	#status.player.pushing,(Gliding_collision_flags).w
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	bset	#status.player.pushing,(Gliding_collision_flags).w
+
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AF8A_2
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	move.w	#0,y_vel(a0)
	bclr	#status.player.in_air,(Gliding_collision_flags).w

return_1AF8A_2:
	rts
; ===========================================================================
; loc_1AF8C:
Knuckles_HitLeftWall_2:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	Knuckles_HitCeiling_2 ; branch if distance is positive (not inside wall)
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	bset	#status.player.pushing,(Gliding_collision_flags).w

; loc_1AFA6:
Knuckles_HitCeiling_2:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Knuckles_HitFloor_2 ; branch if distance is positive (not inside ceiling)
	neg.w	d1
	cmpi.w	#20,d1
	bhs.s	loc_316A08
	add.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1AFBE_2
	move.w	#0,y_vel(a0) ; stop Knuckles in y since he hit a ceiling

return_1AFBE_2:
	rts

loc_316A08:
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	return_316A20
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)
	bset	#status.player.pushing,(Gliding_collision_flags).w

return_316A20:
	rts
; ===========================================================================
; loc_1AFC0:
Knuckles_HitFloor_2:
	tst.w	y_vel(a0)
	bmi.s	return_1AFE6_2
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AFE6_2
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	move.w	#0,y_vel(a0)
	bclr	#status.player.in_air,(Gliding_collision_flags).w

return_1AFE6_2:
	rts
; ===========================================================================
; loc_1AFE8:
Knuckles_HitCeilingAndWalls_2:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Knuckles since he hit a wall
	bset	#status.player.pushing,(Gliding_collision_flags).w
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Knuckles since he hit a wall
	bset	#status.player.pushing,(Gliding_collision_flags).w
+
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	return_1B042_2
	sub.w	d1,y_pos(a0)
	move.w	#0,y_vel(a0) ; stop Knuckles in y since he hit a ceiling

return_1B042_2:
	rts
; ===========================================================================
; loc_1B044:
Knuckles_HitRightWall_2:
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	Knuckles_HitCeiling2_2
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	bset	#status.player.pushing,(Gliding_collision_flags).w

; identical to Knuckles_HitCeiling...
; loc_1B05E:
Knuckles_HitCeiling2_2:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Knuckles_HitFloor2_2
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1B076_2
	move.w	#0,y_vel(a0) ; stop Knuckles in y since he hit a ceiling

return_1B076_2:
	rts
; ===========================================================================
; identical to Knuckles_HitFloor...
; loc_1B078:
Knuckles_HitFloor2_2:
	tst.w	y_vel(a0)
	bmi.s	return_1B09E_2
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1B09E_2
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	move.w	#0,y_vel(a0)
	bclr	#status.player.in_air,(Gliding_collision_flags).w

return_1B09E_2:
	rts
; End of function Knuckles_DoLevelCollision2

; ---------------------------------------------------------------------------
; Subroutine for Knuckles to interact with the floor and walls when he's in the air
; ---------------------------------------------------------------------------

; loc_1AEAA: Knuckles_Floor:
Knuckles_DoLevelCollision:
	move.l	(Primary_Collision).w,(Collision_addr).w
	cmpi.b	#$C,top_solid_bit(a0)
	beq.s	+
	move.l	(Secondary_Collision).w,(Collision_addr).w
+
	move.b	lrb_solid_bit(a0),d5
	move.w	x_vel(a0),d1
	move.w	y_vel(a0),d2
	jsr	(CalcAngle).w
	subi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$40,d0
	beq.w	Knuckles_HitLeftWall
	cmpi.b	#$80,d0
	beq.w	Knuckles_HitCeilingAndWalls
	cmpi.b	#$C0,d0
	beq.w	Knuckles_HitRightWall
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
+
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AF8A_K
	move.b	y_vel(a0),d2
	addq.b	#8,d2
	neg.b	d2
	cmp.b	d2,d1
	bge.s	+
	cmp.b	d2,d0
	blt.s	return_1AF8A_K
+
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Knuckles_ResetOnFloor
	move.b	d3,d0
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	loc_1AF68_K
	move.b	d3,d0
	addi.b	#$10,d0
	andi.b	#$20,d0
	beq.s	loc_1AF5A_K
	asr.w	y_vel(a0)
	bra.s	loc_1AF7C_K
; ===========================================================================

loc_1AF5A_K:
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)
	rts
; ===========================================================================

loc_1AF68_K:
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	cmpi.w	#$FC0,y_vel(a0)
	ble.s	loc_1AF7C_K
	move.w	#$FC0,y_vel(a0)

loc_1AF7C_K:
	move.w	y_vel(a0),inertia(a0)
	tst.b	d3
	bpl.s	return_1AF8A_K
	neg.w	inertia(a0)

return_1AF8A_K:
	rts
; ===========================================================================
; loc_1AF8C:
Knuckles_HitLeftWall:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	Knuckles_HitCeiling ; branch if distance is positive (not inside wall)
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	move.w	y_vel(a0),inertia(a0)
	rts
; ===========================================================================
; loc_1AFA6:
Knuckles_HitCeiling:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Knuckles_HitFloor ; branch if distance is positive (not inside ceiling)
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1AFBE_K
	move.w	#0,y_vel(a0) ; stop Knuckles in y since he hit a ceiling

return_1AFBE_K:
	rts
; ===========================================================================
; loc_1AFC0:
Knuckles_HitFloor:
	tst.w	y_vel(a0)
	bmi.s	return_1AFE6_K
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AFE6_K
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Knuckles_ResetOnFloor
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)

return_1AFE6_K:
	rts
; ===========================================================================
; loc_1AFE8:
Knuckles_HitCeilingAndWalls:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Knuckles since he hit a wall
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Knuckles since he hit a wall
+
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	return_1B042_K
	sub.w	d1,y_pos(a0)
	move.b	d3,d0
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	loc_1B02C_K
	move.w	#0,y_vel(a0) ; stop Knuckles in y since he hit a ceiling
	rts
; ===========================================================================

loc_1B02C_K:
	move.b	d3,angle(a0)
	bsr.w	Knuckles_ResetOnFloor
	move.w	y_vel(a0),inertia(a0)
	tst.b	d3
	bpl.s	return_1B042_K
	neg.w	inertia(a0)

return_1B042_K:
	rts
; ===========================================================================
; loc_1B044:
Knuckles_HitRightWall:
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	Knuckles_HitCeiling2
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Knuckles since he hit a wall
	move.w	y_vel(a0),inertia(a0)
	rts
; ===========================================================================
; identical to Knuckles_HitCeiling...
; loc_1B05E:
Knuckles_HitCeiling2:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Knuckles_HitFloor2
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1B076_K
	move.w	#0,y_vel(a0) ; stop Knuckles in y since he hit a ceiling

return_1B076_K:
	rts
; ===========================================================================
; identical to Knuckles_HitFloor...
; loc_1B078:
Knuckles_HitFloor2:
	tst.w	y_vel(a0)
	bmi.s	return_1B09E_K
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1B09E_K
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.s	Knuckles_ResetOnFloor
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)

return_1B09E_K:
	rts
; End of function Knuckles_DoLevelCollision



; ---------------------------------------------------------------------------
; Subroutine to reset Knuckles's mode when he lands on the floor
; ---------------------------------------------------------------------------

; loc_1B0A0:
Knuckles_ResetOnFloor:
	tst.b	pinball_mode(a0)
	bne.s	Knuckles_ResetOnFloor_Part3
	move.b	#AniIDKnuxAni_Walk,anim(a0)
; loc_1B0AC:
Knuckles_ResetOnFloor_Part2:
	move.b	y_radius(a0),d0
	move.b	#19,y_radius(a0)
	move.b	#9,x_radius(a0)
	bclr	#2,status(a0)
	beq.s	Knuckles_ResetOnFloor_Part3
	move.b	#AniIDKnuxAni_Walk,anim(a0)	; use running/walking/standing animation
	subi.b	#19,d0
	ext.w	d0
	add.w	d0,y_pos(a0)
; loc_1B0DA:
Knuckles_ResetOnFloor_Part3:
	bclr	#status.player.in_air,status(a0)
	bclr	#status.player.pushing,status(a0)
	move.b	#0,jumping(a0)
	move.w	#0,(Chain_Bonus_counter).w
	move.b	#0,flip_angle(a0)
	move.b	#0,flip_turned(a0)
	move.b	#0,flips_remaining(a0)
	move.b	#0,look_delay_counter(a0)
	move.b	#0,double_jump_flag(a0)
	cmpi.b	#AniIDKnuxAni_Glide,anim(a0)
	bhs.s	+
	cmpi.b	#AniIDKnuxAni_Hang2,anim(a0)
	bne.s	return_1B11E_K
+
	move.b	#AniIDKnuxAni_Walk,anim(a0)

return_1B11E_K:
	rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Knuckles when he gets hurt
; ---------------------------------------------------------------------------
; loc_1B120: Obj_01_Sub_4:
Obj09_Hurt:
	tst.w	(Debug_mode_flag).w
	beq.s	Obj09_Hurt_Normal
	btst	#button_B,(Ctrl_1_Press).w
	beq.s	Obj09_Hurt_Normal
	move.w	#1,(Debug_placement_mode).w
	clr.b	(Control_Locked).w
	rts
; ---------------------------------------------------------------------------
; loc_1B13A:
Obj09_Hurt_Normal:
	jsr	(ObjectMove).w
	addi.w	#$30,y_vel(a0)
	btst	#status.player.underwater,status(a0)
	beq.s	+
	subi.w	#$20,y_vel(a0)
+
	cmpi.w	#-$100,(Camera_Min_Y_pos).w
	bne.s	+
	andi.w	#$7FF,y_pos(a0)
+
	bsr.s	Knuckles_HurtStop
	bsr.w	Knuckles_LevelBound
	bsr.w	Knuckles_RecordPos
	bsr.w	Knuckles_Animate
	bsr.w	LoadKnucklesDynPLC
	jmp	(DisplaySprite).w
; ===========================================================================
; loc_1B184:
Knuckles_HurtStop:
	movea.l	a0,a2
	move.w	(Camera_Max_Y_pos).w,d0
	move.w	(Camera_Max_Y_pos_target).w,d1
	cmp.w	d0,d1
	blo.s	.skip
	move.w	d1,d0
.skip:
	addi.w	#screen_height,d0
	cmp.w	y_pos(a0),d0
	blt.s	JmpTo_KillCharacter_K
	bsr.w	Knuckles_DoLevelCollision
	btst	#status.player.in_air,status(a0)
	bne.s	return_1B1C8_K
	moveq	#0,d0
	move.l	d0,x_vel(a0)
	move.w	d0,inertia(a0)
	move.b	d0,obj_control(a0)
	move.b	#AniIDKnuxAni_Walk,anim(a0)
	subq.b	#2,routine(a0)	; => Obj09_Control
	move.b	#120,invulnerable_time(a0)
	move.b	d0,spindash_flag(a0)

return_1B1C8_K:
	rts

JmpTo_KillCharacter_K ; JmpTo
	jmp	(KillCharacter).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Knuckles when he dies
; ...poor Knuckles
; ---------------------------------------------------------------------------

; loc_1B1E6: Obj_01_Sub_6:
Obj09_Dead:
	tst.w	(Debug_mode_flag).w
	beq.s	+
	btst	#button_B,(Ctrl_1_Press).w
	beq.s	+
	move.w	#1,(Debug_placement_mode).w
	clr.b	(Control_Locked).w
	rts
+
	bsr.w	CheckGameOver
	jsr	(ObjectMoveAndFall).w
	bsr.w	Knuckles_RecordPos
	bsr.w	Knuckles_Animate
	bsr.w	LoadKnucklesDynPLC
	jmp	(DisplaySprite).w

; ===========================================================================
; ---------------------------------------------------------------------------
; Knuckles when the level is restarted
; ---------------------------------------------------------------------------
; loc_1B28E:
Obj09_ResetLevel:
	tst.b	(Time_Over_flag).w
	beq.s	Obj09_ResetLevel_Part2
	move.w	#0,restart_countdown(a0)
	move.b	#ObjID_TimeOver,(TimeOver_TimeText+id).w ; load Obj39
	move.b	#ObjID_TimeOver,(TimeOver_OverText+id).w ; load Obj39
	move.b	#2,(TimeOver_TimeText+mapping_frame).w
	move.b	#3,(TimeOver_OverText+mapping_frame).w
	move.w	a0,(TimeOver_TimeText+parent).w
	bra.w	Obj01_Finished
; ---------------------------------------------------------------------------
Obj09_ResetLevel_Part2:
	move.b	#0,(Scroll_lock).w
	move.b	#$A,routine(a0)	; => Obj09_Respawning
	move.w	(Saved_x_pos).w,x_pos(a0)
	move.w	(Saved_y_pos).w,y_pos(a0)
	move.w	(Saved_art_tile).w,art_tile(a0)
	move.w	(Saved_Solid_bits).w,top_solid_bit(a0)
	clr.w	(Ring_count).w
	clr.b	(Extra_life_flags).w
	move.b	#0,obj_control(a0)
	move.b	#5,anim(a0)
	move.l	#0,x_vel(a0)
	move.w	#0,inertia(a0)
	move.b	#1<<status.player.in_air,status(a0)
	move.w	#0,move_lock(a0)
	move.w	#0,restart_countdown(a0)

return_1B31A_K:
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Knuckles when he's offscreen and waiting for the level to restart
; ---------------------------------------------------------------------------
; loc_1B31C: Obj_01_Sub_8:
Obj09_Gone:
	tst.w	restart_countdown(a0)
	beq.s	+
	subq.w	#1,restart_countdown(a0)
	bne.s	+
	move.w	#1,(Level_Inactive_flag).w
+
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Knuckles when he's waiting for the camera to scroll back to where he respawned
; ---------------------------------------------------------------------------
; loc_1B330: Obj_01_Sub_A:
Obj09_Respawning:
	tst.w	(Camera_X_pos_diff).w
	bne.s	+
	tst.w	(Camera_Y_pos_diff).w
	bne.s	+
	move.b	#2,routine(a0)	; => Obj09_Control
+
	bsr.s	Knuckles_Animate
	bsr.w	LoadKnucklesDynPLC
	jmp	(DisplaySprite).w
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to animate Knuckles's sprites
; See also: AnimateSprite
; ---------------------------------------------------------------------------

; loc_1B350:
Knuckles_Animate:
	lea	KnucklesAniData(pc),a1
	moveq	#0,d0
	move.b	anim(a0),d0
	cmp.b	prev_anim(a0),d0	; has animation changed?
	beq.s	KAnim_Do		; if not, branch
	move.b	d0,prev_anim(a0)	; set previous animation
	move.b	#0,anim_frame(a0)	; reset animation frame
	move.b	#0,anim_frame_duration(a0)	; reset frame duration
	bclr	#status.player.pushing,status(a0)
; loc_1B384:
KAnim_Do:
	add.w	d0,d0
	adda.w	(a1,d0.w),a1	; calculate address of appropriate animation script
	move.b	(a1),d0
	bmi.s	KAnim_WalkRun	; if animation is walk/run/roll/jump, branch
	move.b	status(a0),d1
	andi.b	#1<<status.player.x_flip,d1
	andi.b	#~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
	or.b	d1,render_flags(a0)
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.s	KAnim_Delay			; if time remains, branch
	move.b	d0,anim_frame_duration(a0)	; load frame duration
; loc_1B3AA:
KAnim_Do2:
	moveq	#0,d1
	move.b	anim_frame(a0),d1	; load current frame number
	move.b	1(a1,d1.w),d0		; read sprite number from script
	cmpi.b	#$FC,d0
	bhs.s	KAnim_End_FF		; if animation is complete, branch
; loc_1B3BA:
KAnim_Next:
	move.b	d0,mapping_frame(a0)	; load sprite number
	addq.b	#1,anim_frame(a0)	; go to next frame
; return_1B3C2:
KAnim_Delay:
	rts
; ===========================================================================
; loc_1B3C4:
KAnim_End_FF:
	addq.b	#1,d0		; is the end flag = $FF?
	bne.s	KAnim_End_FE	; if not, branch
	move.b	#0,anim_frame(a0)	; restart the animation
	move.b	1(a1),d0	; read sprite number
	bra.s	KAnim_Next
; ===========================================================================
; loc_1B3D4:
KAnim_End_FE:
	addq.b	#1,d0		; is the end flag = $FE?
	bne.s	KAnim_End_FD	; if not, branch
	move.b	2(a1,d1.w),d0	; read the next byte in the script
	sub.b	d0,anim_frame(a0)	; jump back d0 bytes in the script
	sub.b	d0,d1
	move.b	1(a1,d1.w),d0	; read sprite number
	bra.s	KAnim_Next
; ===========================================================================
; loc_1B3E8:
KAnim_End_FD:
	addq.b	#1,d0			; is the end flag = $FD?
	bne.s	KAnim_End		; if not, branch
	move.b	2(a1,d1.w),anim(a0)	; read next byte, run that animation
; return_1B3F2:
KAnim_End:
	rts
; ===========================================================================
; loc_1B3F4:
KAnim_WalkRun:
	addq.b	#1,d0		; is the start flag = $FF?
	bne.w	KAnim_Roll	; if not, branch
	moveq	#0,d0		; is animation walking/running?
	move.b	flip_angle(a0),d0	; if not, branch
	bne.w	KAnim_Tumble
	moveq	#0,d1
	move.b	angle(a0),d0	; get Knuckles's angle
	ble.s	+
	subq.b	#1,d0
+
	move.b	status(a0),d2
	andi.b	#1<<status.player.x_flip,d2	; is Knuckles mirrored horizontally?
	bne.s	+				; if yes, branch
	not.b	d0				; reverse angle
+
	addi.b	#$10,d0		; add $10 to angle
	bpl.s	+		; if angle is $0-$7F, branch
	moveq	#1<<render_flags.x_flip|1<<render_flags.y_flip,d1
+
	andi.b	#~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
	eor.b	d1,d2
	or.b	d2,render_flags(a0)
	btst	#status.player.pushing,status(a0)
	bne.w	KAnim_Push
	lsr.b	#4,d0		; divide angle by 16
	andi.b	#6,d0		; angle must be 0, 2, 4 or 6
	mvabs.w	inertia(a0),d2	; get Knuckles's "speed" for animation purposes
	_btst	#status_secondary.sliding,status_secondary(a0)
	_beq.s	+
	add.w	d2,d2
+
	lea	KnucklesAni_Run(pc),a1	; use running animation
	cmpi.w	#$600,d2		; is Knuckles at running speed?
	bhs.s	+			; use running animation
	lea	KnucklesAni_Walk(pc),a1	; if yes, branch
	add.b	d0,d0
+
	add.b	d0,d0
	move.b	d0,d3
	moveq	#0,d1
	move.b	anim_frame(a0),d1
	move.b	1(a1,d1.w),d0
	cmpi.b	#-1,d0
	bne.s	+
	move.b	#0,anim_frame(a0)
	move.b	1(a1),d0
+
	move.b	d0,mapping_frame(a0)
	add.b	d3,mapping_frame(a0)
	subq.b	#1,anim_frame_duration(a0)
	bpl.s	return_1B4AC_K
	neg.w	d2
	addi.w	#$800,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)	; modify frame duration
	addq.b	#1,anim_frame(a0)		; modify frame number

return_1B4AC_K:
	rts
; ===========================================================================
; loc_1B520:
KAnim_Tumble:
	move.b	flip_angle(a0),d0
	moveq	#0,d1
	move.b	status(a0),d2
	andi.b	#1<<status.player.x_flip,d2
	bne.s	KAnim_Tumble_Left

	andi.b	#~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
	addi.b	#$B,d0
	divu.w	#$16,d0
	addi.b	#$31,d0
	move.b	d0,mapping_frame(a0)
	move.b	#0,anim_frame_duration(a0)
	rts
; ===========================================================================
; loc_1B54E:
KAnim_Tumble_Left:
	andi.b	#~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
	tst.b	flip_turned(a0)
	beq.s	loc_1B566_K
	ori.b	#1<<render_flags.x_flip,render_flags(a0)
	addi.b	#$B,d0
	bra.s	loc_1B572_K
; ===========================================================================

loc_1B566_K:
	ori.b	#1<<render_flags.x_flip|1<<render_flags.y_flip,render_flags(a0)
	neg.b	d0
	addi.b	#$8F,d0

loc_1B572_K:
	divu.w	#$16,d0
	addi.b	#$31,d0
	move.b	d0,mapping_frame(a0)
	move.b	#0,anim_frame_duration(a0)
	rts
; ===========================================================================
; loc_1B586:
KAnim_Roll:
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.w	KAnim_Delay			; if time remains, branch
	addq.b	#1,d0		; is the start flag = $FE?
	bne.s	KAnim_Push	; if not, branch
	mvabs.w	inertia(a0),d2
	lea	KnucklesAni_Roll(pc),a1
	neg.w	d2
	addi.w	#$400,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)
	moveq	#1<<status.player.x_flip,d1
	and.b	status(a0),d1
	andi.b	#~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
	or.b	d1,render_flags(a0)
	bra.w	KAnim_Do2
; ===========================================================================

KAnim_Push:
	subq.b	#1,anim_frame_duration(a0)	; subtract 1 from frame duration
	bpl.w	KAnim_Delay			; if time remains, branch
	move.w	inertia(a0),d2
	bmi.s	+
	neg.w	d2
+
	addi.w	#$800,d2
	bpl.s	+
	moveq	#0,d2
+
	lsr.w	#8,d2
	move.b	d2,anim_frame_duration(a0)
	lea	KnucklesAni_Push(pc),a1
	moveq	#1<<status.player.x_flip,d1
	and.b	status(a0),d1
	andi.b	#~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
	or.b	d1,render_flags(a0)
	bra.w	KAnim_Do2
; ===========================================================================

; ---------------------------------------------------------------------------
; Animation script - Knuckles
; ---------------------------------------------------------------------------
; off_1B618:
KnucklesAniData:			offsetTable
KnuxAni_Walk_ptr:		offsetTableEntry.w KnucklesAni_Walk		;  0 ;   0
KnuxAni_Run_ptr:		offsetTableEntry.w KnucklesAni_Run		;  1 ;   1
KnuxAni_Roll_ptr:		offsetTableEntry.w KnucklesAni_Roll		;  2 ;   2
KnuxAni_Roll2_ptr:		offsetTableEntry.w KnucklesAni_Roll2		;  3 ;   3
KnuxAni_Push_ptr:		offsetTableEntry.w KnucklesAni_Push		;  4 ;   4
KnuxAni_Wait_ptr:		offsetTableEntry.w KnucklesAni_Wait		;  5 ;   5
KnuxAni_Balance_ptr:		offsetTableEntry.w KnucklesAni_Balance		;  6 ;   6
KnuxAni_LookUp_ptr:		offsetTableEntry.w KnucklesAni_LookUp		;  7 ;   7
KnuxAni_Duck_ptr:		offsetTableEntry.w KnucklesAni_Duck		;  8 ;   8
KnuxAni_Spindash_ptr:		offsetTableEntry.w KnucklesAni_Spindash		;  9 ;   9
KnuxAni_Blink_ptr:		offsetTableEntry.w KnucklesAni_Unused		; 10 ;  $A
KnuxAni_GetUp_ptr:		offsetTableEntry.w KnucklesAni_Pull		; 11 ;  $B
KnuxAni_Balance2_ptr:		offsetTableEntry.w KnucklesAni_Balance2		; 12 ;  $C
KnuxAni_Stop_ptr:		offsetTableEntry.w KnucklesAni_Stop		; 13 ;  $D
KnuxAni_Float_ptr:		offsetTableEntry.w KnucklesAni_Float		; 14 ;  $E
KnuxAni_Float2_ptr:		offsetTableEntry.w KnucklesAni_Float2		; 15 ;  $F
KnuxAni_Spring_ptr:		offsetTableEntry.w KnucklesAni_Spring		; 16 ; $10
KnuxAni_Hang_ptr:		offsetTableEntry.w KnucklesAni_Hang		; 17 ; $11
KnuxAni_Dash2_ptr:		offsetTableEntry.w KnucklesAni_Unused_0		; 18 ; $12
KnuxAni_Dash3_ptr:		offsetTableEntry.w KnucklesAni_S3EndingPose	; 19 ; $13
KnuxAni_Hang2_ptr:		offsetTableEntry.w KnucklesAni_WFZHang		; 20 ; $14
KnuxAni_Bubble_ptr:		offsetTableEntry.w KnucklesAni_Bubble		; 21 ; $15
KnuxAni_DeathBW_ptr:		offsetTableEntry.w KnucklesAni_DeathBW		; 22 ; $16
KnuxAni_Drown_ptr:		offsetTableEntry.w KnucklesAni_Drown		; 23 ; $17
KnuxAni_Death_ptr:		offsetTableEntry.w KnucklesAni_Death		; 24 ; $18
KnuxAni_Hurt_ptr:		offsetTableEntry.w KnucklesAni_OilSlide		; 25 ; $19
KnuxAni_Hurt2_ptr:		offsetTableEntry.w KnucklesAni_Hurt		; 26 ; $1A
KnuxAni_Slide_ptr:		offsetTableEntry.w KnucklesAni_OilSlide_0	; 27 ; $1B
KnuxAni_Blank_ptr:		offsetTableEntry.w KnucklesAni_Blank		; 28 ; $1C
KnuxAni_Balance3_ptr:		offsetTableEntry.w KnucklesAni_Unused_1		; 29 ; $1D
KnuxAni_Balance4_ptr:		offsetTableEntry.w KnucklesAni_Unused_2		; 30 ; $1E
SupKnuxAni_Transform_ptr:	offsetTableEntry.w KnucklesAni_Transform	; 31 ; $1F
KnuxAni_Glide_ptr:		offsetTableEntry.w KnucklesAni_Gliding		; 32 ; $20
KnuxAni_FallAfterGlide_ptr:	offsetTableEntry.w KnucklesAni_FallFromGlide	; 33 ; $21
KnuxAni_ClimbLedge_ptr:		offsetTableEntry.w KnucklesAni_GetUp		; 34 ; $22
KnuxAni_LandAfterGlide_ptr:	offsetTableEntry.w KnucklesAni_HardFall		; 35 ; $23
KnuxAni_ShadowBox_ptr:		offsetTableEntry.w KnucklesAni_Badass		; 36 ; $24

KnucklesAni_Walk:	dc.b $FF,  7,  8,  1,  2,  3,  4,  5,  6,$FF
KnucklesAni_Run:	dc.b $FF,$21,$22,$23,$24,$FF,$FF,$FF,$FF,$FF
KnucklesAni_Roll:	dc.b $FE,$9A,$96,$9A,$97,$9A,$98,$9A,$99,$FF
KnucklesAni_Roll2:	dc.b $FE,$9A,$96,$9A,$97,$9A,$98,$9A,$99,$FF
KnucklesAni_Push:	dc.b $FD,$CE,$CF,$D0,$D1,$FF,$FF,$FF,$FF,$FF
KnucklesAni_Wait:
	dc.b   5,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
	dc.b $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
	dc.b $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
	dc.b $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$D2
	dc.b $D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2
	dc.b $D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2
	dc.b $D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3
	dc.b $D3,$D3,$D2,$D2,$D2,$D3,$D3,$D3,$D2,$D2,$D2,$D3,$D3
	dc.b $D3,$D4,$D4,$D4,$D4,$D4,$D7,$D8,$D9,$DA,$DB,$D8,$D9
	dc.b $DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA
	dc.b $DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB
	dc.b $DC,$DD,$DC,$DD,$DE,$DE,$D8,$D7,$FF
KnucklesAni_Balance:
	dc.b   3,$9F,$9F,$A0,$A0,$A1,$A1,$A2,$A2,$A3,$A3,$A4,$A4
	dc.b $A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5
	dc.b $A5,$A5,$A6,$A6,$A6,$A7,$A7,$A7,$A8,$A8,$A9,$A9,$AA
	dc.b $AA,$FE,  6
KnucklesAni_LookUp:	dc.b   5,$D5,$D6,$FE,  1
KnucklesAni_Duck:	dc.b   5,$9B,$9C,$FE,  1
KnucklesAni_Spindash:	dc.b   0,$86,$87,$86,$88,$86,$89,$86,$8A,$86,$8B,$FF
KnucklesAni_Unused:
	dc.b   9,$BA,$C5,$C6,$C6,$C6,$C6,$C6,$C6,$C7,$C7,$C7,$C7
	dc.b $C7,$C7,$C7,$C7,$C7,$C7,$C7,$C7,$FD,  0
KnucklesAni_Pull:	dc.b  $F,$8F,$FF
KnucklesAni_Balance2:
	dc.b   3,$A1,$A1,$A2,$A2,$A3,$A3,$A4,$A4,$A5,$A5,$A5,$A5
	dc.b $A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A6,$A6
	dc.b $A6,$A7,$A7,$A7,$A8,$A8,$A9,$A9,$AA,$AA,$FE
	dc.b   6
KnucklesAni_Stop:	dc.b   3,$9D,$9E,$9F,$A0,$FD,	0
KnucklesAni_Float:	dc.b   7,$C0,$FF
KnucklesAni_Float2:	dc.b   5,$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$FF
KnucklesAni_Spring:	dc.b $2F,$8E,$FD,  0
KnucklesAni_Hang:	dc.b   1,$AE,$AF,$FF
KnucklesAni_Unused_0:	dc.b  $F,$43,$43,$43,$FE,  1
KnucklesAni_S3EndingPose:
	dc.b   5,$B1,$B2,$B2,$B2,$B3,$B4,$FE,  1,  7,$B1,$B3,$B3
	dc.b $B3,$B3,$B3,$B3,$B2,$B3,$B4,$B3,$FE,  4
KnucklesAni_WFZHang:	dc.b $13,$91,$FF
KnucklesAni_Bubble:	dc.b  $B,$B0,$B0,  3,  4,$FD,  0
KnucklesAni_DeathBW:	dc.b $20,$AC,$FF
KnucklesAni_Drown:	dc.b $20,$AD,$FF
KnucklesAni_Death:	dc.b $20,$AB,$FF
KnucklesAni_OilSlide:	dc.b   9,$8C,$FF
KnucklesAni_Hurt:	dc.b $40,$8D,$FF
KnucklesAni_OilSlide_0:	dc.b   9,$8C,$FF
KnucklesAni_Blank:	dc.b $77,  0,$FF
KnucklesAni_Unused_1:	dc.b $13,$D0,$D1,$FF
KnucklesAni_Unused_2:	dc.b   3,$CF,$C8,$C9,$CA,$CB,$FE,  4
KnucklesAni_Gliding:	dc.b $1F,$C0,$FF
KnucklesAni_FallFromGlide:	dc.b   7,$CA,$CB,$FE,	 1
KnucklesAni_GetUp:	dc.b  $F,$CD,$FD,  0
KnucklesAni_HardFall:	dc.b  $F,$9C,$FD,  0
KnucklesAni_Badass:
	dc.b   5,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB
	dc.b $D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8,$D9,$DA,$DB,$D8
	dc.b $D9,$DA,$DB,$D8,$D9,$DA,$DB,$DC,$DD,$DC,$DD,$DE,$DE
	dc.b $FF
KnucklesAni_Transform:
	dc.b   2,$EB,$EB,$EC,$ED,$EC,$ED,$EC,$ED,$EC,$ED,$EC,$ED
	dc.b $FD,  0
	even

; ---------------------------------------------------------------------------
; Knuckles pattern loading subroutine
; ---------------------------------------------------------------------------

; loc_1B848:
LoadKnucklesDynPLC:
	moveq	#0,d0
	move.b	mapping_frame(a0),d0	; load frame number
; loc_1B84E:
LoadKnucklesDynPLC_Part2:
	cmp.b	(Knuckles_LastLoadedDPLC).w,d0
	beq.s	return_1B89A_K
	move.b	d0,(Knuckles_LastLoadedDPLC).w

	lea	(MapRUnc_Knuckles).l,a2
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	bmi.s	return_1B89A_K
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Sonic),d4
    if AssumeSourceAddressInBytes
	move.l	#ArtUnc_Knuckles,d6
    else
	move.l	#dmaSource(ArtUnc_Knuckles),d6
    endif
; loc_1B86E:
KPLC_ReadEntry:
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	d1,d3
	andi.w	#$F,d3
	addq.w	#1,d3
	lsl.w	#4,d3
	andi.w	#$FFF0,d1
    if AssumeSourceAddressInBytes
	add.l	d1,d1
    endif
	add.l	d6,d1
	move.w	d4,d2
	add.w	d3,d4
	add.w	d3,d4
	jsr	(QueueDMATransfer).w
	dbf	d5,KPLC_ReadEntry	; repeat for number of entries

return_1B89A_K:
	rts