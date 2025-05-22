
; ---------------------------------------------------------------
SampleTable:;							NOTE: sample rate is auto-detected from a WAV file if 0
	;		type			pointer		Hz
	dcSample	TYPE_PCM, 		theme, 		8000
	dcSample	TYPE_PCM, 		toon, 		8000
	dc.w	-1	; end marker
; ---------------------------------------------------------------
	incdac	theme,		"sound/uncleducktheme.pcm"
	incdac	toon,		"sound/uncleducktoon.pcm"

