; Sonic the Hedgehog 2 disassembled binary

; Nemesis,   2004: Created original disassembly for SNASM68K
; Aurochs,   2005: Translated to AS and annotated
; Xenowhirl, 2007: More annotation, overall cleanup, Z80 disassembly
; ---------------------------------------------------------------------------
; NOTES:
;
; Set your editor's tab width to 8 characters wide for viewing this file.
;
; It is highly suggested that you read the AS User's Manual before diving too
; far into this disassembly. At least read the section on nameless temporary
; symbols. Your brain may melt if you don't know how those work.
;
; See s2.notes.txt for more comments about this disassembly and other useful info.

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSEMBLY OPTIONS:
;
debugbuild = 1
;
gameRevision = 1
;	| If 0, a REV00 ROM is built
;	| If 1, a REV01 ROM is built, which contains some fixes
;	| If 2, a (theoretical) REV02 ROM is built, which contains even more fixes
padToPowerOfTwo = 0
;	| If 1, pads the end of the ROM to the next power of two bytes (for real hardware)
;
fixBugs = 1
;	| If 1, enables all bug-fixes
;	| See also the 'FixDriverBugs' flag in 's2.sounddriver.asm'
;	| See also the 'FixMusicAndSFXDataBugs' flag in 'build.lua'
skipChecksumCheck = 1
;	| If 1, disables the slow bootup checksum calculation
;
useFullWaterTables = 1
;	| If 1, zone offset tables for water levels cover all level slots instead of only slots 8-$F
;	| Set to 1 if you've shifted level IDs around or you want water in levels with a level slot below 8

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; AS-specific macros and assembler settings
	CPU 68000
	include "s2.macrosetup.asm"

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Simplifying macros and functions
	include "s2.macros.asm"

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equates section - Names for variables.
	include "s2.constants.asm"
	include	"errorhandler/Debugger.asm"

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Expressing SMPS bytecode in a portable and human-readable form
FixMusicAndSFXDataBugs = fixBugs
SonicDriverVer = 2 ; Tell SMPS2ASM that we are targetting Sonic 2's sound driver
	include "sound/_smps2asm_inc.asm"

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Expressing sprite mappings and DPLCs in a portable and human-readable form
SonicMappingsVer := 3
SonicDplcVer := 2
	include "mappings/MapMacros.asm"

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; start of ROM

StartOfRom:
    if * <> 0
	fatal "StartOfRom was $\{*} but it should be 0"
    endif
Vectors:
	dc.l System_Stack	; Initial stack pointer value
	dc.l EntryPoint		; Start of program
	dc.l BusError		; Bus error
	dc.l AddressError	; Address error (4)
	dc.l IllegalInstr	; Illegal instruction
	dc.l ZeroDivide		; Division by zero
	dc.l ChkInstr		; CHK exception
	dc.l TrapvInstr		; TRAPV exception (8)
	dc.l PrivilegeViol	; Privilege violation
	dc.l Trace			; TRACE exception
	dc.l Line1010Emu	; Line-A emulator
	dc.l Line1111Emu	; Line-F emulator (12)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved) (16)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved) (20)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved)
	dc.l ErrorExcept	; Unused (reserved) (24)
	dc.l ErrorExcept	; Spurious exception
	dc.l ErrorTrap		; IRQ level 1
	dc.l ErrorTrap		; IRQ level 2
	dc.l ErrorTrap		; IRQ level 3 (28)
	dc.l H_Int		; IRQ level 4 (horizontal retrace interrupt)
	dc.l ErrorTrap		; IRQ level 5
	dc.l V_Int		; IRQ level 6 (vertical retrace interrupt)
	dc.l ErrorTrap		; IRQ level 7 (32)
	dc.l ErrorTrap		; TRAP #00 exception
	dc.l ErrorTrap		; TRAP #01 exception
	dc.l ErrorTrap		; TRAP #02 exception
	dc.l ErrorTrap		; TRAP #03 exception (36)
	dc.l ErrorTrap		; TRAP #04 exception
	dc.l ErrorTrap		; TRAP #05 exception
	dc.l ErrorTrap		; TRAP #06 exception
	dc.l ErrorTrap		; TRAP #07 exception (40)
	dc.l ErrorTrap		; TRAP #08 exception
	dc.l ErrorTrap		; TRAP #09 exception
	dc.l ErrorTrap		; TRAP #10 exception
	dc.l ErrorTrap		; TRAP #11 exception (44)
	dc.l ErrorTrap		; TRAP #12 exception
	dc.l ErrorTrap		; TRAP #13 exception
	dc.l ErrorTrap		; TRAP #14 exception
	dc.l ErrorTrap		; TRAP #15 exception (48)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved) (52)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved) (56)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved) (60)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved)
	dc.l ErrorTrap		; Unused (reserved) (64)
; byte_100:
Header:
	dc.b "SEGA GENESIS    " ; Console name
	dc.b "(C)SEGA XXXX.XXX" ; Copyright holder and release date (generally year)
	dc.b "SONIC THE       " ; Domestic name
	dc.b "      HEDGEHOG 2"
	dc.b "                "
	dc.b "SONIC THE       " ; International name
	dc.b "      HEDGEHOG 2"
	dc.b "                "
	dc.b "GM XXXXXXXX-XX"   ; Version
; word_18E
Checksum:
	dc.w 0			; Checksum (patched later if incorrect)
	dc.b "J               " ; I/O Support
	dc.l StartOfRom		; Start address of ROM
; dword_1A4
ROMEndLoc:
	dc.l EndOfRom-1		; End address of ROM
	dc.l RAM_Start&$FFFFFF		; Start address of RAM
	dc.l (RAM_End-1)&$FFFFFF	; End address of RAM
	dc.b "    "		; Backup RAM ID
	dc.l $20202020		; Backup RAM start address
	dc.l $20202020		; Backup RAM end address
	dc.b "            "	; Modem support
	dc.b "                                        "	; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
	dc.b "JUE             " ; Country code (region)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Note that the Z80 continues to run, so the music keeps playing.
; loc_200:
ErrorTrap:
	bra.s	ErrorTrap	; Loop indefinitely.

; ===========================================================================
; loc_206:
EntryPoint:
	; Everything from here to just past CheckSumCheck is the standard
	; "MEGA DRIVE hard initial program", distributed by Sega as a file
	; called 'ICD_BLK4.PRG'.
	; http://techdocs.exodusemulator.com/Console/SegaMegaDrive/Software.html#original-development-tools
	tst.l	(HW_Port_1_Control-1).l		; test ports A and B control
	bne.s	PortA_Ok			; If so, branch.
	tst.w	(HW_Expansion_Control-1).l	; test port C control
; loc_214:
PortA_Ok:
	bne.s	PortC_OK ; Skip the VDP and Z80 setup code if this is a soft-reset.
	lea	SetupValues(pc),a5	; Load setup values array address.
	movem.w	(a5)+,d5-d7
	movem.l	(a5)+,a0-a4
	move.b	HW_Version-Z80_Bus_Request(a1),d0	; Get hardware version
	andi.b	#$F,d0					; Compare
	beq.s	SkipSecurity				; If the console has no TMSS, skip the security stuff.
	move.l	#'SEGA',Security_Addr-Z80_Bus_Request(a1) ; Satisfy the TMSS
; loc_234:
SkipSecurity:
	move.w	(a4),d0	; check if VDP works
	moveq	#0,d0	; clear d0
	movea.l	d0,a6	; clear a6
	move.l	a6,usp	; set usp to $0

	moveq	#VDPInitValues_End-VDPInitValues-1,d1 ; run the following loop $18 times
; loc_23E:
VDPInitLoop:
	move.b	(a5)+,d5	; add $8000 to value
	move.w	d5,(a4)		; move value to VDP register
	add.w	d7,d5		; next register
	dbf	d1,VDPInitLoop

	move.l	(a5)+,(a4)	; set VRAM write mode
	move.w	d0,(a3)		; clear the screen
	move.w	d7,(a1)		; stop the Z80
	move.w	d7,(a2)		; reset the Z80
; loc_250:
WaitForZ80:
	btst	d0,(a1)		; has the Z80 stopped?
	bne.s	WaitForZ80	; if not, branch

	moveq	#Z80StartupCodeEnd-Z80StartupCodeBegin-1,d2
; loc_256:
Z80InitLoop:
	move.b	(a5)+,(a0)+
	dbf	d2,Z80InitLoop

	move.w	d0,(a2)
	move.w	d0,(a1)	; start the Z80
	move.w	d7,(a2)	; reset the Z80

; loc_262:
ClrRAMLoop:
	move.l	d0,-(a6)	; clear 4 bytes of RAM
	dbf	d6,ClrRAMLoop	; repeat until the entire RAM is clear
	move.l	(a5)+,(a4)	; set VDP display mode and increment mode
	move.l	(a5)+,(a4)	; set VDP to CRAM write

	moveq	#bytesToLcnt($80),d3	; set repeat times
; loc_26E:
ClrCRAMLoop:
	move.l	d0,(a3)		; clear 2 palettes
	dbf	d3,ClrCRAMLoop	; repeat until the entire CRAM is clear
	move.l	(a5)+,(a4)	; set VDP to VSRAM write

	moveq	#bytesToLcnt($50),d4	; set repeat times
; loc_278: ClrVDPStuff:
ClrVSRAMLoop:
	move.l	d0,(a3)	; clear 4 bytes of VSRAM.
	dbf	d4,ClrVSRAMLoop	; repeat until the entire VSRAM is clear
	moveq	#PSGInitValues_End-PSGInitValues-1,d5	; set repeat times.
; loc_280:
PSGInitLoop:
	move.b	(a5)+,PSG_input-VDP_data_port(a3) ; reset the PSG
	dbf	d5,PSGInitLoop	; repeat for other channels
	move.w	d0,(a2)
	movem.l	(a6),d0-a6	; clear all registers
	move	#$2700,sr	; set the sr
 ; loc_292:
PortC_OK: ;;
	bra.s	GameProgram	; Branch to game program.
; ===========================================================================
; byte_294:
SetupValues:
	dc.w	$8000,bytesToLcnt($10000),$100

	dc.l	Z80_RAM
	dc.l	Z80_Bus_Request
	dc.l	Z80_Reset
	dc.l	VDP_data_port, VDP_control_port

VDPInitValues:	; values for VDP registers
	dc.b 4			; Command $8004 - HInt off, Enable HV counter read
	dc.b $14		; Command $8114 - Display off, VInt off, DMA on, PAL off
	dc.b $30		; Command $8230 - Scroll A Address $C000
	dc.b $3C		; Command $833C - Window Address $F000
	dc.b 7			; Command $8407 - Scroll B Address $E000
	dc.b $6C		; Command $856C - Sprite Table Address $D800
	dc.b 0			; Command $8600 - Null
	dc.b 0			; Command $8700 - Background color Pal 0 Color 0
	dc.b 0			; Command $8800 - Null
	dc.b 0			; Command $8900 - Null
	dc.b $FF		; Command $8AFF - Hint timing $FF scanlines
	dc.b 0			; Command $8B00 - Ext Int off, VScroll full, HScroll full
	dc.b $81		; Command $8C81 - 40 cell mode, shadow/highlight off, no interlace
	dc.b $37		; Command $8D37 - HScroll Table Address $DC00
	dc.b 0			; Command $8E00 - Null
	dc.b 1			; Command $8F01 - VDP auto increment 1 byte
	dc.b 1			; Command $9001 - 64x32 cell scroll size
	dc.b 0			; Command $9100 - Window H left side, Base Point 0
	dc.b 0			; Command $9200 - Window V upside, Base Point 0
	dc.b $FF		; Command $93FF - DMA Length Counter $FFFF
	dc.b $FF		; Command $94FF - See above
	dc.b 0			; Command $9500 - DMA Source Address $0
	dc.b 0			; Command $9600 - See above
	dc.b $80		; Command $9780 - See above + VRAM fill mode
VDPInitValues_End:

	dc.l	vdpComm($0000,VRAM,DMA) ; value for VRAM write mode

	; Z80 instructions (not the sound driver; that gets loaded later)
Z80StartupCodeBegin: ; loc_2CA:
    save
    CPU Z80 ; start assembling Z80 code
    phase 0 ; pretend we're at address 0
	xor	a	; clear a to 0
	ld	bc,((Z80_RAM_End-Z80_RAM)-zStartupCodeEndLoc)-1 ; prepare to loop this many times
	ld	de,zStartupCodeEndLoc+1	; initial destination address
	ld	hl,zStartupCodeEndLoc	; initial source address
	ld	sp,hl	; set the address the stack starts at
	ld	(hl),a	; set first byte of the stack to 0
	ldir		; loop to fill the stack (entire remaining available Z80 RAM) with 0
	pop	ix	; clear ix
	pop	iy	; clear iy
	ld	i,a	; clear i
	ld	r,a	; clear r
	pop	de	; clear de
	pop	hl	; clear hl
	pop	af	; clear af
	ex	af,af'	; swap af with af'
	exx		; swap bc/de/hl with their shadow registers too
	pop	bc	; clear bc
	pop	de	; clear de
	pop	hl	; clear hl
	pop	af	; clear af
	ld	sp,hl	; clear sp
	di		; clear iff1 (for interrupt handler)
	im	1	; interrupt handling mode = 1
	ld	(hl),0E9h ; replace the first instruction with a jump to itself
	jp	(hl)	  ; jump to the first instruction (to stay there forever)
zStartupCodeEndLoc:
    dephase ; stop pretending
	restore
    padding off ; unfortunately our flags got reset so we have to set them again...
Z80StartupCodeEnd:

	dc.w	$8104	; value for VDP display mode
	dc.w	$8F02	; value for VDP increment
	dc.l	vdpComm($0000,CRAM,WRITE)	; value for CRAM write mode
	dc.l	vdpComm($0000,VSRAM,WRITE)	; value for VSRAM write mode

PSGInitValues:
	dc.b	$9F,$BF,$DF,$FF	; values for PSG channel volumes
PSGInitValues_End:
; ===========================================================================

	even
; loc_300:
GameProgram:
	tst.w	(VDP_control_port).l
; loc_306:
CheckSumCheck:
    if gameRevision>0
	move.w	(VDP_control_port).l,d1
	btst	#1,d1
	bne.s	CheckSumCheck	; wait until DMA is completed
    endif
	; "MEGA DRIVE hard initial program" ends here.
	btst	#6,(HW_Expansion_Control).l
	beq.s	ChecksumTest
	tst.b	(Checksum_fourcc).w ; has checksum routine already run?
	bne.s	GameInit

; loc_328:
ChecksumTest:
    if skipChecksumCheck=0	; checksum code
	movea.l	#EndOfHeader,a0	; start checking bytes after the header ($200)
	movea.l	#ROMEndLoc,a1	; stop at end of ROM
	move.l	(a1),d0
	moveq	#0,d1
; loc_338:
ChecksumLoop:
	add.w	(a0)+,d1
	cmp.l	a0,d0
	bhs.s	ChecksumLoop
	movea.l	#Checksum,a1	; read the checksum
	cmp.w	(a1),d1		; compare correct checksum to the one in ROM
	bne.w	ChecksumError	; if they don't match, branch
    endif
;checksum_good:
	; Clear some RAM only on a coldboot.
	lea	(CrossResetRAM).w,a6
	moveq	#0,d7

	moveq	#bytesToLcnt(CrossResetRAM_End-CrossResetRAM),d6
-	move.l	d7,(a6)+
	dbf	d6,-

	move.b	(HW_Version).l,d0
	andi.b	#$C0,d0
	move.b	d0,(Graphics_Flags).w
	st.b	(Checksum_fourcc).w ; set flag so checksum won't be run again
; loc_370:
GameInit:
	; Clear some RAM on every boot and reset.
	lea	(RAM_Start&$FFFFFF).l,a6
	moveq	#0,d7
	move.w	#bytesToLcnt(CrossResetRAM-RAM_Start),d6
; loc_37C:
GameClrRAM:
	move.l	d7,(a6)+
	dbf	d6,GameClrRAM	; clear RAM ($0000-$FDFF)

	bsr.w	InitDMAQueue
	bsr.w	VDPSetupGame
	jsr	(SoundDriverLoad).l
	stopZ80
	moveq	#$40,d0
	move.b	d0,(HW_Port_1_Control).l	; init port 1 (joypad 1)
	move.b	d0,(HW_Port_2_Control).l	; init port 2 (joypad 2)
	move.b	d0,(HW_Expansion_Control).l	; init port 3 (expansion/extra)
	startZ80
	move.b	#GameModeID_SegaScreen,(Game_Mode).w ; set Game Mode to Sega Screen
; loc_394:
MainGameLoop:
	moveq	#0,d0
	move.b	(Game_Mode).w,d0	; load Game Mode
	movea.l	GameModesArray(pc,d0.w),a0
	jsr	(a0)	; jump to apt location in ROM
	bra.s	MainGameLoop		; loop indefinitely
; ===========================================================================
; loc_3A2:
GameModesArray: ;;
GameMode_SegaScreen:	dc.l	SegaScreen		; SEGA screen mode
GameMode_TitleScreen:	dc.l	TitleScreen		; Title screen mode
GameMode_Demo:		dc.l	Level			; Demo mode
GameMode_Level:		dc.l	Level			; Zone play mode
GameMode_OptionsMenu:	dc.l	MenuScreen		; Options mode
GameMode_LevelSelect:	dc.l	MenuScreen		; Level select mode
; ===========================================================================
    if skipChecksumCheck=0	; checksum error code
; loc_3CE:
ChecksumError:
	move.w	d1,-(sp)
	bsr.w	VDPSetupGame
	move.w	(sp)+,d1
	move.l	#vdpComm($0000,CRAM,WRITE),(VDP_control_port).l ; set VDP to CRAM write
	moveq	#16*4-1,d7 ; all colours of all palette lines
; loc_3E2:
Checksum_Red:
	move.w	#$00E,(VDP_data_port).l	; fill palette with red
	dbf	d7,Checksum_Red		; repeat $3F more times
; loc_3EE:
ChecksumFailed_Loop:
	bra.s	ChecksumFailed_Loop
    endif
; ===========================================================================

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; vertical and horizontal interrupt handlers
; VERTICAL INTERRUPT HANDLER:
V_Int:
	movem.l	d0-a6,-(sp)
	lea	(VDP_control_port).l,a5
	lea	VDP_data_port-VDP_control_port(a5),a6
	tst.b	(Vint_routine).w
	beq.s	Vint_Lag_Main

	; waits until vertical blanking is taking place
-	moveq	#8,d0
	and.w	(a5),d0
	beq.s	-

	move.l	#vdpComm($0000,VSRAM,WRITE),(a5)
	move.l	(Vscroll_Factor).w,(a6) ; send screen y-axis pos. to VSRAM
	btst	#6,(Graphics_Flags).w	; is Megadrive PAL?
	beq.s	+			; if not, branch

	move.w	#$700,d0
-	dbf	d0,- ; wait here in a loop doing nothing for a while...
+

	moveq	#0,d0
	move.b	(Vint_routine).w,d0
	move.b	#VintID_Lag,(Vint_routine).w
	st.b	(Hint_flag).w	; allows horizontal interrupt code to run
	move.w	Vint_SwitchTbl(pc,d0.w),d0
	jsr	Vint_SwitchTbl(pc,d0.w)

VintRet:
	addq.l	#1,(Vint_runcount).w
	movem.l	(sp)+,d0-a6
	rte
; ===========================================================================
Vint_SwitchTbl: offsetTable
Vint_Lag_ptr		offsetTableEntry.w Vint_Lag		;   0
Vint_SEGA_ptr:		offsetTableEntry.w Vint_SEGA		;   2
Vint_Title_ptr:		offsetTableEntry.w Vint_Title		;   4
Vint_Unused6_ptr:	offsetTableEntry.w Vint_Unused6		;   6
Vint_Level_ptr:		offsetTableEntry.w Vint_Level		;   8
Vint_TitleCard_ptr:	offsetTableEntry.w Vint_TitleCard	;  $C
Vint_UnusedE_ptr:	offsetTableEntry.w Vint_UnusedE		;  $E
Vint_Pause_ptr:		offsetTableEntry.w Vint_Pause		; $10
Vint_Fade_ptr:		offsetTableEntry.w Vint_Fade		; $12
Vint_PCM_ptr:		offsetTableEntry.w Vint_PCM		; $14
Vint_Menu_ptr:		offsetTableEntry.w Vint_Menu		; $16
; ===========================================================================
;VintSub0
Vint_Lag:
	addq.w	#4,sp	; do not return to caller (avoids VintRet running twice, saves 176 cycles)

Vint_Lag_Main:
	cmpi.b	#GameModeID_TitleCard|GameModeID_Demo,(Game_Mode).w	; pre-level Demo Mode?
	beq.s	.isInLevelMode
	cmpi.b	#GameModeID_TitleCard|GameModeID_Level,(Game_Mode).w	; pre-level Zone play mode?
	beq.s	.isInLevelMode
	cmpi.b	#GameModeID_Demo,(Game_Mode).w	; Demo Mode?
	beq.s	.isInLevelMode
	cmpi.b	#GameModeID_Level,(Game_Mode).w	; Zone play mode?
	beq.s	.isInLevelMode

	bra.s	VintRet
; ---------------------------------------------------------------------------

; loc_4C4:
.isInLevelMode:
	tst.b	(Water_flag).w
	beq.s	Vint0_noWater
	btst	#6,(Graphics_Flags).w ; is Megadrive PAL?
	beq.s	+		; if not, branch

	move.w	(a5),d0
	move.w	#$700,d0
-	dbf	d0,- ; wait here in a loop doing nothing for a while...
+

	st.b	(Hint_flag).w

	tst.b	(Water_fullscreen_flag).w
	bne.s	.useUnderwaterPalette

	dma68kToVDP Normal_palette,0,palette_line_size*4,CRAM

	bra.s	.afterSetPalette
; ---------------------------------------------------------------------------

; loc_526:
.useUnderwaterPalette:
	dma68kToVDP Underwater_palette,0,palette_line_size*4,CRAM

; loc_54A:
.afterSetPalette:
	move.w	(Hint_counter_reserve).w,(a5)

	bra.w	VintRet
; ---------------------------------------------------------------------------

Vint0_noWater:
	btst	#6,(Graphics_Flags).w	; is Megadrive PAL?
	beq.s	+			; if not, branch

	move.w	(a5),d0
	move.w	#$700,d0
-	dbf	d0,- ; wait here in a loop doing nothing for a while...
+

	st.b	(Hint_flag).w
	move.w	(Hint_counter_reserve).w,(a5)

	bra.w	VintRet
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; This subroutine copies the H scroll table buffer (in main RAM) to the H scroll
; table (in VRAM).
;VintSub2
Vint_SEGA:
	bsr.w	Do_ControllerPal

	dma68kToVDP Horiz_Scroll_Buf,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM
	jsr	(SegaScr_VInt).l
	tst.w	(Demo_Time_left).w	; is there time left on the demo?
	beq.s	+			; if not, return
	subq.w	#1,(Demo_Time_left).w	; subtract 1 from time left in demo
+
	bra.w	Set_KosPlus_Bookmark
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;VintSub14
Vint_PCM:
	; makes it so the joypads are only read once every 16 frames
	moveq	#$F,d0
	and.b	(Vint_runcount+3).w,d0
	bne.s	+

	bsr.w	ReadJoypads

+
	tst.w	(Demo_Time_left).w	; is there time left on the demo?
	beq.s	+			; if not, return
	subq.w	#1,(Demo_Time_left).w	; subtract 1 from time left in demo
+
	rts
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;VintSub4
Vint_Title:
	bsr.w	Do_ControllerPal
	tst.w	(Demo_Time_left).w	; is there time left on the demo?
	beq.s	+			; if not, return
	subq.w	#1,(Demo_Time_left).w	; subtract 1 from time left in demo
+
	bra.w	Set_KosPlus_Bookmark
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;VintSub6
Vint_Unused6:
	bra.w	Do_ControllerPal
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;VintSub10
Vint_Pause:
;VintSub8
Vint_Level:
	bsr.w	ReadJoypads
	tst.b	(Water_fullscreen_flag).w
	bne.s	.useUnderwaterPalette
	dma68kToVDP Normal_palette,0,palette_line_size*4,CRAM
	bra.s	.afterPaletteSetup
; ---------------------------------------------------------------------------

; loc_724:
.useUnderwaterPalette:
	dma68kToVDP Underwater_palette,0,palette_line_size*4,CRAM

; loc_748:
.afterPaletteSetup:
	move.w	(Hint_counter_reserve).w,(a5)

	dma68kToVDP Horiz_Scroll_Buf,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM
	dma68kToVDP Sprite_Table,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
+

	bsr.w	ProcessDMAQueue


	movem.l	(Camera_RAM).w,d0-d7
	movem.l	d0-d7,(Camera_RAM_copy).w
	movem.l	(Scroll_flags).w,d0-d3
	movem.l	d0-d3,(Scroll_flags_copy).w
	cmpi.b	#$5C,(Hint_counter_reserve+1).w
	bhs.s	Do_Updates
	move.b	#1,(Do_Updates_in_H_int).w
	bra.w	Set_KosPlus_Bookmark

; ---------------------------------------------------------------------------
; Subroutine to run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_7E6: Demo_Time:
Do_Updates:
	jsr	(LoadTilesAsYouMove).l
	jsr	(HudUpdate).l
	tst.w	(Demo_Time_left).w	; is there time left on the demo?
	beq.s	+			; if not, branch
	subq.w	#1,(Demo_Time_left).w	; subtract 1 from time left in demo
+
	bra.w	Set_KosPlus_Bookmark
; End of function Do_Updates

; ===========================================================================
;VintSubC
Vint_TitleCard:
	bsr.w	ReadJoypads
	tst.b	(Water_fullscreen_flag).w
	bne.s	loc_BB2

	dma68kToVDP Normal_palette,0,palette_line_size*4,CRAM
	bra.s	loc_BD6
; ---------------------------------------------------------------------------

loc_BB2:
	dma68kToVDP Underwater_palette,0,palette_line_size*4,CRAM

loc_BD6:
	move.w	(Hint_counter_reserve).w,(a5)

	dma68kToVDP Horiz_Scroll_Buf,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM
	dma68kToVDP Sprite_Table,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
+
	bsr.w	ProcessDMAQueue
	jsr	(DrawLevelTitleCard).l

	movem.l	(Camera_RAM).w,d0-d7
	movem.l	d0-d7,(Camera_RAM_copy).w
	movem.l	(Scroll_flags).w,d0-d1
	movem.l	d0-d1,(Scroll_flags_copy).w
	bra.w	Set_KosPlus_Bookmark
; ===========================================================================
;VintSubE
Vint_UnusedE:
	bsr.w	Do_ControllerPal
	addq.b	#1,(VIntSubE_RunCount).w
	move.b	#VintID_UnusedE,(Vint_routine).w
	rts
; ===========================================================================
;VintSub12
Vint_Fade:
	bsr.w	Do_ControllerPal
	move.w	(Hint_counter_reserve).w,(a5)
	bra.w	Set_KosPlus_Bookmark
; ===========================================================================
;VintSub16
Vint_Menu:
	bsr.w	ReadJoypads

	dma68kToVDP Normal_palette,0,palette_line_size*4,CRAM
	dma68kToVDP Sprite_Table,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
	dma68kToVDP Horiz_Scroll_Buf,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM

	bsr.w	ProcessDMAQueue

	tst.w	(Demo_Time_left).w
	beq.s	+	; rts
	subq.w	#1,(Demo_Time_left).w
+
	bra.w	Set_KosPlus_Bookmark

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

;sub_E98
Do_ControllerPal:
	bsr.w	ReadJoypads
	tst.b	(Water_fullscreen_flag).w
	bne.s	loc_EDA

	dma68kToVDP Normal_palette,$0000,palette_line_size*4,CRAM
	bra.s	loc_EFE
; ---------------------------------------------------------------------------

loc_EDA:
	dma68kToVDP Underwater_palette,$0000,palette_line_size*4,CRAM

loc_EFE:
	dma68kToVDP Sprite_Table,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
	dma68kToVDP Horiz_Scroll_Buf,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM

	bra.w	ProcessDMAQueue
; End of function sub_E98
; ||||||||||||||| E N D   O F   V - I N T |||||||||||||||||||||||||||||||||||

; ===========================================================================
; Start of H-INT code
H_Int:
	move	#$2700,sr
	tst.b	(Hint_flag).w
	beq.s	H_Int_Done
	clr.b	(Hint_flag).w
	movem.l	a0-a1,-(sp)
	lea	(VDP_data_port).l,a1
	lea	(Underwater_palette).w,a0 ; load palette from RAM
	move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_data_port(a1)	; set VDP to write to CRAM address $00
    rept 32
	move.l	(a0)+,(a1)	; move palette to CRAM (all 64 colors at once)
    endm
	move.w	#$8A00|223,VDP_control_port-VDP_data_port(a1)	; Write %1101 %1111 to register 10 (interrupt every 224th line)
	movem.l	(sp)+,a0-a1
	tst.b	(Do_Updates_in_H_int).w
	bne.s	loc_1072

H_Int_Done:
	rte
; ===========================================================================

loc_1072:
	clr.b	(Do_Updates_in_H_int).w
	movem.l	d0-a6,-(sp)
	bsr.w	Do_Updates
	movem.l	(sp)+,d0-a6
	rte

; ---------------------------------------------------------------------------
; Subroutine to read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_111C:
ReadJoypads:
	lea	(Ctrl_1).w,a0	; address where joypad states are written
	lea	(HW_Port_1_Data).l,a1	; first joypad port
	bsr.s	Joypad_Read		; do the first joypad
	addq.w	#2,a1			; do the second joypad

; sub_112A:
Joypad_Read:
	move.w	#$100,(Z80_Bus_Request).l ; stop the Z80
	move.b	#0,(a1)	; Poll controller data port
	or.l	d0,d0
	move.b	(a1),d0	; Get controller port data (start/A)
	lsl.b	#2,d0
	andi.b	#$C0,d0
	move.b	#$40,(a1)	; Poll controller data port again
	or.l	d0,d0
	move.b	(a1),d1	; Get controller port data (B/C/Dpad)
	startZ80
	andi.b	#$3F,d1
	or.b	d1,d0	; Fuse them into one controller bit array
	not.b	d0
	move.b	(a0),d1	; Get button press data
	eor.b	d0,d1	; Toggle off held buttons
	move.b	d0,(a0)+	; Store raw controller input for held button data
	and.b	d0,d1
	move.b	d1,(a0)+	; Store pressed controller input
	rts
; End of function Joypad_Read


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_1158:
VDPSetupGame:
	lea	(VDP_control_port).l,a0
	lea	VDP_data_port-VDP_control_port(a0),a1
	lea	VDPSetupArray(pc),a2
	moveq	#bytesToWcnt(VDPSetupArray_End-VDPSetupArray),d7
; loc_116C:
VDP_Loop:
	move.w	(a2)+,(a0)
	dbf	d7,VDP_Loop	; set the VDP registers

	move.w	VDPSetupArray+2(pc),(VDP_Reg1_val).w	; get command for register #1 and store it in RAM (for easy display blanking/enabling)
	move.w	#$8A00+223,(Hint_counter_reserve).w	; H-INT every 224th scanline
	moveq	#0,d0

	move.l	#vdpComm(0,VSRAM,WRITE),(a0)
	move.l	d0,(a1)

	move.l	#vdpComm(0,CRAM,WRITE),(a0)

	moveq	#bytesToLcnt(palette_line_size*4),d7
; loc_11A0:
VDP_ClrCRAM:
	move.l	d0,(a1)
	dbf	d7,VDP_ClrCRAM	; clear the CRAM

	moveq	#0,d0
	move.l	d0,(Vscroll_Factor).w
	move.w	d1,-(sp)

	dmaFillVRAM 0,0,$10000	; fill entire VRAM with 0

	move.w	(sp)+,d1
	rts
; End of function VDPSetupGame

; ===========================================================================
; word_11E2:
VDPSetupArray:
	dc.w $8004		; H-INT disabled
	dc.w $8134		; Genesis mode, DMA enabled, VBLANK-INT enabled
	dc.w $8200|(VRAM_Plane_A_Name_Table/$400)	; PNT A base: $C000
	dc.w $8328		; PNT W base: $A000
	dc.w $8400|(VRAM_Plane_B_Name_Table/$2000)	; PNT B base: $E000
	dc.w $8500|(VRAM_Sprite_Attribute_Table/$200)	; Sprite attribute table base: $F800
	dc.w $8600
	dc.w $8700		; Background palette/color: 0/0
	dc.w $8800
	dc.w $8900
	dc.w $8A00		; H-INT every scanline
	dc.w $8B00		; EXT-INT off, V scroll by screen, H scroll by screen
	dc.w $8C81		; H res 40 cells, no interlace, S/H disabled
	dc.w $8D00|(VRAM_Horiz_Scroll_Table/$400)	; H scroll table base: $FC00
	dc.w $8E00
	dc.w $8F02		; VRAM pointer increment: $0002
	dc.w $9001		; Scroll table size: 64x32
	dc.w $9100		; Disable window
	dc.w $9200		; Disable window
VDPSetupArray_End:

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_1208:
ClearScreen:
	dmaFillVRAM 0,0,tiles_to_bytes(2)				; Fill first $40 bytes of VRAM with 0
	dmaFillVRAM 0,VRAM_Plane_A_Name_Table,VRAM_Plane_Table_Size	; Clear Plane A pattern name table
	dmaFillVRAM 0,VRAM_Plane_B_Name_Table,VRAM_Plane_Table_Size	; Clear Plane B pattern name table

	moveq	#0,d0
	move.l	d0,(Vscroll_Factor).w

	lea	(Sprite_Table).w,a0
	moveq	#1,d1
	moveq	#80-1,d7

.loop:
	move.w	d0,(a0)
	move.b	d1,3(a0)
	addq.w	#1,d1
	addq.w	#8,a0
	dbf	d7,.loop
	move.b	d0,-5(a0)

	clearRAM Horiz_Scroll_Buf,Horiz_Scroll_Buf+HorizontalScrollBuffer.len

	rts
; End of function ClearScreen

; ===========================================================================

; loc_F626:
PlayLevelMusic:
	move.w	(Level_Music).w,d0
	; fall into PlayMusic

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Despite the name, this can actually be used for playing sounds.
; The original source code called this 'bgmset'.
; sub_135E:
PlayMusic:
	stopZ80
	move.b	d0,(Z80_RAM+zAbsVar.Queue1).l
	startZ80
	rts
; End of function PlayMusic


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Play a sound if the source is on-screen.
; sub_137C:
PlaySoundLocal:
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.s	PlaySoundExit

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Despite the name, this can actually be used for playing music.
; The original source code called this 'sfxset'.
; sub_1370
PlaySound:
PlaySound2:
	stopZ80
	move.b	d0,(Z80_RAM+zAbsVar.Queue2).l
	startZ80

PlaySoundExit:
	rts
; End of function PlaySound
; End of function PlaySoundLocal

; ---------------------------------------------------------------------------
; Subroutine to pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_1388:
PauseGame:
	tst.b	(Life_count).w	; do you have any lives left?
	beq.w	Unpause		; if not, branch
	tst.b	(Time_Over_flag).w
	bne.w	Unpause
	tst.b	(Game_paused).w	; is game already paused?
	bne.s	+		; if yes, branch
	move.b	(Ctrl_1_Press).w,d0 ; is Start button pressed?
	andi.b	#button_start_mask,d0
	beq.s	PlaySoundExit	; if not, branch
+
	st.b	(Game_paused).w	; freeze time
	stopZ80
	move.b	#MusID_Pause,(Z80_RAM+zAbsVar.StopMusic).l	; pause music
	startZ80
; loc_13B2:
Pause_Loop:
	move.b	#VintID_Pause,(Vint_routine).w
	bsr.w	WaitForVint
	tst.b	(Slow_motion_flag).w	; is slow-motion cheat on?
	beq.s	Pause_ChkStart		; if not, branch
	btst	#button_A,(Ctrl_1_Press).w	; is button A pressed?
	beq.s	Pause_ChkBC		; if not, branch
	move.b	#GameModeID_TitleScreen,(Game_Mode).w ; set game mode to 4 (title screen)
	bra.s	Pause_Resume
; ===========================================================================
; loc_13D4:
Pause_ChkBC:
	btst	#button_B,(Ctrl_1_Held).w ; is button B pressed?
	bne.s	Pause_SlowMo		; if yes, branch
	btst	#button_C,(Ctrl_1_Press).w ; is button C pressed?
	bne.s	Pause_SlowMo		; if yes, branch
; loc_13E4:
Pause_ChkStart:
	move.b	(Ctrl_1_Press).w,d0	; is Start button pressed?
	andi.b	#button_start_mask,d0
	beq.s	Pause_Loop	; if not, branch
; loc_13F2:
Pause_Resume:
	stopZ80
	move.b	#MusID_Unpause,(Z80_RAM+zAbsVar.StopMusic).l	; unpause the music
	startZ80
; loc_13F8:
Unpause:
	clr.b	(Game_paused).w	; unpause the game
; return_13FE:
Pause_DoNothing:
	rts
; ===========================================================================
; loc_1400:
Pause_SlowMo:
	st.b	(Game_paused).w
	stopZ80
	move.b	#MusID_Unpause,(Z80_RAM+zAbsVar.StopMusic).l
	startZ80
	rts
; End of function PauseGame

; ---------------------------------------------------------------------------
; Subroutine to transfer a plane map to VRAM
; ---------------------------------------------------------------------------

; control register:
;    CD1 CD0 A13 A12 A11 A10 A09 A08     (D31-D24)
;    A07 A06 A05 A04 A03 A02 A01 A00     (D23-D16)
;     ?   ?   ?   ?   ?   ?   ?   ?      (D15-D8)
;    CD5 CD4 CD3 CD2  ?   ?  A15 A14     (D7-D0)
;
;	A00-A15 - address
;	CD0-CD3 - code
;	CD4 - 1 if VRAM copy DMA mode. 0 otherwise.
;	CD5 - DMA operation
;
;	Bits CD3-CD0:
;	0000 - VRAM read
;	0001 - VRAM write
;	0011 - CRAM write
;	0100 - VSRAM read
;	0101 - VSRAM write
;	1000 - CRAM read
;
; d0 = control register
; d1 = width
; d2 = heigth
; a1 = source address

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_140E: ShowVDPGraphics: PlaneMapToVRAM:
PlaneMapToVRAM_H40:
	lea	(VDP_data_port).l,a6
	move.l	#vdpCommDelta(planeLoc(64,0,1)),d4	; $800000

-	move.l	d0,VDP_control_port-VDP_data_port(a6)	; move d0 to VDP_control_port
	move.w	d1,d3

-	move.w	(a1)+,(a6)	; from source address to destination in VDP
	dbf	d3,-		; next tile

	add.l	d4,d0		; increase destination address by $80 (1 line)
	dbf	d2,--		; next line

	rts
; End of function PlaneMapToVRAM_H40

; ---------------------------------------------------------------------------
; Alternate subroutine to transfer a plane map to VRAM
; (used for Special Stage background)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_142E: ShowVDPGraphics2: PlaneMapToVRAM2:
PlaneMapToVRAM_H80_SpecialStage:
	lea	(VDP_data_port).l,a6
	move.l	#vdpCommDelta(planeLoc(128,0,1)),d4	; $1000000
-	move.l	d0,VDP_control_port-VDP_data_port(a6)
	move.w	d1,d3
-	move.w	(a1)+,(a6)
	dbf	d3,-
	add.l	d4,d0
	dbf	d2,--
	rts
; End of function PlaneMapToVRAM_H80_SpecialStage

	include "_inc/DMA Queue.asm"
	include "_inc/PLC Processing.asm"
	include "_inc/Enigma Decompressor.asm"
	include "_inc/KosinskiPlus.asm"
	include "_inc/KosinskiPlusM.asm"
	include "_inc/Palette Cycle.asm"
	include "_inc/Palette Fade and Load.asm"
	include "_inc/Palette Pointers.asm"

; ---------------------------------------------------------------------------
; Subroutine to perform vertical synchronization
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_3384: DelayProgram:
WaitForVint:
	move	#$2300,sr

-	tst.b	(Vint_routine).w
	bne.s	-
	rts
; End of function WaitForVint

	include "_incObj/sub RandomNumber.asm"
	include "_incObj/sub CalcSine.asm"
	include "_incObj/sub CalcAngle.asm"

; loc_37B8:
SegaScreen:
	move.b	#MusID_Stop,d0
	bsr.w	PlayMusic ; stop music
	bsr.w	ClearPLC
	ResetDMAQueue
	bsr.w	Pal_FadeToBlack

	clearRAM Misc_Variables,Misc_Variables_End

	clearRAM Object_RAM,Object_RAM_End ; fill object RAM with 0

	lea	(VDP_control_port).l,a6
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8200|(VRAM_SegaScr_Plane_A_Name_Table/$400),(a6)	; PNT A base: $C000
	move.w	#$8400|(VRAM_SegaScr_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $A000
	move.w	#$8700,(a6)		; Background palette/color: 0/0
	move.w	#$8B03,(a6)		; EXT-INT disabled, V scroll by screen, H scroll by line
	move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
	move.w	#$9003,(a6)		; Scroll table size: 128x32 ($2000 bytes)
	clr.b	(Water_fullscreen_flag).w
	move	#$2700,sr
	move.w	(VDP_Reg1_val).w,d0
	andi.b	#$BF,d0
	move.w	d0,(VDP_control_port).l
	bsr.w	ClearScreen

	dmaFillVRAM 0,VRAM_SegaScr_Plane_A_Name_Table,VRAM_SegaScr_Plane_Table_Size ; clear Plane A pattern name table

	lea	(ArtNem_SEGA).l,a1
	moveq	#tiles_to_bytes(ArtTile_ArtNem_Sega_Logo),d2
	bsr.w	Queue_KosPlus_Module

	lea	(ArtNem_IntroTrails).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_Trails),d2
	bsr.w	Queue_KosPlus_Module

	lea	(Chunk_Table).l,a1
	lea	(MapEng_SEGA).l,a0
	moveq	#make_art_tile(ArtTile_VRAM_Start,0,0),d0
	bsr.w	EniDec

	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_SegaScr_Plane_B_Name_Table,VRAM,WRITE),d0
	moveq	#40-1,d1	; 40 cells wide
	moveq	#28-1,d2	; 28 cells tall
	bsr.w	PlaneMapToVRAM_H80_SpecialStage

	tst.b	(Graphics_Flags).w ; are we on a Japanese Mega Drive?
	bmi.s	SegaScreen_Contin ; if not, branch

	; load an extra sprite to hide the TM (trademark) symbol on the SEGA screen
	lea	(SegaHideTM).w,a1
	move.b	#ObjID_SegaHideTM,id(a1)	; load objB1 at $FFFFB080
	move.b	#$4E,subtype(a1) ; <== ObjB1_SubObjData
; loc_38CE:
SegaScreen_Contin:
	moveq	#PalID_SEGA,d0
	bsr.w	PalLoad_Now
	move.w	#-$A,(PalCycle_Frame).w
	moveq	#0,d0
	move.w	d0,(PalCycle_Timer).w
	move.w	d0,(SegaScr_VInt_Subrout).w
	move.w	d0,(SegaScr_PalDone_Flag).w
	lea	(SegaScreenObject).w,a1
	move.b	#ObjID_SonicOnSegaScr,id(a1) ; load objB0 (sega screen?) at $FFFFB040
	move.b	#$4C,subtype(a1) ; <== ObjB0_SubObjData
	move.w	#4*60,(Demo_Time_left).w	; 4 seconds
	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l
; loc_390E:
Sega_WaitPalette:
	move.b	#VintID_SEGA,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	jsr	(RunObjects).l
	jsr	(BuildSprites).l
	bsr.w	Process_KosPlus_Module_Queue
	tst.b	(SegaScr_PalDone_Flag).w
	beq.s	Sega_WaitPalette
	move.b	#VintID_SEGA,(Vint_routine).w
	bsr.w	WaitForVint
	move.w	#3*60,(Demo_Time_left).w	; 3 seconds
; loc_3940:
Sega_WaitEnd:
	move.b	#VintID_PCM,(Vint_routine).w
	bsr.w	WaitForVint
	tst.w	(Demo_Time_left).w
	beq.s	Sega_GotoTitle
	move.b	(Ctrl_1_Press).w,d0	; is Start button pressed?
	andi.b	#button_start_mask,d0
	beq.s	Sega_WaitEnd		; if not, branch
; loc_395E:
Sega_GotoTitle:
	moveq	#0,d0
	move.w	d0,(SegaScr_PalDone_Flag).w
	move.w	d0,(SegaScr_VInt_Subrout).w
	move.b	#GameModeID_TitleScreen,(Game_Mode).w	; => TitleScreen
	rts
; ===========================================================================
; loc_3998:
TitleScreen:
	; Stop music.
	move.b	#MusID_Stop,d0
	bsr.w	PlayMusic

	; Clear the PLC queue, preventing any PLCs from before loading after this point.
	bsr.w	ClearPLC
	ResetDMAQueue

	; Fade out.
	bsr.w	Pal_FadeToBlack

	; Disable interrupts, so that we can have exclusive access to the VDP.
	move	#$2700,sr

	; Configure the VDP for this screen mode.
	lea	(VDP_control_port).l,a6
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8200|(VRAM_TtlScr_Plane_A_Name_Table/$400),(a6)	; PNT A base: $C000
	move.w	#$8400|(VRAM_TtlScr_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $E000
	move.w	#$9001,(a6)		; Scroll table size: 64x32
	move.w	#$9200,(a6)		; Disable window
	move.w	#$8B03,(a6)		; EXT-INT disabled, V scroll by screen, H scroll by line
	move.w	#$8720,(a6)		; Background palette/color: 2/0

	clr.b	(Water_fullscreen_flag).w

	move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled

	; Reset plane maps, sprite table, and scroll tables.
	bsr.w	ClearScreen

	; Reset a bunch of engine state.
	clearRAM Object_Display_Lists,Object_Display_Lists_End ; fill $AC00-$AFFF with $0
	clearRAM Object_RAM,Object_RAM_End ; fill object RAM ($B000-$D5FF) with $0
	clearRAM Misc_Variables,Misc_Variables_End ; clear CPU player RAM and following variables
	clearRAM Camera_RAM,Camera_RAM_End ; clear camera RAM and following variables

	; Load the credit font for the following text.
	lea	(ArtNem_CreditText).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_CreditText),d2
	bsr.w	Queue_KosPlus_Module

	; Load the 'Sonic and Miles 'Tails' Prower in' text.
	lea	off_B2B0(pc),a1
	bsr.w	loc_B272

	; Fade-in, showing the text that was just loaded.
	clearRAM Target_palette,Target_palette_End	; fill palette with 0 (black)
	moveq	#PalID_BGND,d0
	bsr.w	PalLoad_ForFade
	bsr.w	Pal_FadeFromBlack

	; 'Pal_FadeFromBlack' enabled the interrupts, so disable them again
	; so that we have exclusive access to the VDP for the following calls
	; to the Nemesis decompressor.
	move	#$2700,sr

	; Load assets while the above text is being displayed.
	lea	(ArtNem_Title).l,a1
	moveq	#tiles_to_bytes(ArtTile_ArtNem_Title),d2
	bsr.w	Queue_KosPlus_Module

	lea	(ArtNem_TitleSprites).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_TitleSprites),d2
	bsr.w	Queue_KosPlus_Module

	lea	(ArtNem_MenuJunk).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_MenuJunk),d2
	bsr.w	Queue_KosPlus_Module

	lea	(ArtNem_FontStuff).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_FontStuff_TtlScr),d2
	bsr.w	Queue_KosPlus_Module

.loop:
	move.b	#VintID_Title,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	tst.w	(KosPlus_modules_left).w
	bne.s	.loop

	; Clear some variables.
	moveq	#0,d0
	move.b	d0,(Last_star_pole_hit).w
	move.w	d0,(Debug_placement_mode).w
	move.w	d0,(Demo_mode_flag).w
	move.w	d0,(PalCycle_Timer).w
	move.b	d0,(Level_started_flag).w
	move.b	d0,(Debug_mode_flag).w

	; And finally fade out.
	bsr.w	Pal_FadeToBlack

	; 'Pal_FadeToBlack' enabled the interrupts, so disable them again
	; so that we have exclusive access to the VDP for the following calls
	; to the plane map loader.
	move	#$2700,sr

	; Decompress the first part of the title screen background plane map...
	lea	(Chunk_Table).l,a1
	lea	(MapEng_TitleScreen).l,a0
	move.w	#make_art_tile(ArtTile_ArtNem_Title,2,0),d0
	bsr.w	EniDec

	; ...and send it to VRAM.
	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_TtlScr_Plane_B_Name_Table,VRAM,WRITE),d0
	moveq	#40-1,d1 ; Width
	moveq	#28-1,d2 ; Height
	bsr.w	PlaneMapToVRAM_H40

	; Decompress the second part of the title screen background plane map...
	lea	(Chunk_Table).l,a1
	lea	(MapEng_TitleBack).l,a0
	move.w	#make_art_tile(ArtTile_ArtNem_Title,2,0),d0
	bsr.w	EniDec

	; ...and send it to VRAM.
	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_TtlScr_Plane_B_Name_Table+planeLoc(64,40,0),VRAM,WRITE),d0
	moveq	#24-1,d1 ; Width
	moveq	#28-1,d2 ; Height
	bsr.w	PlaneMapToVRAM_H40

	; Decompress the title screen emblem plane map...
	lea	(Chunk_Table).l,a1
	lea	(MapEng_TitleLogo).l,a0
	move.w	#make_art_tile(ArtTile_ArtNem_Title,3,1),d0
	bsr.w	EniDec

	; ...add the copyright text to it...
	lea	(Chunk_Table+planeLoc(40,28,26)).l,a1
	lea	CopyrightText(pc),a2
	moveq	#bytesToWcnt(CopyrightText_End-CopyrightText),d6
-	move.w	(a2)+,(a1)+
	dbf	d6,-

	; ...and send it to VRAM.
	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_TtlScr_Plane_A_Name_Table,VRAM,WRITE),d0
	moveq	#40-1,d1 ; Width
	moveq	#28-1,d2 ; Height
	bsr.w	PlaneMapToVRAM_H40

	; Clear the palette.
	clearRAM Normal_palette,Target_palette_End

	; Load the title screen palette, so we can fade into it later.
	moveq	#PalID_Title,d0
	bsr.w	PalLoad_ForFade

	; Set the time that the title screen lasts (little over ten seconds).
	move.w	#60*10+40,(Demo_Time_left).w

	; Clear the player's inputs, to prevent a leftover input from
	; skipping the intro.
	clr.w	(Ctrl_1).w

	; Load the object responsible for the intro animation.
	move.b	#ObjID_TitleIntro,(IntroSonic+id).w
	move.b	#2,(IntroSonic+subtype).w

	; Run it for a frame, so that it initialises.
	move.b	#VintID_Title,(Vint_routine).w
	bsr.w	WaitForVint
	jsr	(RunObjects).l
	jsr	(BuildSprites).l

	; Load some standard sprites.
	moveq	#PLCID_Std1,d0
	bsr.w	LoadPLC2

	; Reset the cheat input state.
	moveq	#0,d0
	move.w	d0,(Correct_cheat_entries).w
	move.w	d0,(Correct_cheat_entries_2).w

    if debugbuild
	; Sonic 2 Beta 4 reveals that these were the original instructions.
	; The original source code may have been able to produce debug builds with this enabled.
	move.w	#$101,(Level_select_flag).w
	move.w	#$101,(Debug_mode_flag).w
    endif

	; Reset Sonic's position record buffer.
	move.w	#4,(Sonic_Pos_Record_Index).w
	move.w	d0,(Sonic_Pos_Record_Buf).w

	; Initialise the camera's X position.
	move.w	#-$280,(Camera_X_pos).w

	; Enable the VDP's display.
	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l

	; Fade into the palette that was loaded earlier.
	bsr.w	Pal_FadeFromBlack

; loc_3C14:
TitleScreen_Loop:
	move.b	#VintID_Title,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint

	jsr	(RunObjects).l
	jsr	(SwScrl_Title).l
	jsr	(BuildSprites).l

	; Find the masking sprite, and move it to the proper location. The
	; sprite is normally at X 128+128, but in order to perform masking,
	; it must be at X 0.
	; The masking sprite is used to stop Sonic and Tails from overlapping
	; the emblem.
	; You might be wondering why it alternates between 0 and 4 for the X
	; position. That's because masking sprites only work if another
	; sprite rendered before them (or if the previous scanline reached
	; its pixel limit). Because of this, a sprite is placed at X 4 before
	; a second one is placed at X 0.
	lea	(Sprite_Table+4).w,a1
	moveq	#0,d0

	moveq	#(Sprite_Table_End-Sprite_Table)/8-1,d6
-	tst.w	(a1)	; The masking sprite has its art-tile set to $0000.
	bne.s	+
	eor.w	#%100,d0	; Alternate between X positions of 0 and 4.
	move.w	d0,2(a1)
+	addq.w	#8,a1
	dbf	d6,-

	bsr.w	Process_KosPlus_Module_Queue

	bsr.w	TailsNameCheat

	; If the timer has run out, go play a demo.
	tst.w	(Demo_Time_left).w
	beq.w	TitleScreen_Demo

	; If the intro is still playing, then don't let the start button
	; begin the game.
	tst.b	(IntroSonic+obj0e_intro_complete).w
	beq.s	TitleScreen_Loop

	; If the start button has not been pressed, then loop back and keep
	; running the title screen.
	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_start_mask,d0
	beq.s	TitleScreen_Loop ; loop until Start is pressed

	; At this point, the start button has been pressed and it's time to
	; enter one player mode, two player mode, or the options menu.

	move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)

	move.b	#3,(Life_count).w

	moveq	#0,d0
	move.w	d0,(Ring_count).w
	move.l	d0,(Timer).w
	move.l	d0,(Score).w

	move.l	#5000,(Next_Extra_life_score).w

	move.b	#MusID_FadeOut,d0 ; prepare to stop music (fade out)
	bsr.w	PlayMusic

	moveq	#0,d0
	move.b	(Title_screen_option).w,d0
	bne.s	TitleScreen_ChoseOptions	; branch if not a 1-player game

	moveq	#0,d0
    if emerald_hill_zone_act_1=0
	move.w	d0,(Current_ZoneAndAct).w ; emerald_hill_zone_act_1
    else
	move.w	#emerald_hill_zone_act_1,(Current_ZoneAndAct).w
    endif
	tst.b	(Level_select_flag).w	; has level select cheat been entered?
	beq.s	+			; if not, branch
	btst	#button_A,(Ctrl_1_Held).w ; is A held down?
	beq.s	+	 		; if not, branch
	move.b	#GameModeID_LevelSelect,(Game_Mode).w ; => LevelSelectMenu
	rts
; ---------------------------------------------------------------------------
+
	move.w	d0,(Current_Special_StageAndAct).w
	move.w	d0,(Got_Emerald).w
	move.l	d0,(Got_Emeralds_array).w
	move.l	d0,(Got_Emeralds_array+4).w
	rts
; ---------------------------------------------------------------------------
; loc_3D20:
TitleScreen_ChoseOptions:
	move.b	#GameModeID_OptionsMenu,(Game_Mode).w ; => OptionsMenu
	clr.b	(Options_menu_box).w
	rts
; ===========================================================================
; loc_3D2E:
TitleScreen_Demo:
	move.b	#MusID_FadeOut,d0
	bsr.w	PlayMusic

	moveq	#7,d0
	and.w	(Demo_number).w,d0
	add.w	d0,d0
	move.w	DemoLevels(pc,d0.w),d0
	move.w	d0,(Current_ZoneAndAct).w

	addq.w	#1,(Demo_number).w
	cmpi.w	#(DemoLevels_End-DemoLevels)/2,(Demo_number).w
	blo.s	+
	move.w	#0,(Demo_number).w
+
	move.w	#1,(Demo_mode_flag).w
	move.b	#GameModeID_Demo,(Game_Mode).w ; => Level (Demo mode)
	move.b	#3,(Life_count).w

	moveq	#0,d0
	move.w	d0,(Ring_count).w
	move.l	d0,(Timer).w
	move.l	d0,(Score).w

	move.l	#5000,(Next_Extra_life_score).w

	rts
; ===========================================================================
; word_3DAC:
DemoLevels:
	dc.w	emerald_hill_zone_act_1		; EHZ
	dc.w	chemical_plant_zone_act_1	; CPZ
	dc.w	aquatic_ruin_zone_act_1		; ARZ
	dc.w	casino_night_zone_act_1		; CNZ
DemoLevels_End:

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_3DB4:
TailsNameCheat:
	lea	TailsNameCheat_Buttons(pc),a0
	move.w	(Correct_cheat_entries).w,d0
	adda.w	d0,a0
	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_up_mask|button_down_mask|button_left_mask|button_right_mask,d0
	beq.s	++	; rts
	cmp.b	(a0),d0
	bne.s	+
	addq.w	#1,(Correct_cheat_entries).w
	tst.b	1(a0)		; read the next entry
	bne.s	++		; if it's not zero, return

	; Switch the detected console's region between Japanese and
	; international. This affects the presence of trademark symbols, and
	; causes Tails' name to swap between 'Tails' and 'Miles'.
	bchg	#7,(Graphics_Flags).w

	moveq	#SndID_Ring,d0 ; play the ring sound for a successfully entered cheat
	bsr.w	PlaySound
+
	move.w	#0,(Correct_cheat_entries).w
+
	rts
; End of function TailsNameCheat

; ===========================================================================
; byte_3DEE:
TailsNameCheat_Buttons:
	dc.b	button_up_mask
	dc.b	button_down_mask
	dc.b	button_down_mask
	dc.b	button_down_mask
	dc.b	button_up_mask
	dc.b	0	; end
	even

	charset '0','9',0 ; Add character set for numbers
	charset '*',$A ; Add character for star
	charset '@',$B ; Add character for copyright symbol
	charset ':',$C ; Add character for colon
	charset '.',$D ; Add character for period
	charset 'A','Z',$E ; Add character set for letters

; word_3E82:
CopyrightText:
  irpc chr,"@ 1992 SEGA"
    if "chr"<>" "
	dc.w  make_art_tile(ArtTile_ArtNem_FontStuff_TtlScr + 'chr'|0,0,0)
    else
	dc.w  make_art_tile(ArtTile_VRAM_Start,0,0)
    endif
  endm
CopyrightText_End:

    charset ; Revert character set

	include "_inc/Music List.asm"

; ---------------------------------------------------------------------------
; Level
; DEMO AND ZONE LOOP (MLS values $08, $0C; bit 7 set indicates that load routine is running)
; ---------------------------------------------------------------------------
; loc_3EC4:
Level:
	bset	#GameModeFlag_TitleCard,(Game_Mode).w ; add $80 to screen mode (for pre level sequence)
	move.b	#MusID_FadeOut,d0
	bsr.w	PlayMusic	; fade out music
	bsr.w	ClearPLC
	bsr.w	Pal_FadeToBlack
	move	#$2700,sr
	bsr.w	ClearScreen
	jsr	(LoadTitleCard).l ; load title card patterns
	move	#$2300,sr
	moveq	#0,d0
	move.w	d0,(Level_frame_counter).w
	move.b	(Current_Zone).w,d0

	; multiply d0 by 12, the size of a level art load block
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0

	lea	(LevelArtPointers).l,a2
	lea	(a2,d0.w),a2
	moveq	#0,d0
	move.b	(a2),d0	; PLC1 ID
	beq.s	+
	bsr.w	LoadPLC
+
	moveq	#PLCID_Std2,d0
	bsr.w	LoadPLC
	bsr.w	Level_SetPlayerMode
	moveq	#PLCID_MilesLife2P,d0
	cmpi.w	#1,(Player_mode).w
	bne.s	Level_ClrRam
	addq.w	#PLCID_MilesLife-PLCID_MilesLife2P,d0
+
	tst.b	(Graphics_Flags).w
	bpl.s	+
	addq.w	#PLCID_TailsLife2P-PLCID_MilesLife2P,d0
+
	bsr.w	LoadPLC
; loc_3F48:
Level_ClrRam:
	clearRAM Object_Display_Lists,Object_Display_Lists_End
	clearRAM Object_RAM,LevelOnly_Object_RAM_End ; clear object RAM and level-only object RAM
	clearRAM MiscLevelVariables,MiscLevelVariables_End
	clearRAM Misc_Variables,Misc_Variables_End
	clearRAM Oscillating_Data,Oscillating_variables_End
	clearRAM CNZ_saucer_data,CNZ_saucer_data_End

	cmpi.w	#chemical_plant_zone_act_2,(Current_ZoneAndAct).w ; CPZ 2
	beq.s	Level_InitWater
	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w ; ARZ
	beq.s	Level_InitWater
	cmpi.b	#hidden_palace_zone,(Current_Zone).w ; HPZ
	bne.s	+

Level_InitWater:
	move.b	#1,(Water_flag).w
+
	lea	(VDP_control_port).l,a6
	move.w	#$8B03,(a6)		; EXT-INT disabled, V scroll by screen, H scroll by line
	move.w	#$8200|(VRAM_Plane_A_Name_Table/$400),(a6)	; PNT A base: $C000
	move.w	#$8400|(VRAM_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $E000
	move.w	#$8500|(VRAM_Sprite_Attribute_Table/$200),(a6)	; Sprite attribute table base: $F800
	move.w	#$9001,(a6)		; Scroll table size: 64x32
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8720,(a6)		; Background palette/color: 2/0
	move.w	#$8C81,(a6)		; H res 40 cells, no interlace
	tst.b	(Debug_options_flag).w
	beq.s	++
	btst	#button_C,(Ctrl_1_Held).w
	beq.s	+
	move.w	#$8C89,(a6)	; H res 40 cells, no interlace, S/H enabled
+
	btst	#button_A,(Ctrl_1_Held).w
	beq.s	+
	move.b	#1,(Debug_mode_flag).w
+
	move.w	#$8ADF,(Hint_counter_reserve).w	; H-INT every 223rd scanline
	move.w	(Hint_counter_reserve).w,(a6)
	ResetDMAQueue
	tst.b	(Water_flag).w	; does level have water?
	beq.s	Level_LoadPal	; if not, branch
	move.w	#$8014,(a6)	; H-INT enabled
	moveq	#0,d0
	move.w	(Current_ZoneAndAct).w,d0
    if useFullWaterTables=0
	subi.w	#hidden_palace_zone_act_1,d0
    endif
	ror.b	#1,d0
	lsr.w	#6,d0
	lea	WaterHeight(pc),a1	; load water height array
	move.w	(a1,d0.w),d0
	move.w	d0,(Water_Level_1).w ; set water heights
	move.w	d0,(Water_Level_2).w
	move.w	d0,(Water_Level_3).w
	clr.b	(Water_routine).w	; clear water routine counter
	clr.b	(Water_fullscreen_flag).w	; clear water movement
	move.b	#1,(Water_on).w	; enable water
; loc_407C:
Level_LoadPal:
	moveq	#PalID_BGND,d0
	bsr.w	PalLoad_Now	; load Sonic's palette line
	tst.b	(Water_flag).w	; does level have water?
	beq.s	Level_GetBgm	; if not, branch
	moveq	#PalID_HPZ_U,d0	; palette number $15
	cmpi.b	#hidden_palace_zone,(Current_Zone).w
	beq.s	Level_WaterPal ; branch if level is HPZ
	moveq	#PalID_CPZ_U,d0	; palette number $16
	cmpi.b	#chemical_plant_zone,(Current_Zone).w
	beq.s	Level_WaterPal ; branch if level is CPZ
	moveq	#PalID_ARZ_U,d0	; palette number $17
; loc_409E:
Level_WaterPal:
	bsr.w	PalLoad_Water_Now	; load underwater palette (with d0)
	tst.b	(Last_star_pole_hit).w ; is it the start of the level?
	beq.s	Level_GetBgm	; if yes, branch
	move.b	(Saved_Water_move).w,(Water_fullscreen_flag).w
; loc_40AE:
Level_GetBgm:
	moveq	#0,d0
	move.b	(Current_Zone).w,d0
	lea	MusicList(pc),a1
; loc_40C8:
Level_PlayBgm:
	move.b	(a1,d0.w),d0		; load from music playlist
	move.w	d0,(Level_Music).w	; store level music
	bsr.w	PlayMusic		; play level music
	move.b	#ObjID_TitleCard,(TitleCard+id).w ; load Obj34 (level title card) at $FFFFB080
; loc_40DA:
Level_TtlCard:
	move.b	#VintID_TitleCard,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	jsr	(RunObjects).l
	jsr	(BuildSprites).l
	bsr.w	Process_KosPlus_Module_Queue
	move.w	(TitleCard_ZoneName+x_pos).w,d0
	cmp.w	(TitleCard_ZoneName+titlecard_x_target).w,d0 ; has title card sequence finished?
	bne.s	Level_TtlCard		; if not, branch
	tst.w	(KosPlus_modules_left).w		; are there any items in the pattern load cue?
	bne.s	Level_TtlCard		; if yes, branch
	move.b	#VintID_TitleCard,(Vint_routine).w
	bsr.w	WaitForVint
	jsr	(Hud_Base).l
+
	bsr.w	InitRingFrame
	moveq	#PalID_BGND,d0
	bsr.w	PalLoad_ForFade	; load Sonic's palette line
	bsr.w	LevelSizeLoad
	bsr.w	DeformBgLayer
	clr.w	(Vscroll_Factor_FG).w

	clearRAM Horiz_Scroll_Buf,Horiz_Scroll_Buf+HorizontalScrollBuffer.len

	bsr.w	LoadZoneTiles
	bsr.w	loadZoneBlockMaps
	jsr	(LoadAnimatedBlocks).l
	bsr.w	DrawInitialBG
	bsr.w	LoadCollisionIndexes
	bsr.w	WaterEffects
	bsr.w	InitPlayers
	move.w	#0,(Ctrl_1_Logical).w
	move.w	#0,(Ctrl_1).w
	move.b	#1,(Control_Locked).w
	move.b	#0,(Level_started_flag).w
; Level_ChkWater:
	tst.b	(Water_flag).w	; does level have water?
	beq.s	+	; if not, branch
	move.b	#ObjID_WaterSurface,(WaterSurface1+id).w ; load Obj04 (water surface) at $FFFFB380
	move.w	#$60,(WaterSurface1+x_pos).w ; set horizontal offset
	move.b	#ObjID_WaterSurface,(WaterSurface2+id).w ; load Obj04 (water surface) at $FFFFB3C0
	move.w	#$120,(WaterSurface2+x_pos).w ; set different horizontal offset
+
	cmpi.b	#chemical_plant_zone,(Current_Zone).w	; check if zone == CPZ
	bne.s	+			; branch if not
	move.b	#ObjID_CPZPylon,(CPZPylon+id).w ; load Obj7C (CPZ pylon) at $FFFFB340
+
	cmpi.b	#oil_ocean_zone,(Current_Zone).w	; check if zone == OOZ
	bne.s	Level_ClrHUD		; branch if not
	move.b	#ObjID_Oil,(Oil+id).w ; load Obj07 (OOZ oil) at $FFFFB380
; Level_LoadObj: misnomer now
Level_ClrHUD:
	moveq	#0,d0
	tst.b	(Last_star_pole_hit).w	; are you starting from a lamppost?
	bne.s	Level_FromCheckpoint	; if yes, branch
	move.w	d0,(Ring_count).w	; clear rings
	move.l	d0,(Timer).w		; clear time
	move.b	d0,(Extra_life_flags).w	; clear extra lives counter
; loc_41E4:
Level_FromCheckpoint:
	move.b	d0,(Time_Over_flag).w
	move.b	d0,(SlotMachine_Routine).w
	move.w	d0,(SlotMachineInUse).w
	move.w	d0,(Debug_placement_mode).w
	move.w	d0,(Level_Inactive_flag).w
	move.w	d0,(Rings_Collected).w
	move.w	d0,(Monitors_Broken).w
	move.w	d0,(Loser_Time_Left).w
	move.b	d0,(Super_Sonic_flag).w
	bsr.w	OscillateNumInit
	moveq	#1,d0
	move.b	d0,(Update_HUD_score).w
	move.b	d0,(Update_HUD_rings).w
	move.b	d0,(Update_HUD_timer).w
	jsr	(ObjectsManager).l
	jsr	(RingsManager).l
	jsr	(SpecialCNZBumpers).l
	jsr	(RunObjects).l
	jsr	(BuildSprites).l
	jsr	(AniArt_Load).l
	bsr.w	SetLevelEndType
	move.w	#0,(Demo_button_index).w
	lea	DemoScriptPointers(pc),a1
	moveq	#0,d0
	move.b	(Current_Zone).w,d0	; load zone value
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a1,d0.w),a1
	move.b	1(a1),(Demo_press_counter).w
	move.w	#$668,(Demo_Time_left).w
	tst.b	(Water_flag).w
	beq.s	++
	moveq	#PalID_HPZ_U,d0
	cmpi.b	#hidden_palace_zone,(Current_Zone).w
	beq.s	+
	moveq	#PalID_CPZ_U,d0
	cmpi.b	#chemical_plant_zone,(Current_Zone).w
	beq.s	+
	moveq	#PalID_ARZ_U,d0
+
	bsr.w	PalLoad_Water_ForFade
+
	move.w	#-1,(TitleCard_ZoneName+titlecard_leaveflag).w
	move.b	#$E,(TitleCard_Left+routine).w	; make the left part move offscreen
	move.w	#$A,(TitleCard_Left+titlecard_location).w

-	move.b	#VintID_TitleCard,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	jsr	(RunObjects).l
	jsr	(BuildSprites).l
	bsr.w	Process_KosPlus_Module_Queue
	tst.b	(TitleCard_Background+id).w
	bne.s	-	; loop while the title card background is still loaded

	move.b	#$16,(TitleCard_ZoneName+routine).w
	move.w	#$2D,(TitleCard_ZoneName+anim_frame_duration).w
	move.b	#$16,(TitleCard_Zone+routine).w
	move.w	#$2D,(TitleCard_Zone+anim_frame_duration).w
	tst.b	(TitleCard_ActNumber+id).w
	beq.s	+	; branch if the act number has been unloaded
	move.b	#$16,(TitleCard_ActNumber+routine).w
	move.w	#$2D,(TitleCard_ActNumber+anim_frame_duration).w
+	move.b	#0,(Control_Locked).w
	move.b	#1,(Level_started_flag).w

; Level_StartGame: loc_435A:
	bclr	#GameModeFlag_TitleCard,(Game_Mode).w ; clear $80 from the game mode

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------
; loc_4360:
Level_MainLoop:
	bsr.w	PauseGame
	move.b	#VintID_Level,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	addq.w	#1,(Level_frame_counter).w ; add 1 to level timer
	bsr.w	MoveSonicInDemo
	bsr.w	WaterEffects
	jsr	(RunObjects).l
	tst.w	(Level_Inactive_flag).w
	bne.w	Level
	bsr.w	DeformBgLayer
	bsr.w	UpdateWaterSurface
	jsr	(RingsManager).l
	cmpi.b	#casino_night_zone,(Current_Zone).w	; is it CNZ?
	bne.s	+			; if not, branch past jsr
	jsr	(SpecialCNZBumpers).l
+
	jsr	(AniArt_Load).l
	bsr.w	PalCycle_Load
	bsr.w	Process_KosPlus_Module_Queue
	bsr.w	OscillateNumDo
	bsr.w	ChangeRingFrame
	bsr.w	CheckLoadSignpostArt
	jsr	(BuildSprites).l
	jsr	(ObjectsManager).l
	cmpi.b	#GameModeID_Demo,(Game_Mode).w	; check if in demo mode
	beq.s	+
	cmpi.b	#GameModeID_Level,(Game_Mode).w	; check if in normal play mode
	beq.s	Level_MainLoop
	rts
; ---------------------------------------------------------------------------
+
	tst.w	(Level_Inactive_flag).w
	bne.s	+
	tst.w	(Demo_Time_left).w
	beq.s	+
	cmpi.b	#GameModeID_Demo,(Game_Mode).w
	beq.w	Level_MainLoop
	move.b	#GameModeID_SegaScreen,(Game_Mode).w ; => SegaScreen
	rts
; ---------------------------------------------------------------------------
+
	cmpi.b	#GameModeID_Demo,(Game_Mode).w
	bne.s	+
	move.b	#GameModeID_SegaScreen,(Game_Mode).w ; => SegaScreen
+
	move.w	#1*60,(Demo_Time_left).w	; 1 second
	move.w	#$3F,(Palette_fade_range).w
	clr.w	(PalChangeSpeed).w
-
	move.b	#VintID_Level,(Vint_routine).w
	bsr.w	WaitForVint
	bsr.w	MoveSonicInDemo
	jsr	(RunObjects).l
	jsr	(BuildSprites).l
	jsr	(ObjectsManager).l
	subq.w	#1,(PalChangeSpeed).w
	bpl.s	+
	move.w	#2,(PalChangeSpeed).w
	bsr.w	Pal_FadeToBlack.UpdateAllColours
+
	tst.w	(Demo_Time_left).w
	bne.s	-
	rts

; ---------------------------------------------------------------------------
; Subroutine to set the player mode, which is forced to Sonic and Tails in
; the demo mode and in 2P mode
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_4450:
Level_SetPlayerMode:
	cmpi.b	#GameModeID_TitleCard|GameModeID_Demo,(Game_Mode).w ; pre-level demo mode?
	beq.s	+			; if yes, branch
	move.w	(Player_option).w,(Player_mode).w ; use the option chosen in the Options screen
	rts
+
	move.w	#0,(Player_mode).w	; force Sonic alone
	rts
; End of function Level_SetPlayerMode


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_446E:
InitPlayers:
	move.w	(Player_mode).w,d0
	bne.s	InitPlayers_TailsAlone ; branch if this isn't a Sonic and Tails game

	move.b	#ObjID_Sonic,(MainCharacter+id).w ; load Obj01 Sonic object at $FFFFB000
	move.b	#ObjID_SpindashDust,(Sonic_Dust+id).w ; load Obj08 Sonic's spindash dust/splash object at $FFFFD100
	rts
; ===========================================================================
; loc_44BE:
InitPlayers_TailsAlone: ; either Sonic or Tails but not both
	subq.w	#1,d0
	move.b	#ObjID_Tails,(MainCharacter+id).w ; load Obj02 Tails object at $FFFFB000
	move.b	#ObjID_SpindashDust,(Tails_Dust+id).w ; load Obj08 Tails' spindash dust/splash object at $FFFFD100
	addq.w	#4,(MainCharacter+y_pos).w
	rts
; End of function InitPlayers

	include "_inc/Water.asm"
	include "_inc/Wind Tunnels.asm"
	include "_inc/Slides.asm"
	include "_inc/MoveSonicInDemo.asm"
	include "_inc/Load Collision Index.asm"
	include "_incObj/sub OscillatingNumber.asm"

; ---------------------------------------------------------------------------
; Queue ring frame graphics loading
; ---------------------------------------------------------------------------

InitRingFrame:
	moveq	#-1,d1
	move.b	d1,(Rings_anim_prev).w			; Make sure initial frame art loads
	move.b	d1,(Ring_spill_prev).w

LoadRingFrame:
	cmpi.b	#6,(MainCharacter+routine).w	; Is Sonic dead?
	bhs.s	.end				; If so, branch

	moveq	#0,d1				; Get ring frame offset for regular rings
	move.b	(Rings_anim_frame).w,d1
	cmp.b	(Rings_anim_prev).w,d1		; Has it changed?
	beq.s	.noring				; If not, branch
	move.b	d1,(Rings_anim_prev).w		; Mark frame's art as loaded

	lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
	addi.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
	move.w	#tiles_to_bytes(ArtTile_ArtNem_Ring),d2
	moveq	#$80/2,d3
	jsr	(QueueDMATransfer).w		; (or DMA_68KtoVRAM)

.noring:
	moveq	#0,d1				; Get ring frame offset for lost rings
	move.b	(Ring_spill_anim_frame).w,d1
	cmp.b	(Ring_spill_prev).w,d1		; Has it changed?
	beq.s	.end				; If not, branch
	move.b	d1,(Ring_spill_prev).w		; Mark frame's art as loaded

	lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
	addi.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
	move.w	#tiles_to_bytes(ArtTile_ArtNem_Ring_loss),d2
	moveq	#$80/2,d3
	jmp	(QueueDMATransfer).w		; (or DMA_68KtoVRAM)

.end:
	rts

; ---------------------------------------------------------------------------
; Subroutine to change global object animation variables (like rings)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_4B64:
ChangeRingFrame:
	bsr.s	LoadRingFrame
	subq.b	#1,(Rings_anim_counter).w
	bpl.s	+
	move.b	#3,(Rings_anim_counter).w
	addq.b	#1,(Rings_anim_frame).w ; animate rings in the level (obj25)
	andi.b	#7,(Rings_anim_frame).w
+
	tst.b	(Ring_spill_anim_counter).w
	beq.s	+	; rts
	moveq	#0,d0
	move.b	(Ring_spill_anim_counter).w,d0
	add.w	(Ring_spill_anim_accum).w,d0
	move.w	d0,(Ring_spill_anim_accum).w
	rol.w	#7,d0
	andi.w	#7,d0
	move.b	d0,(Ring_spill_anim_frame).w ; animate scattered rings (obj37)
	subq.b	#1,(Ring_spill_anim_counter).w
+
	rts
; End of function ChangeRingFrame




; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

nosignpost macro actid
	cmpi.w	#actid,(Current_ZoneAndAct).w
	beq.ATTRIBUTE	+	; rts
    endm

; sub_4BD2:
SetLevelEndType:
	clr.b	(Level_Has_Signpost).w	; set level type to non-signpost
	nosignpost.s metropolis_zone_act_3
	nosignpost.s wing_fortress_zone_act_1
	nosignpost.s death_egg_zone_act_1
	nosignpost.s sky_chase_zone_act_1
	tst.b	(Current_Act).w		; is zone act number non-zero?
	bne.s	+	; if so, branch

; loc_4C40:
LevelEnd_SetSignpost:
	st.b	(Level_Has_Signpost).w	; set level type to signpost
+	rts
; End of function SetLevelEndType


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_4C48:
CheckLoadSignpostArt:
	tst.b	(Level_Has_Signpost).w
	beq.s	+	; rts
	tst.w	(Debug_placement_mode).w
	bne.s	+	; rts
	move.w	(Camera_X_pos).w,d0
	move.w	(Camera_Max_X_pos).w,d1
	subi.w	#$100,d1
	cmp.w	d1,d0
	blt.s	+
	tst.b	(Update_HUD_timer).w
	beq.s	+
	cmp.w	(Camera_Min_X_pos).w,d1
	beq.s	+
	move.w	d1,(Camera_Min_X_pos).w ; prevent camera from scrolling back to the left
	moveq	#PLCID_Signpost,d0 ; <== PLC_1F
	bra.w	LoadPLC2		; load signpost art
; ---------------------------------------------------------------------------
; loc_4C80:
+	rts
; End of function CheckLoadSignpostArt




; ===========================================================================
; Demo scripts
	include "demodata/EHZ.asm"
	include "demodata/CPZ.asm"
	include "demodata/ARZ.asm"

	include "_inc/Load Zone Tiles.asm"

 ; temporarily remap characters to title card letter format
 ; Characters are encoded as Aa, Bb, Cc, etc. through a macro
 charset 'A',0	; can't have an embedded 0 in a string
 charset 'B',"\4\8\xC\4\x10\x14\x18\x1C\x1E\x22\x26\x2A\4\4\x30\x34\x38\x3C\x40\x44\x48\x4C\x52\x56\4"
 charset 'a',"\4\4\4\4\4\4\4\4\2\4\4\4\6\4\4\4\4\4\4\4\4\4\6\4\4"
 charset '.',"\x5A"

; letter lookup string
llookup	:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ ."

; macro for defining title card letters in conjunction with the remapped character set
titleLetters macro letters
     ;  ". ZYXWVUTSRQPONMLKJIHGFEDCBA"
used := %0110000000000110000000010000	; set to initial state
    irpc char,letters
	if ~~(used&1<<strstr(llookup,"char"))	; has the letter been used already?
used := used|1<<strstr(llookup,"char")	; if not, mark it as used
	dc.b "char"			; output letter code
	if "char"=="."
	dc.b 2			; output character size
	else
	dc.b lowstring("char")	; output letter size
	endif
	endif
    endm
	dc.w $FFFF	; output string terminator
    endm

 charset ; revert character set

; ------------------------------------------------------------------------
; MENU ANIMATION SCRIPT
; ------------------------------------------------------------------------
;word_87C6:
Anim_SonicMilesBG:	zoneanimstart
	; Sonic/Miles animated background
	zoneanimdecl  -1, ArtUnc_MenuBack,    1,  6, $A
	dc.b   0,$C7
	dc.b  $A,  5
	dc.b $14,  5
	dc.b $1E,$C7
	dc.b $14,  5
	dc.b  $A,  5
	even

	zoneanimend


; ---------------------------------------------------------------------------
; Common menu screen subroutine for transferring text to RAM

; ARGUMENTS:
; d0 = starting art tile
; a1 = data source
; a2 = destination
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_8FBE:
MenuScreenTextToRAM:
	moveq	#0,d1
	move.b	(a1)+,d1
-	move.b	(a1)+,d0
	move.w	d0,(a2)+
	dbf	d1,-
	rts
; End of function MenuScreenTextToRAM

; ===========================================================================
; loc_8BD4:
MenuScreen:
	bsr.w	Pal_FadeToBlack
	move	#$2700,sr
	move.w	(VDP_Reg1_val).w,d0
	andi.b	#$BF,d0
	move.w	d0,(VDP_control_port).l
	bsr.w	ClearScreen
	lea	(VDP_control_port).l,a6
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)		; PNT A base: $C000
	move.w	#$8400|(VRAM_Menu_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $E000
	move.w	#$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)		; PNT A base: $C000
	move.w	#$8700,(a6)		; Background palette/color: 0/0
	move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
	move.w	#$9001,(a6)		; Scroll table size: 64x32

	clearRAM Object_Display_Lists,Object_Display_Lists_End
	clearRAM Object_RAM,Object_RAM_End

	; load background + graphics of font/LevSelPics
	ResetDMAQueue
	lea	(ArtNem_FontStuff).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_FontStuff),d2
	bsr.w	Queue_KosPlus_Module
	lea	(ArtNem_MenuBox).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_MenuBox),d2
	bsr.w	Queue_KosPlus_Module
	lea	(ArtNem_LevelSelectPics).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_LevelSelectPics),d2
	bsr.w	Queue_KosPlus_Module
	lea	(Chunk_Table).l,a1
	lea	(MapEng_MenuBack).l,a0
	move.w	#make_art_tile(ArtTile_VRAM_Start,3,0),d0
	bsr.w	EniDec
	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_Plane_B_Name_Table,VRAM,WRITE),d0
	moveq	#40-1,d1
	moveq	#28-1,d2
	bsr.w	PlaneMapToVRAM_H40	; fullscreen background

	cmpi.b	#GameModeID_LevelSelect,(Game_Mode).w	; level select menu?
	beq.w	MenuScreen_LevelSelect	; if yes, branch

; ===========================================================================
; loc_8FCC:
MenuScreen_Options:
	lea	(Chunk_Table).l,a1
	lea	MapEng_Options(pc),a0
	moveq	#make_art_tile(ArtTile_ArtNem_MenuBox,0,0),d0
	bsr.w	EniDec
	lea	(Chunk_Table+$160).l,a1
	lea	MapEng_Options(pc),a0
	move.w	#make_art_tile(ArtTile_ArtNem_MenuBox,1,0),d0
	bsr.w	EniDec
	clr.b	(Options_menu_box).w
	bsr.w	OptionScreen_DrawSelected
	addq.b	#1,(Options_menu_box).w
	bsr.w	OptionScreen_DrawUnselected
	addq.b	#1,(Options_menu_box).w
	bsr.w	OptionScreen_DrawUnselected
	moveq	#0,d0
	move.b	d0,(Options_menu_box).w
	move.b	d0,(Level_started_flag).w
	move.w	d0,(Anim_Counters).w
	lea	Anim_SonicMilesBG(pc),a2
	jsr	(Dynamic_Normal).l
	moveq	#PalID_Menu,d0
	bsr.w	PalLoad_ForFade
	moveq	#MusID_Options,d0
	bsr.w	PlayMusic
	moveq	#0,d0
	move.l	d0,(Camera_X_pos).w
	move.l	d0,(Camera_Y_pos).w
	move.w	d0,(Correct_cheat_entries).w
	move.w	d0,(Correct_cheat_entries_2).w
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	Process_KosPlus_Queue
	bsr.w	WaitForVint
	bsr.w	Process_KosPlus_Module_Queue
	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l
	bsr.w	Pal_FadeFromBlack
; loc_9060:
OptionScreen_Main:
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint
	move	#$2700,sr
	bsr.w	OptionScreen_DrawUnselected
	bsr.w	OptionScreen_Controls
	bsr.w	OptionScreen_DrawSelected
	move	#$2300,sr
	lea	Anim_SonicMilesBG(pc),a2
	jsr	(Dynamic_Normal).l
	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_start_mask,d0
	bne.s	OptionScreen_Select
	bra.s	OptionScreen_Main
; ===========================================================================
; loc_909A:
OptionScreen_Select:
	move.b	(Options_menu_box).w,d0
	bne.s	OptionScreen_Select_Other
	; Start a single player game
	moveq	#0,d0
    if emerald_hill_zone_act_1=0
	move.w	d0,(Current_ZoneAndAct).w ; emerald_hill_zone_act_1
    else
	move.w	#emerald_hill_zone_act_1,(Current_ZoneAndAct).w
    endif
	move.w	d0,(Current_Special_StageAndAct).w
	move.w	d0,(Got_Emerald).w
	move.l	d0,(Got_Emeralds_array).w
	move.l	d0,(Got_Emeralds_array+4).w
	move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
	rts
; ===========================================================================
; loc_90D8:
OptionScreen_Select_Other:
	; When pressing START on the sound test option, return to the SEGA screen
	move.b	#GameModeID_SegaScreen,(Game_Mode).w ; => SegaScreen
	rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

;sub_90E0:
OptionScreen_Controls:
	moveq	#0,d2
	move.b	(Options_menu_box).w,d2
	move.b	(Ctrl_1_Press).w,d0
	btst	#button_up,d0
	beq.s	+
	subq.b	#1,d2
	bcc.s	+
	moveq	#1,d2

+
	btst	#button_down,d0
	beq.s	+
	addq.b	#1,d2
	cmpi.b	#2,d2
	blo.s	+
	moveq	#0,d2

+
	move.b	d2,(Options_menu_box).w
	add.w	d2,d2
	add.w	d2,d2
	move.b	OptionScreen_Choices(pc,d2.w),d3 ; number of choices for the option
	movea.l	OptionScreen_Choices(pc,d2.w),a1 ; location where the choice is stored (in RAM)
	move.w	(a1),d2
	btst	#button_left,d0
	beq.s	+
	subq.b	#1,d2
	bcc.s	+
	move.b	d3,d2

+
	btst	#button_right,d0
	beq.s	+
	addq.b	#1,d2
	cmp.b	d3,d2
	bls.s	+
	moveq	#0,d2

+
	tst.b	(Options_menu_box).w
	beq.s	+
	btst	#button_A,d0
	beq.s	+
	addi.b	#$10,d2
	bcc.s	+
	moveq	#0,d2
+
	move.w	d2,(a1)
	tst.b	(Options_menu_box).w
	beq.s	+	; rts
	andi.w	#button_B_mask|button_C_mask,d0
	beq.s	+	; rts
	move.w	(Sound_test_sound).w,d0
	bsr.w	PlayMusic
	lea	level_select_cheat(pc),a0
	lea	continues_cheat(pc),a2
	lea	(Level_select_flag).w,a1	; Also Slow_motion_flag
	moveq	#0,d2	; flag to tell the routine to enable the continues cheat
	bra.w	CheckCheats

+
	rts
; End of function OptionScreen_Controls

; ===========================================================================
; word_917A:
OptionScreen_Choices:
	dc.l (2-1)<<24|(Player_option&$FFFFFF)
	dc.l ($00-1)<<24|(Sound_test_sound&$FFFFFF)

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


;sub_9186
OptionScreen_DrawSelected:
	bsr.w	OptionScreen_SelectTextPtr
	moveq	#0,d1
	move.b	(Options_menu_box).w,d1
	lsl.w	#3,d1
	lea	OptScrBoxData(pc),a3
	lea	(a3,d1.w),a3
	move.w	#palette_line_3,d0
	lea	(Chunk_Table+$30).l,a2
	movea.l	(a3)+,a1
	bsr.w	MenuScreenTextToRAM
	lea	(Chunk_Table+$B6).l,a2
	moveq	#0,d1
	tst.b	(Options_menu_box).w
	bne.s	+
	move.b	(Options_menu_box).w,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	OptionScreen_Choices(pc),a1
	movea.l	(a1,d1.w),a1
	move.w	(a1),d1
	add.w	d1,d1
	add.w	d1,d1
+
	movea.l	(a4,d1.w),a1
	bsr.w	MenuScreenTextToRAM
	tst.b	(Options_menu_box).w
	beq.s	+
	lea	(Chunk_Table+$C2).l,a2
	bsr.w	OptionScreen_HexDumpSoundTest
+
	lea	(Chunk_Table).l,a1
	move.l	(a3)+,d0
	moveq	#22-1,d1
	moveq	#8-1,d2
	bra.w	PlaneMapToVRAM_H40
; ===========================================================================

;loc_91F8
OptionScreen_DrawUnselected:
	bsr.w	OptionScreen_SelectTextPtr
	moveq	#0,d1
	move.b	(Options_menu_box).w,d1
	lsl.w	#3,d1
	lea	OptScrBoxData(pc),a3
	lea	(a3,d1.w),a3
	moveq	#palette_line_0,d0
	lea	(Chunk_Table+$190).l,a2
	movea.l	(a3)+,a1
	bsr.w	MenuScreenTextToRAM
	lea	(Chunk_Table+$216).l,a2
	moveq	#0,d1
	tst.b	(Options_menu_box).w
	bne.s	+
	move.b	(Options_menu_box).w,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	OptionScreen_Choices(pc),a1
	movea.l	(a1,d1.w),a1
	move.w	(a1),d1
	add.w	d1,d1
	add.w	d1,d1

+
	movea.l	(a4,d1.w),a1
	bsr.w	MenuScreenTextToRAM
	tst.b	(Options_menu_box).w
	beq.s	+
	lea	(Chunk_Table+$222).l,a2
	bsr.w	OptionScreen_HexDumpSoundTest

+
	lea	(Chunk_Table+$160).l,a1
	move.l	(a3)+,d0
	moveq	#22-1,d1
	moveq	#8-1,d2
	bra.w	PlaneMapToVRAM_H40
; ===========================================================================

;loc_9268
OptionScreen_SelectTextPtr:
	lea	off_92D2(pc),a4
	tst.b	(Graphics_Flags).w
	bpl.s	+
	lea	off_92DE(pc),a4

+
	tst.b	(Options_menu_box).w
	beq.s	+
	lea	off_92F2(pc),a4

+
	rts
; ===========================================================================

;loc_9296
OptionScreen_HexDumpSoundTest:
	move.w	(Sound_test_sound).w,d1
	move.b	d1,d2
	lsr.b	#4,d1
	bsr.s	+
	move.b	d2,d1

+
	andi.w	#$F,d1
	cmpi.b	#$A,d1
	blo.s	+
	addq.b	#4,d1

+
	addi.b	#$10,d1
	move.b	d1,d0
	move.w	d0,(a2)+
	rts
; ===========================================================================
; off_92BA:
OptScrBoxData:

; macro to declare the data for an options screen box
boxData macro txtlabel,vramAddr
	dc.l txtlabel, vdpComm(vramAddr,VRAM,WRITE)
    endm

	boxData	TextOptScr_PlayerSelect,VRAM_Plane_A_Name_Table+planeLoc(64,9,4)
	boxData	TextOptScr_SoundTest,VRAM_Plane_A_Name_Table+planeLoc(64,9,12)

off_92D2:
	dc.l TextOptScr_SonicAlone
	dc.l TextOptScr_MilesAlone
off_92DE:
	dc.l TextOptScr_SonicAlone
	dc.l TextOptScr_TailsAlone
off_92F2:
	dc.l TextOptScr_0
; ===========================================================================
; loc_92F6:
; ===========================================================================
; macro for generating level select strings
levselstr macro str
	save
	codepage	LEVELSELECT
	dc.b strlen(str)-1, str
	restore
    endm

; codepage for level select
	save
	codepage LEVELSELECT
	charset '0','9', 16
	charset 'A','Z', 30
	charset 'a','z', 30
	charset '*', 26
	charset $A9, 27	; '?'
	charset ':', 28
	charset '.', 29
	charset ' ',  0
	restore
planeLocH28 function col,line,(($50 * line) + (2 * col))

MenuScreen_LevelSelect:
	; Load foreground (sans zone icon)
	lea	(Chunk_Table).l,a1
	lea	MapEng_LevSel(pc),a0	; 2 bytes per 8x8 tile, compressed
	moveq	#make_art_tile(ArtTile_VRAM_Start,0,0),d0
	bsr.w	EniDec
	lea	(Chunk_Table).l,a1
	lea	(MapEng_LevSel).l,a0	; 2 bytes per 8x8 tile, compressed
	move.w	#make_art_tile(ArtTile_VRAM_Start,0,0),d0
	bsr.w	EniDec
	save
	codepage	LEVELSELECT	; This is here so we can use '*' instead of '$1A'
	lea	(Chunk_Table).l,a3
	lea	(LevelSelectText).l,a1
	lea	(LevSel_MappingOffsets).l,a5
	moveq	#0,d0
	move.w	#$D-1,d1		; This is how many entries there are in LevelSelectText

.writezone:
	move.w	(a5)+,d3	; Get relative address in plane map to write to
	lea	(a3,d3.w),a2	; Get absolute address
	moveq	#0,d2
	move.b	(a1)+,d2	; Get length of string
	move.w	d2,d3		; Store it

.writeletter:
	move.b	(a1)+,d0	; Get character from string
	;ori.w	#make_art_tile($000,0,0),d0
	move.w	d0,(a2)+	; Send it to plane map
	dbf	d2,.writeletter	; Loop for entire string
	cmpi.W	#$4,d1
	ble.s	.righthandside
	move.w	#$D,d2		; Maximum length of string
	bra.S	.calculatespaces
.righthandside:
	move.w	#$C,d2		; Maximum length of string
.calculatespaces:
	sub.w	d3,d2		; Get remaining space in string
	bcs.s	.stringfull	; If there is none, skip ahead
.blankloop:
	move.w	#make_art_tile(' ',0,0),(a2)+	; Full the remaining space with blank characters
	dbf	d2,.blankloop
.stringfull:
	move.w	#make_art_tile('1',0,0),(a2)	; Write (act) '1'
	lea	$28*2(a2),a2	; Next line
	move.w	#make_art_tile('2',0,0),(a2)	; Write (act) '2'
	dbf	d1,.writezone

	; Assuming the last line was the sound test...
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act) '2'
	lea	-$28*2(a2),a2	; Go back to (act) '1'
	move.w	#make_art_tile('*',0,0),(a2)	; Replace that with '*'

	lea	-$28*4(a2),a2	; Go back to (act)
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act)
	lea	-$28*2(a2),a2	; Go back to (act)
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act)
	lea	-$28*4(a2),a2	; Go back to (act)
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act)
	lea	-$28*2(a2),a2	; Go back to (act)
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act)
	lea	-$28*4(a2),a2	; Go back to (act)
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act)
	lea	-$28*2(a2),a2	; Go back to (act)
	move.w	#make_art_tile(' ',0,0),(a2)	; Get rid of (act)

	; Overwrite duplicate METROPOLIS 1 with 3
	move.w	#make_art_tile('3',0,0),(Chunk_Table+planeLocH28($24,5)).l

	restore

	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_Plane_A_Name_Table,VRAM,WRITE),d0
	moveq	#40-1,d1
	moveq	#28-1,d2	; 40x28 = whole screen
	bsr.w	PlaneMapToVRAM_H40	; display patterns

	; Draw sound test number
	moveq	#palette_line_0,d3
	bsr.w	LevelSelect_DrawSoundNumber

	; Load zone icon
	lea	(Chunk_Table+planeLoc(40,0,28)).l,a1
	lea	MapEng_LevSelIcon(pc),a0
	move.w	#make_art_tile(ArtTile_ArtNem_LevelSelectPics,0,0),d0
	bsr.w	EniDec

	bsr.w	LevelSelect_DrawIcon

	moveq	#0,d0
	move.w	d0,(Player_mode).w
	move.b	d0,(Level_started_flag).w
	move.w	d0,(Anim_Counters).w

	; Animate background (loaded back in MenuScreen)
	lea	Anim_SonicMilesBG(pc),a2
	jsr	(Dynamic_Normal).l	; background

	moveq	#PalID_Menu,d0
	bsr.w	PalLoad_ForFade

	lea	(Normal_palette_line3).w,a1
	lea	(Target_palette_line3).w,a2

	moveq	#bytesToLcnt(palette_line_size),d1
	moveq	#0,d0
-	move.l	(a1),(a2)+
	move.l	d0,(a1)+
	dbf	d1,-

	moveq	#MusID_Options,d0
	bsr.w	PlayMusic

	move.w	#(30*60)-1,(Demo_Time_left).w	; 30 seconds
	moveq	#0,d0
	move.l	d0,(Camera_X_pos).w
	move.l	d0,(Camera_Y_pos).w
	move.w	d0,(Correct_cheat_entries).w
	move.w	d0,(Correct_cheat_entries_2).w

	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint

	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l

	bsr.w	Pal_FadeFromBlack

;loc_93AC:
LevelSelect_Main:	; routine running during level select
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint

	move	#$2700,sr

	moveq	#palette_line_0,d3
	bsr.w	LevelSelect_MarkFields	; unmark fields
	bsr.w	LevSelControls		; possible change selected fields
	move.w	#palette_line_3,d3
	bsr.w	LevelSelect_MarkFields	; mark fields

	bsr.w	LevelSelect_DrawIcon

	move	#$2300,sr

	lea	Anim_SonicMilesBG(pc),a2
	jsr	(Dynamic_Normal).l

	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_start_mask,d0	; start pressed?
	bne.s	LevelSelect_PressStart	; yes
	bra.s	LevelSelect_Main	; no
; ===========================================================================

;loc_93F0:
LevelSelect_PressStart:
	move.w	(Level_select_zone).w,d0
	add.w	d0,d0
	move.w	LevelSelect_Order(pc,d0.w),d0
	bmi.s	LevelSelect_Return	; sound test
	cmpi.w	#$4000,d0
	bne.s	LevelSelect_StartZone

;loc_944C:
LevelSelect_Return:
	move.b	#GameModeID_SegaScreen,(Game_Mode).w ; => SegaScreen
	rts
; ===========================================================================
; -----------------------------------------------------------------------------
; Level Select Level Order

; One entry per item in the level select menu. Just set the value for the item
; you want to link to the level/act number of the level you want to load when
; the player selects that item.
; -----------------------------------------------------------------------------
;Misc_9454:
LevelSelect_Order:
	dc.w	emerald_hill_zone_act_1
	dc.w	emerald_hill_zone_act_2	; 1
	dc.w	chemical_plant_zone_act_1	; 2
	dc.w	chemical_plant_zone_act_2	; 3
	dc.w	aquatic_ruin_zone_act_1	; 4
	dc.w	aquatic_ruin_zone_act_2	; 5
	dc.w	casino_night_zone_act_1	; 6
	dc.w	casino_night_zone_act_2	; 7
	dc.w	hill_top_zone_act_1	; 8
	dc.w	hill_top_zone_act_2	; 9
	dc.w	mystic_cave_zone_act_1	; 10
	dc.w	mystic_cave_zone_act_2	; 11
	dc.w	hidden_palace_zone_act_1	; 12
	dc.w	hidden_palace_zone_act_2	; 13
	dc.w	oil_ocean_zone_act_1	; 14
	dc.w	oil_ocean_zone_act_2	; 15
	dc.w	metropolis_zone_act_1	; 16
	dc.w	metropolis_zone_act_2	; 17
	dc.w	metropolis_zone_act_3	; 18
	dc.w	sky_chase_zone_act_1	; 19
	dc.w	wing_fortress_zone_act_1	; 20
	dc.w	death_egg_zone_act_1	; 21
	dc.w	$FFFF	; 23 - sound test
; ===========================================================================

;loc_9480:
LevelSelect_StartZone:
	andi.w	#$3FFF,d0
	move.w	d0,(Current_ZoneAndAct).w
	move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
	move.b	#3,(Life_count).w
	moveq	#0,d0
	move.w	d0,(Ring_count).w
	move.l	d0,(Timer).w
	move.l	d0,(Score).w
	move.l	#5000,(Next_Extra_life_score).w
	move.b	#MusID_FadeOut,d0
	bra.w	PlayMusic

; ===========================================================================
; ---------------------------------------------------------------------------
; Change what you're selecting in the level select
; ---------------------------------------------------------------------------
; loc_94DC:
LevSelControls:
	move.b	(Ctrl_1_Press).w,d1
	andi.b	#button_up_mask|button_down_mask,d1
	bne.s	+	; up/down pressed
	subq.w	#1,(LevSel_HoldTimer).w
	bpl.s	LevSelControls_CheckLR

+
	move.w	#$B,(LevSel_HoldTimer).w
	move.b	(Ctrl_1_Held).w,d1
	andi.b	#button_up_mask|button_down_mask,d1
	beq.s	LevSelControls_CheckLR	; up/down not pressed, check for left & right
	move.w	(Level_select_zone).w,d0
	btst	#button_up,d1
	beq.s	+
	subq.w	#1,d0	; decrease by 1
	bcc.s	+	; >= 0?
	moveq	#$16,d0	; set to $17

+
	btst	#button_down,d1
	beq.s	+
	addq.w	#1,d0	; yes, add 1
	cmpi.w	#$17,d0
	blo.s	+	; smaller than $18?
	moveq	#0,d0	; if not, set to 0

+
	move.w	d0,(Level_select_zone).w
	rts
; ===========================================================================
; loc_9522:
LevSelControls_CheckLR:
	cmpi.w	#$16,(Level_select_zone).w	; are we in the sound test?
	bne.s	LevSelControls_SwitchSide	; no
	move.w	(Sound_test_sound).w,d0
	move.b	(Ctrl_1_Press).w,d1
	btst	#button_left,d1
	beq.s	+
	subq.b	#1,d0

+
	btst	#button_right,d1
	beq.s	+
	addq.b	#1,d0

+
	btst	#button_A,d1
	beq.s	+
	addi.b	#$10,d0
	bcc.s	+
	moveq	#0,d0

+
	move.w	d0,(Sound_test_sound).w
	andi.w	#button_B_mask|button_C_mask,d1
	beq.s	+	; rts
	move.w	(Sound_test_sound).w,d0
	bsr.w	PlayMusic
	lea	debug_cheat(pc),a0
	lea	super_sonic_cheat(pc),a2
	lea	(Debug_options_flag).w,a1	; Also S1_hidden_credits_flag
	moveq	#1,d2	; flag to tell the routine to enable the Super Sonic cheat
	bra.w	CheckCheats

+
	rts
; ===========================================================================
; loc_958A:
LevSelControls_SwitchSide:	; not in soundtest, not up/down pressed
	move.b	(Ctrl_1_Press).w,d1
	andi.b	#button_left_mask|button_right_mask,d1
	beq.s	+				; no direction key pressed
	move.w	(Level_select_zone).w,d0	; left or right pressed
	move.b	LevelSelect_SwitchTable(pc,d0.w),d0 ; set selected zone according to table
	move.w	d0,(Level_select_zone).w
+
	bra.s	LevelSelect_PickCharacterNumber
; ===========================================================================
;byte_95A2:
LevelSelect_SwitchTable:
	dc.b $10	; EHZ1 - MTZ1
	dc.b $11	; EHZ2 - MTZ2
	dc.b $13	; CPZ1 - SCZ
	dc.b $13	; CPZ2 - SCZ
	dc.b $14	; ARZ1 - WFZ
	dc.b $14	; ARZ2 - WFZ
	dc.b $15	; CNZ1 - DEZ
	dc.b $15	; CNZ2 - DEZ
	dc.b $16	; HTZ1 - Sound Test
	dc.b $16	; HTZ2 - Sound Test
	dc.b $16	; MCZ1 - Sound Test
	dc.b $16	; MCZ2 - Sound Test
	dc.b $16	; HPZ1 - Sound Test
	dc.b $16	; HPZ2 - Sound Test
	dc.b $16	; OOZ1 - Sound Test
	dc.b $16	; OOZ2 - Sound Test
	dc.b 0		; MTZ1 - EHZ1
	dc.b 1		; MTZ2 - EHZ2
	dc.b 1		; MTZ3 - EHZ2
	dc.b 2		; SCZ - CPZ1
	dc.b 4		; WFZ - ARZ1
	dc.b 6		; DEZ - CNZ1
	dc.b 8		; Sound Test - HTZ1
	even
; ---------------------------------------------------------------------------

LevelSelect_PickCharacterNumber:
	btst	#button_C,(Ctrl_1_Press).w
	beq.s	locret_7F60
	addq.w	#1,(Player_option).w
	cmpi.w	#3,(Player_option).w
	blo.s	locret_7F60
	move.w	#0,(Player_option).w

locret_7F60:
	rts
; ===========================================================================

;loc_95B8:
LevelSelect_MarkFields:
	lea	(Chunk_Table).l,a4
	lea	LevSel_MarkTable(pc),a5
	lea	(VDP_data_port).l,a6
	moveq	#0,d0
	move.w	(Level_select_zone).w,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	(a5,d0.w),a3
	moveq	#0,d0
	move.b	(a3),d0
	mulu.w	#$50,d0
	moveq	#0,d1
	move.b	1(a3),d1
	add.w	d1,d0
	lea	(a4,d0.w),a1
	moveq	#0,d1
	move.b	(a3),d1
	lsl.w	#7,d1
	add.b	1(a3),d1
	addi.w	#VRAM_Plane_A_Name_Table,d1
	lsl.l	#2,d1
	lsr.w	#2,d1
	ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d1
	swap	d1
	move.l	d1,4(a6)

	moveq	#$D,d2
-	move.w	(a1)+,d0
	add.w	d3,d0
	move.w	d0,(a6)
	dbf	d2,-

	addq.w	#2,a3
	moveq	#0,d0
	move.b	(a3),d0
	beq.s	+
	mulu.w	#$50,d0
	moveq	#0,d1
	move.b	1(a3),d1
	add.w	d1,d0
	lea	(a4,d0.w),a1
	moveq	#0,d1
	move.b	(a3),d1
	lsl.w	#7,d1
	add.b	1(a3),d1
	addi.w	#VRAM_Plane_A_Name_Table,d1
	lsl.l	#2,d1
	lsr.w	#2,d1
	ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d1
	swap	d1
	move.l	d1,4(a6)
	move.w	(a1)+,d0
	add.w	d3,d0
	move.w	d0,(a6)

+
	cmpi.w	#$16,(Level_select_zone).w
	bne.s	LevelSelect_DrawCharacterNumber
	bra.s	LevelSelect_DrawSoundNumber

LevelSelect_DrawCharacterNumber:
	move.l	#vdpComm(VRAM_Plane_A_Name_Table+planeLoc(32,32,10),VRAM,WRITE),(VDP_control_port).l
	move.w	(Player_option).w,d0
	bra.s	LevelSelect_DrawContinued
; ===========================================================================
;loc_965A:
LevelSelect_DrawSoundNumber:
	move.l	#vdpComm(VRAM_Plane_A_Name_Table+planeLoc(64,34,15),VRAM,WRITE),(VDP_control_port).l
	move.w	(Sound_test_sound).w,d0

LevelSelect_DrawContinued:
	move.b	d0,d2
	lsr.b	#4,d0
	bsr.s	+
	move.b	d2,d0

+
	andi.w	#$F,d0
	cmpi.b	#$A,d0
	blo.s	+
	addq.b	#4,d0

+
	addi.b	#$10,d0
	add.w	d3,d0
	move.w	d0,(a6)
	rts
; ===========================================================================

;loc_9688:
LevelSelect_DrawIcon:
	move.w	(Level_select_zone).w,d0
	lea	LevSel_IconTable(pc),a3
	lea	(a3,d0.w),a3
	lea	(Chunk_Table+planeLoc(40,0,28)).l,a1
	moveq	#0,d0
	move.b	(a3),d0
	lsl.w	#3,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lea	(a1,d0.w),a1
	move.l	#vdpComm(VRAM_Plane_A_Name_Table+planeLoc(64,27,20),VRAM,WRITE),d0
	moveq	#4-1,d1
	moveq	#3-1,d2
	bsr.w	PlaneMapToVRAM_H40
	lea	Pal_LevelIcons(pc),a1
	moveq	#0,d0
	move.b	(a3),d0
	lsl.w	#5,d0
	lea	(a1,d0.w),a1
	lea	(Normal_palette_line3).w,a2

	move.l  #vdpComm(2*16*2,CRAM,WRITE),VDP_control_port-VDP_data_port(a6)

	moveq	#bytesToLcnt(palette_line_size),d1
-
	move.l	(a1),(a6)
	move.l	(a1)+,(a2)+
	dbf	d1,-

	rts
; ===========================================================================
;byte_96D8
Icon_EHZ = 0
Icon_CPZ = 7
Icon_ARZ = 8
Icon_CNZ = 6
Icon_HTZ = 2
Icon_MCZ = 5
Icon_OOZ = 4
Icon_MTZ = 1
Icon_SCZ = 9
Icon_WFZ = $A
Icon_DEZ = $B
Icon_SpecStag  = $C
Icon_SoundTest = $E
Icon_HPZ = 3
Icon_X = $D

LevSel_IconTable:
	dc.b   Icon_EHZ,Icon_EHZ		;0	EHZ
	dc.b   Icon_CPZ,Icon_CPZ		;2	CPZ
	dc.b   Icon_ARZ,Icon_ARZ		;4	ARZ
	dc.b   Icon_CNZ,Icon_CNZ		;6	CNZ
	dc.b   Icon_HTZ,Icon_HTZ		;8	HTZ
	dc.b   Icon_MCZ,Icon_MCZ		;$A	MCZ
	dc.b   Icon_HPZ,Icon_HPZ	;$C	HPZ
	dc.b   Icon_OOZ,Icon_OOZ		;$C	OOZ
	dc.b   Icon_MTZ,Icon_MTZ,Icon_MTZ	;$E	MTZ
	dc.b   Icon_SCZ				;$11	SCZ
	dc.b   Icon_WFZ				;$12	WFZ
	dc.b   Icon_DEZ				;$13	DEZ
	dc.b   Icon_SoundTest			;$15	Sound Test
	even
;byte_96EE:
LevSel_MarkTable:	; 4 bytes per level select entry
; line primary, 2*column ($E fields), line secondary, 2*column secondary (1 field)
	dc.b   3,  6,  3,$24	;0
	dc.b   3,  6,  4,$24
	dc.b   6,  6,  6,$24
	dc.b   6,  6,  7,$24
	dc.b   9,  6,  9,$24	;4
	dc.b   9,  6, $A,$24
	dc.b  $C,  6, $C,$24
	dc.b  $C,  6, $D,$24
	dc.b  $F,  6, $F,$24	;8
	dc.b  $F,  6,$10,$24
	dc.b $12,  6,$12,$24
	dc.b $12,  6,$13,$24
	dc.b $15,  6,$15,$24	;$C
	dc.b $15,  6,$16,$24
	dc.b $18,  6,$18,$24	;$C
	dc.b $18,  6,$19,$24
; --- second column ---
	dc.b   3,$2C,  3,$48
	dc.b   3,$2C,  4,$48
	dc.b   3,$2C,  5,$48	;$10
	dc.b   6,$2C,  0,  0
	dc.b   9,$2C,  0,  0
	dc.b  $C,$2C,  0,  0
;	dc.b  $F,$2C,  0,  0	;$14
	dc.b  $F,$2C, $F,$48
	dc.b 0,0,0,0
; ===========================================================================
; loc_9746:
CheckCheats:	; This is called from 2 places: the options screen and the level select screen
	move.w	(Correct_cheat_entries).w,d0	; Get the number of correct sound IDs entered so far
	adda.w	d0,a0				; Skip to the next entry
	move.w	(Sound_test_sound).w,d0		; Get the current sound test sound
	cmp.b	(a0),d0				; Compare it to the cheat
	bne.s	+				; If they're different, branch
	addq.w	#1,(Correct_cheat_entries).w	; Add 1 to the number of correct entries
	tst.b	1(a0)				; Is the next entry 0?
	bne.s	++				; If not, branch
	move.w	#$101,(a1)			; Enable the cheat
	moveq	#SndID_Ring,d0			; Play the ring sound
	bsr.w	PlaySound
+
	move.w	#0,(Correct_cheat_entries).w	; Clear the number of correct entries
+
	move.w	(Correct_cheat_entries_2).w,d0	; Do the same procedure with the other cheat
	adda.w	d0,a2
	move.w	(Sound_test_sound).w,d0
	cmp.b	(a2),d0
	bne.s	++
	addq.w	#1,(Correct_cheat_entries_2).w
	tst.b	1(a2)
	bne.s	+++	; rts
	tst.w	d2				; Test this to determine which cheat to enable
	bne.s	+				; If not 0, branch
	move.b	#$F,(Continue_count).w		; Give 15 continues
	moveq	#SndID_ContinueJingle,d0	; Play the continue jingle
	bsr.w	PlaySound
	bra.s	++
; ===========================================================================
+
	move.w	#7,(Got_Emerald).w		; Give 7 emeralds to the player
	moveq	#MusID_Emerald,d0		; Play the emerald jingle
	bsr.w	PlayMusic
+
	move.w	#0,(Correct_cheat_entries_2).w	; Clear the number of correct entries
+
	rts
; ===========================================================================
level_select_cheat:
	; 17th September 1965, the birthdate of one of Sonic 2's developers,
	; Yuji Naka.
	dc.b $19, $65,   9, $17,   0
	rev02even
; byte_97B7
continues_cheat:
	; November 24th, which was Sonic 2's release date in the EU and US.
	dc.b   1,   1,   2,   4,   0
	rev02even
debug_cheat:
	; 24th November 1992 (also known as "Sonic 2sday"), which was
	; Sonic 2's release date in the EU and US.
	dc.b   1,   9,   9,   2,   1,   1,   2,   4,   0
	rev02even
; byte_97C5
super_sonic_cheat:
	; Book of Genesis, 41:26, which makes frequent reference to the
	; number 7. 7 happens to be the number of Chaos Emeralds.
	; The Mega Drive is known as the Genesis in the US.
	dc.b   4,   1,   2,   6,   0
	rev02even

	; set the character set for menu text
	charset '@',"\27\30\31\32\33\34\35\36\37\38\39\40\41\42\43\44\45\46\47\48\49\50\51\52\53\54\55"
	charset '0',"\16\17\18\19\20\21\22\23\24\25"
	charset '*',$1A
	charset ':',$1C
	charset '.',$1D
	charset ' ',0

	; options screen menu text

TextOptScr_PlayerSelect:	menutxt	"* PLAYER SELECT *"	; byte_97CA:
TextOptScr_SonicAlone:		menutxt	"SONIC ALONE    "	; byte_97FC:
TextOptScr_MilesAlone:		menutxt	"MILES ALONE    "	; byte_980C:
TextOptScr_TailsAlone:		menutxt	"TAILS ALONE    "	; byte_981C:
TextOptScr_SoundTest:		menutxt	"*  SOUND TEST   *"	; byte_985E:
TextOptScr_0:			menutxt	"      00       "	; byte_9870:

	charset ; reset character set
LevSel_MappingOffsets:
		dc.w planeLocH28(3,3)
		dc.w planeLocH28(3,6)
		dc.w planeLocH28(3,9)
		dc.w planeLocH28(3,$C)
		dc.w planeLocH28(3,$F)
		dc.w planeLocH28(3,$12)
		dc.w planeLocH28(3,$15)
		dc.w planeLocH28(3,$18)

		dc.w planeLocH28($16,3)
		dc.w planeLocH28($16,6)
		dc.w planeLocH28($16,9)
		dc.w planeLocH28($16,$C)
		dc.w planeLocH28($16,$F)
		dc.w planeLocH28($16,$12)

LevelSelectText:
		levselstr "EMERALD HILL"
		levselstr "CHEMICAL PLANT"
		levselstr "AQUATIC RUIN"
		levselstr "CASINO NIGHT"
		levselstr "HILL TOP"
		levselstr "MYSTIC CAVE"
		levselstr "HIDDEN PALACE"
		levselstr "OIL OCEAN"
		levselstr "METROPOLIS"
		levselstr "SKY CHASE"
		levselstr "WING FORTRESS"
		levselstr "DEATH EGG"
		levselstr "SOUND TEST *"
		even
; level select picture palettes
; byte_9880:
Pal_LevelIcons:	BINCLUDE "art/palettes/Level Select Icons.bin"
; options screen mappings (Enigma compressed)
; byte_9AB2:
	even
MapEng_Options:	BINCLUDE "mappings/misc/Options Screen.eni"

; level select screen mappings (Enigma compressed)
; byte_9ADE:
	even
MapEng_LevSel:	BINCLUDE "mappings/misc/Level Select.eni"

; 1P and 2P level select icon mappings (Enigma compressed)
; byte_9C32:
	even
MapEng_LevSelIcon:	BINCLUDE "mappings/misc/Level Select Icons.eni"
	even

loc_B272:
	move	#$2700,sr
	lea	(VDP_data_port).l,a6
-
	move.l	(a1)+,d0
	bmi.s	++
	movea.l	d0,a2
	move.w	(a1)+,d0
	bsr.s	sub_B29E
	move.l	d0,4(a6)
	move.b	(a2)+,d0
	lsl.w	#8,d0
-
	move.b	(a2)+,d0
	bmi.s	+
	move.w	d0,(a6)
	bra.s	-
; ===========================================================================
+	bra.s	--
; ===========================================================================
+
	move	#$2300,sr
	rts
; End of function ShowCreditsScreen


; ---------------------------------------------------------------------------
; Subroutine to convert a VRAM address into a 32-bit VRAM write command word
; Input:
;	d0	VRAM address (word)
; Output:
;	d0	32-bit VDP command word for a VRAM write to specified address.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_B29E:
	andi.l	#$FFFF,d0
	lsl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d0
	swap	d0
	rts
; End of function sub_B29E

; macro for declaring pointer/position structures for intro/credit text
vram_pnt := VRAM_Plane_A_Name_Table
creditsPtrs macro addr,pos
	if "addr"<>""
		dc.l addr
		dc.w vram_pnt + pos
		shift
		shift
		creditsPtrs ALLARGS
	else
		dc.w -1
	endif
    endm

textLoc function col,line,(($80 * line) + (2 * col))

 ; temporarily remap characters to credit text format
 ; let's encode 2-wide characters like Aa, Bb, Cc, etc. and hide it with a macro
 charset '@',"\x3B\2\4\6\8\xA\xC\xE\x10\x12\x13\x15\x17\x19\x1B\x1D\x1F\x21\x23\x25\x27\x29\x2B\x2D\x2F\x31\x33"
 charset 'a',"\3\5\7\9\xB\xD\xF\x11\x12\x14\x16\x18\x1A\x1C\x1E\x20\x22\x24\x26\x28\x2A\x2C\x2E\x30\x32\x34"
 charset '!',"\x3D\x39\x3F\x36"
 charset '\H',"\x39\x37\x38"
 charset '9',"\x3E\x40\x41"
 charset '1',"\x3C\x35"
 charset '.',"\x3A"
 charset ' ',0

 ; macro for defining credit text in conjunction with the remapped character set
vram_src := ArtTile_ArtNem_CreditText_CredScr
creditText macro pal,ss
	if ((vram_src & $FF) <> $0) && ((vram_src & $FF) <> $1)
		fatal "The low byte of vram_src was $\{vram_src & $FF}, but it must be $00 or $01."
	endif
	dc.b (make_art_tile(vram_src,pal,0) & $FF00) >> 8
	irpc char,ss
	dc.b "char"
	switch "char"
	case "I"
	case "1"
		dc.b "!"
	case "2"
		dc.b "$"
	case "9"
		dc.b "#"
	elsecase
l := lowstring("char")
		if l<>"char"
			dc.b l
		endif
	endcase
	endm
	dc.b -1
	rev02even
    endm

 charset ; revert character set

; intro text pointers (one intro screen)
vram_pnt := VRAM_TtlScr_Plane_A_Name_Table
off_B2B0: creditsPtrs	byte_BD1A,textLoc($0F,$09), byte_BCEE,textLoc($11,$0C), \
			byte_BCF6,textLoc($03,$0F), byte_BCE9,textLoc($12,$12)

 ; temporarily remap characters to intro text format
 charset '@',"\x3A\1\3\5\7\9\xB\xD\xF\x11\x12\x14\x16\x18\x1A\x1C\x1E\x20\x22\x24\x26\x28\x2A\x2C\x2E\x30\x32"
 charset 'a',"\2\4\6\8\xA\xC\xE\x10\x11\x13\x15\x17\x19\x1B\x1D\x1F\x21\x23\x25\x27\x29\x2B\x2D\x2F\x31\x33"
 charset '!',"\x3C\x38\x3E\x35"
 charset '\H',"\x38\x36\x37"
 charset '9',"\x3D\x3F\x40"
 charset '1',"\x3B\x34"
 charset '.',"\x39"
 charset ' ',0

; intro text
vram_src := ArtTile_ArtNem_CreditText
byte_BCE9:	creditText   0,"IN"
byte_BCEE:	creditText   0,"AND"
byte_BCF6:	creditText   0,"MILES 'TAILS' PROWER"
byte_BD1A:	creditText   0,"SONIC"

 charset ; revert character set

; -------------------------------------------------------------------------------
; Nemesis compressed art
; 64 blocks
; Standard font used in credits
; -------------------------------------------------------------------------------
; ArtNem_BD26:
ArtNem_CreditText:	BINCLUDE	"art/kosinskiplusm/Credit Text.kospm"
	even

	include "_inc/LevelSizeLoad.asm"

; ===========================================================================
; --------------------------------------------------------------------------------------
; CHARACTER START LOCATION ARRAY

; 2 entries per act, corresponding to the X and Y locations that you want the player to
; appear at when the level starts.
; --------------------------------------------------------------------------------------
StartLocations: zoneOrderedTable 2,4	; WrdArr_StartLoc
	; EHZ
	zoneTableBinEntry	2, "startpos/EHZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/EHZ_2.bin"	; Act 2
	; Zone 1
	zoneTableBinEntry	2, "startpos/01_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/01_2.bin"	; Act 2
	; WZ
	zoneTableBinEntry	2, "startpos/WZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/WZ_2.bin"	; Act 2
	; Zone 3
	zoneTableBinEntry	2, "startpos/03_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/03_2.bin"	; Act 2
	; MTZ
	zoneTableBinEntry	2, "startpos/MTZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/MTZ_2.bin"	; Act 2
	; MTZ
	zoneTableBinEntry	2, "startpos/MTZ_3.bin"	; Act 3
	zoneTableBinEntry	2, "startpos/MTZ_4.bin"	; Act 4
	; WFZ
	zoneTableBinEntry	2, "startpos/WFZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/WFZ_2.bin"	; Act 2
	; HTZ
	zoneTableBinEntry	2, "startpos/HTZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/HTZ_2.bin"	; Act 2
	; HPZ
	zoneTableBinEntry	2, "startpos/HPZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/HPZ_2.bin"	; Act 2
	; Zone 9
	zoneTableBinEntry	2, "startpos/09_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/09_2.bin"	; Act 2
	; OOZ
	zoneTableBinEntry	2, "startpos/OOZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/OOZ_2.bin"	; Act 2
	; MCZ
	zoneTableBinEntry	2, "startpos/MCZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/MCZ_2.bin"	; Act 2
	; CNZ
	zoneTableBinEntry	2, "startpos/CNZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/CNZ_2.bin"	; Act 2
	; CPZ
	zoneTableBinEntry	2, "startpos/CPZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/CPZ_2.bin"	; Act 2
	; DEZ
	zoneTableBinEntry	2, "startpos/DEZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/DEZ_2.bin"	; Act 2
	; ARZ
	zoneTableBinEntry	2, "startpos/ARZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/ARZ_2.bin"	; Act 2
	; SCZ
	zoneTableBinEntry	2, "startpos/SCZ_1.bin"	; Act 1
	zoneTableBinEntry	2, "startpos/SCZ_2.bin"	; Act 2
    zoneTableEnd

	include "_inc/Camera Init.asm"

	include "_inc/Software Scrolling Manager.asm" ; This needs to be broken up further
	include "_inc/Camera Scrolling.asm"

	include "_inc/Level Drawing.asm"

	include "_inc/LoadLevelLayout.asm" ; includes loadZoneBlockMaps

	include "_inc/DynamicLevelEvents.asm" ; Another big one
; ===========================================================================

; loc_F62E:
LoadPLC_AnimalExplosion:
	moveq	#0,d0
	move.b	(Current_Zone).w,d0
	lea	(Animal_PLCTable).l,a2
	move.b	(a2,d0.w),d0
	jsr	(LoadPLC).w
	moveq	#PLCID_Explosion,d0
	jmp	(LoadPLC).w
; ===========================================================================
	include "_incObj/11 Bridge.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj11_MapUnc_FC28:	include "mappings/sprite/obj11_a.asm"

; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj11_MapUnc_FC70:	include "mappings/sprite/obj11_b.asm"

; ===========================================================================
	include "_incObj/15 ARZ Swinging Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj15_MapUnc_101E8:			include "mappings/sprite/obj15_a.asm"
Obj15_Obj83_MapUnc_1021E:	include "mappings/sprite/obj83.asm"
	include "mappings/sprite/obj7A_b.asm"
	include "mappings/sprite/obj15_b.asm"

; ===========================================================================
	include "_incObj/17 Spiked Pole Helix.asm"
; ===========================================================================
; -----------------------------------------------------------------------------
; sprite mappings - helix of spikes on a pole (GHZ) (unused)
; -----------------------------------------------------------------------------
Obj17_MapUnc_10452:	include "mappings/sprite/obj17.asm"
; ===========================================================================

	include "_incObj/18 Platforms.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj18_MapUnc_107F6:	include "mappings/sprite/obj18_a.asm"
Obj18_MapUnc_1084E:	include "mappings/sprite/obj18_b.asm"
; ===========================================================================
	include "_incObj/1A & 1F Collapsing Floors.asm"
; -------------------------------------------------------------------------------
; unused sprite mappings (GHZ)
; -------------------------------------------------------------------------------
Obj1A_MapUnc_10C6C:	include "mappings/sprite/obj1A_a.asm"
; ----------------------------------------------------------------------------
; unused sprite mappings (MZ, SLZ, SBZ)
; ----------------------------------------------------------------------------
Obj1F_MapUnc_10F0C:	include "mappings/sprite/obj1F_a.asm"

; Slope data for platforms.
;byte_10FDC:
Obj1A_OOZ_SlopeData:
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
;byte_10FEC:
Obj1A_HPZ_SlopeData
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
	even
; ----------------------------------------------------------------------------
; sprite mappings (HPZ)
; ----------------------------------------------------------------------------
Obj1A_MapUnc_1101C:	include "mappings/sprite/obj1A_b.asm"
; ----------------------------------------------------------------------------
; sprite mappings (OOZ)
; ----------------------------------------------------------------------------
Obj1F_MapUnc_110C6:	include "mappings/sprite/obj1F_b.asm"
; -------------------------------------------------------------------------------
; sprite mappings (MCZ)
; -------------------------------------------------------------------------------
Obj1F_MapUnc_11106:	include "mappings/sprite/obj1F_c.asm"
; -------------------------------------------------------------------------------
; sprite mappings (ARZ)
; -------------------------------------------------------------------------------
Obj1F_MapUnc_1115E:	include "mappings/sprite/obj1F_d.asm"
; ===========================================================================
	include "_incObj/1C Bridge Stake and Falling Oil.asm"
	include "_incObj/71 Bridge Stake and Pulsing Orb.asm"
; ===========================================================================
	include "_anim/HPZ Stake and Orb.asm"

; --------------------------------------------------------------------------------
; sprite mappings
; --------------------------------------------------------------------------------
Obj71_MapUnc_11396:	include "mappings/sprite/obj71_a.asm"
; ----------------------------------------------------------------------------------------
; Unknown sprite mappings
; ----------------------------------------------------------------------------------------
Obj1C_MapUnc_113D6:	include "mappings/sprite/obj1C_a.asm"
Obj1C_MapUnc_113EE:	include "mappings/sprite/obj1C_b.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj1C_MapUnc_11406:	include "mappings/sprite/obj1C_c.asm"
Obj1C_MapUnc_114AE:	include "mappings/sprite/obj1C_d.asm"
Obj1C_MapUnc_11552:	include "mappings/sprite/obj1C_e.asm"
Obj71_MapUnc_11576:	include "mappings/sprite/obj71_b.asm"
; ===========================================================================

	include "_incObj/2A MCZ Stomper.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj2A_MapUnc_11666:	include "mappings/sprite/obj2A.asm"
; ===========================================================================

	include "_incObj/2D CPZ One Way Barrier.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj2D_MapUnc_11822:	include "mappings/sprite/obj2D.asm"
; ===========================================================================

	include "_incObj/28 Animals.asm"
; ===========================================================================
	include "_incObj/29 Points.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj28_MapUnc_11E1C:	include "mappings/sprite/obj28_a.asm"
Obj28_MapUnc_11E40:	include "mappings/sprite/obj28_b.asm"
Obj28_MapUnc_11E64:	include "mappings/sprite/obj28_c.asm"
Obj28_MapUnc_11E88:	include "mappings/sprite/obj28_d.asm"
Obj28_MapUnc_11EAC:	include "mappings/sprite/obj28_e.asm"
Obj29_MapUnc_11ED0:	include "mappings/sprite/obj29.asm"

; ===========================================================================
	include "_incObj/25 & 37 Rings.asm" ; also includes the dead code for Sonic 1's Big Rings
; ===========================================================================
	include "_anim/Rings.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj25_MapUnc_12382:	include "mappings/sprite/Rings.asm"

; ===========================================================================
	include "_incObj/DC CNZ Ring Prize.asm"
; ===========================================================================
	include "_incObj/26 Monitor.asm"
; ===========================================================================
	include "_incObj/2E Monitor Contents.asm"
; ===========================================================================
	include "_anim/Monitors.asm"
; ---------------------------------------------------------------------------------
; Sprite Mappings - Sprite table for monitor and monitor contents (26, ??)
; ---------------------------------------------------------------------------------
; MapUnc_12D36: MapUnc_obj26:
Obj26_MapUnc_12D36:	include "mappings/sprite/obj26.asm"
; ===========================================================================

	include "_incObj/0E Title Screen Animations.asm"
; ===========================================================================
	include "_incObj/C9 Title Screen Palette Changing Handler.asm"

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


TitleScreen_SetFinalState:
	tst.b	obj0e_intro_complete(a0)
	bne.w	+	; rts

	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_up_mask|button_down_mask|button_left_mask|button_right_mask|button_B_mask|button_C_mask|button_A_mask,(Ctrl_1_Press).w
	andi.b	#button_start_mask,d0
	beq.w	+	; rts

	; Initialise Sonic object.
	st.b	obj0e_intro_complete(a0)
	move.b	#$10,routine_secondary(a0)
	move.b	#$12,mapping_frame(a0)
	move.w	#spriteScreenPositionXCentered(-24),x_pixel(a0)
	move.w	#spriteScreenPositionYCentered(-88),y_pixel(a0)

	; Initialise Sonic's hand object.
	lea	(IntroSonicHand).w,a1
	bsr.w	TitleScreen_InitSprite
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#$A,routine(a1)
	move.w	#2*$80,priority(a1)
	move.b	#9,mapping_frame(a1)
	move.b	#4,routine_secondary(a1)
	move.w	#spriteScreenPositionXCentered(33),x_pixel(a1)
	move.w	#spriteScreenPositionYCentered(-47),y_pixel(a1)

	; Initialise Tails object.
	lea	(IntroTails).w,a1
	bsr.w	TitleScreen_InitSprite
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#4,routine(a1)
	move.b	#4,mapping_frame(a1)
	move.b	#6,routine_secondary(a1)
	move.w	#3*$80,priority(a1)
	move.w	#spriteScreenPositionXCentered(-88),x_pixel(a1)
	move.w	#spriteScreenPositionYCentered(-80),y_pixel(a1)

	; Initialise Tails' hand object.
	lea	(IntroTailsHand).w,a1
	bsr.w	TitleScreen_InitSprite
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#$10,routine(a1)
	move.w	#2*$80,priority(a1)
	move.b	#$13,mapping_frame(a1)
	move.b	#4,routine_secondary(a1)
	move.w	#spriteScreenPositionXCentered(-19),x_pixel(a1)
	move.w	#spriteScreenPositionYCentered(-31),y_pixel(a1)

	; Initialise top-of-emblem object.
	lea	(IntroEmblemTop).w,a1
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#6,subtype(a1)

	; Initialise sprite mask object.
	bsr.w	Obj0E_LoadMaskingSprite

	; Initialise title screen menu object.
	move.b	#ObjID_TitleMenu,(TitleScreenMenu+id).w

	; Delete palette-changer object.
	lea	(TitleScreenPaletteChanger).w,a1
	bsr.w	DeleteObject2

	; Load palette line 4.
	lea	Pal_1342C(pc),a1
	lea	(Normal_palette_line4).w,a2
	moveq	#bytesToLcnt(palette_line_size),d6
-	move.l	(a1)+,(a2)+
	dbf	d6,-

	; Load palette line 3.
	lea	Pal_1340C(pc),a1
	lea	(Normal_palette_line3).w,a2
	moveq	#bytesToLcnt(palette_line_size),d6
-	move.l	(a1)+,(a2)+
	dbf	d6,-

	; Load palette line 1.
	lea	Pal_133EC(pc),a1
	lea	(Normal_palette).w,a2
	moveq	#bytesToLcnt(palette_line_size),d6
-	move.l	(a1)+,(a2)+
	dbf	d6,-

	; Play title screen music if it isn't already playing.
	tst.b	obj0e_music_playing(a0)
	bne.s	+
	moveq	#MusID_Title,d0
	jmp	(PlayMusic).w
+
	rts
; End of function TitleScreen_SetFinalState


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; sub_135EA:
TitleScreen_InitSprite:
	move.l	#Obj0E_MapUnc_136A8,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_TitleSprites,0,0),art_tile(a1)
	move.w	#4*$80,priority(a1)
	rts
; End of function TitleScreen_InitSprite

; ===========================================================================
	include "_incObj/0F Title Screen Menu.asm"
; ===========================================================================
	include "_anim/Title Screen.asm"
; -----------------------------------------------------------------------------
; Sprite Mappings - Flashing stars from intro (Obj0E)
; -----------------------------------------------------------------------------
Obj0E_MapUnc_136A8:	include "mappings/sprite/obj0E.asm"
; -----------------------------------------------------------------------------
; Sprite Mappings - Menu
; -----------------------------------------------------------------------------
Obj0F_MapUnc_13B70:	include "mappings/sprite/obj0F.asm"

; ===========================================================================
	include "_incObj/34 Title Cards.asm"
; ===========================================================================
;byte_13F62:
Animal_PLCTable: zoneOrderedTable 1,1
	zoneTableEntry.b PLCID_EhzAnimals	; EHZ
	zoneTableEntry.b PLCID_EhzAnimals	; Zone 1
	zoneTableEntry.b PLCID_EhzAnimals	; WZ
	zoneTableEntry.b PLCID_EhzAnimals	; Zone 3
	zoneTableEntry.b PLCID_MtzAnimals	; MTZ1,2
	zoneTableEntry.b PLCID_MtzAnimals	; MTZ3
	zoneTableEntry.b PLCID_WfzAnimals	; WFZ
	zoneTableEntry.b PLCID_HtzAnimals	; HTZ
	zoneTableEntry.b PLCID_HpzAnimals	; HPZ
	zoneTableEntry.b PLCID_HpzAnimals	; Zone 9
	zoneTableEntry.b PLCID_OozAnimals	; OOZ
	zoneTableEntry.b PLCID_MczAnimals	; MCZ
	zoneTableEntry.b PLCID_CnzAnimals	; CNZ
	zoneTableEntry.b PLCID_CpzAnimals	; CPZ
	zoneTableEntry.b PLCID_DezAnimals	; DEZ
	zoneTableEntry.b PLCID_ArzAnimals	; ARZ
	zoneTableEntry.b PLCID_SczAnimals	; SCZ
    zoneTableEnd

	dc.b PLCID_SczAnimals	; level slot $11 (non-existent), not part of main table
	even

; ===========================================================================
	include "_incObj/39 Game Over.asm"
; ===========================================================================
	include "_incObj/3A Got Through Card.asm"
; ===========================================================================
	include "_inc/Level Order.asm"

results_screen_object macro startx, targetx, y, routine, frame
	dc.w	startx, targetx, spriteScreenPositionYCentered(y)
	dc.b	routine, frame
    endm

results_screen_object_size = 8

; byte_14380:
Obj3A_SubObjectMetadata:
	;                               start X,          target X, start Y, routine, map frame
	results_screen_object  spriteScreenPositionX(            0-96), spriteScreenPositionXCentered(  0),     -56,       2,         0
	results_screen_object  spriteScreenPositionX( screen_width+64), spriteScreenPositionXCentered(-32),     -38,       4,         3
	results_screen_object  spriteScreenPositionX(screen_width+128), spriteScreenPositionXCentered( 32),     -38,       6,         4
	results_screen_object  spriteScreenPositionX(screen_width+184), spriteScreenPositionXCentered( 88),     -50,       8,         6
	results_screen_object  spriteScreenPositionX(screen_width+400), spriteScreenPositionXCentered(  0),      48,       4,         9
	results_screen_object  spriteScreenPositionX(screen_width+352), spriteScreenPositionXCentered(  0),       0,       4,        $A
	results_screen_object  spriteScreenPositionX(screen_width+368), spriteScreenPositionXCentered(  0),      16,       4,        $B
	results_screen_object  spriteScreenPositionX(screen_width+384), spriteScreenPositionXCentered(  0),      32,     $16,        $E
Obj3A_SubObjectMetadata_End:
; ===========================================================================

	include "mappings/sprite/Title Cards.asm"

; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj39_MapUnc_14C6C:	include "mappings/sprite/obj39.asm"

	include "mappings/sprite/Got Through.asm"
; ===========================================================================

;loc_15584: ; level title card drawing function called from Vint
DrawLevelTitleCard:
	lea	(VDP_data_port).l,a6
	tst.w	(TitleCard_ZoneName+titlecard_leaveflag).w
	bne.w	loc_15670
	moveq	#$3F,d5
	move.l	#make_block_tile_pair(ArtTile_ArtNem_TitleCard+$5A,0,0,0,1),d6

loc_155A8:
	lea	(TitleCard_Background+titlecard_vram_dest).w,a0
;	moveq	#1,d7	; Once for P1, once for P2 (if in 2p mode)

loc_155AE:
	move.w	(a0)+,d0
	beq.s	loc_155C6
	clr.w	-2(a0)
	bsr.w	sub_15792
	move.l	d0,VDP_control_port-VDP_data_port(a6)
	move.w	d5,d4

loc_155C0:
	move.l	d6,(a6)
	dbf	d4,loc_155C0

loc_155C6:
;	dbf	d7,loc_155AE
	moveq	#$26,d1
	sub.w	(TitleCard_Bottom+titlecard_split_point).w,d1
	lsr.w	#1,d1
	subq.w	#1,d1
	moveq	#7,d5
	move.l	#make_block_tile_pair(ArtTile_ArtNem_TitleCard+$5C,0,0,1,1),d6

loc_155EA:
	lea	(TitleCard_Bottom+titlecard_vram_dest).w,a0
;	moveq	#1,d7	; Once for P1, once for P2 (if in 2p mode)

loc_155F0:
	move.w	(a0)+,d0
	beq.s	loc_15614
	clr.w	-2(a0)
	bsr.w	sub_15792
	move.w	d5,d4

loc_155FE:
	move.l	d0,VDP_control_port-VDP_data_port(a6)
	move.w	d1,d3

loc_15604:
	move.l	d6,(a6)
	dbf	d3,loc_15604
	addi.l	#vdpCommDelta(gameplay_plane_width/tile_width*2),d0
	dbf	d4,loc_155FE

loc_15614:
;	dbf	d7,loc_155F0
	move.w	(TitleCard_Left+titlecard_split_point).w,d1 ; horizontal draw from left until this position
	subq.w	#1,d1
	moveq	#$D,d5
	move.l	#make_block_tile_pair(ArtTile_ArtNem_TitleCard+$58,0,0,0,1),d6 ; VRAM location of graphic to fill on left side

loc_15634:
	lea	(TitleCard_Left+titlecard_vram_dest).w,a0 ; obj34 red title card left side part
;	moveq	#1,d7	; Once for P1, once for P2 (if in 2p mode)
	move.w	#$8F80,VDP_control_port-VDP_data_port(a6)	; VRAM pointer increment: $0080

loc_15640:
	move.w	(a0)+,d0
	beq.s	loc_15664
	clr.w	-2(a0)
	bsr.w	sub_15792
	move.w	d1,d4

loc_1564E:
	move.l	d0,VDP_control_port-VDP_data_port(a6)
	move.w	d5,d3

loc_15654:
	move.l	d6,(a6)
	dbf	d3,loc_15654
	addi.l	#vdpCommDelta($0002),d0
	dbf	d4,loc_1564E

loc_15664:
;	dbf	d7,loc_15640
	move.w	#$8F02,VDP_control_port-VDP_data_port(a6)	; VRAM pointer increment: $0002
	rts
; ===========================================================================

loc_15670:
	moveq	#9,d3
	moveq	#3,d4
	move.l	#make_block_tile_pair(ArtTile_ArtNem_TitleCard+$5A,0,0,0,1),d5
	move.l	#make_block_tile_pair(ArtTile_ArtNem_TitleCard+$5C,0,0,1,1),d6
+
	lea	(TitleCard_Left+titlecard_vram_dest).w,a0
;	moveq	#1,d7	; Once for P1, once for P2 (if in 2p mode)
	move.w	#$8F80,VDP_control_port-VDP_data_port(a6)	; VRAM pointer increment: $0080

loc_156A2:
	move.w	(a0)+,d0
	beq.s	loc_156CE
	clr.w	-2(a0)
	bsr.w	sub_15792
	moveq	#3,d2

loc_156B0:
	move.l	d0,VDP_control_port-VDP_data_port(a6)

	move.w	d3,d1
-	move.l	d5,(a6)
	dbf	d1,-

	move.w	d4,d1
-	move.l	d6,(a6)
	dbf	d1,-

	addi.l	#vdpCommDelta($0002),d0
	dbf	d2,loc_156B0

loc_156CE:
;	dbf	d7,loc_156A2
	move.w	#$8F02,VDP_control_port-VDP_data_port(a6)	; VRAM pointer increment: $0002
	moveq	#7,d5
	move.l	#make_block_tile_pair(ArtTile_ArtNem_TitleCard+$5A,0,0,0,1),d6
+
	lea	(TitleCard_Bottom+titlecard_vram_dest).w,a0
;	moveq	#1,d7	; Once for P1, once for P2 (if in 2p mode)

loc_156F4:
	move.w	(a0)+,d0
	beq.s	loc_15714
	clr.w	-2(a0)
	bsr.w	sub_15792

	move.w	d5,d4
-	move.l	d0,VDP_control_port-VDP_data_port(a6)
	move.l	d6,(a6)
	move.l	d6,(a6)
	addi.l	#vdpCommDelta(gameplay_plane_width/tile_width*2),d0
	dbf	d4,-

loc_15714:
;	dbf	d7,loc_156F4
	move.w	(TitleCard_Background+titlecard_vram_dest).w,d4
	beq.s	loc_1578C
	; Initialize plane A for both players; we have to do this here as otherwise
	; it will appear corrupted when the title card leaves.
	lea	VDP_control_port-VDP_data_port(a6),a5

loc_15758:
	lea	(Camera_X_pos).w,a3
	lea	(Level_Layout).w,a4
	move.w	#vdpComm(VRAM_Plane_A_Name_Table,VRAM,WRITE)>>16,d2
	move.w	(TitleCard_Background+titlecard_vram_dest).w,d4

	moveq	#2-1,d6 ; Do two rows
-	movem.l	d4-d6,-(sp)
	moveq	#-16,d5
	move.w	d4,d1
	bsr.w	CalculateVRAMAddressOfBlockForPlayer1
	move.w	d1,d4
	moveq	#-16,d5
	moveq	#64/2-1,d6
	bsr.w	DrawBlockRow_CustomWidth
	movem.l	(sp)+,d4-d6
	addi.w	#16,d4
	dbf	d6,-

loc_1578C:
	clr.w	(TitleCard_Background+titlecard_vram_dest).w
	rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to convert a VRAM address into a 32-bit VRAM write command word
; Input:
;	d0	VRAM address (word)
; Output:
;	d0	32-bit VDP command word for a VRAM write to specified address.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_15792:
	andi.l	#$FFFF,d0
	lsl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d0
	swap	d0
	rts
; End of function sub_15792

; ===========================================================================
; loc_157D2:
LoadTitleCard:
	lea	(ArtNem_TitleCard).l,a1
	move.w	#tiles_to_bytes(ArtTile_ArtNem_TitleCard),d2
	jsr	(Queue_KosPlus_Module).w
	lea	(ArtNem_TitleCard2).l,a0
	lea	(Level_Layout).w,a1
	jsr	(KosPlusDec).w
	moveq	#0,d0
	move.b	(Current_Zone).w,d0
	move.b	Off_TitleCardLetters(pc,d0.w),d0
	lea	TitleCardLetters(pc),a0
	lea	(a0,d0.w),a0
	move.l	#vdpComm(tiles_to_bytes(ArtTile_LevelName),VRAM,WRITE),d0

loc_157EC:
	move	#$2700,sr
	lea	(Level_Layout).w,a1
	lea	(VDP_data_port).l,a6
	move.l	d0,4(a6)

loc_157FE:
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	loc_1581A
	lsl.w	#5,d0
	lea	(a1,d0.w),a2
	moveq	#0,d1
	move.b	(a0)+,d1
	lsl.w	#3,d1
	subq.w	#1,d1

loc_15812:
	move.l	(a2)+,(a6)
	dbf	d1,loc_15812
	bra.s	loc_157FE
; ===========================================================================

loc_1581A:
	move	#$2300,sr
	rts
; ===========================================================================
; byte_15820:
Off_TitleCardLetters: zoneOrderedTable 1,1
	zoneTableEntry.b TitleCardLetters_EHZ - TitleCardLetters	; EHZ
	zoneTableEntry.b TitleCardLetters_EHZ - TitleCardLetters	; Zone 1
	zoneTableEntry.b TitleCardLetters_EHZ - TitleCardLetters	; WZ
	zoneTableEntry.b TitleCardLetters_EHZ - TitleCardLetters	; Zone 3
	zoneTableEntry.b TitleCardLetters_MTZ - TitleCardLetters	; MTZ1,2
	zoneTableEntry.b TitleCardLetters_MTZ - TitleCardLetters	; MTZ3
	zoneTableEntry.b TitleCardLetters_WFZ - TitleCardLetters	; WFZ
	zoneTableEntry.b TitleCardLetters_HTZ - TitleCardLetters	; HTZ
	zoneTableEntry.b TitleCardLetters_HPZ - TitleCardLetters	; HPZ
	zoneTableEntry.b TitleCardLetters_EHZ - TitleCardLetters	; Zone 9
	zoneTableEntry.b TitleCardLetters_OOZ - TitleCardLetters	; OOZ
	zoneTableEntry.b TitleCardLetters_MCZ - TitleCardLetters	; MCZ
	zoneTableEntry.b TitleCardLetters_CNZ - TitleCardLetters	; CNZ
	zoneTableEntry.b TitleCardLetters_CPZ - TitleCardLetters	; CPZ
	zoneTableEntry.b TitleCardLetters_DEZ - TitleCardLetters	; DEZ
	zoneTableEntry.b TitleCardLetters_ARZ - TitleCardLetters	; ARZ
	zoneTableEntry.b TitleCardLetters_SCZ - TitleCardLetters	; SCZ
    zoneTableEnd
	even

 ; temporarily remap characters to title card letter format
 ; Characters are encoded as Aa, Bb, Cc, etc. through a macro
 charset 'A',0	; can't have an embedded 0 in a string
 charset 'B',"\4\8\xC\4\x10\x14\x18\x1C\x1E\x22\x26\x2A\4\4\x30\x34\x38\x3C\x40\x44\x48\x4C\x52\x56\4"
 charset 'a',"\4\4\4\4\4\4\4\4\2\4\4\4\6\4\4\4\4\4\4\4\4\4\6\4\4"
 charset '.',"\x5A"

; Defines which letters load for the continue screen
; Each letter occurs only once, and the letters ENOZ (i.e. ZONE) aren't loaded here
; However, this is hidden by the titleLetters macro, and normal titles can be used
; (the macro is defined near SpecialStage_ResultsLetters, which uses it before here)
; The actual mappings for zone title cards are found at MapUnc_TitleCards

; word_15832:
TitleCardLetters:

TitleCardLetters_EHZ:
	titleLetters	"EMERALD HILL"
TitleCardLetters_MTZ:
	titleLetters	"METROPOLIS"
TitleCardLetters_HTZ:
	titleLetters	"HILL TOP"
TitleCardLetters_HPZ:
	titleLetters	"HIDDEN PALACE"
TitleCardLetters_OOZ:
	titleLetters	"OIL OCEAN"
TitleCardLetters_MCZ:
	titleLetters	"MYSTIC CAVE"
TitleCardLetters_CNZ:
	titleLetters	"CASINO NIGHT"
TitleCardLetters_CPZ:
	titleLetters	"CHEMICAL PLANT"
TitleCardLetters_ARZ:
	titleLetters	"AQUATIC RUIN"
TitleCardLetters_SCZ:
	titleLetters	"SKY CHASE"
TitleCardLetters_WFZ:
	titleLetters	"WING FORTRESS"
TitleCardLetters_DEZ:
	titleLetters	"DEATH EGG"

 charset ; revert character set

; ===========================================================================
	include "_incObj/36 Spikes.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj36_MapUnc_15B68:	include "mappings/sprite/obj36.asm"
; ===========================================================================
	include "_incObj/3B Purple Rock.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; Unused sprite mappings
; -------------------------------------------------------------------------------
Obj3B_MapUnc_15D2E:	include "mappings/sprite/obj3B.asm"
; ===========================================================================
	include "_incObj/3C Smashable Wall.asm"
; -------------------------------------------------------------------------------
; Unused sprite mappings
; -------------------------------------------------------------------------------
Obj3C_MapUnc_15ECC:	include "mappings/sprite/obj3C.asm"
; ===========================================================================

	include "_incObj/sub RunObjects.asm"
; ===========================================================================
	include "_inc/Object Pointers.asm" ; also includes the null object

	include "_incObj/sub ObjectMove.asm" ; also ObjectMoveAndFall
	include "_incObj/sub DeleteObject.asm" ; also MarkObjGone
	include "_incObj/sub DisplaySprite.asm"
	include "_incObj/sub AnimateSprite.asm"

	include "_inc/BuildSprites.asm" ; also DrawSprites and the 2P versions
; ===========================================================================
	include "_inc/Rings Manager.asm"
; ===========================================================================
	include "_inc/CNZ Bumpers.asm"
; ===========================================================================
SpecialCNZBumpers_Act1:
	dc.w	0, 0, 0
	BINCLUDE	"level/objects/CNZ 1 bumpers.bin"	; byte_1781A

SpecialCNZBumpers_Act2:
	BINCLUDE	"level/objects/CNZ 2 bumpers.bin"	; byte_1795E
; ===========================================================================
	include "_inc/Objects Manager.asm"

;---------------------------------------------------------------------------------------
; CNZ object layouts for 2-player mode (various objects were deleted)
;---------------------------------------------------------------------------------------

; Macro for marking the boundaries of an object layout file
ObjectLayoutBoundary macro
	dc.w	$FFFF, $0000, $0000
    endm

	ObjectLayoutBoundary

    ; a Crawl badnik was moved slightly further away from a ledge
    ; 2 flippers were moved closer to a wall
Objects_CNZ1_2P:	BINCLUDE	"level/objects/CNZ_1_2P.bin"


	ObjectLayoutBoundary

    ; 4 Crawl badniks were slightly moved, placing them closer/farther away from ledges
    ; 2 flippers were moved away from a wall to keep players from getting stuck behind them
Objects_CNZ2_2P:	BINCLUDE	"level/objects/CNZ_2_2P.bin"

	ObjectLayoutBoundary

; ===========================================================================
	include "_incObj/41 Springs.asm"
	include "_anim/Springs.asm"
	include "mappings/sprite/Springs.asm"
; ===========================================================================

	include "_incObj/0D Signpost.asm"
; ===========================================================================
	include "_anim/Signpost.asm"
; -------------------------------------------------------------------------------
; sprite mappings - Primary sprite table for object 0D (signpost)
; -------------------------------------------------------------------------------
; SprTbl_0D_Primary:
Obj0D_MapUnc_195BE:	include "mappings/sprite/obj0D_a.asm"
; -------------------------------------------------------------------------------
; sprite mappings - Secondary sprite table for object 0D (signpost)
; -------------------------------------------------------------------------------
; SprTbl_0D_Scndary:
Obj0D_MapUnc_19656:	include "mappings/sprite/obj0D_b.asm"
; -------------------------------------------------------------------------------
; dynamic pattern loading cues
; -------------------------------------------------------------------------------
Obj0D_MapRUnc_196EE:	include "mappings/spriteDPLC/obj0D.asm"
; ===========================================================================

	include "_incObj/sub SolidObject.asm" ; also SlopedSolid
; ===========================================================================
	include "_incObj/sub MvSonicOnPtfm.asm" ; also MvSonicOnSlope
; ===========================================================================
	include "_incObj/sub PlatformObject.asm" ; also SlopedPlatform
; ===========================================================================
	include "_incObj/01 Sonic.asm" ; Needs to be broken up further!
; ===========================================================================
	include "_anim/Sonic.asm"
	include "_incObj/sub LoadSonicDynPLC.asm"
; ===========================================================================
	include "_incObj/02 Tails.asm" ; Needs to be broken up further!
; ===========================================================================
	include "_anim/Tails.asm"
	include "_incObj/sub LoadTailsDynPLC.asm" ; also LoadTailsTailsDynPLC
; ===========================================================================
	include "_incObj/05 Tails' Tails.asm"
	include "_anim/Tails' Tails.asm"
; ===========================================================================
	include "_incObj/0A Bubbles & Drowning Countdown.asm"
; ===========================================================================
	include "_incObj/sub ResumeMusic.asm"
; ===========================================================================
	include "_anim/Bubbles.asm"
; ===========================================================================
	include "_incObj/38 Shield.asm"
; ===========================================================================
	include "_incObj/35 Invincibility Stars.asm"
; ===========================================================================
Ani_obj35:	include "_anim/Invincibility Stars.asm"
	include "_anim/Shield.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj38_MapUnc_1DBE4:	include "mappings/sprite/obj38.asm"
Obj35_MapUnc_1DCBC:	include "mappings/sprite/obj35.asm"

; ===========================================================================
	include "_incObj/08 Splash & Dust.asm"
; ===========================================================================
	include "_anim/Splash & Dust.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj08_MapUnc_1DF5E:	include "mappings/sprite/obj08.asm"
; -------------------------------------------------------------------------------
; dynamic pattern loading cues
; -------------------------------------------------------------------------------
Obj08_MapRUnc_1E074:	include "mappings/spriteDPLC/obj08.asm"
; ===========================================================================
	include "_incObj/7E Super Sonic's Stars.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj7E_MapUnc_1E1BE:	include "mappings/sprite/obj7E.asm"
; ===========================================================================

	include "_incObj/Sonic AnglePos.asm"
; ===========================================================================
	include "_incObj/sub FindTile.asm" ; also FindFloor and FindWall

	include "_incObj/sub CalcRoom.asm" ; InFront and OverHead
	include "_incObj/sub CheckFloor.asm" ; also Walls and Ceilings
; ===========================================================================
	include "_incObj/79 Starpost.asm"
; ===========================================================================
	include "_anim/Starpost.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj79_MapUnc_1F424:	include "mappings/sprite/obj79_a.asm"
Obj79_MapUnc_1F4A0:	include "mappings/sprite/obj79_b.asm"
; ===========================================================================
	include "_incObj/79 Starpost (Part 2).asm" ; Stars for Special Stage entrance
; ===========================================================================
	include "_incObj/7D Hidden Bonuses.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; Unused sprite mappings
; -------------------------------------------------------------------------------
Obj7D_MapUnc_1F6FE:	include "mappings/sprite/obj7D.asm"
; ===========================================================================
	include "_incObj/44 Bumper.asm"
; ===========================================================================
	include "_anim/Bumper.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj44_MapUnc_1F85A:	include "mappings/sprite/obj44.asm"
; ===========================================================================
	include "_incObj/24 ARZ Bubbles.asm"
; ===========================================================================
	include "_anim/ARZ Bubbles.asm"
	include "mappings/sprite/ARZ Bubbles.asm"
; ===========================================================================
	include "_incObj/03 Collision Switcher.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj03_MapUnc_1FFB8:	include "mappings/sprite/obj03.asm"
; ===========================================================================
	include "_incObj/0B CPZ Pipe.asm"
; ===========================================================================
	include "_anim/CPZ Pipe.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj0B_MapUnc_201A0:	include "mappings/sprite/obj0B.asm"
; ===========================================================================
	include "_incObj/0C Small Floating Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; Unused sprite mappings
; ----------------------------------------------------------------------------
Obj0C_MapUnc_202FA:	include "mappings/sprite/obj0C.asm"
; ===========================================================================
	include "_incObj/12 HPZ Emerald.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings (unused)
; -------------------------------------------------------------------------------
Obj12_MapUnc_20382:	include "mappings/sprite/obj12.asm"
; ===========================================================================
	include "_incObj/13 HPZ Waterfall.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings (unused)
; -------------------------------------------------------------------------------
Obj13_MapUnc_20528:	include "mappings/sprite/obj13.asm"
; ===========================================================================
	include "_incObj/04 Water Surface.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj04_MapUnc_20A0E:	include "mappings/sprite/obj04_a.asm"
Obj04_MapUnc_20AFE:	include "mappings/sprite/obj04_b.asm"
; ===========================================================================
	include "_incObj/49 EHZ Waterfall.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj49_MapUnc_20C50:	include "mappings/sprite/obj49.asm"
; ===========================================================================
	include "_incObj/31 Lava Collision Maker.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj31_MapUnc_20E74:	include "mappings/sprite/obj31_b.asm"
; ===========================================================================
	include "_incObj/74 Invisible Solid Block.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj74_MapUnc_20F66:	include "mappings/sprite/obj74.asm"
; ===========================================================================
	include "_incObj/7C Pylon.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj7C_MapUnc_2103C:	include "mappings/sprite/obj7C.asm"
; ===========================================================================
	include "_incObj/27 Explosion.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj27_MapUnc_21120:	include "mappings/sprite/obj27.asm"
; ===========================================================================
	include "_incObj/84 Pinball Mode Trigger.asm"
	include "_incObj/8B WFZ Cycling Palette Switcher.asm"
; ===========================================================================
	include "_incObj/06 Corkscrew.asm" ; EHZ spiral path and MTZ rotating cylinder
; ===========================================================================
	include "_incObj/14 Seesaw.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj14_MapUnc_21CF0:	include "mappings/sprite/obj14_a.asm"
Obj14_MapUnc_21D7C:	include "mappings/sprite/obj14_b.asm"
; ===========================================================================
	include "_incObj/16 HTZ Diagonal Lift.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj16_MapUnc_21F14:	include "mappings/sprite/obj16.asm"
; ===========================================================================
	include "_incObj/19 Moving Platforms.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj19_MapUnc_2222A:	include "mappings/sprite/obj19.asm"
; ===========================================================================
	include "_incObj/1B CPZ Speed Booster.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj1B_MapUnc_223E2:	include "mappings/sprite/obj1B.asm"
; ===========================================================================
	include "_incObj/1D CPZ Blue Balls.asm"
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj1D_MapUnc_22576:	include "mappings/sprite/obj1D.asm"
; ===========================================================================
	include "_incObj/1E CPZ Spin Tube.asm"
; ===========================================================================
obj1E67Size macro {INTLABEL}
__LABEL__ label *
	dc.w __LABEL___End-__LABEL__-2
	endm
; -------------------------------------------------------------------------------
; spin tube data - entry/exit
; -------------------------------------------------------------------------------
; off_22980:
	include	"misc/obj1E_a.asm"
; -------------------------------------------------------------------------------
; spin tube data - main tube
; -------------------------------------------------------------------------------
; off_22E88:
	include	"misc/obj1E_b.asm"
; ===========================================================================
	include "_incObj/20 HTZ Boss Lava Bubble.asm"
; ===========================================================================
	include "_anim/HTZ Boss Lava Bubble.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj20_MapUnc_23254:	include "mappings/sprite/obj20_a.asm"
Obj20_MapUnc_23294:	include "mappings/sprite/obj20_b.asm"
; ===========================================================================
	include "_incObj/2F & 32 Smashable Ground & Blocks.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj2F_MapUnc_236FA:	include "mappings/sprite/obj2F.asm"
Obj32_MapUnc_23852:	include "mappings/sprite/obj32_a.asm"
Obj32_MapUnc_23886:	include "mappings/sprite/obj32_b.asm"
; ===========================================================================
	include "_incObj/30 HTZ Quake Lava.asm"
; ===========================================================================
	include "_incObj/33 OOZ Green Platform.asm"
; ===========================================================================
	include "_anim/OOZ Green Platform.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj33_MapUnc_23DDC:	include "mappings/sprite/obj33_a.asm"
Obj33_MapUnc_23DF0:	include "mappings/sprite/obj33_b.asm"
; ===========================================================================
	include "_incObj/43 OOZ Sliding Spikes.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj43_MapUnc_23FE0:	include "mappings/sprite/obj43.asm"
; ===========================================================================
	include "_incObj/07 Oil Ocean.asm"
; ===========================================================================
	include "_incObj/45 OOZ Pressure Spring.asm"
; ===========================================================================
	include "_anim/OOZ Pressure Spring.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj45_MapUnc_2451A:	include "mappings/sprite/obj45.asm"
; ===========================================================================
	include "_incObj/46 OOZ Ball.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; Unused sprite mappings
; ----------------------------------------------------------------------------
Obj46_MapUnc_24C52:	include "mappings/sprite/obj46.asm"
; ===========================================================================
	include "_incObj/47 Button.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj47_MapUnc_24D96:	include "mappings/sprite/obj47.asm"
; ===========================================================================
	include "_incObj/3D OOZ Smashable Launcher Cap.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj3D_MapUnc_250BA:	include "mappings/sprite/obj3D.asm"
; ===========================================================================
	include "_incObj/48 OOZ Cannon.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj48_MapUnc_254FE:	include "mappings/sprite/obj48.asm"
; ===========================================================================
	include "_incObj/22 ARZ Arrow Shooter.asm"
; ===========================================================================
	include "_anim/ARZ Arrow Shooter.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj22_MapUnc_25804:	include "mappings/sprite/obj22.asm"
; ===========================================================================
	include "_incObj/23 ARZ Falling Pillar.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj23_MapUnc_259E6:	include "mappings/sprite/obj23.asm"
; ===========================================================================
	include "_incObj/2B ARZ Rising Pillar.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj2B_MapUnc_25C6E:	include "mappings/sprite/obj2B.asm"
; ===========================================================================
	include "_incObj/2C ARZ Leaf Spawner.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj2C_MapUnc_2631E:	include "mappings/sprite/obj2C.asm"
; ===========================================================================
	include "_incObj/40 Springboard.asm"
	include "_anim/Springboard.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj40_MapUnc_265F4:	include "mappings/sprite/obj40.asm"
; ===========================================================================
	include "_incObj/42 MTZ Steam Spring.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj42_MapUnc_2686C:	include "mappings/sprite/obj42.asm"
; ===========================================================================
	include "_incObj/64 MTZ Twin Crusher.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj64_MapUnc_26A5C:	include "mappings/sprite/obj64.asm"
; ===========================================================================
	include "_incObj/65 MTZ Long Moving Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj65_Obj6A_Obj6B_MapUnc_26EC8:	include "mappings/sprite/obj65_a.asm"
Obj65_MapUnc_26F04:	include "mappings/sprite/obj65_b.asm"
; ===========================================================================
	include "_incObj/66 MTZ Spring Walls.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj66_MapUnc_27120:	include "mappings/sprite/obj66.asm"
; ===========================================================================
	include "_incObj/67 MTZ Spin Tube.asm"
; ===========================================================================
; MTZ tube position data
; off_273F2:
	include	"misc/obj67.asm"
	include "_anim/MTZ Spin Tube.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj67_MapUnc_27548:	include "mappings/sprite/obj67.asm"
; ===========================================================================
	include "_incObj/68 MTZ Harpoon Block.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj68_Obj6D_MapUnc_27750:	include "mappings/sprite/obj68.asm"
; ===========================================================================
	include "_incObj/6D MTZ Floor Harpoon.asm"
; ===========================================================================
	include "_incObj/69 Nut.asm" ; BLAME THE DISCORD FOR THIS ONE
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj69_MapUnc_27A26:	include "mappings/sprite/obj69.asm"
; ===========================================================================
	include "_incObj/6A MTZ Shifting Platform.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj6A_MapUnc_27D30:	include "mappings/sprite/obj6A.asm"
; ===========================================================================
	include "_incObj/6B MTZ Immobile Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj6B_MapUnc_2800E:	include "mappings/sprite/obj6B.asm"
; ===========================================================================
	include "_incObj/6C MTZ Pulley Platform.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj6C_MapUnc_28372:	include "mappings/sprite/obj6C.asm"
; ===========================================================================
	include "_incObj/6E MTZ Circular Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj6E_MapUnc_2852C:	include "mappings/sprite/obj6E.asm"
; ===========================================================================
	include "_incObj/70 MTZ Giant Cog.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj70_MapUnc_28786:	include "mappings/sprite/obj70.asm"
; ===========================================================================
	include "_incObj/72 CNZ Conveyor.asm"
; ===========================================================================
	include "_incObj/73 MCZ Rotating Platform (Unused).asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj73_MapUnc_28B9C:	include "mappings/sprite/obj73.asm"
; ===========================================================================
	include "_incObj/75 MCZ Brick.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj75_MapUnc_28D8A:	include "mappings/sprite/obj75.asm"
; ===========================================================================
	include "_incObj/76 MCZ Sliding Spikes.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj76_MapUnc_28F3A:	include "mappings/sprite/obj76.asm"
; ===========================================================================
	include "_incObj/77 MCZ Bridge.asm"
; ===========================================================================
	include "_anim/MCZ Bridge.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj77_MapUnc_29064:	include "mappings/sprite/obj77.asm"
; ===========================================================================
	include "_incObj/78 Staircase.asm"
; ===========================================================================
	include "_incObj/7A CPZ Sliding Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj7A_MapUnc_29564:	include "mappings/sprite/obj7A.asm"
; ===========================================================================
	include "_incObj/7B CPZ Spring Lid.asm"
; ===========================================================================
	include "_anim/CPZ Spring Lid.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj7B_MapUnc_29780:	include "mappings/sprite/obj7B.asm"
; ===========================================================================
	include "_incObj/7F MCZ Vine Switch.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj7F_MapUnc_29938:	include "mappings/sprite/obj7F.asm"
; ===========================================================================
	include "_incObj/80 MCZ Moving Vine.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj80_MapUnc_29C64:	include "mappings/sprite/obj80_a.asm"
Obj80_MapUnc_29DD0:	include "mappings/sprite/obj80_b.asm"
; ===========================================================================
	include "_incObj/81 MCZ Drawbridge.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj81_MapUnc_2A24E:	include "mappings/sprite/obj81.asm"
; ===========================================================================
	include "_incObj/82 ARZ Swinging Platform.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj82_MapUnc_2A476:	include "mappings/sprite/obj82.asm"
; ===========================================================================
	include "_incObj/83 ARZ Rotating Platform Triple.asm"
; ===========================================================================
	include "_incObj/3F OOZ Fan.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
; sidefacing fan
Obj3F_MapUnc_2AA12:	include "mappings/sprite/obj3F_a.asm"
; upfacing fan
Obj3F_MapUnc_2AAC4:	include "mappings/sprite/obj3F_b.asm"
; ===========================================================================
	include "_incObj/85 CNZ Pinball Plunger Spring.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj85_MapUnc_2B07E:	include "mappings/sprite/obj85_a.asm"
Obj85_MapUnc_2B0EC:	include "mappings/sprite/obj85_b.asm"
; ===========================================================================
	include "_incObj/86 CNZ Pinball Flipper.asm"
	include "_anim/CNZ Pinball Flipper.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj86_MapUnc_2B45A:	include "mappings/sprite/obj86.asm"
; ===========================================================================
	include "_incObj/D2 CNZ Snake Block.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjD2_MapUnc_2B694:	include "mappings/sprite/objD2.asm"
; ===========================================================================
	include "_incObj/D3 CNZ Bomb Prize.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjD3_MapUnc_2B8D4:	include "mappings/sprite/objD6_a.asm"
; ===========================================================================
	include "_incObj/D4 CNZ Big Block.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjD4_MapUnc_2B9CA:	include "mappings/sprite/objD4.asm"
; ===========================================================================
	include "_incObj/D5 CNZ Elevator.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjD5_MapUnc_2BB40:	include "mappings/sprite/objD5.asm"
; ===========================================================================
	include "_incObj/D6 CNZ Points Cage.asm"
	include "_anim/CNZ Points Cage.asm"
; ------------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------------
ObjD6_MapUnc_2BEBC:	include "mappings/sprite/objD6_b.asm"
; ===========================================================================
	include "_incObj/sub SlotMachine.asm"
; ===========================================================================
	include "_incObj/D7 CNZ Bumper.asm"
; ===========================================================================
	include "_anim/CNZ Bumper.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjD7_MapUnc_2C626:	include "mappings/sprite/objD7.asm"
; ===========================================================================
	include "_incObj/D8 CNZ Point Block.asm"
; ===========================================================================
	include "_anim/CNZ Point Block.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjD8_MapUnc_2C8C4:	include "mappings/sprite/objD8.asm"
; ===========================================================================
	include "_incObj/D9 Invisible Hang Flag.asm"
; ===========================================================================
	include "_incObj/4A Octus.asm"
; ===========================================================================
	include "_anim/Octus.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj4A_MapUnc_2CBFE:	include "mappings/sprite/obj4A.asm"
; ===========================================================================
	include "_incObj/50 Aquis.asm"
; ===========================================================================
	include "_anim/Aquis.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj50_MapUnc_2CF94:	include "mappings/sprite/obj50.asm"
; ===========================================================================
	include "_incObj/4B Buzzer.asm"
; ===========================================================================
	include "_anim/Buzzer.asm"
; ----------------------------------------------------------------------------
; sprite mappings -- Buzz Bomber Sprite Table
; ----------------------------------------------------------------------------
; MapUnc_2D2EA: SprTbl_Buzzer:
Obj4B_MapUnc_2D2EA:	include "mappings/sprite/obj4B.asm"
; ===========================================================================
	include "_incObj/5C Masher.asm"
; ===========================================================================
	include "_anim/Masher.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj5C_MapUnc_2D442:	include "mappings/sprite/obj5C.asm"
; ===========================================================================
	include "_incObj/58 Boss Explosions.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj58_MapUnc_2D50A:	include "mappings/sprite/obj58.asm"
; ===========================================================================
	include "_incObj/sub BossCommon.asm" ; bunch of common stuff for bosses, like damage and animation
; ===========================================================================
	include "_incObj/5D CPZ Boss.asm"

BranchTo2_JmpTo34_DisplaySprite ; BranchTo
JmpTo34_DisplaySprite ; JmpTo
	jmp	(DisplaySprite).l
JmpTo51_DeleteObject ; JmpTo
	jmp	(DeleteObject).l
; ===========================================================================
	include "_anim/CPZ Boss 1.asm"
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_CPZBoss
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2EADC:	include "mappings/sprite/obj5D_a.asm"

	include "_anim/CPZ Boss 2.asm"

; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_Eggpod
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2ED8C:	include "mappings/sprite/obj5D_b.asm"
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_EggpodJets
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2EE88:	include "mappings/sprite/obj5D_c.asm"
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_BossSmoke
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2EEA0:	include "mappings/sprite/obj5D_d.asm"
; ===========================================================================
	include "_incObj/56 EHZ Boss.asm"
; ===========================================================================
	include "_anim/EHZ Boss 1.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj56_MapUnc_2F970:	include "mappings/sprite/obj56_a.asm"
	; propeller
	; 7 frames
	include "_anim/EHZ Boss 2.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj56_MapUnc_2FA58:	include "mappings/sprite/obj56_b.asm"
	; ground vehicle
	; frame 0 = vehicle itself
	; frame 1-3 = spike
	; frame 4-5 = foreground wheel
	; frame 6-7 = background wheel
	include "_anim/EHZ Boss 3.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj56_MapUnc_2FAF8:	include "mappings/sprite/obj56_c.asm"
	; flying vehicle
	; frame 0 = bottom
	; frame 1-2 = top, normal
	; frame 3-4 = top, laughter
	; frame 5 = top, when hit
	; frame 6 = top, when flying off
; ===========================================================================
	include "_incObj/52 HTZ Boss.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_BossSmoke
; ----------------------------------------------------------------------------
Obj52_MapUnc_30258:	include "mappings/sprite/obj52_a.asm"
	include "_anim/HTZ Boss.asm"
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_Eggpod + ?
; ----------------------------------------------------------------------------
Obj52_MapUnc_302BC:	include "mappings/sprite/obj52_b.asm"
; ===========================================================================
	include "_incObj/89 ARZ Boss.asm"
; ===========================================================================
	include "_anim/ARZ Boss 1.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj89_MapUnc_30D68:	include "mappings/sprite/obj89_a.asm"
	include "_anim/ARZ Boss 2.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj89_MapUnc_30E04:	include "mappings/sprite/obj89_b.asm"
; ===========================================================================
	include "_incObj/57 MCZ Boss.asm"
; ===========================================================================
	include "_anim/MCZ Boss.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj57_MapUnc_316EC:	include "mappings/sprite/obj57.asm"
; ===========================================================================
	include "_incObj/51 CNZ Boss.asm"
; ===========================================================================
	include "_anim/CNZ Boss.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj51_MapUnc_320EA:	include "mappings/sprite/obj51.asm"
; ===========================================================================
	include "_incObj/53 & 54 MTZ Boss.asm" ; 54 is the boss, 53 are the shield orbs
; ===========================================================================
	include "_anim/MTZ Boss.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj54_MapUnc_32DC6:	include "mappings/sprite/obj54.asm"
; ===========================================================================
	include "_incObj/55 OOZ Boss.asm"
; ===========================================================================
	include "_anim/OOZ Boss.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj55_MapUnc_33756:	include "mappings/sprite/obj55.asm"
; ===========================================================================
	include "_incObj/sub LoadSubObject.asm"
	include "_incObj/sub ObjCommon.asm" ; Lots of common subroutines for objects in here
; ===========================================================================
	include "_incObj/8C Whisp.asm"
	include "_anim/Whisp.asm"
; ------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------
Obj8C_MapUnc_36A4E:	include "mappings/sprite/obj8C.asm"
; ===========================================================================
	include "_incObj/8D, 8F & 90 Grounder in Wall.asm" ; 8F is the wall, 90 is the debris
	include "_anim/Grounder in Wall.asm"
	include "mappings/sprite/obj8D_90.asm"
; ===========================================================================
	include "_incObj/91 Chop Chop.asm"
	include "_anim/Chop Chop.asm"
; --------------------------------------------------------------------------
; sprite mappings
; --------------------------------------------------------------------------
Obj91_MapUnc_36EF6:	include "mappings/sprite/obj91.asm"
; ===========================================================================
	include "_incObj/92 & 93 Spiker.asm" ; 93 is the drill it launches
	include "_anim/Spiker.asm"
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj92_Obj93_MapUnc_37092:	include "mappings/sprite/obj93.asm"
; ===========================================================================
	include "_incObj/95 Sol.asm"
; ===========================================================================
	include "_anim/Sol.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj95_MapUnc_372E6:	include "mappings/sprite/obj95.asm"

Invalid_SubObjData:

; ===========================================================================
	include "_incObj/94, 96 & 97 Rexon.asm" ; 97 is the head
; ------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------
Obj94_Obj98_MapUnc_37678:	include "mappings/sprite/obj97.asm"

; seems to be a lookup table for oscillating horizontal position offset
byte_376A8:
	dc.b $F,  0
	dc.b $F,$FF	; 1
	dc.b $F,$FF	; 2
	dc.b $F,$FE	; 3
	dc.b $F,$FD	; 4
	dc.b $F,$FC	; 5
	dc.b $E,$FC	; 6
	dc.b $E,$FB	; 7
	dc.b $E,$FA	; 8
	dc.b $E,$FA	; 9
	dc.b $D,$F9	; 10
	dc.b $D,$F8	; 11
	dc.b $C,$F8	; 12
	dc.b $C,$F7	; 13
	dc.b $C,$F6	; 14
	dc.b $B,$F6	; 15
	dc.b $B,$F5	; 16
	dc.b $A,$F5	; 17
	dc.b $A,$F4	; 18
	dc.b  9,$F4	; 19
	dc.b  8,$F4	; 20
	dc.b  8,$F3	; 21
	dc.b  7,$F3	; 22
	dc.b  6,$F2	; 23
	dc.b  6,$F2	; 24
	dc.b  5,$F2	; 25
	dc.b  4,$F2	; 26
	dc.b  4,$F1	; 27
	dc.b  3,$F1	; 28
	dc.b  2,$F1	; 29
	dc.b  1,$F1	; 30
	dc.b  1,$F1	; 31

; ===========================================================================
	include "_incObj/98 Projectile With Gravity.asm"
; ===========================================================================
; off_37764:
Obj94_SubObjData2:
	subObjData Obj94_Obj98_MapUnc_37678,make_art_tile(ArtTile_ArtNem_Rexon,1,0),1<<render_flags.on_screen|1<<render_flags.level_fg,4,4,$98
; off_3776E:
Obj99_SubObjData:
	subObjData Obj99_Obj98_MapUnc_3789A,make_art_tile(ArtTile_ArtNem_Nebula,1,1),1<<render_flags.on_screen|1<<render_flags.level_fg,4,8,$8B
; off_37778:
Obj9A_SubObjData2:
	subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),1<<render_flags.on_screen|1<<render_flags.level_fg,4,4,$98
; off_37782:
Obj9D_SubObjData2:
	subObjData Obj9D_Obj98_MapUnc_37D96,make_art_tile(ArtTile_ArtNem_Coconuts,0,0),1<<render_flags.on_screen|1<<render_flags.level_fg,4,8,$8B
; off_3778C:
ObjA4_SubObjData2:
	subObjData ObjA4_Obj98_MapUnc_38A96,make_art_tile(ArtTile_ArtNem_MtzSupernova,0,1),1<<render_flags.on_screen|1<<render_flags.level_fg,5,4,$98
; off_37796:
ObjA6_SubObjData:
	subObjData ObjA5_ObjA6_Obj98_MapUnc_38CCA,make_art_tile(ArtTile_ArtNem_Spiny,1,0),1<<render_flags.on_screen|1<<render_flags.level_fg,5,4,$98
; off_377A0:
ObjA7_SubObjData3:
	subObjData ObjA7_ObjA8_ObjA9_Obj98_MapUnc_3921A,make_art_tile(ArtTile_ArtNem_Grabber,1,1),1<<render_flags.on_screen|1<<render_flags.level_fg,4,4,$98
; off_377AA:
ObjAD_SubObjData3:
	subObjData ObjAD_Obj98_MapUnc_395B4,make_art_tile(ArtTile_ArtNem_WfzScratch,0,0),1<<render_flags.on_screen|1<<render_flags.level_fg,5,4,$98
; off_377B4:
ObjAF_SubObjData:
	subObjData ObjAF_Obj98_MapUnc_39E68,make_art_tile(ArtTile_ArtNem_CNZBonusSpike,1,0),1<<render_flags.on_screen|1<<render_flags.level_fg,5,4,$98
; off_377BE:
ObjB8_SubObjData2:
	subObjData ObjB8_Obj98_MapUnc_3BA46,make_art_tile(ArtTile_ArtNem_WfzWallTurret,0,0),1<<render_flags.on_screen|1<<render_flags.level_fg,3,4,$98

; ===========================================================================
	include "_incObj/99 Nebula.asm"
	include "_anim/Nebula.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj99_Obj98_MapUnc_3789A:	include "mappings/sprite/obj99.asm"
; ===========================================================================
	include "_incObj/9A & 9B Turtloid.asm" ; 9B is the one riding on top
; ===========================================================================
	include "_incObj/9C Balkiry's Jet.asm"
	include "_anim/Turtloid Shot.asm"
	include "_anim/Turtloid.asm"
	include "_anim/Balkiry's Jet.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj9A_Obj98_MapUnc_37B62:	include "mappings/sprite/obj9C.asm"

; ===========================================================================
	include "_incObj/9D Coconuts.asm"
	include "_anim/Coconuts.asm"
; ------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------
Obj9D_Obj98_MapUnc_37D96:	include "mappings/sprite/obj9D.asm"

; ===========================================================================
	include "_incObj/9E Crawltron.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj9E_MapUnc_37FF2:	include "mappings/sprite/obj9E.asm"

; ===========================================================================
	include "_incObj/9F & A0 Shellcracker.asm" ; A0 is the claw
	include "_anim/Shellcracker.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj9F_MapUnc_38314:	include "mappings/sprite/objA0.asm"
; ===========================================================================
	include "_incObj/A1 & A2 Slicer.asm" ; A2 is the pincers
	include "_anim/Slicer.asm"
	include "_anim/Slicer's Pincers.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjA1_MapUnc_385E2:	include "mappings/sprite/objA2.asm"

; ===========================================================================
	include "_incObj/A3 Flasher.asm"
	include "_anim/Flasher.asm"
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
ObjA3_MapUnc_388F0:	include "mappings/sprite/objA3.asm"

; ===========================================================================
	include "_incObj/A4 Asteron.asm"
	include "_anim/Asteron.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjA4_Obj98_MapUnc_38A96:	include "mappings/sprite/objA4.asm"

; ===========================================================================
	include "_incObj/A5 & A6 Spiny.asm" ; A6 is the Spiny on a wall
	include "_anim/Spiny.asm"
; ------------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------------
ObjA5_ObjA6_Obj98_MapUnc_38CCA:	include "mappings/sprite/objA6.asm"
; ===========================================================================
	include "_incObj/A7, A8, A9, AA & AB Grabber.asm" ; A8 is the legs, A9 is the spool, AA is the string, AB is unused
	include "_anim/Grabber.asm"
	include "mappings/sprite/Grabber.asm"
; ===========================================================================
	include "_incObj/AC Balkiry.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjAC_MapUnc_393CC:	include "mappings/sprite/objAC.asm"

; ===========================================================================
	include "_incObj/AD & AE Clucker.asm" ; AD is the base it comes out of, AE is Clucker itself
	include "_anim/Clucker.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjAD_Obj98_MapUnc_395B4:	include "mappings/sprite/objAE.asm"
; ===========================================================================
	include "_incObj/AF Mecha Sonic.asm"
	include "_anim/Mecha Sonic.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjAF_Obj98_MapUnc_39E68:	include "mappings/sprite/objAF_a.asm"
ObjAF_MapUnc_3A08C:	include "mappings/sprite/objAF_b.asm"
; ===========================================================================
	include "_incObj/B0 & B1 Sonic on Sega Screen.asm" ; B1 is the trademark hider for JP regions
	include "_anim/Sonic on Sega Screen.asm"
; ------------------------------------------------------------------------------
; sprite mappings
; Gigantic Sonic (2x size) mappings for the SEGA screen
; also has the "trademark hider" mappings
; ------------------------------------------------------------------------------
ObjB1_MapUnc_3A5A6:	include "mappings/sprite/objB1.asm"
; ===========================================================================
;loc_3A68A
SegaScr_VInt:
	move.w	(SegaScr_VInt_Subrout).w,d0
	beq.s	.return
	clr.w	(SegaScr_VInt_Subrout).w
	move.w	off_3A69E-2(pc,d0.w),d0
	jmp	off_3A69E(pc,d0.w)
.return:
	rts
; ===========================================================================
off_3A69E:	offsetTable
		offsetTableEntry.w loc_3A6A2	; 0
		offsetTableEntry.w loc_3A6D4	; 2
; ===========================================================================

loc_3A6A2:
	dma68kToVDP SegaScreenScaledSpriteDataStart,tiles_to_bytes(ArtTile_ArtUnc_Giant_Sonic),\
	            SegaScreenScaledSpriteDataEnd-SegaScreenScaledSpriteDataStart,VRAM

	lea	ObjB1_Streak_fade_to_right(pc),a1
	; 9 full lines ($100 bytes each) plus $28 8-pixel cells
	move.l	#vdpComm(VRAM_SegaScr_Plane_A_Name_Table + planeLoc(128,40,9),VRAM,WRITE),d0	; $49500003
	bra.s	loc_3A710
; ===========================================================================

loc_3A6D4:
	dmaFillVRAM 0,VRAM_SegaScr_Plane_A_Name_Table,VRAM_SegaScr_Plane_Table_Size ; clear Plane A pattern name table

	lea	ObjB1_Streak_fade_to_left(pc),a1
	; $49A00003; 9 full lines ($100 bytes each) plus $50 8-pixel cells
	move.l	#vdpComm(VRAM_SegaScr_Plane_A_Name_Table + planeLoc(128,80,9),VRAM,WRITE),d0

loc_3A710:
	lea	(VDP_data_port).l,a6
	; This is the line delta; for each line, the code below
	; writes $30 entries, leaving $50 untouched.
	move.l	#vdpCommDelta(planeLoc(128,0,1)),d6	; $1000000
	moveq	#7,d1	; Inner loop: repeat 8 times
	moveq	#9,d2	; Outer loop: repeat $A times
-
	move.l	d0,4(a6)	; Send command to VDP: set address to write to
	move.w	d1,d3		; Reset inner loop counter
	movea.l	a1,a2		; Reset data pointer
-
	move.w	(a2)+,d4	; Read one pattern name table entry
	bclr	#$A,d4		; Test bit $A and clear (flag for end of line)
	beq.s	+			; Branch if bit was clear
	bsr.s	loc_3A742	; Fill rest of line with this set of pixels
+
	move.w	d4,(a6)		; Write PNT entry
	dbf	d3,-
	add.l	d6,d0		; Point to the next VRAM area to be written to
	dbf	d2,--
	rts
; ===========================================================================

loc_3A742:
	moveq	#$28,d5		; Fill next $29 entries...
-
	move.w	d4,(a6)		; ...using the PNT entry that had bit $A set
	dbf	d5,-
	rts
; ===========================================================================
; Pattern A name table entries, with special flag detailed below
; These are used for the streaks, and point to VRAM in the $1000-$10FF range
ObjB1_Streak_fade_to_right:
	dc.w make_block_tile(ArtTile_ArtNem_Trails+0,0,0,1,1)	; 0
	dc.w make_block_tile(ArtTile_ArtNem_Trails+1,0,0,1,1)	; 2
	dc.w make_block_tile(ArtTile_ArtNem_Trails+2,0,0,1,1)	; 4
	dc.w make_block_tile(ArtTile_ArtNem_Trails+3,0,0,1,1)	; 6
	dc.w make_block_tile(ArtTile_ArtNem_Trails+4,0,0,1,1)	; 8
	dc.w make_block_tile(ArtTile_ArtNem_Trails+5,0,0,1,1)	; 10
	dc.w make_block_tile(ArtTile_ArtNem_Trails+6,0,0,1,1)	; 12
	dc.w make_block_tile(ArtTile_ArtNem_Trails+7,0,0,1,1) | (1 << $A)	; 14	; Bit $A is used as a flag to use this tile $29 times
ObjB1_Streak_fade_to_left:
	dc.w make_block_tile(ArtTile_ArtNem_Trails+7,0,0,1,1) | (1 << $A)	;  0	; Bit $A is used as a flag to use this tile $29 times
	dc.w make_block_tile(ArtTile_ArtNem_Trails+6,0,0,1,1)	; 2
	dc.w make_block_tile(ArtTile_ArtNem_Trails+5,0,0,1,1)	; 4
	dc.w make_block_tile(ArtTile_ArtNem_Trails+4,0,0,1,1)	; 6
	dc.w make_block_tile(ArtTile_ArtNem_Trails+3,0,0,1,1)	; 8
	dc.w make_block_tile(ArtTile_ArtNem_Trails+2,0,0,1,1)	; 10
	dc.w make_block_tile(ArtTile_ArtNem_Trails+1,0,0,1,1)	; 12
	dc.w make_block_tile(ArtTile_ArtNem_Trails+0,0,0,1,1)	; 14
Streak_Horizontal_offsets:
	dc.b $12
	dc.b   4	; 1
	dc.b   4	; 2
	dc.b   2	; 3
	dc.b   2	; 4
	dc.b   2	; 5
	dc.b   2	; 6
	dc.b   0	; 7
	dc.b   0	; 8
	dc.b   0	; 9
	dc.b   0	; 10
	dc.b   0	; 11
	dc.b   0	; 12
	dc.b   0	; 13
	dc.b   0	; 14
	dc.b   4	; 15
	dc.b   4	; 16
	dc.b   6	; 17
	dc.b  $A	; 18
	dc.b   8	; 19
	dc.b   6	; 20
	dc.b   4	; 21
	dc.b   4	; 22
	dc.b   4	; 23
	dc.b   4	; 24
	dc.b   6	; 25
	dc.b   6	; 26
	dc.b   8	; 27
	dc.b   8	; 28
	dc.b  $A	; 29
	dc.b  $A	; 30
	dc.b  $C	; 31
	dc.b  $E	; 32
	dc.b $10	; 33
	dc.b $16	; 34
	dc.b   0	; 35
	even
; ===========================================================================
	include "_incObj/B2 Tornado.asm"
	include "_anim/Tornado.asm"
; -----------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------
ObjB2_MapUnc_3AFF2:	include "mappings/sprite/objB2_a.asm"
ObjB2_MapUnc_3B292:	include "mappings/sprite/objB2_b.asm"
; ===========================================================================
	include "_incObj/B3 Clouds.asm"
; -----------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------
ObjB3_MapUnc_3B32C:	include "mappings/sprite/objB3.asm"
; ===========================================================================
	include "_incObj/B4 WFZ Vertical Propeller.asm"
	include "_anim/WFZ Vertical Propeller.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjB4_MapUnc_3B3BE:	include "mappings/sprite/objB4.asm"
; ===========================================================================
	include "_incObj/B5 WFZ Horizontal Propeller.asm"
	include "_anim/WFZ Horizontal Propeller.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjB5_MapUnc_3B548:	include "mappings/sprite/objB5.asm"
; ===========================================================================
	include "_incObj/B6 WFZ Tilting Platform.asm"
	include "_anim/WFZ Tilting Platform.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjB6_MapUnc_3B856:	include "mappings/sprite/objB6.asm"
; ===========================================================================
	include "_incObj/B7 WFZ Huge Laser.asm"
ObjB7_MapUnc_3B8E4:	include "mappings/sprite/objB7.asm"
; ===========================================================================
	include "_incObj/B8 WFZ Wall Turret.asm"
	include "_anim/WFZ Wall Turret.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjB8_Obj98_MapUnc_3BA46:	include "mappings/sprite/objB8.asm"
; ===========================================================================
	include "_incObj/B9 WFZ Cutscene Laser.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjB9_MapUnc_3BB18:	include "mappings/sprite/objB9.asm"
; ===========================================================================
	include "_incObj/BA WFZ Wheel.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBA_MapUnc_3BB70:	include "mappings/sprite/objBA.asm"
; ===========================================================================
	include "_incObj/BB Deleted Object.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBB_MapUnc_3BBA0:	include "mappings/sprite/objBB.asm"
; ===========================================================================
	include "_incObj/BC WFZ Escape Jet.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBC_MapUnc_3BC08:	include "mappings/sprite/objBC.asm"
; ===========================================================================
	include "_incObj/BD WFZ Platforms.asm"
	include "_anim/WFZ Platforms.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBD_MapUnc_3BD3E:	include "mappings/sprite/objBD.asm"
; ===========================================================================
	include "_incObj/BE WFZ Lateral Cannon Platform.asm"
	include "_anim/WFZ Lateral Cannon Platform.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBE_MapUnc_3BE46:	include "mappings/sprite/objBE.asm"
; ===========================================================================
	include "_incObj/BF WFZ Destructible Pole.asm"
	include "_anim/WFZ Destructible Pole.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjBF_MapUnc_3BEE0:	include "mappings/sprite/objBF.asm"
; ===========================================================================
	include "_incObj/C0 WFZ Launcher.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjC0_MapUnc_3C098:	include "mappings/sprite/objC0.asm"
; ===========================================================================
	include "_incObj/C1 WFZ Breakable Plating.asm" ; animation script is embedded in the code
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
ObjC1_MapUnc_3C280:	include "mappings/sprite/objC1.asm"
; ===========================================================================
	include "_incObj/C2 WFZ Rivet Switch.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjC2_MapUnc_3C3C2:	include "mappings/sprite/objC2.asm"

Invalid_SubObjData2:

; ===========================================================================
	include "_incObj/C3 & C4 WFZ Cutscene Smoke.asm"
; ===========================================================================
	include "_incObj/C5 WFZ Boss.asm"
	include "_anim/WFZ Boss.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjC5_MapUnc_3CCD8:	include "mappings/sprite/objC5_a.asm"
ObjC5_MapUnc_3CEBC:	include "mappings/sprite/objC5_b.asm"
; ===========================================================================
	include "_incObj/C6 Eggman.asm"
	include "_anim/Eggman.asm"
; ----------------------------------------------------------------------------
; sprite mappings ; Robotnik running
; ----------------------------------------------------------------------------
ObjC6_MapUnc_3D0EE:	include "mappings/sprite/objC6_a.asm"
ObjC6_MapUnc_3D1DE:	include "mappings/sprite/objC6_b.asm"
; ===========================================================================
	include "_incObj/C8 Crawl.asm"
	include "_anim/Crawl.asm"
; ----------------------------------------------------------------------------
; sprite mappings ; Crawl CNZ
; ----------------------------------------------------------------------------
ObjC8_MapUnc_3D450:	include "mappings/sprite/objC8.asm"
; ===========================================================================
	include "_incObj/C7 Death Egg Robot.asm" ; Contains macros for a custom animation format, might need more splitting?
	include "_anim/Death Egg Robot 1.asm"
	include "_anim/Death Egg Robot 2.asm"
	include "_anim/Death Egg Robot 3.asm"
; ------------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------------
ObjC7_MapUnc_3E5F8:	include "mappings/sprite/objC7.asm"
; ===========================================================================
	include "_incObj/sub Scale2x.asm"
; ===========================================================================
	include "_incObj/8A Credits.asm"
; ===========================================================================
; ----------------------------------------------------------------------------
; sprite mappings (unused?)
; ----------------------------------------------------------------------------
Obj8A_MapUnc_3EB4E:	include "mappings/sprite/obj8A.asm"
; ===========================================================================
	include "_incObj/3E Prison Capsule.asm"
; ===========================================================================
	include "_anim/Prison Capsule.asm"
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj3E_MapUnc_3F436:	include "mappings/sprite/obj3E.asm"
; ===========================================================================

	include "_incObj/sub TouchResponse.asm" ; includes HurtCharacter, KillCharacter, and Boss damage stuff. Maybe split better??
; ===========================================================================
	include "_inc/Animate Level Graphics.asm"
; ===========================================================================

	include "_inc/HUD Update.asm"
; ===========================================================================
; ArtUnc_4134C:
Art_Hud:	BINCLUDE	"art/uncompressed/Big and small numbers used on counters - 1.bin"
; ArtUnc_4164C:
Art_LivesNums:	BINCLUDE	"art/uncompressed/Big and small numbers used on counters - 2.bin"
; ArtUnc_4178C:
Art_Text:	BINCLUDE	"art/uncompressed/Big and small numbers used on counters - 3.bin"

; ===========================================================================
	include "_inc/Debug Mode.asm"
; ===========================================================================
	include "_inc/Debug Lists.asm"
	include "_inc/Level Headers.asm"
	include "_inc/Pattern Load Cues.asm"
;---------------------------------------------------------------------------------------
; Collision Data
;---------------------------------------------------------------------------------------
ColCurveMap:		BINCLUDE	"collision/Curve and resistance mapping.bin"
	even
ColArrayVertical:	BINCLUDE	"collision/Collision array - Vertical.bin"
ColArrayHorizontal:	BINCLUDE	"collision/Collision array - Horizontal.bin"
	even

ColP_EHZHTZ:	BINCLUDE	"collision/EHZ and HTZ primary 16x16 collision index.unc"
	even
ColS_EHZHTZ:	BINCLUDE	"collision/EHZ and HTZ secondary 16x16 collision index.unc"
	even
ColP_WZ:	;BINCLUDE	"collision/WZ primary 16x16 collision index.unc"
	;even
ColP_MTZ:	BINCLUDE	"collision/MTZ primary 16x16 collision index.unc"
	even
ColP_HPZ:	BINCLUDE	"collision/HPZ primary 16x16 collision index.unc"
	even
ColS_HPZ:	BINCLUDE	"collision/HPZ secondary 16x16 collision index.unc"
	even
ColP_OOZ:	BINCLUDE	"collision/OOZ primary 16x16 collision index.unc"
	even
ColP_MCZ:	BINCLUDE	"collision/MCZ primary 16x16 collision index.unc"
	even
ColP_CNZ:	BINCLUDE	"collision/CNZ primary 16x16 collision index.unc"
	even
ColS_CNZ:	BINCLUDE	"collision/CNZ secondary 16x16 collision index.unc"
	even
ColP_CPZDEZ:	BINCLUDE	"collision/CPZ and DEZ primary 16x16 collision index.unc"
	even
ColS_CPZDEZ:	BINCLUDE	"collision/CPZ and DEZ secondary 16x16 collision index.unc"
	even
ColP_ARZ:	BINCLUDE	"collision/ARZ primary 16x16 collision index.unc"
	even
ColS_ARZ:	BINCLUDE	"collision/ARZ secondary 16x16 collision index.unc"
	even
ColP_WFZSCZ:	BINCLUDE	"collision/WFZ and SCZ primary 16x16 collision index.unc"
	even
ColS_WFZSCZ:	BINCLUDE	"collision/WFZ and SCZ secondary 16x16 collision index.unc"
	even
ColP_Invalid:

;---------------------------------------------------------------------------------------
; Offset index of level layouts
; Two entries per zone, pointing to the level layouts for acts 1 and 2 of each zone
; respectively.
;---------------------------------------------------------------------------------------
Off_Level: zoneOrderedOffsetTable 4,2
	; EHZ
	zoneTableEntry.l Level_EHZ1	; Act 1
	zoneTableEntry.l Level_EHZ2	; Act 2
	; Zone 1
	zoneTableEntry.l Level_Invalid	; Act 1
	zoneTableEntry.l Level_Invalid	; Act 2
	; WZ
	zoneTableEntry.l Level_Invalid	; Act 1
	zoneTableEntry.l Level_Invalid	; Act 2
	; Zone 3
	zoneTableEntry.l Level_Invalid	; Act 1
	zoneTableEntry.l Level_Invalid	; Act 2
	; MTZ
	zoneTableEntry.l Level_MTZ1	; Act 1
	zoneTableEntry.l Level_MTZ2	; Act 2
	; MTZ
	zoneTableEntry.l Level_MTZ3	; Act 3
	zoneTableEntry.l Level_MTZ3	; Act 4
	; WFZ
	zoneTableEntry.l Level_WFZ	; Act 1
	zoneTableEntry.l Level_WFZ	; Act 2
	; HTZ
	zoneTableEntry.l Level_HTZ1	; Act 1
	zoneTableEntry.l Level_HTZ2	; Act 2
	; HPZ
	zoneTableEntry.l Level_HPZ1	; Act 1
	zoneTableEntry.l Level_HPZ1	; Act 2
	; Zone 9
	zoneTableEntry.l Level_Invalid	; Act 1
	zoneTableEntry.l Level_Invalid	; Act 2
	; OOZ
	zoneTableEntry.l Level_OOZ1	; Act 1
	zoneTableEntry.l Level_OOZ2	; Act 2
	; MCZ
	zoneTableEntry.l Level_MCZ1	; Act 1
	zoneTableEntry.l Level_MCZ2	; Act 2
	; CNZ
	zoneTableEntry.l Level_CNZ1	; Act 1
	zoneTableEntry.l Level_CNZ2	; Act 2
	; CPZ
	zoneTableEntry.l Level_CPZ1	; Act 1
	zoneTableEntry.l Level_CPZ2	; Act 2
	; DEZ
	zoneTableEntry.l Level_DEZ	; Act 1
	zoneTableEntry.l Level_DEZ	; Act 2
	; ARZ
	zoneTableEntry.l Level_ARZ1	; Act 1
	zoneTableEntry.l Level_ARZ2	; Act 2
	; SCZ
	zoneTableEntry.l Level_SCZ	; Act 1
	zoneTableEntry.l Level_SCZ	; Act 2
    zoneTableEnd

Level_Invalid:
Level_EHZ1:	BINCLUDE	"level/layout/EHZ_1.kosp"
	even
Level_EHZ2:	BINCLUDE	"level/layout/EHZ_2.kosp"
	even
Level_MTZ1:	BINCLUDE	"level/layout/MTZ_1.kosp"
	even
Level_MTZ2:	BINCLUDE	"level/layout/MTZ_2.kosp"
	even
Level_MTZ3:	BINCLUDE	"level/layout/MTZ_3.kosp"
	even
Level_WFZ:	BINCLUDE	"level/layout/WFZ.kosp"
	even
Level_HTZ1:	BINCLUDE	"level/layout/HTZ_1.kosp"
	even
Level_HTZ2:	BINCLUDE	"level/layout/HTZ_2.kosp"
	even
Level_HPZ1:	BINCLUDE	"level/layout/HPZ_1.kosp"
	even
Level_OOZ1:	BINCLUDE	"level/layout/OOZ_1.kosp"
	even
Level_OOZ2:	BINCLUDE	"level/layout/OOZ_2.kosp"
	even
Level_MCZ1:	BINCLUDE	"level/layout/MCZ_1.kosp"
	even
Level_MCZ2:	BINCLUDE	"level/layout/MCZ_2.kosp"
	even
Level_CNZ1:	BINCLUDE	"level/layout/CNZ_1.kosp"
	even
Level_CNZ2:	BINCLUDE	"level/layout/CNZ_2.kosp"
	even
Level_CPZ1:	BINCLUDE	"level/layout/CPZ_1.kosp"
	even
Level_CPZ2:	BINCLUDE	"level/layout/CPZ_2.kosp"
	even
Level_DEZ:	BINCLUDE	"level/layout/DEZ.kosp"
	even
Level_ARZ1:	BINCLUDE	"level/layout/ARZ_1.kosp"
	even
Level_ARZ2:	BINCLUDE	"level/layout/ARZ_2.kosp"
	even
Level_SCZ:	BINCLUDE	"level/layout/SCZ.kosp"
	even

;---------------------------------------------------------------------------------------
; Animated Level Art
;---------------------------------------------------------------------------------------
; EHZ and HTZ
ArtUnc_Flowers1:	BINCLUDE	"art/uncompressed/EHZ and HTZ flowers - 1.bin"
ArtUnc_Flowers2:	BINCLUDE	"art/uncompressed/EHZ and HTZ flowers - 2.bin"
ArtUnc_Flowers3:	BINCLUDE	"art/uncompressed/EHZ and HTZ flowers - 3.bin"
ArtUnc_Flowers4:	BINCLUDE	"art/uncompressed/EHZ and HTZ flowers - 4.bin"
ArtUnc_EHZPulseBall:	BINCLUDE	"art/uncompressed/Pulsing ball against checkered background (EHZ).bin"
ArtNem_HTZCliffs:	BINCLUDE	"art/uncompressed/Dynamically reloaded cliffs in HTZ background.unc"
ArtUnc_HTZClouds:	BINCLUDE	"art/uncompressed/Background clouds (HTZ).bin"

; MTZ
ArtUnc_MTZCylinder:	BINCLUDE	"art/uncompressed/Spinning metal cylinder (MTZ).bin"
ArtUnc_Lava:		BINCLUDE	"art/uncompressed/Lava.bin"
ArtUnc_MTZAnimBack:	BINCLUDE	"art/uncompressed/Animated section of MTZ background.bin"

; HPZ
ArtUnc_HPZPulseOrb:	BINCLUDE	"art/uncompressed/Pulsing orb (HPZ).bin"

; OOZ
ArtUnc_OOZPulseBall:	BINCLUDE	"art/uncompressed/Pulsing ball (OOZ).bin"
ArtUnc_OOZSquareBall1:	BINCLUDE	"art/uncompressed/Square rotating around ball in OOZ - 1.bin"
ArtUnc_OOZSquareBall2:	BINCLUDE	"art/uncompressed/Square rotating around ball in OOZ - 2.bin"
ArtUnc_Oil1:		BINCLUDE	"art/uncompressed/Oil - 1.bin"
ArtUnc_Oil2:		BINCLUDE	"art/uncompressed/Oil - 2.bin"

; CNZ
ArtUnc_CNZFlipTiles:	BINCLUDE	"art/uncompressed/Flipping foreground section (CNZ).bin"
ArtUnc_CNZSlotPics:	BINCLUDE	"art/uncompressed/Slot pictures.bin"
ArtUnc_CPZAnimBack:	BINCLUDE	"art/uncompressed/Animated background section (CPZ and DEZ).bin"

; ARZ
ArtUnc_Waterfall1:	BINCLUDE	"art/uncompressed/ARZ waterfall patterns - 1.bin"
ArtUnc_Waterfall2:	BINCLUDE	"art/uncompressed/ARZ waterfall patterns - 2.bin"
ArtUnc_Waterfall3:	BINCLUDE	"art/uncompressed/ARZ waterfall patterns - 3.bin"

;---------------------------------------------------------------------------------------
; Player Assets
;---------------------------------------------------------------------------------------
	align tiles_to_bytes(1)
ArtUnc_Sonic:			BINCLUDE	"art/uncompressed/Sonic's art.bin"
	align tiles_to_bytes(1)
ArtUnc_Tails:			BINCLUDE	"art/uncompressed/Tails's art.bin"

MapUnc_Sonic:			include		"mappings/sprite/Sonic.asm"

MapRUnc_Sonic:			include		"mappings/spriteDPLC/Sonic.asm"

ArtNem_Shield:			BINCLUDE	"art/kosinskiplusm/Shield.kospm"
	even
ArtNem_Invincible_stars:	BINCLUDE	"art/kosinskiplusm/Invincibility stars.kospm"
	even
ArtUnc_SplashAndDust:		BINCLUDE	"art/uncompressed/Splash and skid dust.bin"

ArtNem_SuperSonic_stars:	BINCLUDE	"art/kosinskiplusm/Super Sonic stars.kospm"
	even
MapUnc_Tails:			include		"mappings/sprite/Tails.asm"

MapRUnc_Tails:			include		"mappings/spriteDPLC/Tails.asm"

;---------------------------------------------------------------------------------------
; Sega Screen Assets
;---------------------------------------------------------------------------------------
ArtNem_SEGA:			BINCLUDE	"art/kosinskiplusm/SEGA.kospm"
	even
ArtNem_IntroTrails:		BINCLUDE	"art/kosinskiplusm/Shaded blocks from intro.kospm"
	even
MapEng_SEGA:			BINCLUDE	"mappings/misc/SEGA mappings.eni"
	even

;---------------------------------------------------------------------------------------
; Title Screen Assets
;---------------------------------------------------------------------------------------
MapEng_TitleScreen:		BINCLUDE	"mappings/misc/Mappings for title screen background.eni"
	even
MapEng_TitleBack:		BINCLUDE	"mappings/misc/Mappings for title screen background 2.eni" ; title screen background (smaller part, water/horizon)
	even
MapEng_TitleLogo:		BINCLUDE	"mappings/misc/Sonic the Hedgehog 2 title screen logo mappings.eni"
	even
ArtNem_Title:			BINCLUDE	"art/kosinskiplusm/Main patterns from title screen.kospm"
	even
ArtNem_TitleSprites:		BINCLUDE	"art/kosinskiplusm/Sonic and Tails from title screen.kospm"
	even
ArtNem_MenuJunk:		BINCLUDE	"art/kosinskiplusm/A few menu blocks.kospm"
	even

;---------------------------------------------------------------------------------------
; General Level Assets
;---------------------------------------------------------------------------------------
ArtNem_Button:			BINCLUDE	"art/kosinskiplusm/Button.kospm"
	even
ArtNem_VrtclSprng:		BINCLUDE	"art/kosinskiplusm/Vertical spring.kospm"
	even
ArtNem_HrzntlSprng:		BINCLUDE	"art/kosinskiplusm/Horizontal spring.kospm"
	even
ArtNem_DignlSprng:		BINCLUDE	"art/kosinskiplusm/Diagonal spring.kospm"
	even
ArtNem_HUD:			BINCLUDE	"art/kosinskiplusm/HUD.kospm" ; Score, Rings, Time
	even
ArtNem_Sonic_life_counter:	BINCLUDE	"art/kosinskiplusm/Sonic lives counter.kospm"
	even
Art_Ring:			BINCLUDE	"art/uncompressed/Rings.unc"
ArtNem_Ring_sparkles:		BINCLUDE	"art/kosinskiplusm/Ring Sparkles.kospm"
	even
ArtNem_Powerups:		BINCLUDE	"art/kosinskiplusm/Monitor and contents.kospm"
	even
ArtNem_Spikes:			BINCLUDE	"art/kosinskiplusm/Spikes.kospm"
	even
ArtNem_Numbers:			BINCLUDE	"art/kosinskiplusm/Numbers.kospm"
	even
ArtNem_Checkpoint:		BINCLUDE	"art/kosinskiplusm/Star pole.kospm"
	even
ArtNem_Signpost:		BINCLUDE	"art/kosinskiplusm/Signpost.kospm" ; For one-player mode.
	even
ArtUnc_Signpost:		BINCLUDE	"art/uncompressed/Signpost.bin" ; For two-player mode.
	even
ArtNem_LeverSpring:		BINCLUDE	"art/kosinskiplusm/Lever spring.kospm"
	even
ArtNem_HorizSpike:		BINCLUDE	"art/kosinskiplusm/Long horizontal spike.kospm"
	even
ArtNem_BigBubbles:		BINCLUDE	"art/kosinskiplusm/Bubble generator.kospm" ; Bubble from underwater
	even
ArtNem_Bubbles:			BINCLUDE	"art/kosinskiplusm/Bubbles.kospm" ; Bubbles from character
	even
ArtUnc_Countdown:		BINCLUDE	"art/uncompressed/Numbers for drowning countdown.bin"
	even
ArtNem_Game_Over:		BINCLUDE	"art/kosinskiplusm/Game and Time Over text.kospm"
	even
ArtNem_Explosion:		BINCLUDE	"art/kosinskiplusm/Explosion.kospm"
	even
ArtNem_MilesLife:		BINCLUDE	"art/kosinskiplusm/Miles life counter.kospm"
	even
ArtNem_Capsule:			BINCLUDE	"art/kosinskiplusm/Egg Prison.kospm"
	even
ArtNem_ContinueTails:		BINCLUDE	"art/kosinskiplusm/Tails on continue screen.kospm"
	even
ArtNem_MiniSonic:		BINCLUDE	"art/kosinskiplusm/Sonic continue.kospm"
	even
ArtNem_TailsLife:		BINCLUDE	"art/kosinskiplusm/Tails life counter.kospm"
	even
ArtNem_MiniTails:		BINCLUDE	"art/kosinskiplusm/Tails continue.kospm"
	even

;---------------------------------------------------------------------------------------
; Menu Assets
;---------------------------------------------------------------------------------------
ArtNem_FontStuff:		BINCLUDE	"art/kosinskiplusm/Standard font.kospm"
	even
MapEng_MenuBack:		BINCLUDE	"mappings/misc/Sonic and Miles animated background.eni"
	even
ArtUnc_MenuBack:		BINCLUDE	"art/uncompressed/Sonic and Miles animated background.bin"
	even
ArtNem_TitleCard:		BINCLUDE	"art/kosinskiplusm/Title card.kospm"
	even
ArtNem_TitleCard2:		BINCLUDE	"art/kosinski/Font using large broken letters.kosp"
	even
ArtNem_MenuBox:			BINCLUDE	"art/kosinskiplusm/A menu box with a shadow.kospm"
	even
ArtNem_LevelSelectPics:		BINCLUDE	"art/kosinskiplusm/Pictures in level preview box from level select.kospm"
	even
ArtNem_ResultsText:		BINCLUDE	"art/kosinskiplusm/End of level results text.kospm" ; Text for Sonic or Tails Got Through Act and Bonus/Perfect
	even
ArtNem_Perfect:			BINCLUDE	"art/kosinskiplusm/Perfect text.kospm"
	even

;---------------------------------------------------------------------------------------
; Small Animal Assets
;---------------------------------------------------------------------------------------
ArtNem_Flicky:			BINCLUDE	"art/kosinskiplusm/Flicky.kospm"
	even
ArtNem_Squirrel:		BINCLUDE	"art/kosinskiplusm/Squirrel.kospm" ; Ricky
	even
ArtNem_Mouse:			BINCLUDE	"art/kosinskiplusm/Mouse.kospm"    ; Micky
	even
ArtNem_Chicken:			BINCLUDE	"art/kosinskiplusm/Chicken.kospm"  ; Cucky
	even
ArtNem_Monkey:			BINCLUDE	"art/kosinskiplusm/Monkey.kospm"   ; Wocky
	even
ArtNem_Eagle:			BINCLUDE	"art/kosinskiplusm/Eagle.kospm"    ; Locky
	even
ArtNem_Pig:			BINCLUDE	"art/kosinskiplusm/Pig.kospm"      ; Picky
	even
ArtNem_Seal:			BINCLUDE	"art/kosinskiplusm/Seal.kospm"     ; Rocky
	even
ArtNem_Penguin:			BINCLUDE	"art/kosinskiplusm/Penguin.kospm"  ; Pecky
	even
ArtNem_Turtle:			BINCLUDE	"art/kosinskiplusm/Turtle.kospm"   ; Tocky
	even
ArtNem_Bear:			BINCLUDE	"art/kosinskiplusm/Bear.kospm"     ; Becky
	even
ArtNem_Rabbit:			BINCLUDE	"art/kosinskiplusm/Rabbit.kospm"   ; Pocky
	even

;---------------------------------------------------------------------------------------
; WFZ Assets
;---------------------------------------------------------------------------------------
ArtNem_WfzSwitch:		BINCLUDE	"art/kosinskiplusm/WFZ boss chamber switch.kospm" ; Rivet thing that you bust to get inside the ship
	even
ArtNem_BreakPanels:		BINCLUDE	"art/kosinskiplusm/Breakaway panels from WFZ.kospm"
	even

;---------------------------------------------------------------------------------------
; HPZ Assets
;---------------------------------------------------------------------------------------
Nem_HPZ_Bridge:			BINCLUDE	"art/kosinskiplusm/HPZ bridge.kospm"
	even
Nem_HPZ_Waterfall:		BINCLUDE	"art/kosinskiplusm/HPZ waterfall.kospm"
	even
Nem_HPZ_Emerald:		BINCLUDE	"art/kosinskiplusm/HPZ Emerald.kospm"
	even
Nem_HPZ_Platform:		BINCLUDE	"art/kosinskiplusm/HPZ Platform.kospm"
	even
Nem_HPZ_PulsingBall:		BINCLUDE	"art/kosinskiplusm/HPZ Pulsing Ball.kospm"
	even
Nem_HPZ_Various:		BINCLUDE	"art/kosinskiplusm/HPZ Various.kospm"
	even

;---------------------------------------------------------------------------------------
; OOZ Assets
;---------------------------------------------------------------------------------------
ArtNem_SpikyThing:		BINCLUDE	"art/kosinskiplusm/Spiked ball from OOZ.kospm"
	even
ArtNem_BurnerLid:		BINCLUDE	"art/kosinskiplusm/Burner Platform from OOZ.kospm"
	even
ArtNem_StripedBlocksVert:	BINCLUDE	"art/kosinskiplusm/Striped blocks from CPZ.kospm"
	even
ArtNem_Oilfall:			BINCLUDE	"art/kosinskiplusm/Cascading oil hitting oil from OOZ.kospm"
	even
ArtNem_Oilfall2:		BINCLUDE	"art/kosinskiplusm/Cascading oil from OOZ.kospm"
	even
ArtNem_BallThing:		BINCLUDE	"art/kosinskiplusm/Ball on spring from OOZ (beta holdovers).kospm"
	even
ArtNem_LaunchBall:		BINCLUDE	"art/kosinskiplusm/Transporter ball from OOZ.kospm"
	even
ArtNem_OOZPlatform:		BINCLUDE	"art/kosinskiplusm/OOZ collapsing platform.kospm"
	even
ArtNem_PushSpring:		BINCLUDE	"art/kosinskiplusm/Push spring from OOZ.kospm"
	even
ArtNem_OOZSwingPlat:		BINCLUDE	"art/kosinskiplusm/Swinging platform from OOZ.kospm"
	even
ArtNem_StripedBlocksHoriz:	BINCLUDE	"art/kosinskiplusm/4 stripy blocks from OOZ.kospm"
	even
ArtNem_OOZElevator:		BINCLUDE	"art/kosinskiplusm/Rising platform from OOZ.kospm"
	even
ArtNem_OOZFanHoriz:		BINCLUDE	"art/kosinskiplusm/Fan from OOZ.kospm"
	even
ArtNem_OOZBurn:			BINCLUDE	"art/kosinskiplusm/Green flame from OOZ burners.kospm"
	even

;---------------------------------------------------------------------------------------
; CNZ Assets
;---------------------------------------------------------------------------------------
ArtNem_CNZSnake:		BINCLUDE	"art/kosinskiplusm/Caterpiller platforms from CNZ.kospm" ; Patterns for appearing and disappearing string of platforms
	even
ArtNem_CNZBonusSpike:		BINCLUDE	"art/kosinskiplusm/Spikey ball from CNZ slots.kospm"
	even
ArtNem_BigMovingBlock:		BINCLUDE	"art/kosinskiplusm/Moving block from CNZ and CPZ.kospm"
	even
ArtNem_CNZElevator:		BINCLUDE	"art/kosinskiplusm/CNZ elevator.kospm"
	even
ArtNem_CNZCage:			BINCLUDE	"art/kosinskiplusm/CNZ slot machine bars.kospm"
	even
ArtNem_CNZHexBumper:		BINCLUDE	"art/kosinskiplusm/Hexagonal bumper from CNZ.kospm"
	even
ArtNem_CNZRoundBumper:		BINCLUDE	"art/kosinskiplusm/Round bumper from CNZ.kospm"
	even
ArtNem_CNZDiagPlunger:		BINCLUDE	"art/kosinskiplusm/Diagonal impulse spring from CNZ.kospm"
	even
ArtNem_CNZVertPlunger:		BINCLUDE	"art/kosinskiplusm/Vertical impulse spring.kospm"
	even
ArtNem_CNZMiniBumper:		BINCLUDE	"art/kosinskiplusm/Drop target from CNZ.kospm" ; Weird blocks that you hit 3 times to get rid of
	even
ArtNem_CNZFlipper:		BINCLUDE	"art/kosinskiplusm/Flippers.kospm"
	even

;---------------------------------------------------------------------------------------
; CPZ Assets
;---------------------------------------------------------------------------------------
ArtNem_CPZElevator:		BINCLUDE	"art/kosinskiplusm/Large moving platform from CPZ.kospm"
	even
ArtNem_WaterSurface:		BINCLUDE	"art/kosinskiplusm/Top of water in HPZ and CNZ.kospm"
	even
ArtNem_CPZBooster:		BINCLUDE	"art/kosinskiplusm/Speed booster from CPZ.kospm"
	even
ArtNem_CPZDroplet:		BINCLUDE	"art/kosinskiplusm/CPZ worm enemy.kospm"
	even
ArtNem_CPZMetalThings:		BINCLUDE	"art/kosinskiplusm/CPZ metal things.kospm" ; Girder, cylinders
	even
ArtNem_CPZMetalBlock:		BINCLUDE	"art/kosinskiplusm/CPZ large moving platform blocks.kospm"
	even
ArtNem_ConstructionStripes:	BINCLUDE	"art/kosinskiplusm/Stripy blocks from CPZ.kospm"
	even
ArtNem_CPZAnimatedBits:		BINCLUDE	"art/kosinskiplusm/Small yellow moving platform from CPZ.kospm"
	even
ArtNem_CPZStairBlock:		BINCLUDE	"art/kosinskiplusm/Moving block from CPZ.kospm"
	even
ArtNem_CPZTubeSpring:		BINCLUDE	"art/kosinskiplusm/CPZ spintube exit cover.kospm"
	even

;---------------------------------------------------------------------------------------
; ARZ Assets
;---------------------------------------------------------------------------------------
ArtNem_WaterSurface2:		BINCLUDE	"art/kosinskiplusm/Top of water in ARZ.kospm"
	even
ArtNem_Leaves:			BINCLUDE	"art/kosinskiplusm/Leaves in ARZ.kospm"
	even
ArtNem_ArrowAndShooter:		BINCLUDE	"art/kosinskiplusm/Arrow shooter and arrow from ARZ.kospm"
	even
ArtNem_ARZBarrierThing:		BINCLUDE	"art/kosinskiplusm/One way barrier from ARZ.kospm" ; Unused
	even

;---------------------------------------------------------------------------------------
; EHZ/OOZ Badnik Assets
;---------------------------------------------------------------------------------------
; These Badniks being grouped together here is unusual, but can be explained by two things:
; 1. This is where all Badnik tiles were kept in the earliest prototypes.
; 2. These are the only Badniks left from those prototypes.
ArtNem_Buzzer:			BINCLUDE	"art/kosinskiplusm/Buzzer enemy.kospm"
	even
ArtNem_Octus:			BINCLUDE	"art/kosinskiplusm/Octopus badnik from OOZ.kospm"
	even
ArtNem_Aquis:			BINCLUDE	"art/kosinskiplusm/Seahorse from OOZ.kospm"
	even
ArtNem_Masher:			BINCLUDE	"art/kosinskiplusm/EHZ Pirahna badnik.kospm"
	even

;---------------------------------------------------------------------------------------
; Boss Assets
;---------------------------------------------------------------------------------------
ArtNem_Eggpod:			BINCLUDE	"art/kosinskiplusm/Eggpod.kospm" ; Robotnik's main ship
	even
ArtNem_CPZBoss:			BINCLUDE	"art/kosinskiplusm/CPZ boss.kospm"
	even
ArtNem_FieryExplosion:		BINCLUDE	"art/kosinskiplusm/Large explosion.kospm"
	even
ArtNem_EggpodJets:		BINCLUDE	"art/kosinskiplusm/Horizontal jet.kospm"
	even
ArtNem_BossSmoke:		BINCLUDE	"art/kosinskiplusm/Smoke trail from CPZ and HTZ bosses.kospm"
	even
ArtNem_EHZBoss:			BINCLUDE	"art/kosinskiplusm/EHZ boss.kospm"
	even
ArtNem_EggChoppers:		BINCLUDE	"art/kosinskiplusm/Chopper blades for EHZ boss.kospm"
	even
ArtNem_HTZBoss:			BINCLUDE	"art/kosinskiplusm/HTZ boss.kospm"
	even
ArtNem_ARZBoss:			BINCLUDE	"art/kosinskiplusm/ARZ boss.kospm"
	even
ArtNem_MCZBoss:			BINCLUDE	"art/kosinskiplusm/MCZ boss.kospm"
	even
ArtNem_CNZBoss:			BINCLUDE	"art/kosinskiplusm/CNZ boss.kospm"
	even
ArtNem_OOZBoss:			BINCLUDE	"art/kosinskiplusm/OOZ boss.kospm"
	even
ArtNem_MTZBoss:			BINCLUDE	"art/kosinskiplusm/MTZ boss.kospm"
	even
ArtUnc_FallingRocks:		BINCLUDE	"art/uncompressed/Falling rocks and stalactites from MCZ.bin"
	even

;---------------------------------------------------------------------------------------
; ARZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_Whisp:			BINCLUDE	"art/kosinskiplusm/Blowfly from ARZ.kospm"
	even
ArtNem_Grounder:		BINCLUDE	"art/kosinskiplusm/Grounder from ARZ.kospm"
	even
ArtNem_ChopChop:		BINCLUDE	"art/kosinskiplusm/Shark from ARZ.kospm"
	even

;---------------------------------------------------------------------------------------
; HTZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_Rexon:			BINCLUDE	"art/kosinskiplusm/Rexxon (lava snake) from HTZ.kospm"
	even
ArtNem_Spiker:			BINCLUDE	"art/kosinskiplusm/Driller badnik from HTZ.kospm"
	even

;---------------------------------------------------------------------------------------
; SCZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_Nebula:			BINCLUDE	"art/kosinskiplusm/Bomber badnik from SCZ.kospm"
	even
ArtNem_Turtloid:		BINCLUDE	"art/kosinskiplusm/Turtle badnik from SCZ.kospm"
	even

;---------------------------------------------------------------------------------------
; EHZ Badnik Assets (again)
;---------------------------------------------------------------------------------------
ArtNem_Coconuts:		BINCLUDE	"art/kosinskiplusm/Coconuts badnik from EHZ.kospm"
	even

;---------------------------------------------------------------------------------------
; MCZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_Crawlton:		BINCLUDE	"art/kosinskiplusm/Snake badnik from MCZ.kospm"
	even
ArtNem_Flasher:			BINCLUDE	"art/kosinskiplusm/Firefly from MCZ.kospm"
	even

;---------------------------------------------------------------------------------------
; MTZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_MtzMantis:		BINCLUDE	"art/kosinskiplusm/Praying mantis badnik from MTZ.kospm"
	even
ArtNem_Shellcracker:		BINCLUDE	"art/kosinskiplusm/Shellcracker badnik from MTZ.kospm"
	even
ArtNem_MtzSupernova:		BINCLUDE	"art/kosinskiplusm/Exploding star badnik from MTZ.kospm"
	even

;---------------------------------------------------------------------------------------
; CPZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_Spiny:			BINCLUDE	"art/kosinskiplusm/Weird crawling badnik from CPZ.kospm"
	even
ArtNem_Grabber:			BINCLUDE	"art/kosinskiplusm/Spider badnik from CPZ.kospm"
	even

;---------------------------------------------------------------------------------------
; WFZ Badnik Assets
;---------------------------------------------------------------------------------------
ArtNem_WfzScratch:		BINCLUDE	"art/kosinskiplusm/Scratch from WFZ.kospm" ; Chicken badnik
	even
ArtNem_Balkrie:			BINCLUDE	"art/kosinskiplusm/Balkrie (jet badnik) from SCZ.kospm" ; This SCZ badnik is here for some reason.
	even

;---------------------------------------------------------------------------------------
; WFZ/DEZ Assets
; It seems that these were haphazardly thrown together instead of neatly-split like the
; other zones' assets.
;---------------------------------------------------------------------------------------
ArtNem_SilverSonic:		BINCLUDE	"art/kosinskiplusm/Silver Sonic.kospm"
	even
ArtNem_Tornado:			BINCLUDE	"art/kosinskiplusm/The Tornado.kospm" ; Sonic's plane.
	even
ArtNem_WfzWallTurret:		BINCLUDE	"art/kosinskiplusm/Wall turret from WFZ.kospm"
	even
ArtNem_WfzHook:			BINCLUDE	"art/kosinskiplusm/Hook on chain from WFZ.kospm"
	even
ArtNem_WfzGunPlatform:		BINCLUDE	"art/kosinskiplusm/Retracting platform from WFZ.kospm"
	even
ArtNem_WfzConveyorBeltWheel:	BINCLUDE	"art/kosinskiplusm/Wheel for belt in WFZ.kospm"
	even
ArtNem_WfzFloatingPlatform:	BINCLUDE	"art/kosinskiplusm/Moving platform from WFZ.kospm"
	even
ArtNem_WfzVrtclLazer:		BINCLUDE	"art/kosinskiplusm/Unused vertical laser in WFZ.kospm"
	even
ArtNem_Clouds:			BINCLUDE	"art/kosinskiplusm/Clouds.kospm"
	even
ArtNem_WfzHrzntlLazer:		BINCLUDE	"art/kosinskiplusm/Red horizontal laser from WFZ.kospm"
	even
ArtNem_WfzLaunchCatapult:	BINCLUDE	"art/kosinskiplusm/Catapult that shoots Sonic to the side from WFZ.kospm"
	even
ArtNem_WfzBeltPlatform:		BINCLUDE	"art/kosinskiplusm/Platform on belt in WFZ.kospm"
	even
ArtNem_WfzUnusedBadnik:		BINCLUDE	"art/kosinskiplusm/Unused badnik from WFZ.kospm" ; This is not grouped with the zone's badniks, suggesting that it's not a badnik at all.
	even
ArtNem_WfzVrtclPrpllr:		BINCLUDE	"art/kosinskiplusm/Vertical spinning blades in WFZ.kospm"
	even
ArtNem_WfzHrzntlPrpllr:		BINCLUDE	"art/kosinskiplusm/Horizontal spinning blades in WFZ.kospm"
	even
ArtNem_WfzTiltPlatforms:	BINCLUDE	"art/kosinskiplusm/Tilting plaforms in WFZ.kospm"
	even
ArtNem_WfzThrust:		BINCLUDE	"art/kosinskiplusm/Thrust from Robotnik's getaway ship in WFZ.kospm"
	even
ArtNem_WFZBoss:			BINCLUDE	"art/kosinskiplusm/WFZ boss.kospm"
	even
ArtNem_RobotnikUpper:		BINCLUDE	"art/kosinskiplusm/Robotnik's head.kospm"
	even
ArtNem_RobotnikRunning:		BINCLUDE	"art/kosinskiplusm/Robotnik.kospm"
	even
ArtNem_RobotnikLower:		BINCLUDE	"art/kosinskiplusm/Robotnik's lower half.kospm"
	even
ArtNem_DEZWindow:		BINCLUDE	"art/kosinskiplusm/Window in back that Robotnik looks through in DEZ.kospm"
	even
ArtNem_DEZBoss:			BINCLUDE	"art/kosinskiplusm/Eggrobo.kospm"
	even
; This last-minute badnik addition was mistakenly included with the WFZ/DEZ assets instead of in its own 'CNZ Badnik Assets' section.
ArtNem_Crawl:			BINCLUDE	"art/kosinskiplusm/Bouncer badnik from CNZ.kospm"
	even
ArtNem_TornadoThruster:		BINCLUDE	"art/kosinskiplusm/Rocket thruster for Tornado.kospm"
	even


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; LEVEL ART AND BLOCK MAPPINGS (16x16 and 128x128)
;
; #define BLOCK_TBL_LEN  // table length unknown
; #define BIGBLOCK_TBL_LEN // table length unknown
; typedef uint16_t uword
;
; struct blockMapElement {
;  uword unk : 5;    // u
;  uword patternIndex : 11; };  // i
; // uuuu uiii iiii iiii
;
; blockMapElement (*blockMapTable)[BLOCK_TBL_LEN][4] = 0xFFFF9000
;
; struct bigBlockMapElement {
;  uword : 4
;  uword blockMapIndex : 12; };  //I
; // 0000 IIII IIII IIII
;
; bigBlockMapElement (*bigBlockMapTable)[BIGBLOCK_TBL_LEN][64] = 0xFFFF0000
;
; /*
; This data determines how the level blocks will be constructed graphically. There are
; two kinds of block mappings: 16x16 and 128x128.
;
; 16x16 blocks are made up of four cells arranged in a square (thus, 16x16 pixels).
; Two bytes are used to define each cell, so the block is 8 bytes long. It can be
; represented by the bitmap blockMapElement, of which the members are:
;
; unk
;  These bits have to do with pattern orientation. I do not know their exact
;  meaning.
; patternIndex
;  The pattern's address divided by $20. Otherwise said: an index into the
;  pattern array.
;
; Each mapping can be expressed as an array of four blockMapElements, while the
; whole table is expressed as a two-dimensional array of blockMapElements (blockMapTable).
; The maps are read in left-to-right, top-to-bottom order.
;
; 128x128 maps are basically lists of indices into blockMapTable. The levels are built
; out of these "big blocks", rather than the "small" 16x16 blocks. bigBlockMapTable is,
; predictably, the table of big block mappings.
; Each big block is 8 16x16 blocks, or 16 cells, square. This produces a total of 16
; blocks or 64 cells.
; As noted earlier, each element of the table provides 'i' for blockMapTable[i][j].
; */

; All of these are compressed in the Kosinski format.

BM16_EHZ:	BINCLUDE	"mappings/16x16/EHZ.kosp"
ArtKos_EHZ:	BINCLUDE	"art/kosinski/EHZ_HTZ.kosp"
BM16_HTZ:	BINCLUDE	"mappings/16x16/HTZ.kosp"
ArtKos_HTZ:	BINCLUDE	"art/kosinski/HTZ_Supp.kosp" ; HTZ pattern suppliment to EHZ level patterns
BM128_EHZ:	BINCLUDE	"mappings/128x128/EHZ_HTZ.kosp"

BM16_MTZ:	BINCLUDE	"mappings/16x16/MTZ.kosp"
ArtKos_MTZ:	BINCLUDE	"art/kosinski/MTZ.kosp"
BM128_MTZ:	BINCLUDE	"mappings/128x128/MTZ.kosp"

BM16_HPZ:	BINCLUDE	"mappings/16x16/HPZ.kosp"
ArtKos_HPZ:	BINCLUDE	"art/kosinski/HPZ.kosp"
BM128_HPZ:	BINCLUDE	"mappings/128x128/HPZ.kosp"

BM16_OOZ:	BINCLUDE	"mappings/16x16/OOZ.kosp"
ArtKos_OOZ:	BINCLUDE	"art/kosinski/OOZ.kosp"
BM128_OOZ:	BINCLUDE	"mappings/128x128/OOZ.kosp"

BM16_MCZ:	BINCLUDE	"mappings/16x16/MCZ.kosp"
ArtKos_MCZ:	BINCLUDE	"art/kosinski/MCZ.kosp"
BM128_MCZ:	BINCLUDE	"mappings/128x128/MCZ.kosp"

BM16_CNZ:	BINCLUDE	"mappings/16x16/CNZ.kosp"
ArtKos_CNZ:	BINCLUDE	"art/kosinski/CNZ.kosp"
BM128_CNZ:	BINCLUDE	"mappings/128x128/CNZ.kosp"

BM16_CPZ:	BINCLUDE	"mappings/16x16/CPZ_DEZ.kosp"
ArtKos_CPZ:	BINCLUDE	"art/kosinski/CPZ_DEZ.kosp"
BM128_CPZ:	BINCLUDE	"mappings/128x128/CPZ_DEZ.kosp"

BM16_ARZ:	BINCLUDE	"mappings/16x16/ARZ.kosp"
ArtKos_ARZ:	BINCLUDE	"art/kosinski/ARZ.kosp"
BM128_ARZ:	BINCLUDE	"mappings/128x128/ARZ.kosp"

BM16_WFZ:	BINCLUDE	"mappings/16x16/WFZ_SCZ.kosp"
ArtKos_SCZ:	BINCLUDE	"art/kosinski/WFZ_SCZ.kosp"
ArtKos_WFZ:	BINCLUDE	"art/kosinski/WFZ_Supp.kosp" ; WFZ pattern suppliment to SCZ tiles
BM128_WFZ:	BINCLUDE	"mappings/128x128/WFZ_SCZ.kosp"

;--------------------------------------------------------------------------------------
; Offset index of ring locations
;  The first commented number on each line is an array index; the second is the
;  associated zone.
;--------------------------------------------------------------------------------------
Off_Rings: zoneOrderedOffsetTable 4,2
	; EHZ
	zoneTableEntry.l  Rings_EHZ_1	; Act 1
	zoneTableEntry.l  Rings_EHZ_2	; Act 2
	; Zone 1
	zoneTableEntry.l  Rings_Lev1_1	; Act 1
	zoneTableEntry.l  Rings_Lev1_2	; Act 2
	; WZ
	zoneTableEntry.l  Rings_WZ_1	; Act 1
	zoneTableEntry.l  Rings_WZ_2	; Act 2
	; Zone 3
	zoneTableEntry.l  Rings_Lev3_1	; Act 1
	zoneTableEntry.l  Rings_Lev3_2	; Act 2
	; MTZ
	zoneTableEntry.l  Rings_MTZ_1	; Act 1
	zoneTableEntry.l  Rings_MTZ_2	; Act 2
	; MTZ
	zoneTableEntry.l  Rings_MTZ_3	; Act 3
	zoneTableEntry.l  Rings_MTZ_4	; Act 4
	; WFZ
	zoneTableEntry.l  Rings_WFZ_1	; Act 1
	zoneTableEntry.l  Rings_WFZ_2	; Act 2
	; HTZ
	zoneTableEntry.l  Rings_HTZ_1	; Act 1
	zoneTableEntry.l  Rings_HTZ_2	; Act 2
	; HPZ
	zoneTableEntry.l  Rings_HPZ_1	; Act 1
	zoneTableEntry.l  Rings_HPZ_2	; Act 2
	; Zone 9
	zoneTableEntry.l  Rings_Lev9_1	; Act 1
	zoneTableEntry.l  Rings_Lev9_2	; Act 2
	; OOZ
	zoneTableEntry.l  Rings_OOZ_1	; Act 1
	zoneTableEntry.l  Rings_OOZ_2	; Act 2
	; MCZ
	zoneTableEntry.l  Rings_MCZ_1	; Act 1
	zoneTableEntry.l  Rings_MCZ_2	; Act 2
	; CNZ
	zoneTableEntry.l  Rings_CNZ_1	; Act 1
	zoneTableEntry.l  Rings_CNZ_2	; Act 2
	; CPZ
	zoneTableEntry.l  Rings_CPZ_1	; Act 1
	zoneTableEntry.l  Rings_CPZ_2	; Act 2
	; DEZ
	zoneTableEntry.l  Rings_DEZ_1	; Act 1
	zoneTableEntry.l  Rings_DEZ_2	; Act 2
	; ARZ
	zoneTableEntry.l  Rings_ARZ_1	; Act 1
	zoneTableEntry.l  Rings_ARZ_2	; Act 2
	; SCZ
	zoneTableEntry.l  Rings_SCZ_1	; Act 1
	zoneTableEntry.l  Rings_SCZ_2	; Act 2
    zoneTableEnd

Rings_EHZ_1:	BINCLUDE	"level/rings/EHZ_1.bin"
Rings_EHZ_2:	BINCLUDE	"level/rings/EHZ_2.bin"
Rings_Lev1_1:	BINCLUDE	"level/rings/01_1.bin"
Rings_Lev1_2:	BINCLUDE	"level/rings/01_2.bin"
Rings_WZ_1:	BINCLUDE	"level/rings/WZ_1.bin"
Rings_WZ_2:	BINCLUDE	"level/rings/WZ_2.bin"
Rings_Lev3_1:	BINCLUDE	"level/rings/03_1.bin"
Rings_Lev3_2:	BINCLUDE	"level/rings/03_2.bin"
Rings_MTZ_1:	BINCLUDE	"level/rings/MTZ_1.bin"
Rings_MTZ_2:	BINCLUDE	"level/rings/MTZ_2.bin"
Rings_MTZ_3:	BINCLUDE	"level/rings/MTZ_3.bin"
Rings_MTZ_4:	BINCLUDE	"level/rings/MTZ_4.bin"
Rings_HTZ_1:	BINCLUDE	"level/rings/HTZ_1.bin"
Rings_HTZ_2:	BINCLUDE	"level/rings/HTZ_2.bin"
Rings_HPZ_1:	BINCLUDE	"level/rings/HPZ_1.bin"
Rings_HPZ_2:	BINCLUDE	"level/rings/HPZ_2.bin"
Rings_Lev9_1:	BINCLUDE	"level/rings/09_1.bin"
Rings_Lev9_2:	BINCLUDE	"level/rings/09_2.bin"
Rings_OOZ_1:	BINCLUDE	"level/rings/OOZ_1.bin"
Rings_OOZ_2:	BINCLUDE	"level/rings/OOZ_2.bin"
Rings_MCZ_1:	BINCLUDE	"level/rings/MCZ_1.bin"
Rings_MCZ_2:	BINCLUDE	"level/rings/MCZ_2.bin"
Rings_CNZ_1:	BINCLUDE	"level/rings/CNZ_1.bin"
Rings_CNZ_2:	BINCLUDE	"level/rings/CNZ_2.bin"
Rings_CPZ_1:	BINCLUDE	"level/rings/CPZ_1.bin"
Rings_CPZ_2:	BINCLUDE	"level/rings/CPZ_2.bin"
Rings_DEZ_1:	BINCLUDE	"level/rings/DEZ_1.bin"
Rings_DEZ_2:	BINCLUDE	"level/rings/DEZ_2.bin"
Rings_WFZ_1:	BINCLUDE	"level/rings/WFZ_1.bin"
Rings_WFZ_2:	BINCLUDE	"level/rings/WFZ_2.bin"
Rings_ARZ_1:	BINCLUDE	"level/rings/ARZ_1.bin"
Rings_ARZ_2:	BINCLUDE	"level/rings/ARZ_2.bin"
Rings_SCZ_1:	BINCLUDE	"level/rings/SCZ_1.bin"
Rings_SCZ_2:	BINCLUDE	"level/rings/SCZ_2.bin"
	even

; --------------------------------------------------------------------------------------
; Offset index of object locations
; --------------------------------------------------------------------------------------
Off_Objects: zoneOrderedOffsetTable 4,2
	; EHZ
	zoneTableEntry.l  Objects_EHZ_1	; Act 1
	zoneTableEntry.l  Objects_EHZ_2	; Act 2
	; Zone 1
	zoneTableEntry.l  Objects_Null	; Act 1
	zoneTableEntry.l  Objects_Null	; Act 2
	; WZ
	zoneTableEntry.l  Objects_Null	; Act 1
	zoneTableEntry.l  Objects_Null	; Act 2
	; Zone 3
	zoneTableEntry.l  Objects_Null	; Act 1
	zoneTableEntry.l  Objects_Null	; Act 2
	; MTZ
	zoneTableEntry.l  Objects_MTZ_1	; Act 1
	zoneTableEntry.l  Objects_MTZ_2	; Act 2
	; MTZ
	zoneTableEntry.l  Objects_MTZ_3	; Act 3
	zoneTableEntry.l  Objects_MTZ_3	; Act 4
	; WFZ
	zoneTableEntry.l  Objects_WFZ_1	; Act 1
	zoneTableEntry.l  Objects_WFZ_2	; Act 2
	; HTZ
	zoneTableEntry.l  Objects_HTZ_1	; Act 1
	zoneTableEntry.l  Objects_HTZ_2	; Act 2
	; HPZ
	zoneTableEntry.l  Objects_HPZ_1	; Act 1
	zoneTableEntry.l  Objects_HPZ_2	; Act 2
	; Zone 9
	zoneTableEntry.l  Objects_Null	; Act 1
	zoneTableEntry.l  Objects_Null	; Act 2
	; OOZ
	zoneTableEntry.l  Objects_OOZ_1	; Act 1
	zoneTableEntry.l  Objects_OOZ_2	; Act 2
	; MCZ
	zoneTableEntry.l  Objects_MCZ_1	; Act 1
	zoneTableEntry.l  Objects_MCZ_2	; Act 2
	; CNZ
	zoneTableEntry.l  Objects_CNZ_1	; Act 1
	zoneTableEntry.l  Objects_CNZ_2	; Act 2
	; CPZ
	zoneTableEntry.l  Objects_CPZ_1	; Act 1
	zoneTableEntry.l  Objects_CPZ_2	; Act 2
	; DEZ
	zoneTableEntry.l  Objects_DEZ_1	; Act 1
	zoneTableEntry.l  Objects_DEZ_2	; Act 2
	; ARZ
	zoneTableEntry.l  Objects_ARZ_1	; Act 1
	zoneTableEntry.l  Objects_ARZ_2	; Act 2
	; SCZ
	zoneTableEntry.l  Objects_SCZ_1	; Act 1
	zoneTableEntry.l  Objects_SCZ_2	; Act 2
    zoneTableEnd

	; These things act as boundaries for the object layout parser, so it doesn't read past the end/beginning of the file
	ObjectLayoutBoundary
Objects_EHZ_1:	BINCLUDE	"level/objects/EHZ_1.bin"
	ObjectLayoutBoundary

Objects_EHZ_2:	BINCLUDE	"level/objects/EHZ_2.bin"

	ObjectLayoutBoundary
Objects_MTZ_1:	BINCLUDE	"level/objects/MTZ_1.bin"
	ObjectLayoutBoundary
Objects_MTZ_2:	BINCLUDE	"level/objects/MTZ_2.bin"
	ObjectLayoutBoundary
Objects_MTZ_3:	BINCLUDE	"level/objects/MTZ_3.bin"
	ObjectLayoutBoundary

Objects_WFZ_1:	BINCLUDE	"level/objects/WFZ_1.bin"

	ObjectLayoutBoundary
Objects_WFZ_2:	BINCLUDE	"level/objects/WFZ_2.bin"
	ObjectLayoutBoundary
Objects_HTZ_1:	BINCLUDE	"level/objects/HTZ_1.bin"
	ObjectLayoutBoundary
Objects_HTZ_2:	BINCLUDE	"level/objects/HTZ_2.bin"
	ObjectLayoutBoundary
Objects_HPZ_1:	BINCLUDE	"level/objects/HPZ_1.bin"
	ObjectLayoutBoundary
Objects_HPZ_2:	BINCLUDE	"level/objects/HPZ_2.bin"
	ObjectLayoutBoundary
Objects_OOZ_1:	BINCLUDE	"level/objects/OOZ_1.bin"
	ObjectLayoutBoundary
Objects_OOZ_2:	BINCLUDE	"level/objects/OOZ_2.bin"
	ObjectLayoutBoundary
Objects_MCZ_1:	BINCLUDE	"level/objects/MCZ_1.bin"
	ObjectLayoutBoundary
Objects_MCZ_2:	BINCLUDE	"level/objects/MCZ_2.bin"
	ObjectLayoutBoundary

Objects_CNZ_1:	BINCLUDE	"level/objects/CNZ_1.bin"
	ObjectLayoutBoundary
Objects_CNZ_2:	BINCLUDE	"level/objects/CNZ_2.bin"


	ObjectLayoutBoundary
Objects_CPZ_1:	BINCLUDE	"level/objects/CPZ_1.bin"
	ObjectLayoutBoundary
Objects_CPZ_2:	BINCLUDE	"level/objects/CPZ_2.bin"
	ObjectLayoutBoundary
Objects_DEZ_1:	BINCLUDE	"level/objects/DEZ_1.bin"
	ObjectLayoutBoundary
Objects_DEZ_2:	BINCLUDE	"level/objects/DEZ_2.bin"
	ObjectLayoutBoundary
Objects_ARZ_1:	BINCLUDE	"level/objects/ARZ_1.bin"
	ObjectLayoutBoundary
Objects_ARZ_2:	BINCLUDE	"level/objects/ARZ_2.bin"
	ObjectLayoutBoundary
Objects_SCZ_1:	BINCLUDE	"level/objects/SCZ_1.bin"
	ObjectLayoutBoundary
Objects_SCZ_2:	BINCLUDE	"level/objects/SCZ_2.bin"
	ObjectLayoutBoundary
Objects_Null:
	ObjectLayoutBoundary

; --------------------------------------------------------------------------------------
; EHZ/HTZ Assets
; --------------------------------------------------------------------------------------
ArtNem_HtzFireball1:		BINCLUDE	"art/kosinskiplusm/Fireball 1.kospm"
	even
ArtNem_Waterfall:		BINCLUDE	"art/kosinskiplusm/Waterfall tiles.kospm"
	even
ArtNem_HtzFireball2:		BINCLUDE	"art/kosinskiplusm/Fireball 2.kospm"
	even
ArtNem_EHZ_Bridge:		BINCLUDE	"art/kosinskiplusm/EHZ bridge.kospm"
	even
ArtNem_HtzZipline:		BINCLUDE	"art/kosinskiplusm/HTZ zip-line platform.kospm"
	even
ArtNem_HtzValveBarrier:		BINCLUDE	"art/kosinskiplusm/One way barrier from HTZ.kospm"
	even
ArtNem_HtzSeeSaw:		BINCLUDE	"art/kosinskiplusm/See-saw in HTZ.kospm"
	even
ArtNem_HtzRock:			BINCLUDE	"art/kosinskiplusm/Rock from HTZ.kospm"
	even
ArtNem_Sol:			BINCLUDE	"art/kosinskiplusm/Sol badnik from HTZ.kospm" ; Not grouped with the other badniks for some reason...
	even

; --------------------------------------------------------------------------------------
; MTZ Assets
; --------------------------------------------------------------------------------------
ArtNem_MtzWheel:		BINCLUDE	"art/kosinskiplusm/Large spinning wheel from MTZ.kospm"
	even
ArtNem_MtzWheelIndent:		BINCLUDE	"art/kosinskiplusm/Large spinning wheel from MTZ - indent.kospm"
	even
ArtNem_MtzSpikeBlock:		BINCLUDE	"art/kosinskiplusm/MTZ spike block.kospm"
	even
ArtNem_MtzSteam:		BINCLUDE	"art/kosinskiplusm/Steam from MTZ.kospm"
	even
ArtNem_MtzSpike:		BINCLUDE	"art/kosinskiplusm/Spike from MTZ.kospm"
	even
ArtNem_MtzAsstBlocks:		BINCLUDE	"art/kosinskiplusm/Similarly shaded blocks from MTZ.kospm"
	even
ArtNem_MtzLavaBubble:		BINCLUDE	"art/kosinskiplusm/Lava bubble from MTZ.kospm"
	even
ArtNem_LavaCup:			BINCLUDE	"art/kosinskiplusm/Lava cup from MTZ.kospm"
	even
ArtNem_BoltEnd_Rope:		BINCLUDE	"art/kosinskiplusm/Bolt end and rope from MTZ.kospm"
	even	
ArtNem_MtzCog:			BINCLUDE	"art/kosinskiplusm/Small cog from MTZ.kospm"
	even
ArtNem_MtzSpinTubeFlash:	BINCLUDE	"art/kosinskiplusm/Spin tube flash from MTZ.kospm"
	even

; --------------------------------------------------------------------------------------
; MCZ Assets
; --------------------------------------------------------------------------------------
ArtNem_Crate:			BINCLUDE	"art/kosinskiplusm/Large wooden box from MCZ.kospm"
	even
ArtNem_MCZCollapsePlat:		BINCLUDE	"art/kosinskiplusm/Collapsing platform from MCZ.kospm"
	even
ArtNem_VineSwitch:		BINCLUDE	"art/kosinskiplusm/Pull switch from MCZ.kospm"
	even
ArtNem_VinePulley:		BINCLUDE	"art/kosinskiplusm/Vine that lowers from MCZ.kospm"
	even
ArtNem_MCZGateLog:		BINCLUDE	"art/kosinskiplusm/Drawbridge logs from MCZ.kospm"
	even

; ---------------------------------------------------------------------------
; Subroutine to load the sound driver
; ---------------------------------------------------------------------------
; sub_EC000:
SoundDriverLoad:
	move.w	sr,-(sp)
	move.w	#$2700,sr
	lea	(Z80_Bus_Request).l,a3
	lea	(Z80_Reset).l,a2
	moveq	#0,d2
	move.w	#$100,d1
	move.w	d1,(a2)	; release Z80 reset (was held high by console on startup)
	move.w	d1,(a3)	; get Z80 bus
-	btst	d2,(a3)
	bne.s	-	; wait until the 68000 has the bus
	lea	Snd_Driver(pc),a0
	lea	(Z80_RAM).l,a1
	jsr	(KosPlusDec).w
	btst	#0,(VDP_control_port+1).l	; check video mode
	sne	(Z80_RAM+zPalModeByte).l	; set if PAL
	move.w	d2,(a2)	; hold Z80 reset
	moveq	#$7F,d3
	dbf	d3,*
	move.w	d1,(a2)	; release Z80 reset
	move.w	d2,(a3)	; release Z80 bus
	move.w	(sp)+,sr
	rts

; ===========================================================================
; ---------------------------------------------------------------------------
; S2 sound driver (Sound driver compression (slightly modified Saxman))
; ---------------------------------------------------------------------------
; loc_EC0E8:
Snd_Driver:
	save
	include "s2.sounddriver.asm" ; CPU Z80
	restore
	padding off
	!org (Snd_Driver+Size_of_Snd_driver_guess) ; don't worry; I know what I'm doing

; loc_ED04C:
Snd_Driver_End:

; ---------------------------------------------------------------------------
; Music pointers
; ---------------------------------------------------------------------------

; loc_F0000:
MusicPoint1:	startBank

SndDAC_Kick:	include	"sound/DAC/generated/Kick.inc"
SndDAC_Snare:	include	"sound/DAC/generated/Snare.inc"
SndDAC_Timpani:	include	"sound/DAC/generated/Timpani.inc"
SndDAC_Tom:	include	"sound/DAC/generated/Tom.inc"
SndDAC_Clap:	include	"sound/DAC/generated/Clap.inc"
SndDAC_Scratch:	include	"sound/DAC/generated/Scratch.inc"
SndDAC_Bongo:	include	"sound/DAC/generated/Bongo.inc"
Mus_ARZ:	include	"sound/music/87 - ARZ.asm"
Mus_Invincible:	include	"sound/music/97 - Invincible.asm"
Mus_Credits:	include	"sound/music/9E - Credits.asm"
Sound20:	include "sound/sfx/A0 - Jump.asm"
Sound21:	include "sound/sfx/A1 - Checkpoint.asm"
Sound22:	include "sound/sfx/A2 - Spike Switch.asm"
Sound23:	include "sound/sfx/A3 - Hurt.asm"
Sound24:	include "sound/sfx/A4 - Skidding.asm"
Sound25:	include "sound/sfx/A5 - Block Push.asm"
Sound26:	include "sound/sfx/A6 - Hurt by Spikes.asm"
Sound27:	include "sound/sfx/A7 - Sparkle.asm"
Sound28:	include "sound/sfx/A8 - Beep.asm"
Sound29:	include "sound/sfx/A9 - Special Stage Item (Unused).asm"
Sound2A:	include "sound/sfx/AA - Splash.asm"
Sound2B:	include "sound/sfx/AB - Swish.asm"
Sound2C:	include "sound/sfx/AC - Boss Hit.asm"
Sound2D:	include "sound/sfx/AD - Inhaling Bubble.asm"
Sound2E:	include "sound/sfx/AE - Lava Ball.asm"
Sound2F:	include "sound/sfx/AF - Shield.asm"
Sound30:	include "sound/sfx/B0 - Laser Beam.asm"
Sound31:	include "sound/sfx/B1 - Electricity (Unused).asm"
Sound32:	include "sound/sfx/B2 - Drown.asm"
Sound33:	include "sound/sfx/B3 - Fire Burn.asm"
Sound34:	include "sound/sfx/B4 - Bumper.asm"
Sound35:	include "sound/sfx/B5 - Ring.asm"
Sound36:	include "sound/sfx/B6 - Spikes Move.asm"
Sound37:	include "sound/sfx/B7 - Rumbling.asm"
Sound38:	include "sound/sfx/B8 - Unknown (Unused).asm"
Sound39:	include "sound/sfx/B9 - Smash.asm"
Sound3A:	include "sound/sfx/BA - Special Stage Glass (Unused).asm"
Sound3B:	include "sound/sfx/BB - Door Slam.asm"
Sound3C:	include "sound/sfx/BC - Spin Dash Release.asm"
Sound3D:	include "sound/sfx/BD - Hammer.asm"
Sound3E:	include "sound/sfx/BE - Roll.asm"
Sound3F:	include "sound/sfx/BF - Continue Jingle.asm"
Sound40:	include "sound/sfx/C0 - Casino Bonus.asm"
Sound41:	include "sound/sfx/C1 - Explosion.asm"
Sound42:	include "sound/sfx/C2 - Water Warning.asm"
Sound43:	include "sound/sfx/C3 - Enter Giant Ring (Unused).asm"
Sound44:	include "sound/sfx/C4 - Boss Explosion.asm"
Sound45:	include "sound/sfx/C5 - Tally End.asm"
Sound46:	include "sound/sfx/C6 - Ring Spill.asm"
Sound47:	include "sound/sfx/C7 - Chain Rise (Unused).asm"
Sound48:	include "sound/sfx/C8 - Flamethrower.asm"
Sound49:	include "sound/sfx/C9 - Hidden Bonus (Unused).asm"
Sound4A:	include "sound/sfx/CA - Special Stage Entry.asm"
Sound4B:	include "sound/sfx/CB - Slow Smash.asm"
Sound4C:	include "sound/sfx/CC - Spring.asm"
Sound4D:	include "sound/sfx/CD - Switch.asm"
Sound4E:	include "sound/sfx/CE - Ring Left Speaker.asm"
Sound4F:	include "sound/sfx/CF - Signpost.asm"
Sound50:	include "sound/sfx/D0 - CNZ Boss Zap.asm"
Sound51:	include "sound/sfx/D1 - Unknown (Unused).asm"
Sound52:	include "sound/sfx/D2 - Unknown (Unused).asm"
Sound53:	include "sound/sfx/D3 - Signpost 2P.asm"
Sound54:	include "sound/sfx/D4 - OOZ Lid Pop.asm"
Sound55:	include "sound/sfx/D5 - Sliding Spike.asm"
Sound56:	include "sound/sfx/D6 - CNZ Elevator.asm"
Sound57:	include "sound/sfx/D7 - Platform Knock.asm"
Sound58:	include "sound/sfx/D8 - Bonus Bumper.asm"
Sound59:	include "sound/sfx/D9 - Large Bumper.asm"
Sound5A:	include "sound/sfx/DA - Gloop.asm"
Sound5B:	include "sound/sfx/DB - Pre-Arrow Firing.asm"
Sound5C:	include "sound/sfx/DC - Fire.asm"
Sound5D:	include "sound/sfx/DD - Arrow Stick.asm"
Sound5E:	include "sound/sfx/DE - Helicopter.asm"
Sound5F:	include "sound/sfx/DF - Super Transform.asm"
Sound60:	include "sound/sfx/E0 - Spin Dash Rev.asm"
Sound61:	include "sound/sfx/E1 - Rumbling 2.asm"
Sound62:	include "sound/sfx/E2 - CNZ Launch.asm"
Sound63:	include "sound/sfx/E3 - Flipper.asm"
Sound64:	include "sound/sfx/E4 - HTZ Lift Click.asm"
Sound65:	include "sound/sfx/E5 - Leaves.asm"
Sound66:	include "sound/sfx/E6 - Mega Mack Drop.asm"
Sound67:	include "sound/sfx/E7 - Drawbridge Move.asm"
Sound68:	include "sound/sfx/E8 - Quick Door Slam.asm"
Sound69:	include "sound/sfx/E9 - Drawbridge Down.asm"
Sound6A:	include "sound/sfx/EA - Laser Burst.asm"
Sound6B:	include "sound/sfx/EB - Scatter.asm"
Sound6C:	include "sound/sfx/EC - Teleport.asm"
Sound6D:	include "sound/sfx/ED - Error.asm"
Sound6E:	include "sound/sfx/EE - Mecha Sonic Buzz.asm"
Sound6F:	include "sound/sfx/EF - Large Laser.asm"
Sound70:	include "sound/sfx/F0 - Oil Slide.asm"

	finishBank

; ----------------------------------------------------------------------------------
; Filler (free space)
; ----------------------------------------------------------------------------------
	; the PCM data has to line up with the end of the bank.
	cnop -Size_of_SEGA_sound, $8000

; -------------------------------------------------------------------------------
; Sega Intro Sound
; 8-bit unsigned raw audio at 16Khz
; -------------------------------------------------------------------------------
; loc_F1E8C:
Snd_Sega:	include	"sound/PCM/generated/SEGA.inc"

	if Snd_Sega.size > $8000
		fatal "Sega sound must fit within $8000 bytes, but you have a $\{Snd_Sega.size} byte Sega sound."
	endif
	if Snd_Sega.size > Size_of_SEGA_sound
		fatal "Size_of_SEGA_sound = $\{Size_of_SEGA_sound}, but you have a $\{Snd_Sega.size} byte Sega sound."
	endif

; ------------------------------------------------------------------------------
; Music pointers
; ------------------------------------------------------------------------------
; loc_F8000:
MusicPoint2:	startBank

; loc_F803C:
Mus_HPZ:	include	"sound/music/90 - HPZ.asm"
Mus_Drowning:	include	"sound/music/9F - Drowning.asm"
Mus_CNZ_2P:	include	"sound/music/88 - CNZ 2P.asm"
Mus_EHZ:	include	"sound/music/82 - EHZ.asm"
Mus_MTZ:	include	"sound/music/85 - MTZ.asm"
Mus_CNZ:	include	"sound/music/89 - CNZ.asm"
Mus_MCZ:	include	"sound/music/8B - MCZ.asm"
Mus_MCZ_2P:	include	"sound/music/83 - MCZ 2P.asm"
Mus_DEZ:	include	"sound/music/8A - DEZ.asm"
Mus_SpecStage:	include	"sound/music/92 - Special Stage.asm"
Mus_Options:	include	"sound/music/91 - Options.asm"
Mus_Ending:	include	"sound/music/95 - Ending.asm"
Mus_EndBoss:	include	"sound/music/94 - Final Boss.asm"
Mus_CPZ:	include	"sound/music/8E - CPZ.asm"
Mus_Boss:	include	"sound/music/93 - Boss.asm"
Mus_SCZ:	include	"sound/music/8D - SCZ.asm"
Mus_OOZ:	include	"sound/music/84 - OOZ.asm"
Mus_WFZ:	include	"sound/music/8F - WFZ.asm"
Mus_EHZ_2P:	include	"sound/music/8C - EHZ 2P.asm"
Mus_2PResult:	include	"sound/music/81 - 2 Player Menu.asm"
Mus_SuperSonic:	include	"sound/music/96 - Super Sonic.asm"
Mus_HTZ:	include	"sound/music/86 - HTZ.asm"
Mus_Title:	include	"sound/music/99 - Title Screen.asm"
Mus_EndLevel:	include	"sound/music/9A - End of Act.asm"
Mus_ExtraLife:	include	"sound/music/98 - Extra Life.asm"
Mus_GameOver:	include	"sound/music/9B - Game Over.asm"
Mus_Continue:	include	"sound/music/9C - Continue.asm"
Mus_Emerald:	include	"sound/music/9D - Got Emerald.asm"

	finishBank

	even
	include	"errorhandler/ErrorHandler.asm"

; end of 'ROM'
	if padToPowerOfTwo && (*-StartOfRom)&(*-StartOfRom-1)
		cnop	-1,2<<lastbit(*-StartOfRom-1)
		dc.b	$00
paddingSoFar	:= paddingSoFar+1
	else
		even
	endif
EndOfRom:
	if MOMPASS=2
		; "About" because it will be off by the same amount that Size_of_Snd_driver_guess is incorrect (if you changed it), and because I may have missed a small amount of internal padding somewhere
		message "ROM size is $\{EndOfRom-StartOfRom} bytes (\{(EndOfRom-StartOfRom)/1024.0} KiB). About $\{paddingSoFar} bytes are padding. "
	endif
	END
