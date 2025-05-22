;this routine helps make megapcm send DAC output, taken from a snippet of modified smps
SendDAC:
;		MPCM_stopZ80
;		MPCM_ensureYMWriteReady
;.waitLoop:	tst.b	(ym2612_a0).l		; is FM busy?
;		bmi.s	.waitLoop		; branch if yes
;		move.b	d0, (ym2612_a0).l
;		nop
;		move.b	d1, (ym2612_d0).l
;		nop
;		nop
;.waitLoop2:	tst.b	(ym2612_a0).l		; is FM busy?
;		bmi.s	.waitLoop2		; branch if yes
		move.b	#$2A, (ym2612_a0).l	; restore DAC output for Mega PCM
		MPCM_startZ80
		rts