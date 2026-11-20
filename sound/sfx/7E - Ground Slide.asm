Sound_7E_Header:
	smpsHeaderStartSong 3
	smpsHeaderVoiceNull
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cPSG3, Sound_7E_PSG3,	$00, $03

; PSG3 Data
Sound_7E_PSG3:
	smpsPSGform         $E7
	smpsModSet          $01, $01, $01, $01
	dc.b	nMaxPSG2, $09
	smpsPSGAlterVol     $04
	dc.b	nG6, $06
	smpsStop