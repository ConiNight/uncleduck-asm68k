; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------

palp:	macro paladdress,ramaddress,colours
	dc.l paladdress
	dc.w ramaddress, (colours>>1)-1
	endm

PalPointers:

; palette address, RAM address, colours

ptr_Pal_Title:		palp	Pal_Title,v_pal_dry,$10
			even

palid_Title:		equ (ptr_Pal_Title-PalPointers)/8
