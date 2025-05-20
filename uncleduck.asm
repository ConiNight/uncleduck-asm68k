;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth and Esrael L.G. Neto

; ===========================================================================

	include	"Constants.asm"
	include	"Variables.asm"
	include	"Macros.asm"

EnableSRAM:	equ 0	; change to 1 to enable SRAM
BackupSRAM:	equ 1
AddressSRAM:	equ 3	; 0 = odd+even; 2 = even only; 3 = odd only

; ===========================================================================

StartOfRom:
Vectors:	dc.l v_systemstack&$FFFFFF	; Initial stack pointer value
		dc.l EntryPoint			; Start of program
		dc.l BusError			; Bus error
		dc.l AddressError		; Address error (4)
		dc.l IllegalInstr		; Illegal instruction
		dc.l ZeroDivide			; Division by zero
		dc.l ChkInstr			; CHK exception
		dc.l TrapvInstr			; TRAPV exception (8)
		dc.l PrivilegeViol		; Privilege violation
		dc.l Trace				; TRACE exception
		dc.l Line1010Emu		; Line-A emulator
		dc.l Line1111Emu		; Line-F emulator (12)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved) (16)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved) (20)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved) (24)
		dc.l ErrorExcept		; Spurious exception
		dc.l ErrorTrap			; IRQ level 1
		dc.l ErrorTrap			; IRQ level 2
		dc.l ErrorTrap			; IRQ level 3 (28)
		dc.l HBlank				; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap			; IRQ level 5
		dc.l VBlank				; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap			; IRQ level 7 (32)
		dc.l ErrorTrap			; TRAP #00 exception
		dc.l ErrorTrap			; TRAP #01 exception
		dc.l ErrorTrap			; TRAP #02 exception
		dc.l ErrorTrap			; TRAP #03 exception (36)
		dc.l ErrorTrap			; TRAP #04 exception
		dc.l ErrorTrap			; TRAP #05 exception
		dc.l ErrorTrap			; TRAP #06 exception
		dc.l ErrorTrap			; TRAP #07 exception (40)
		dc.l ErrorTrap			; TRAP #08 exception
		dc.l ErrorTrap			; TRAP #09 exception
		dc.l ErrorTrap			; TRAP #10 exception
		dc.l ErrorTrap			; TRAP #11 exception (44)
		dc.l ErrorTrap			; TRAP #12 exception
		dc.l ErrorTrap			; TRAP #13 exception
		dc.l ErrorTrap			; TRAP #14 exception
		dc.l ErrorTrap			; TRAP #15 exception (48)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.b "SEGA MEGA DRIVE " ; Hardware system ID (Console name)
		dc.b "(C)SEGA 1991.APR" ; Copyright holder and release date (generally year)
		dc.b "SONIC THE               HEDGEHOG                " ; Domestic name
		dc.b "SONIC THE               HEDGEHOG                " ; International name
		dc.b "GM 00004049-01" ; Serial/version number (Rev non-0)
Checksum:
		dc.w $AFC7
		dc.b "J               " ; I/O support
		dc.l StartOfRom		; Start address of ROM
RomEndLoc:	dc.l EndOfRom-1		; End address of ROM
		dc.l $FF0000		; Start address of RAM
		dc.l $FFFFFF		; End address of RAM
		if EnableSRAM=1
		dc.b $52, $41, $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20 ; SRAM support
		else
		dc.l $20202020
		endc
		dc.l $20202020		; SRAM start ($200001)
		dc.l $20202020		; SRAM end ($20xxxx)
		dc.b "                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
		dc.b "JUE             " ; Region (Country code)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Unlike Sonic 2, Sonic 1 uses the 68000 for playing music, so it stops too

ErrorTrap:
		nop	
		nop	
		bra.s	ErrorTrap
; ===========================================================================

EntryPoint:
		tst.l	(z80_port_1_control).l ; test port A & B control registers
		bne.s	PortA_Ok
		tst.w	(z80_expansion_control).l ; test port C control register

PortA_Ok:
		bne.s	SkipSetup ; Skip the VDP and Z80 setup code if port A, B or C is ok...?
		lea	SetupValues(pc),a5	; Load setup values array address.
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version (from $A10001)
		andi.b	#$F,d0
		beq.s	SkipSecurity	; If the console has no TMSS, skip the security stuff.
		move.l	#'SEGA',$2F00(a1) ; move "SEGA" to TMSS register ($A14000)

SkipSecurity:
		move.w	(a4),d0	; clear write-pending flag in VDP to prevent issues if the 68k has been reset in the middle of writing a command long word to the VDP.
		moveq	#0,d0	; clear d0
		movea.l	d0,a6	; clear a6
		move.l	a6,usp	; set usp to $0

		moveq	#$17,d1
VDPInitLoop:
		move.b	(a5)+,d5	; add $8000 to value
		move.w	d5,(a4)		; move value to	VDP register
		add.w	d7,d5		; next register
		dbf	d1,VDPInitLoop
		
		move.l	(a5)+,(a4)
		move.w	d0,(a3)		; clear	the VRAM
		move.w	d7,(a1)		; stop the Z80
		move.w	d7,(a2)		; reset	the Z80

WaitForZ80:
		btst	d0,(a1)		; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch

		moveq	#$25,d2
Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop
		
		move.w	d0,(a2)
		move.w	d0,(a1)		; start	the Z80
		move.w	d7,(a2)		; reset	the Z80

ClrRAMLoop:
		move.l	d0,-(a6)	; clear 4 bytes of RAM
		dbf	d6,ClrRAMLoop	; repeat until the entire RAM is clear
		move.l	(a5)+,(a4)	; set VDP display mode and increment mode
		move.l	(a5)+,(a4)	; set VDP to CRAM write

		moveq	#$1F,d3	; set repeat times
ClrCRAMLoop:
		move.l	d0,(a3)	; clear 2 palettes
		dbf	d3,ClrCRAMLoop	; repeat until the entire CRAM is clear
		move.l	(a5)+,(a4)	; set VDP to VSRAM write

		moveq	#$13,d4
ClrVSRAMLoop:
		move.l	d0,(a3)	; clear 4 bytes of VSRAM.
		dbf	d4,ClrVSRAMLoop	; repeat until the entire VSRAM is clear
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)	; reset	the PSG
		dbf	d5,PSGInitLoop	; repeat for other channels
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear all registers
		disable_ints

SkipSetup:
		bra.s	GameProgram	; begin game

; ===========================================================================
SetupValues:	dc.w $8000		; VDP register start number
		dc.w $3FFF		; size of RAM/4
		dc.w $100		; VDP register diff

		dc.l z80_ram		; start	of Z80 RAM
		dc.l z80_bus_request	; Z80 bus request
		dc.l z80_reset		; Z80 reset
		dc.l vdp_data_port	; VDP data
		dc.l vdp_control_port	; VDP control

		dc.b 4			; VDP $80 - 8-colour mode
		dc.b $14		; VDP $81 - Megadrive mode, DMA enable
		dc.b ($C000>>10)	; VDP $82 - foreground nametable address
		dc.b ($F000>>10)	; VDP $83 - window nametable address
		dc.b ($E000>>13)	; VDP $84 - background nametable address
		dc.b ($D800>>9)		; VDP $85 - sprite table address
		dc.b 0			; VDP $86 - unused
		dc.b 0			; VDP $87 - background colour
		dc.b 0			; VDP $88 - unused
		dc.b 0			; VDP $89 - unused
		dc.b 255		; VDP $8A - HBlank register
		dc.b 0			; VDP $8B - full screen scroll
		dc.b $81		; VDP $8C - 40 cell display
		dc.b ($DC00>>10)	; VDP $8D - hscroll table address
		dc.b 0			; VDP $8E - unused
		dc.b 1			; VDP $8F - VDP increment
		dc.b 1			; VDP $90 - 64 cell hscroll size
		dc.b 0			; VDP $91 - window h position
		dc.b 0			; VDP $92 - window v position
		dc.w $FFFF		; VDP $93/94 - DMA length
		dc.w 0			; VDP $95/96 - DMA source
		dc.b $80		; VDP $97 - DMA fill VRAM
		dc.l $40000080		; VRAM address 0

		dc.b $AF		; xor	a
		dc.b $01, $D9, $1F	; ld	bc,1fd9h
		dc.b $11, $27, $00	; ld	de,0027h
		dc.b $21, $26, $00	; ld	hl,0026h
		dc.b $F9		; ld	sp,hl
		dc.b $77		; ld	(hl),a
		dc.b $ED, $B0		; ldir
		dc.b $DD, $E1		; pop	ix
		dc.b $FD, $E1		; pop	iy
		dc.b $ED, $47		; ld	i,a
		dc.b $ED, $4F		; ld	r,a
		dc.b $D1		; pop	de
		dc.b $E1		; pop	hl
		dc.b $F1		; pop	af
		dc.b $08		; ex	af,af'
		dc.b $D9		; exx
		dc.b $C1		; pop	bc
		dc.b $D1		; pop	de
		dc.b $E1		; pop	hl
		dc.b $F1		; pop	af
		dc.b $F9		; ld	sp,hl
		dc.b $F3		; di
		dc.b $ED, $56		; im1
		dc.b $36, $E9		; ld	(hl),e9h
		dc.b $E9		; jp	(hl)

		dc.w $8104		; VDP display mode
		dc.w $8F02		; VDP increment
		dc.l $C0000000		; CRAM write mode
		dc.l $40000010		; VSRAM address 0

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,($A1000D).l
		beq.s	CheckSumCheck
		cmpi.l	#'init',(v_init).w ; has checksum routine already run?
		beq.w	GameInit	; if yes, branch

CheckSumCheck:
		movea.l	#EndOfHeader,a0	; start	checking bytes after the header	($200)
		movea.l	#RomEndLoc,a1	; stop at end of ROM
		move.l	(a1),d0
		moveq	#0,d1

	@loop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bhs.s	@loop
		movea.l	#Checksum,a1	; read the checksum
		cmp.w	(a1),d1		; compare checksum in header to ROM
		bne.w	CheckSumError	; if they don't match, branch

	CheckSumOk:
		lea	($FFFFFE00).w,a6
		moveq	#0,d7
		move.w	#$7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM	; clear RAM ($FE00-$FFFF)

		move.b	(z80_version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_megadrive).w ; get region setting
		move.l	#'init',(v_init).w ; set flag so checksum won't run again

GameInit:
		lea	($FF0000).l,a6
		moveq	#0,d7
		move.w	#$3F7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM	; clear RAM ($0000-$FDFF)

		bsr.w	VDPSetupGame
		bsr.w	SoundDriverLoad
		bsr.w	JoypadInit
		move.b	#id_Sega,(v_gamemode).w ; set Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0 ; load Game Mode
		andi.w	#$1C,d0	; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		jsr	GameModeArray(pc,d0.w) ; jump to apt location in ROM
		bra.s	MainGameLoop	; loop indefinitely
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

ptr_GM_Sega:	bra.w	GM_Sega		; Sega Screen ($00)

ptr_GM_Title:	bra.w	GM_Title	; Title	Screen ($04)

		rts	
; ===========================================================================

CheckSumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l ; set VDP to CRAM write
		moveq	#$3F,d7

	@fillred:
		move.w	#cRed,(vdp_data_port).l ; fill palette with red
		dbf	d7,@fillred	; repeat $3F more times

	@endlessloop:
		bra.s	@endlessloop
; ===========================================================================

BusError:
		move.b	#2,(v_errortype).w
		bra.s	loc_43A

AddressError:
		move.b	#4,(v_errortype).w
		bra.s	loc_43A

IllegalInstr:
		move.b	#6,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	loc_462

ZeroDivide:
		move.b	#8,(v_errortype).w
		bra.s	loc_462

ChkInstr:
		move.b	#$A,(v_errortype).w
		bra.s	loc_462

TrapvInstr:
		move.b	#$C,(v_errortype).w
		bra.s	loc_462

PrivilegeViol:
		move.b	#$E,(v_errortype).w
		bra.s	loc_462

Trace:
		move.b	#$10,(v_errortype).w
		bra.s	loc_462

Line1010Emu:
		move.b	#$12,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	loc_462

Line1111Emu:
		move.b	#$14,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	loc_462

ErrorExcept:
		move.b	#0,(v_errortype).w
		bra.s	loc_462
; ===========================================================================

loc_43A:
		disable_ints
		addq.w	#2,sp
		move.l	(sp)+,(v_spbuffer).w
		addq.w	#2,sp
		movem.l	d0-a7,(v_regbuffer).w
		bsr.w	ShowErrorMessage
		move.l	2(sp),d0
		bsr.w	ShowErrorValue
		move.l	(v_spbuffer).w,d0
		bsr.w	ShowErrorValue
		bra.s	loc_478
; ===========================================================================

loc_462:
		disable_ints
		movem.l	d0-a7,(v_regbuffer).w
		bsr.w	ShowErrorMessage
		move.l	2(sp),d0
		bsr.w	ShowErrorValue

loc_478:
		bsr.w	ErrorWaitForC
		movem.l	(v_regbuffer).w,d0-a7
		enable_ints
		rte	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowErrorMessage:
		lea	(vdp_data_port).l,a6
		locVRAM	$F800
		lea	(Art_Text).l,a0
		move.w	#$27F,d1
	@loadgfx:
		move.w	(a0)+,(a6)
		dbf	d1,@loadgfx

		moveq	#0,d0		; clear	d0
		move.b	(v_errortype).w,d0 ; load error code
		move.w	ErrorText(pc,d0.w),d0
		lea	ErrorText(pc,d0.w),a0
		locVRAM	(vram_fg+$604)
		moveq	#$12,d1		; number of characters (minus 1)

	@showchars:
		moveq	#0,d0
		move.b	(a0)+,d0
		addi.w	#$790,d0
		move.w	d0,(a6)
		dbf	d1,@showchars	; repeat for number of characters
		rts	
; End of function ShowErrorMessage

; ===========================================================================
ErrorText:	dc.w @exception-ErrorText, @bus-ErrorText
		dc.w @address-ErrorText, @illinstruct-ErrorText
		dc.w @zerodivide-ErrorText, @chkinstruct-ErrorText
		dc.w @trapv-ErrorText, @privilege-ErrorText
		dc.w @trace-ErrorText, @line1010-ErrorText
		dc.w @line1111-ErrorText
@exception:	dc.b "ERROR EXCEPTION    "
@bus:		dc.b "BUS ERROR          "
@address:	dc.b "ADDRESS ERROR      "
@illinstruct:	dc.b "ILLEGAL INSTRUCTION"
@zerodivide:	dc.b "@ERO DIVIDE        "
@chkinstruct:	dc.b "CHK INSTRUCTION    "
@trapv:		dc.b "TRAPV INSTRUCTION  "
@privilege:	dc.b "PRIVILEGE VIOLATION"
@trace:		dc.b "TRACE              "
@line1010:	dc.b "LINE 1010 EMULATOR "
@line1111:	dc.b "LINE 1111 EMULATOR "
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowErrorValue:
		move.w	#$7CA,(a6)	; display "$" symbol
		moveq	#7,d2

	@loop:
		rol.l	#4,d0
		bsr.s	@shownumber	; display 8 numbers
		dbf	d2,@loop
		rts	
; End of function ShowErrorValue


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


@shownumber:
		move.w	d0,d1
		andi.w	#$F,d1
		cmpi.w	#$A,d1
		blo.s	@chars0to9
		addq.w	#7,d1		; add 7 for characters A-F

	@chars0to9:
		addi.w	#$7C0,d1
		move.w	d1,(a6)
		rts	
; End of function sub_5CA


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ErrorWaitForC:
		bsr.w	ReadJoypads
		cmpi.b	#btnC,(v_jpadpress1).w ; is button C pressed?
		bne.w	ErrorWaitForC	; if not, branch
		rts	
; End of function ErrorWaitForC

; ===========================================================================

Art_Text:	incbin	"artunc\menutext.bin" ; text used in level select and debug mode
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------

VBlank:
		movem.l	d0-a6,-(sp)
		tst.b	(v_vbla_routine).w
		beq.s	VBla_00
		move.w	(vdp_control_port).l,d0
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l ; send screen y-axis pos. to VSRAM
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	@notPAL		; if not, branch

		move.w	#$700,d0
	@waitPAL:
		dbf	d0,@waitPAL ; wait here in a loop doing nothing for a while...

	@notPAL:
		move.b	(v_vbla_routine).w,d0
		move.b	#0,(v_vbla_routine).w
		andi.w	#$3E,d0
		move.w	VBla_Index(pc,d0.w),d0
		jsr	VBla_Index(pc,d0.w)

VBla_Music:
		jsr	(UpdateMusic).l

VBla_Exit:
		addq.l	#1,(v_vbla_count).w
		movem.l	(sp)+,d0-a6
		rte	
; ===========================================================================
VBla_Index:	dc.w VBla_00-VBla_Index, VBla_02-VBla_Index
		dc.w VBla_04-VBla_Index, VBla_06-VBla_Index
		dc.w VBla_08-VBla_Index, VBla_0A-VBla_Index
		dc.w VBla_0C-VBla_Index, VBla_0E-VBla_Index
		dc.w VBla_10-VBla_Index, VBla_12-VBla_Index
		dc.w VBla_14-VBla_Index, VBla_16-VBla_Index
		dc.w VBla_0C-VBla_Index
; ===========================================================================

VBla_00:
		bra.w	VBla_Music
; ===========================================================================

VBla_02:
		bsr.w	sub_106E

VBla_14:
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	
; ===========================================================================

VBla_04:
		bsr.w	sub_106E
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	
; ===========================================================================

VBla_06:
		bsr.w	sub_106E
		rts	
; ===========================================================================

VBla_10:

VBla_08:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		startZ80
		bra.w	VBla_Exit

; ---------------------------------------------------------------------------
; Subroutine to	run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Demo_Time:
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	@end		; if not, branch
		subq.w	#1,(v_demolength).w ; subtract 1 from time left

	@end:
		rts	
; End of function Demo_Time

; ===========================================================================

VBla_0A:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		startZ80
		tst.w	(v_demolength).w	; is there time left on the demo?
		beq.w	@end	; if not, return
		subq.w	#1,(v_demolength).w	; subtract 1 from time left in demo

	@end:
		rts	
; ===========================================================================

VBla_0C:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		move.w	(v_hbla_hreg).w,(a5)
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		startZ80
		rts	
; ===========================================================================

VBla_0E:
		bsr.w	sub_106E
		addq.b	#1,($FFFFF628).w
		move.b	#$E,(v_vbla_routine).w
		rts	
; ===========================================================================

VBla_12:
		bsr.w	sub_106E
		move.w	(v_hbla_hreg).w,(a5)
; ===========================================================================

VBla_16:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		startZ80
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_106E:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		startZ80
		rts	
; End of function sub_106E

; ---------------------------------------------------------------------------
; Horizontal interrupt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HBlank:
		disable_ints
		tst.b	($FFFFF64F).w
		bne.s	loc_119E

	@nochg:
		rte	
; ===========================================================================

loc_119E:
		clr.b	($FFFFF64F).w
		movem.l	d0-a6,-(sp)
		bsr.w	Demo_Time
		jsr	(UpdateMusic).l
		movem.l	(sp)+,d0-a6
		rte	
; End of function HBlank

; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (expansion/extra)
		startZ80
		rts	
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(v_jpadhold1).w,a0 ; address where joypad states are written
		lea	($A10003).l,a1	; first	joypad port
		bsr.s	@read		; do the first joypad
		addq.w	#2,a1		; do the second	joypad

	@read:
		move.b	#0,(a1)
		nop	
		nop	
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop	
		nop	
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts	
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:
		lea	(vdp_control_port).l,a0
		lea	(vdp_data_port).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

	@setreg:
		move.w	(a2)+,(a0)
		dbf	d7,@setreg	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_buffer1).w
		move.w	#$8A00+223,(v_hbla_hreg).w	; H-INT every 224th scanline
		moveq	#0,d0
		move.l	#$C0000000,(vdp_control_port).l ; set VDP to CRAM write
		move.w	#$3F,d7

	@clrCRAM:
		move.w	d0,(a1)
		dbf	d7,@clrCRAM	; clear	the CRAM

		clr.l	(v_scrposy_vdp).w
		clr.l	(v_scrposx_vdp).w
		move.l	d1,-(sp)
		fillVRAM	0,$FFFF,0

	@waitforDMA:
		move.w	(a5),d1
		btst	#1,d1		; is DMA (fillVRAM) still running?
		bne.s	@waitforDMA	; if yes, branch

		move.w	#$8F02,(a5)	; set VDP increment size
		move.l	(sp)+,d1
		rts	
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004		; 8-colour mode
		dc.w $8134		; enable V.interrupts, enable DMA
		dc.w $8200+(vram_fg>>10) ; set foreground nametable address
		dc.w $8300+($A000>>10)	; set window nametable address
		dc.w $8400+(vram_bg>>13) ; set background nametable address
		dc.w $8500+(vram_sprites>>9) ; set sprite table address
		dc.w $8600		; unused
		dc.w $8700		; set background colour (palette entry 0)
		dc.w $8800		; unused
		dc.w $8900		; unused
		dc.w $8A00		; default H.interrupt register
		dc.w $8B00		; full-screen vertical scrolling
		dc.w $8C00		; 32-cell display mode
		dc.w $8D00+(vram_hscroll>>10) ; set background hscroll address
		dc.w $8E00		; unused
		dc.w $8F02		; set VDP increment size
		dc.w $9001		; 64-cell hscroll size
		dc.w $9100		; window horizontal position
		dc.w $9200		; window vertical position

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		fillVRAM	0,$FFF,vram_fg ; clear foreground namespace

	@wait1:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait1

		move.w	#$8F02,(a5)
		fillVRAM	0,$FFF,vram_bg ; clear background namespace

	@wait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait2

		move.w	#$8F02,(a5)
		clr.l	(v_scrposy_vdp).w
		clr.l	(v_scrposx_vdp).w

		lea	(v_spritetablebuffer).w,a1
		moveq	#0,d0
		move.w	#($280/4),d1	; This should be ($280/4)-1, leading to a slight bug (first bit of v_pal_water is cleared)

	@clearsprites:
		move.l	d0,(a1)+
		dbf	d1,@clearsprites ; clear sprite table (in RAM)

		lea	(v_hscrolltablebuffer).w,a1
		moveq	#0,d0
		move.w	#($400/4),d1	; This should be ($400/4)-1, leading to a slight bug (first bit of the Sonic object's RAM is cleared)

	@clearhscroll:
		move.l	d0,(a1)+
		dbf	d1,@clearhscroll ; clear hscroll table (in RAM)
		rts	
; End of function ClearScreen

; ---------------------------------------------------------------------------
; Subroutine to	load the sound driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SoundDriverLoad:
		nop	
		stopZ80
		resetZ80
		lea	(Kos_Z80).l,a0	; load sound driver
		lea	(z80_ram).l,a1	; target Z80 RAM
		bsr.w	KosDec		; decompress
		resetZ80a
		nop	
		nop	
		nop	
		nop	
		resetZ80
		startZ80
		rts	
; End of function SoundDriverLoad

		include	"_incObj\sub PlaySound.asm"

; ---------------------------------------------------------------------------
; Subroutine to	copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TilemapToVRAM:
		lea	(vdp_data_port).l,a6
		move.l	#$800000,d4

	Tilemap_Line:
		move.l	d0,4(a6)	; move d0 to VDP_control_port
		move.w	d1,d3

	Tilemap_Cell:
		move.w	(a1)+,(a6)	; write value to namespace
		dbf	d3,Tilemap_Cell	; next tile
		add.l	d4,d0		; goto next line
		dbf	d2,Tilemap_Line	; next line
		rts	
; End of function TilemapToVRAM

		include	"_inc\Nemesis Decompression.asm"
		include	"_inc\Enigma Decompression.asm"
		include	"_inc\Kosinski Decompression.asm"

; ---------------------------------------------------------------------------
; Subroutine to	fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$003F,(v_pfade_start).w ; set start position = 0; size = $40

PalFadeIn_Alt:				; start position and size are already set
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf	d0,@fill 	; fill palette with black

		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeIn_FromBlack
		dbf	d4,@mainloop
		rts	
; End of function PaletteFadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_FromBlack:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		lea	(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@addcolour:
		bsr.s	FadeIn_AddColour ; increase colour
		dbf	d0,@addcolour	; repeat for size of palette
@exit:
		rts	
; End of function FadeIn_FromBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_AddColour:
@addblue:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3		; is colour already at threshold level?
		beq.s	@next		; if yes, branch
		move.w	d3,d1
		addi.w	#$200,d1	; increase blue	value
		cmp.w	d2,d1		; has blue reached threshold level?
		bhi.s	@addgreen	; if yes, branch
		move.w	d1,(a0)+	; update palette
		rts	
; ===========================================================================

@addgreen:
		move.w	d3,d1
		addi.w	#$20,d1		; increase green value
		cmp.w	d2,d1
		bhi.s	@addred
		move.w	d1,(a0)+	; update palette
		rts	
; ===========================================================================

@addred:
		addq.w	#2,(a0)+	; increase red value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0		; next colour
		rts	
; End of function FadeIn_AddColour


; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeOut_ToBlack
		dbf	d4,@mainloop
		rts	
; End of function PaletteFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_ToBlack:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@decolour:
		bsr.s	FadeOut_DecColour ; decrease colour
		dbf	d0,@decolour	; repeat for size of palette

		moveq	#0,d0
		lea	(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@decolour2:
		bsr.s	FadeOut_DecColour
		dbf	d0,@decolour2
		rts	
; End of function FadeOut_ToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_DecColour:
@dered:
		move.w	(a0),d2
		beq.s	@next
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	@degreen
		subq.w	#2,(a0)+	; decrease red value
		rts	
; ===========================================================================

@degreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	@deblue
		subi.w	#$20,(a0)+	; decrease green value
		rts	
; ===========================================================================

@deblue:
		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	@next
		subi.w	#$200,(a0)+	; decrease blue	value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0
		rts	
; End of function FadeOut_DecColour

; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf	d0,@fill 	; fill palette with white

		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteIn_FromWhite
		dbf	d4,@mainloop
		rts	
; End of function PaletteWhiteIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_FromWhite:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		lea	(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@decolour:
		bsr.s	WhiteIn_DecColour ; decrease colour
		dbf	d0,@decolour	; repeat for size of palette
		rts	
; End of function WhiteIn_FromWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_DecColour:
@deblue:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	@next
		move.w	d3,d1
		subi.w	#$200,d1	; decrease blue	value
		blo.s	@degreen
		cmp.w	d2,d1
		blo.s	@degreen
		move.w	d1,(a0)+
		rts	
; ===========================================================================

@degreen:
		move.w	d3,d1
		subi.w	#$20,d1		; decrease green value
		blo.s	@dered
		cmp.w	d2,d1
		blo.s	@dered
		move.w	d1,(a0)+
		rts	
; ===========================================================================

@dered:
		subq.w	#2,(a0)+	; decrease red value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0
		rts	
; End of function WhiteIn_DecColour

; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		move.w	#$15,d4

	@mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteOut_ToWhite
		dbf	d4,@mainloop
		rts	
; End of function PaletteWhiteOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@addcolour:
		bsr.s	WhiteOut_AddColour
		dbf	d0,@addcolour

		moveq	#0,d0
		lea	(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf	d0,@addcolour2
		rts	
; End of function WhiteOut_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:
@addred:
		move.w	(a0),d2
		cmpi.w	#cWhite,d2
		beq.s	@next
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#cRed,d1
		beq.s	@addgreen
		addq.w	#2,(a0)+	; increase red value
		rts	
; ===========================================================================

@addgreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#cGreen,d1
		beq.s	@addblue
		addi.w	#$20,(a0)+	; increase green value
		rts	
; ===========================================================================

@addblue:
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#cBlue,d1
		beq.s	@next
		addi.w	#$200,(a0)+	; increase blue	value
		rts	
; ===========================================================================

@next:
		addq.w	#2,a0
		rts	
; End of function WhiteOut_AddColour

; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Sega:
		tst.b	(v_pcyc_time+1).w
		bne.s	loc_206A
		lea	(v_pal_dry+$20).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	(v_pcyc_num).w,d0

loc_2020:
		bpl.s	loc_202A
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_2020
; ===========================================================================

loc_202A:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2034
		addq.w	#2,d0

loc_2034:
		cmpi.w	#$60,d0
		bhs.s	loc_203E
		move.w	(a0)+,(a1,d0.w)

loc_203E:
		addq.w	#2,d0
		dbf	d1,loc_202A

		move.w	(v_pcyc_num).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2054
		addq.w	#2,d0

loc_2054:
		cmpi.w	#$64,d0
		blt.s	loc_2062
		move.w	#$401,(v_pcyc_time).w
		moveq	#-$C,d0

loc_2062:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0
		rts	
; ===========================================================================

loc_206A:
		subq.b	#1,(v_pcyc_time).w
		bpl.s	loc_20BC
		move.b	#4,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		blo.s	loc_2088
		moveq	#0,d0
		rts	
; ===========================================================================

loc_2088:
		move.w	d0,(v_pcyc_num).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	(v_pal_dry+$04).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(v_pal_dry+$20).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_20A8:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_20B2
		addq.w	#2,d0

loc_20B2:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_20A8

loc_20BC:
		moveq	#1,d0
		rts	
; End of function PalCycle_Sega

; ===========================================================================

Pal_Sega1:	incbin	"palette\Sega1.bin"
Pal_Sega2:	incbin	"palette\Sega2.bin"

; ---------------------------------------------------------------------------
; Subroutines to load palettes

; input:
;	d0 = index number for palette
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad1:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		adda.w	#v_pal_dry_dup-v_pal_dry,a3		; skip to "main" RAM address
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		move.w	(a1)+,d7	; get length of palette

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad2

; ===========================================================================

		include	"_inc\Palette Pointers.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------
Pal_SegaBG:	incbin	"palette\Sega Background.bin"
Pal_Title:	incbin	"palette\Title Screen.bin"

; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WaitForVBla:
		enable_ints

	@wait:
		tst.b	(v_vbla_routine).w ; has VBlank routine finished?
		bne.s	@wait		; if not, branch
		rts	
; End of function WaitForVBla

; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

GM_Sega:
		move.b	#bgm_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	PaletteFadeOut
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8700,(a6)	; set background colour (palette entry 0)
		move.w	#$8B00,(a6)	; full-screen vertical scrolling
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		locVRAM	0
		lea	(Nem_SegaLogo).l,a0 ; load Sega	logo patterns
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_SegaLogo).l,a0 ; load Sega	logo mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$E510,$17,7
		copyTilemap	$FF0180,$C000,$27,$1B

		moveq	#palid_SegaBG,d0
		bsr.w	PalLoad2	; load Sega logo palette
		move.w	#-$A,(v_pcyc_num).w
		move.w	#0,(v_pcyc_time).w
		move.w	#0,(v_pal_buffer+$12).w
		move.w	#0,(v_pal_buffer+$10).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l

Sega_WaitPal:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPal

		move.b	#sfx_Sega,d0
		bsr.w	PlaySound_Special	; play "SEGA" sound
		move.b	#$14,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	#$1E,(v_demolength).w

Sega_WaitEnd:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.w	(v_demolength).w
		beq.s	Sega_GotoTitle
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Sega_WaitEnd	; if not, branch

Sega_GotoTitle:
		move.b	#id_Title,(v_gamemode).w ; go to title screen
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:
		move.b	#bgm_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	PaletteFadeOut
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)	; 64-cell hscroll size
		move.w	#$9200,(a6)	; window vertical position
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)	; set background colour (palette line 2, entry 0)
		bsr.w	ClearScreen

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

	Tit_ClrObj1:
		move.l	d0,(a1)+
		dbf	d1,Tit_ClrObj1	; fill object space ($D000-$EFFF) with 0

		locVRAM	0
		lea	(Nem_JapNames).l,a0 ; load Japanese credits
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_JapNames).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C000,$27,$1B

		lea	(v_pal_dry_dup).w,a1
		moveq	#cBlack,d0
		move.w	#$1F,d1

	Tit_ClrPal:
		move.l	d0,(a1)+
		dbf	d1,Tit_ClrPal	; fill palette with 0 (black)
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	PaletteFadeIn
		disable_ints
		locVRAM	$4000
		lea	(Nem_TitleFg).l,a0 ; load title	screen patterns
		bsr.w	NemDec
		locVRAM	$6000
		lea	(Nem_TitleSonic).l,a0 ;	load Sonic title screen	patterns
		bsr.w	NemDec
		locVRAM	$A200
		lea	(Nem_TitleTM).l,a0 ; load "TM" patterns
		bsr.w	NemDec
		lea	(vdp_data_port).l,a6
		locVRAM	$D000,4(a6)
		lea	(Art_Text).l,a5	; load level select font
		move.w	#$28F,d1

	Tit_LoadText:
		move.w	(a5)+,(a6)
		dbf	d1,Tit_LoadText	; load level select font
		bsr.w	PaletteFadeOut
		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bgscreenposx).w,a3
		lea	($FF0000).l,a1
		lea	(Eni_Title).l,a0 ; load	title screen mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C206,$21,$15

		moveq	#palid_Title,d0	; load title screen palette
		bsr.w	PalLoad1
		move.b	#bgm_Title,d0
		bsr.w	PlaySound_Special	; play title screen music
		move.w	#$178,(v_demolength).w ; run title screen for $178 frames

		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		andi.b	#btnStart,(v_jpadpress1).w ; check if Start is pressed
		bne.w	Tit_Sega	; if not, branch
		tst.w	(v_demolength).w
		bne.w	Tit_MainLoop
Tit_Sega:
		move.b	#id_Sega,(v_gamemode).w ; set screen mode to Sega
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExecuteObjects:
		lea	(v_objspace).w,a0 ; set address for object RAM
		moveq	#$7F,d7
		moveq	#0,d0

loc_D348:
		move.b	(a0),d0		; load object number from RAM
		beq.s	loc_D358
		add.w	d0,d0
		add.w	d0,d0
		movea.l	Obj_Index-4(pc,d0.w),a1
		jsr	(a1)		; run the object's code
		moveq	#0,d0

loc_D358:
		lea	$40(a0),a0	; next object
		dbf	d7,loc_D348
		rts	
; ===========================================================================

loc_D362:
		moveq	#$1F,d7
		bsr.s	loc_D348
		moveq	#$5F,d7

loc_D368:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_D378
		tst.b	obRender(a0)
		bpl.s	loc_D378
		bsr.w	DisplaySprite

loc_D378:
		lea	$40(a0),a0

loc_D37C:
		dbf	d7,loc_D368
		rts	
; End of function ExecuteObjects

; ===========================================================================
; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
Obj_Index:
		include	"_inc\Object Pointers.asm"

		include	"_incObj\sub ObjectFall.asm"
		include	"_incObj\sub SpeedToPos.asm"
		include	"_incObj\sub DisplaySprite.asm"
		include	"_incObj\sub AnimateSprite.asm"
		include	"_incObj\sub DeleteObject.asm"
		include	"_incObj\sub CalcAngle.asm"

; ===========================================================================
BldSpr_ScrPos:	dc.l 0				; blank
		dc.l v_screenposx&$FFFFFF	; main screen x-position
		dc.l v_bgscreenposx&$FFFFFF	; background x-position	1
		dc.l v_bg3screenposx&$FFFFFF	; background x-position	2
; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:
		lea	(v_spritetablebuffer).w,a2 ; set address for sprite table
		moveq	#0,d5
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

	@priorityLoop:
		tst.w	(a4)	; are there objects left to draw?
		beq.w	@nextPriority	; if not, branch
		moveq	#2,d6

	@objectLoop:
		movea.w	(a4,d6.w),a0	; load object ID
		tst.b	(a0)		; if null, branch
		beq.w	@skipObject
		bclr	#7,obRender(a0)		; set as not visible

		move.b	obRender(a0),d0
		move.b	d0,d4
		andi.w	#$C,d0		; get drawing coordinates
		beq.s	@screenCoords	; branch if 0 (screen coordinates)
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
	; check object bounds
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	@skipObject	; left edge out of bounds
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	@skipObject	; right edge out of bounds
		addi.w	#128,d3		; VDP sprites start at 128px

		btst	#4,d4		; is assume height flag on?
		beq.s	@assumeHeight	; if yes, branch
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	@skipObject	; top edge out of bounds
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	@skipObject
		addi.w	#128,d2		; VDP sprites start at 128px
		bra.s	@drawObject
; ===========================================================================

	@screenCoords:
		move.w	$A(a0),d2	; special variable for screen Y
		move.w	obX(a0),d3
		bra.s	@drawObject
; ===========================================================================

	@assumeHeight:
		move.w	obY(a0),d2
		sub.w	obMap(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		blo.s	@skipObject
		cmpi.w	#$180,d2
		bhs.s	@skipObject

	@drawObject:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4		; is static mappings flag on?
		bne.s	@drawFrame	; if yes, branch
		move.b	obFrame(a0),d1
		add.b	d1,d1
		adda.w	(a1,d1.w),a1	; get mappings frame address
		move.b	(a1)+,d1	; number of sprite pieces
		subq.b	#1,d1
		bmi.s	@setVisible

	@drawFrame:
		bsr.w	BuildSpr_Draw	; write data from sprite pieces to buffer

	@setVisible:
		bset	#7,obRender(a0)		; set object as visible

	@skipObject:
		addq.w	#2,d6
		subq.w	#2,(a4)			; number of objects left
		bne.w	@objectLoop

	@nextPriority:
		lea	$80(a4),a4
		dbf	d7,@priorityLoop
		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	@spriteLimit
		move.l	#0,(a2)
		rts	
; ===========================================================================

	@spriteLimit:
		move.b	#0,-5(a2)	; set last sprite link
		rts	
; End of function BuildSprites


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Draw:
		movea.w	obGfx(a0),a3
		btst	#0,d4
		bne.s	BuildSpr_FlipX
		btst	#1,d4
		bne.w	BuildSpr_FlipY
; End of function BuildSpr_Draw


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Normal:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	@return
		move.b	(a1)+,d0	; get y-offset
		ext.w	d0
		add.w	d2,d0		; add y-position
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,(a2)+	; write sprite size
		addq.b	#1,d5		; increase sprite counter
		move.b	d5,(a2)+	; set as sprite link
		move.b	(a1)+,d0	; get art tile
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0		; add art tile offset
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d0	; get x-offset
		ext.w	d0
		add.w	d3,d0		; add x-position
		andi.w	#$1FF,d0	; keep within 512px
		bne.s	@writeX
		addq.w	#1,d0

	@writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,BuildSpr_Normal	; process next sprite piece

	@return:
		rts	
; End of function BuildSpr_Normal

; ===========================================================================

BuildSpr_FlipX:
		btst	#1,d4		; is object also y-flipped?
		bne.w	BuildSpr_FlipXY	; if yes, branch

	@loop:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	@return
		move.b	(a1)+,d0	; y position
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4	; size
		move.b	d4,(a2)+	
		addq.b	#1,d5		; link
		move.b	d5,(a2)+
		move.b	(a1)+,d0	; art tile
		lsl.w	#8,d0
		move.b	(a1)+,d0	
		add.w	a3,d0
		eori.w	#$800,d0	; toggle flip-x in VDP
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d0	; get x-offset
		ext.w	d0
		neg.w	d0			; negate it
		add.b	d4,d4		; calculate flipped position by size
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0	; keep within 512px
		bne.s	@writeX
		addq.w	#1,d0

	@writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,@loop		; process next sprite piece

	@return:
		rts	
; ===========================================================================

BuildSpr_FlipY:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	@return
		move.b	(a1)+,d0	; get y-offset
		move.b	(a1),d4		; get size
		ext.w	d0
		neg.w	d0		; negate y-offset
		lsl.b	#3,d4	; calculate flip offset
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0	; add y-position
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,(a2)+	; size
		addq.b	#1,d5
		move.b	d5,(a2)+	; link
		move.b	(a1)+,d0	; art tile
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0	; toggle flip-y in VDP
		move.w	d0,(a2)+
		move.b	(a1)+,d0	; x-position
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	@writeX
		addq.w	#1,d0

	@writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,BuildSpr_FlipY	; process next sprite piece

	@return:
		rts	
; ===========================================================================

BuildSpr_FlipXY:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	@return
		move.b	(a1)+,d0	; calculated flipped y
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d4	; size
		move.b	d4,(a2)+	; link
		addq.b	#1,d5
		move.b	d5,(a2)+	; art tile
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0	; toggle flip-x/y in VDP
		move.w	d0,(a2)+
		move.b	(a1)+,d0	; calculate flipped x
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	@writeX
		addq.w	#1,d0

	@writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,BuildSpr_FlipXY	; process next sprite piece

	@return:
		rts	

		include	"_incObj\sub ChkObjectVisible.asm"

		include	"_incObj\sub FindFreeObj.asm"

Nem_SegaLogo:	incbin	"artnem\Sega Logo (JP1).bin" ; large Sega logo
		even
Eni_SegaLogo:	incbin	"tilemaps\Sega Logo (JP1).bin" ; large Sega logo (mappings)
		even

Eni_Title:	incbin	"tilemaps\Title Screen.bin" ; title screen foreground (mappings)
		even
Nem_TitleFg:	incbin	"artnem\Title Screen Foreground.bin"
		even
Nem_TitleSonic:	incbin	"artnem\Title Screen Sonic.bin"
		even
Nem_TitleTM:	incbin	"artnem\Title Screen TM.bin"
		even
Eni_JapNames:	incbin	"tilemaps\Hidden Japanese Credits.bin" ; Japanese credits (mappings)
		even
Nem_JapNames:	incbin	"artnem\Hidden Japanese Credits.bin"
		even

		dcb.b $63C,$FF

SoundDriver:	include "s1.sounddriver.asm"

; end of 'ROM'
		even
EndOfRom:


		END
