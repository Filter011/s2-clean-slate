Sound65_Leaves_Header:
	smpsHeaderStartSong 2
	smpsHeaderVoiceNull
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cPSG3, Sound65_Leaves_PSG3,	$00, $00

; PSG3 Data
Sound65_Leaves_PSG3:
	smpsPSGvoice        fTone_03
	smpsPSGform         $E7
	dc.b	nMaxPSG, $03
	smpsPSGvoice        fTone_06
	dc.b	nMaxPSG, $04
	smpsPSGAlterVol     $02
	dc.b	nMaxPSG, $02
	smpsPSGvoice        fTone_03
	smpsPSGAlterVol     $FE
	dc.b	nMaxPSG, $08, nMaxPSG, $18
	smpsStop