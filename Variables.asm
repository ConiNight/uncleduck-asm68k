; Variables (v) and Flags (f)

v_regbuffer:	equ $FFFFFC00	; stores registers d0-a7 during an error event ($40 bytes)
v_spbuffer:	equ $FFFFFC40	; stores most recent sp address (4 bytes)
v_errortype:	equ $FFFFFC44	; error type

v_bgscroll_buffer:	equ	$FFFFA800	; background scroll buffer ($200 bytes)
v_ngfx_buffer:	equ $FFFFAA00	; Nemesis graphics decompression buffer ($200 bytes)
v_spritequeue:	equ $FFFFAC00	; sprite display queue, in order of priority ($400 bytes)

v_hscrolltablebuffer:	equ $FFFFCC00	; scrolling table data (actually $380 bytes, but $400 is reserved for it)

v_objspace:	equ $FFFFD000	; object variable space ($40 bytes per object) ($2000 bytes)

; Title screen objects
v_sonicteam	= v_objspace+$80	; object variable space for the "SONIC TEAM PRESENTS" text ($40 bytes)
v_titlesonic	= v_objspace+$40	; object variable space for Sonic in the title screen ($40 bytes)
v_pressstart	= v_objspace+$80	; object variable space for the "PRESS START BUTTON" text ($40 bytes)
v_titletm	= v_objspace+$C0	; object variable space for the trademark symbol ($40 bytes)
v_ttlsonichide	= v_objspace+$100	; object variable space for hiding part of Sonic ($40 bytes)

v_snddriver_ram:	equ $FFFFF000 ; start of RAM for the sound driver data ($5C0 bytes)

v_gamemode:	equ $FFFFF600	; game mode (00=Sega; 04=Title; 08=Demo; 0C=Level; 10=SS; 14=Cont; 18=End; 1C=Credit; +8C=PreLevel)
v_jpadhold2:	equ $FFFFF602	; joypad input - held, duplicate
v_jpadpress2:	equ $FFFFF603	; joypad input - pressed, duplicate
v_jpadhold1:	equ $FFFFF604	; joypad input - held
v_jpadpress1:	equ $FFFFF605	; joypad input - pressed

v_vdp_buffer1:	equ $FFFFF60C	; VDP instruction buffer (2 bytes)

v_demolength:	equ $FFFFF614	; the length of a demo in frames (2 bytes)
v_scrposy_vdp:	equ $FFFFF616	; screen position y (VDP) (2 bytes)
v_bgscrposy_vdp:	equ $FFFFF618	; background screen position y (VDP) (2 bytes)
v_scrposx_vdp:	equ $FFFFF61A	; screen position x (VDP) (2 bytes)
v_bgscrposx_vdp:	equ $FFFFF61C	; background screen position x (VDP) (2 bytes)
v_bg3scrposy_vdp:	equ $FFFFF61E	; (2 bytes)
v_bg3scrposx_vdp:	equ $FFFFF620	; (2 bytes)

v_hbla_hreg:	equ $FFFFF624	; VDP H.interrupt register buffer (8Axx) (2 bytes)
v_pfade_start:	equ $FFFFF626	; palette fading - start position in bytes
v_pfade_size:	equ $FFFFF627	; palette fading - number of colours
v_vbla_routine:	equ $FFFFF62A	; VBlank - routine counter
v_spritecount:	equ $FFFFF62C	; number of sprites on-screen
v_pcyc_num:	equ $FFFFF632	; palette cycling - current reference number (2 bytes)
v_pcyc_time:	equ $FFFFF634	; palette cycling - time until the next change (2 bytes)
v_vdp_buffer2:	equ $FFFFF640	; VDP instruction buffer (2 bytes)

v_pal_buffer:	equ $FFFFF650	; palette data buffer (used for palette cycling) ($30 bytes)

v_screenposx:	equ $FFFFF700	; screen position x (2 bytes)
v_screenposy:	equ $FFFFF704	; screen position y (2 bytes)
v_bgscreenposx:	equ $FFFFF708	; background screen position x (2 bytes)
v_bgscreenposy:	equ $FFFFF70C	; background screen position y (2 bytes)
v_bg2screenposx:	equ $FFFFF710	; 2 bytes
v_bg2screenposy:	equ $FFFFF714	; 2 bytes
v_bg3screenposx:	equ $FFFFF718	; 2 bytes
v_bg3screenposy:	equ $FFFFF71C	; 2 bytes

v_scrshiftx:	equ $FFFFF73A	; x-screen shift (new - last) * $100
v_scrshifty:	equ $FFFFF73C	; y-screen shift (new - last) * $100

v_spritetablebuffer:	equ $FFFFF800 ; sprite table ($280 bytes, last $80 bytes are overwritten by v_pal_water_dup)
v_pal_dry:	equ $FFFFFB00	; main palette ($80 bytes)
v_pal_dry_dup:	equ $FFFFFB80	; duplicate palette, used for transitions ($80 bytes)
v_pal_water:	equ $FFFFFA80	; main underwater palette ($80 bytes)
v_systemstack:	equ $FFFFFE00
v_vbla_count:	equ $FFFFFE0C	; vertical interrupt counter (adds 1 every VBlank) (4 bytes)
v_megadrive:	equ $FFFFFFF8	; Megadrive machine type
v_init:		equ $FFFFFFFC	; 'init' text string (4 bytes)
