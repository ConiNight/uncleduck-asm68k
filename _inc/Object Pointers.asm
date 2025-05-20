; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
ptr_Obj01:		dc.l NullObject
ptr_Obj02:		dc.l NullObject
ptr_Obj03:		dc.l NullObject
ptr_Obj04:		dc.l NullObject
ptr_Obj05:		dc.l NullObject
ptr_Obj06:		dc.l NullObject
ptr_Obj07:		dc.l NullObject
ptr_Obj08:		dc.l NullObject
ptr_Obj09:		dc.l NullObject
ptr_Obj0A:		dc.l NullObject
ptr_Obj0B:		dc.l NullObject
ptr_Obj0C:		dc.l NullObject
ptr_Obj0D:		dc.l NullObject
ptr_Obj0E:		dc.l NullObject
ptr_Obj0F:		dc.l NullObject
NullObject:
		jmp	(DeleteObject).l