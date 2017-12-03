
;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Utility.s V1.0.0
;
;     Utility.library V1.0.0
;
;     This is the utility.library core.
;


	%Include	"Libraries\Utility\Ascii2Hex.s"
	%Include	"Libraries\Utility\Hex2Ascii.s"
	%Include	"Libraries\Utility\Sprintf.s"
	%Include	"Libraries\Utility\Strcmp.s"
	%Include	"Libraries\Utility\Stricmp.s"
	%Include	"Libraries\Utility\Strlen.s"
	%Include	"Libraries\Utility\ToLower.s"
	%Include	"Libraries\Utility\ToUpper.s"

	%Include	"Libraries\Utility\Lists\Lists.s"
	%Include	"Libraries\Utility\Tags\Tags.s"



UtilStart	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

UtilVersion	Equ	1
UtilRevision	Equ	1

UtilLibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,UtilVersion
	Dd	LT_REVISION,UtilRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,UtilName
	Dd	LT_IDSTRING,UtilIDString
	Dd	LT_INIT,UtilInitTable

UtilInitTable	Dd	0	; _SIZE
	Dd	UteBase
	Dd	UtilityInit
	Dd	-1

UtilName	Db	"utility.library",0
UtilIDString	Db	"utility.library 1.1 (2001-03-28)",0


Utility_OpenCount	Dd	1


OpenUtility	Mov	eax,UteBase
	Ret

CloseUtility:
ExpungeUtility	Mov	eax,-1
	Ret

NullUtility	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
UtilityInit	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	UTIL_RemoveTail		; -116
	Dd	UTIL_RemoveHead		; -112
	Dd	UTIL_Remove		; -108
	Dd	UTIL_InsertNode		; -104
	Dd	UTIL_InitList		; -100
	Dd	UTIL_AddTail		; -96
	Dd	UTIL_AddHead		; -92
	;
	Dd	UTIL_FetchTags		; -88
	Dd	UTIL_FindTag		; -84
	Dd	UTIL_SetTagData		; -80
	Dd	UTIL_AddNodeSorted	; -76
	Dd	UTIL_Sprintf		; -72
	Dd	UTIL_ToUpper		; -68
	Dd	UTIL_ToLower		; -64
	Dd	UTIL_FindName		; -60
	Dd	UTIL_FreeTaglist		; -56
	Dd	UTIL_CloneTaglist		; -52
	Dd	UTIL_Ascii2Hex		; -48
	Dd	UTIL_Hex2Ascii		; -44
	Dd	UTIL_GetTagData		; -40
	Dd	UTIL_StrLen		; -36
	Dd	UTIL_StriCmp		; -32
	Dd	UTIL_StrCmp		; -28
	;-
	Dd	NullUtility		; -24
	Dd	NullUtility		; -20
	Dd	NullUtility		; -16
	Dd	ExpungeUtility		; -12
	Dd	CloseUtility		; -8
	Dd	OpenUtility		; -4
UteBase:

