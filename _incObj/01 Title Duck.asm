; ---------------------------------------------------------------------------
; Object 01 - Uncle Duck Dancing in the Title Card
; ---------------------------------------------------------------------------

TitleDuck:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TCard_Index(pc,d0.w),d1
		jmp	TCard_Index(pc,d1.w)
; ===========================================================================
TCard_Index:	dc.w TCard_Main-TCard_Index
		dc.w TCard_Animate-TCard_Index
; ===========================================================================

TCard_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$140,obX(a0)
		move.w	#$F0,obScreenY(a0) ; position is fixed to screen
		move.l	#Map_TCard,obMap(a0)
		move.b	#1,obPriority(a0)

TCard_Animate:	; Routine 1
		lea	(Ani_TCard).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
		rts	