
; ---------------------------------------------------------------
SampleTable:;							NOTE: sample rate is auto-detected from a WAV file if 0
	;		type			pointer		Hz
	dcSample	TYPE_PCM, 		theme, 		80*100
	dcSample	TYPE_PCM, 		toon, 		80*100
	dcSample	TYPE_PCM, 		theme, 		80*85
	dcSample	TYPE_PCM, 		toon, 		80*85
	dc.w	-1	; end marker
; ---------------------------------------------------------------
	incdac	theme,		"sound/uncleducktheme.pcm"
	incdac	toon,		"sound/uncleducktoon.pcm"

