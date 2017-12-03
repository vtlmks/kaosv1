%ifndef Includes_LVO_DOS_I
%define Includes_LVO_DOS_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Dos.I V1.0.0
;
;     Library Vector Offsets for Dos library
;

	LIBINIT
	LIBDEF	LVOAddPart
	LIBDEF	LVOPathPart
	LIBDEF	LVOFilePart
	LIBDEF	LVOAddDosEntry
	LIBDEF	LVOFreeDosEntry
	LIBDEF	LVOFindDosEntry
	LIBDEF	LVOLockDosList
	LIBDEF	LVOUnlockDosList
	LIBDEF	LVOOpen
	LIBDEF	LVOClose
	LIBDEF	LVORead
	LIBDEF	LVOSeek
	LIBDEF	LVOWrite
	LIBDEF	LVOLoadSeg
	LIBDEF	LVOUnloadSeg
	LIBDEF	LVOAssignPath



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
