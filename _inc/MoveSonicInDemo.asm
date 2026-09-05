; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_481E:
MoveSonicInDemo:
	tst.w	(Demo_mode_flag).w	; is demo mode on?
	bne.s	MoveDemo_On	; if yes, branch
	rts
; ===========================================================================
; loc_48AA:
MoveDemo_On:
	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_start_mask,d0
	beq.s	+
	move.b	#GameModeID_TitleScreen,(Game_Mode).w ; => TitleScreen
+
	lea	DemoScriptPointers(pc),a1 ; load pointer to input data
	moveq	#0,d0
	move.b	(Current_Zone).w,d0
; loc_48DA:
MoveDemo_On_P1:
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a1,d0.w),a1

	move.w	(Demo_button_index).w,d0
	adda.w	d0,a1	; a1 now points to the current button press data
	move.b	(a1),d0	; load button press
	lea	(Ctrl_1_Held).w,a0
	move.b	d0,d1
	move.b	Ctrl_1_Held_Logical-Ctrl_1_Held(a0),d2
	eor.b	d2,d0	; determine which buttons differ between this frame and the last
	move.b	d1,(a0)+ ; save button press data from demo to Ctrl_1_Held
	and.b	d1,d0	; only keep the buttons that were pressed on this frame
	move.b	d0,(a0)+ ; save the same thing to Ctrl_1_Press
	subq.b	#1,(Demo_press_counter).w  ; decrement counter until next press
	bcc.s	MoveDemo_On_P2	   ; if it isn't 0 yet, branch
	move.b	3(a1),(Demo_press_counter).w ; reset counter to length of next press
	addq.w	#2,(Demo_button_index).w ; advance to next button press
; loc_4908:
MoveDemo_On_P2:
	rts
; End of function MoveSonicInDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; DEMO SCRIPT POINTERS

; Contains an array of pointers to the script controlling the players actions
; to use for each level.
; ---------------------------------------------------------------------------
; off_4948:
DemoScriptPointers: zoneOrderedTable 4,1
	zoneTableEntry.l Demo_EHZ	; EHZ
	zoneTableEntry.l Demo_EHZ	; Zone 1
	zoneTableEntry.l Demo_EHZ	; WZ
	zoneTableEntry.l Demo_EHZ	; Zone 3
	zoneTableEntry.l Demo_EHZ	; MTZ1,2
	zoneTableEntry.l Demo_EHZ	; MTZ3
	zoneTableEntry.l Demo_EHZ	; WFZ
	zoneTableEntry.l Demo_EHZ	; HTZ
	zoneTableEntry.l Demo_EHZ	; HPZ
	zoneTableEntry.l Demo_EHZ	; Zone 9
	zoneTableEntry.l Demo_EHZ	; OOZ
	zoneTableEntry.l Demo_EHZ	; MCZ
	zoneTableEntry.l Demo_CNZ	; CNZ
	zoneTableEntry.l Demo_CPZ	; CPZ
	zoneTableEntry.l Demo_EHZ	; DEZ
	zoneTableEntry.l Demo_ARZ	; ARZ
	zoneTableEntry.l Demo_EHZ	; SCZ
    zoneTableEnd