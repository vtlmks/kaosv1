;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Dos.s V1.0.0
;
;     Dos.library V1.0.0
;
;     This is the dos.library core.
;


	%Include	"Libraries\Dos\AddDosEntry.s"
	%Include	"Libraries\Dos\AddPart.s"
	%Include	"Libraries\Dos\AssignPath.s"
	%Include	"Libraries\Dos\ChangeDir.s"
	%Include	"Libraries\Dos\Close.s"
	%Include	"Libraries\Dos\FilePart.s"
	%Include	"Libraries\Dos\FindDosEntry.s"
	%Include	"Libraries\Dos\FreeDosEntry.s"
	%Include	"Libraries\Dos\LoadSeg.s"
	%Include	"Libraries\Dos\Lock.s"
	%Include	"Libraries\Dos\LockDosList.s"
	%Include	"Libraries\Dos\Open.s"
	%Include	"Libraries\Dos\PathPart.s"
	%Include	"Libraries\Dos\Read.s"
	%Include	"Libraries\Dos\Seek.s"
	%Include	"Libraries\Dos\Unlock.s"
	%Include	"Libraries\Dos\UnlockDosList.s"
	%Include	"Libraries\Dos\UnloadSeg.s"
	%Include	"Libraries\Dos\Write.s"


DosStart	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

DosVersion	Equ	1
DosRevision	Equ	0

DosLibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,DosVersion
	Dd	LT_REVISION,DosRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,DosName
	Dd	LT_IDSTRING,DosIDString
	Dd	LT_INIT,DosInitTable
	Dd	TAG_DONE

DosInitTable	Dd	0	; _SIZE
	Dd	DosBase
	Dd	DosInit
	Dd	-1

DosName	Db	"dos.library",0
DosIDString	Db	"dos.library 1.0 (2000-09-24)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Dos_OpenCount	Dd	1

OpenDos	Mov	eax,DosBase
	Ret

CloseDos:
ExpungeDos	Mov	eax,-1
	Ret

NullDos	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DosInit	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	DOS_ChangeDir		; -100
	Dd	DOS_Unlock		; -96
	Dd	DOS_Lock		; -92
	Dd	DOS_AssignPath		; -88
	Dd	DOS_UnloadSeg		; -84
	Dd	DOS_LoadSeg		; -80
	Dd	DOS_Write		; -76
	Dd	DOS_Seek		; -72
	Dd	DOS_Read		; -68
	Dd	DOS_Close		; -64
	Dd	DOS_Open		; -60
	Dd	DOS_UnlockDosList		; -56
	Dd	DOS_LockDosList		; -52
	Dd	DOS_FindDosEntry		; -48
	Dd	DOS_FreeDosEntry		; -44
	Dd	DOS_AddDosEntry		; -40
	Dd	DOS_FilePart		; -36
	Dd	DOS_PathPart		; -32
	Dd	DOS_AddPart		; -28
	;-
	Dd	NullDos		; -24
	Dd	NullDos		; -20
	Dd	NullDos		; -16
	Dd	ExpungeDos		; -12
	Dd	CloseDos		; -8
	Dd	OpenDos		; -4
DosBase:

