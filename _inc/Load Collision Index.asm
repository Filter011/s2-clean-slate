; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_49BC:
LoadCollisionIndexes:
	move.w	(Current_ZoneAndAct).w,d0
	ror.b	#1,d0
	lsr.w	#4,d0
	move.l	Off_Col(pc,d0.w),(Primary_Collision).w
	move.l	Off_Col+4(pc,d0.w),(Secondary_Collision).w
	rts
; End of function LoadCollisionIndexes

; ===========================================================================
; ---------------------------------------------------------------------------
; Pointers to primary and secondary collision indexes

; Contains an array of pointers to the primary collision index data for each
; level. 1 pointer for each level, pointing the primary collision index.
; ---------------------------------------------------------------------------
Off_Col: zoneOrderedTable 4,4
	zoneTableEntry.l ColP_EHZHTZ	; EHZ1
	zoneTableEntry.l ColS_EHZHTZ	; EHZ1
	zoneTableEntry.l ColP_EHZHTZ	; EHZ2
	zoneTableEntry.l ColS_EHZHTZ	; EHZ2
	zoneTableEntry.l ColP_Invalid	; Zone 1 Act 1
	zoneTableEntry.l ColP_Invalid	; Zone 1 Act 1
	zoneTableEntry.l ColP_Invalid	; Zone 1 Act 2
	zoneTableEntry.l ColP_Invalid	; Zone 1 Act 2
	zoneTableEntry.l ColP_WZ	; WZ1
	zoneTableEntry.l ColP_WZ	; WZ1
	zoneTableEntry.l ColP_WZ	; WZ2
	zoneTableEntry.l ColP_WZ	; WZ2
	zoneTableEntry.l ColP_Invalid	; Zone 3 Act 1
	zoneTableEntry.l ColP_Invalid	; Zone 3 Act 1
	zoneTableEntry.l ColP_Invalid	; Zone 3 Act 2
	zoneTableEntry.l ColP_Invalid	; Zone 3 Act 2
	zoneTableEntry.l ColP_MTZ	; MTZ1
	zoneTableEntry.l ColP_MTZ	; MTZ1
	zoneTableEntry.l ColP_MTZ	; MTZ2
	zoneTableEntry.l ColP_MTZ	; MTZ2
	zoneTableEntry.l ColP_MTZ	; MTZ3
	zoneTableEntry.l ColP_MTZ	; MTZ3
	zoneTableEntry.l ColP_MTZ	; MTZ4
	zoneTableEntry.l ColP_MTZ	; MTZ4
	zoneTableEntry.l ColP_WFZSCZ	; WFZ1
	zoneTableEntry.l ColS_WFZSCZ	; WFZ1
	zoneTableEntry.l ColP_WFZSCZ	; WFZ2
	zoneTableEntry.l ColS_WFZSCZ	; WFZ2
	zoneTableEntry.l ColP_EHZHTZ	; HTZ1
	zoneTableEntry.l ColS_EHZHTZ	; HTZ1
	zoneTableEntry.l ColP_EHZHTZ	; HTZ2
	zoneTableEntry.l ColS_EHZHTZ	; HTZ2
	zoneTableEntry.l ColP_HPZ	; HPZ1
	zoneTableEntry.l ColS_HPZ	; HPZ1
	zoneTableEntry.l ColP_HPZ	; HPZ2
	zoneTableEntry.l ColS_HPZ	; HPZ2
	zoneTableEntry.l ColP_Invalid	; Zone 9 Act 1
	zoneTableEntry.l ColP_Invalid	; Zone 9 Act 1
	zoneTableEntry.l ColP_Invalid	; Zone 9 Act 2
	zoneTableEntry.l ColP_Invalid	; Zone 9 Act 2
	zoneTableEntry.l ColP_OOZ	; OOZ1
	zoneTableEntry.l ColP_OOZ	; OOZ1
	zoneTableEntry.l ColP_OOZ	; OOZ2
	zoneTableEntry.l ColP_OOZ	; OOZ2
	zoneTableEntry.l ColP_MCZ	; MCZ1
	zoneTableEntry.l ColP_MCZ	; MCZ1
	zoneTableEntry.l ColP_MCZ	; MCZ2
	zoneTableEntry.l ColP_MCZ	; MCZ2
	zoneTableEntry.l ColP_CNZ	; CNZ1
	zoneTableEntry.l ColS_CNZ	; CNZ1
	zoneTableEntry.l ColP_CNZ	; CNZ2
	zoneTableEntry.l ColS_CNZ	; CNZ2
	zoneTableEntry.l ColP_CPZDEZ	; CPZ1
	zoneTableEntry.l ColS_CPZDEZ	; CPZ1
	zoneTableEntry.l ColP_CPZDEZ	; CPZ2
	zoneTableEntry.l ColS_CPZDEZ	; CPZ2
	zoneTableEntry.l ColP_CPZDEZ	; DEZ1
	zoneTableEntry.l ColS_CPZDEZ	; DEZ1
	zoneTableEntry.l ColP_CPZDEZ	; DEZ2
	zoneTableEntry.l ColS_CPZDEZ	; DEZ2
	zoneTableEntry.l ColP_ARZ	; ARZ1
	zoneTableEntry.l ColS_ARZ	; ARZ1
	zoneTableEntry.l ColP_ARZ	; ARZ2
	zoneTableEntry.l ColS_ARZ	; ARZ2
	zoneTableEntry.l ColP_WFZSCZ	; SCZ1
	zoneTableEntry.l ColS_WFZSCZ	; SCZ1
	zoneTableEntry.l ColP_WFZSCZ	; SCZ2
	zoneTableEntry.l ColS_WFZSCZ	; SCZ2
    zoneTableEnd