Sound67_DrawbridgeMove_Header:
	smpsHeaderStartSong 2
	smpsHeaderVoiceNull
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cPSG3, Sound67_DrawbridgeMove_PSG3,	$00, $00

; PSG3 Data
Sound67_DrawbridgeMove_PSG3:
	smpsPSGvoice        fTone_06
	smpsPSGform         $E7
	dc.b	nEb1, $0A, nG1, nB1, nEb2, nG2, nB2, $08
	dc.b	nEb3, nG3, nB3
	smpsStop