; ---------------------------------------------------------------------------
; Objects Manager
; Subroutine that keeps track of any objects that need to remember
; their state, such as monitors or enemies.
;
; input variables:
;  -none-
;
; writes:
;  d0, d1
;  d2 = respawn index of object to load
;  d6 = camera position
;
;  a0 = address in object placement list
;  a2 = respawn table
; ---------------------------------------------------------------------------

; loc_17AA4
ObjectsManager:
	moveq	#0,d0
	move.b	(Obj_placement_routine).w,d0
	move.w	ObjectsManager_States(pc,d0.w),d0
	jmp	ObjectsManager_States(pc,d0.w)
; ===========================================================================
ObjectsManager_States: offsetTable
	offsetTableEntry.w ObjectsManager_Init		; 0
	offsetTableEntry.w ObjectsManager_Main		; 2
; ===========================================================================
; loc_17AB8
ObjectsManager_Init:
	addq.b	#2,(Obj_placement_routine).w
	move.w	(Current_ZoneAndAct).w,d0 ; If level == $0F01 (ARZ 2)...
	ror.b	#1,d0			; then this yields $0F80...
	lsr.w	#5,d0			; and this yields $003E.
	lea	(Off_Objects).l,a0	; Next, we load the first pointer in the object layout list pointer index,
	movea.l	(a0,d0.w),a0		; (Point1 * 2) + $003E
	; initialize each object load address with the first object in the layout
	move.l	a0,(Obj_load_addr_right).w
	move.l	a0,(Obj_load_addr_left).w
	lea	(Object_Respawn_Table).w,a2
	move.w	#$0101,(a2)+	; the first two bytes are not used as respawn values
	; instead, they are used to keep track of the current respawn indexes

	moveq	#bytesToLcnt(Obj_respawn_data_End-Obj_respawn_data),d0 ; set loop counter
	moveq	#0,d1

-	move.l	d1,(a2)+		; loop clears all other respawn values
	dbf	d0,-

    if (Obj_respawn_data_End-Obj_respawn_data)&2
	move.w	d1,(a2)+
    endif

	lea	(Obj_respawn_index).w,a2	; reset a2
	moveq	#0,d2
	move.w	(Camera_X_pos).w,d6
	subi.w	#$80,d6	; look one chunk to the left
	bcc.s	+	; if the result was negative,
	moveq	#0,d6	; cap at zero
+
	andi.w	#$FF80,d6	; limit to increments of $80 (width of a chunk)
	movea.l	(Obj_load_addr_right).w,a0	; load address of object placement list

-	; at the beginning of a level this gives respawn table entries to any object that is one chunk
	; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)
	cmp.w	(a0),d6		; is object's x position >= d6?
	bls.s	loc_17B3E	; if yes, branch
	tst.b	2(a0)	; does the object get a respawn table entry?
	bpl.s	+	; if not, branch
	move.b	(a2),d2
	addq.b	#1,(a2)	; respawn index of next object to the right
+
	addq.w	#6,a0	; next object
	bra.s	-
; ---------------------------------------------------------------------------

loc_17B3E:
	move.l	a0,(Obj_load_addr_right).w	; remember rightmost object that has been processed, so far (we still need to look forward)
	movea.l	(Obj_load_addr_left).w,a0	; reset a0
	subi.w	#$80,d6		; look even farther left (any object behind this is out of range)
	bcs.s	loc_17B62	; branch, if camera position would be behind level's left boundary

-	; count how many objects are behind the screen that are not in range and need to remember their state
	cmp.w	(a0),d6		; is object's x position >= d6?
	bls.s	loc_17B62	; if yes, branch
	tst.b	2(a0)	; does the object get a respawn table entry?
	bpl.s	+	; if not, branch
	addq.b	#1,1(a2)	; respawn index of current object to the left

+
	addq.w	#6,a0
	bra.s	-	; continue with next object
; ---------------------------------------------------------------------------

loc_17B62:
	move.l	a0,(Obj_load_addr_left).w	; remember current object from the left
	move.w	#-1,(Camera_X_pos_last).w	; make sure ObjectsManager_GoingForward is run

; loc_17B84
ObjectsManager_Main:
	moveq	#-$80,d0
	move.w	(Camera_X_pos).w,d1
	add.w	d0,d1
	and.w	d0,d1
	move.w	d1,(Camera_X_pos_coarse).w

	lea	(Obj_respawn_index).w,a2
	moveq	#0,d2
	moveq	#-$80,d6
	and.w	(Camera_X_pos).w,d6
	cmp.w	(Camera_X_pos_last).w,d6	; is the X range the same as last time?
	beq.w	ObjectsManager_SameXRange	; if yes, branch (rts)
	bge.s	ObjectsManager_GoingForward	; if new pos is greater than old pos, branch

	; if the player is moving back
;ObjectsManager_GoingBackward:
	move.w	d6,(Camera_X_pos_last).w	; remember current position for next time

	movea.l	(Obj_load_addr_left).w,a0	; get current object from the left
	subi.w	#$80,d6		; look one chunk to the left
	bcs.s	.done1		; branch, if camera position would be behind level's left boundary

.nextObject1:
	; load all objects left of the screen that are now in range
	cmp.w	-6(a0),d6	; is the previous object's X pos less than d6?
	bge.s	.done1		; if it is, branch
	subq.w	#6,a0		; get object's address
	tst.b	2(a0)		; does the object get a respawn table entry?
	bpl.s	.noRespawn1	; if not, branch
	subq.b	#1,1(a2)	; respawn index of this object
	move.b	1(a2),d2
.noRespawn1:
	bsr.w	ChkLoadObj	; load object
	bne.s	.fullSST	; branch, if SST is full
	subq.w	#6,a0
	bra.s	.nextObject1	; continue with previous object
; ---------------------------------------------------------------------------

.fullSST:
	; undo a few things, if the object couldn't load
	tst.b	2(a0)		; does the object get a respawn table entry?
	bpl.s	.noRespawn3	; if not, branch
	addq.b	#1,1(a2)	; since we didn't load the object, undo last change
.noRespawn3:
	addq.w	#6,a0		; go back to last object
; loc_17BE6:
.done1:
	move.l	a0,(Obj_load_addr_left).w	; remember current object from the left

	movea.l	(Obj_load_addr_right).w,a0	; get next object from the right
	addi.w	#$300,d6			; look two chunks beyond the right edge of the screen

.nextObject2:
	; subtract number of objects that have been moved out of range (from the right side)
	cmp.w	-6(a0),d6	; is the previous object's X pos less than d6?
	bgt.s	.done2		; if it is, branch
	tst.b	-4(a0)		; does the previous object get a respawn table entry?
	bpl.s	.noRespawn2	; if not, branch
	subq.b	#1,(a2)		; respawn index of next object to the right
.noRespawn2:
	subq.w	#6,a0
	bra.s	.nextObject2	; continue with previous object
; ---------------------------------------------------------------------------
; loc_17C04:
.done2:
	move.l	a0,(Obj_load_addr_right).w	; remember next object from the right
	rts
; ---------------------------------------------------------------------------

ObjectsManager_GoingForward:
	move.w	d6,(Camera_X_pos_last).w

	movea.l	(Obj_load_addr_right).w,a0	; get next object from the right
	addi.w	#$280,d6			; look two chunks forward

.nextObject1:
	; load all objects right of the screen that are now in range
	cmp.w	(a0),d6		; is object's x position >= d6?
	bls.s	.done1		; if yes, branch
	tst.b	2(a0)		; does the object get a respawn table entry?
	bpl.s	.noRespawn1	; if not, branch
	move.b	(a2),d2		; respawn index of this object
	addq.b	#1,(a2)		; respawn index of next object to the right
.noRespawn1:
	bsr.w	ChkLoadObj	; load object (and get address of next object)
	beq.s	.nextObject1	; continue loading objects, if the SST isn't full
; loc_17C2A:
.done1:
	move.l	a0,(Obj_load_addr_right).w	; remember next object from the right

	movea.l	(Obj_load_addr_left).w,a0	; get current object from the left
	subi.w	#$300,d6			; look one chunk behind the left edge of the screen
	bcs.s	.done2				; branch, if camera position would be behind level's left boundary

.nextObject2:
	; subtract number of objects that have been moved out of range (from the left)
	cmp.w	(a0),d6		; is object's x position >= d6?
	bls.s	.done2		; if yes, branch
	tst.b	2(a0)		; does the object get a respawn table entry?
	bpl.s	.noRespawn2	; if not, branch
	addq.b	#1,1(a2)	; respawn index of next object to the left
.noRespawn2:
	addq.w	#6,a0
	bra.s	.nextObject2	; continue with previous object
; ---------------------------------------------------------------------------
; loc_17C4A:
.done2:
	move.l	a0,(Obj_load_addr_left).w	; remember current object from the left

ObjectsManager_SameXRange:
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check if an object needs to be loaded.
;
; input variables:
;  d2 = respawn index of object to be loaded
;
;  a0 = address in object placement list
;  a2 = object respawn table
;
; writes:
;  d0, d1
;  a1 = object
; ---------------------------------------------------------------------------
;loc_17F36:
ChkLoadObj:
	tst.b	2(a0)	; does the object get a respawn table entry?
	bpl.s	+	; if not, branch
	bset	#7,2(a2,d2.w)	; mark object as loaded
	beq.s	+		; branch if it wasn't already loaded
	addq.w	#6,a0	; next object
	moveq	#0,d0	; let the objects manager know that it can keep going
	rts
; ---------------------------------------------------------------------------

+
	bsr.s	AllocateObject	; find empty slot
	bne.s	return_17F7E	; branch, if there is no room left in the SST
	move.w	(a0)+,x_pos(a1)
	move.w	(a0)+,d0	; there are three things stored in this word
	bpl.s	+		; branch, if the object doesn't get a respawn table entry
	move.b	d2,respawn_index(a1)
+
	move.w	d0,d1		; copy for later
	andi.w	#$FFF,d0	; get y-position
	move.w	d0,y_pos(a1)
	rol.w	#render_flags.y_flip+2,d1	; adjust bits
	andi.b	#1<<render_flags.x_flip|1<<render_flags.y_flip,d1	; get render flags
	move.b	d1,render_flags(a1)
	move.b	d1,status(a1)
	move.b	(a0)+,id(a1) ; load obj
	move.b	(a0)+,subtype(a1)
	moveq	#0,d0

return_17F7E:
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object array
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_17FDA: ; allocObject: ; SingleObjLoad:
AllocateObject:
	lea	(Dynamic_Object_RAM).w,a1 ; a1=object
	moveq	#(Dynamic_Object_RAM_End-Dynamic_Object_RAM)/object_size-1,d0 ; search to end of table

/
	lea	next_object(a1),a1 ; load obj address ; goto next object RAM slot
	tst.b	id(a1)	; is object RAM slot empty?
	dbeq	d0,-	; repeat until end

return_17FF8:
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object array AFTER the current one in the table
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_17FFA: ; allocObjectAfterCurrent: ; SingleObjLoad2:
AllocateObjectAfterCurrent:
	movea.l	a0,a1
	move.w	#Dynamic_Object_RAM_End,d0	; $D000
	sub.w	a0,d0	; subtract current object location
    if object_size=$40
	lsr.w	#object_size_bits,d0	; divide by $40
	subq.w	#1,d0	; keep from going over the object zone
	bcs.s	return_18014
    else
	lsr.w	#6,d0			; divide by $40
	move.b	+(pc,d0.w),d0		; load the right number of objects from table
	bmi.s	return_18014		; if negative, we have failed!
    endif

-
	lea	next_object(a1),a1 ; load obj address ; goto next object RAM slot
	tst.b	id(a1)	; is object RAM slot empty?
	dbeq	d0,-	; repeat until end

return_18014:
	rts

    if object_size<>$40
+
.a	set	Dynamic_Object_RAM
.b	set	Dynamic_Object_RAM_End
.c	set	.b			; begin from bottom of array and decrease backwards
	rept	(.b-.a+$40-1)/$40	; repeat for all slots, minus exception
.c	set	.c-$40			; address for previous $40 (also skip last part)
	dc.b	(.b-.c-1)/object_size-1	; write possible slots according to object_size division + hack + dbf hack
	endm
	even
    endif