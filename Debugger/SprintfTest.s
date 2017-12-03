;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;

;  eax - Formatstring
;  ebx - Data
;  ecx - Buffer
;  edx - PutChar procedure or null for default
;

Sprintf	Lea	eax,[FormatString]
	Lea	ebx,[FormatData]
	Lea	ecx,[Buffer]
	XOr	edx,edx
	LIBCALL	Sprintf,UteBase

	Lea	esi,[Buffer]
	Call	DebWriteLines
	Ret

FormatString	Db	"%ld %lx %d %x %lu %u %c",0xa,0

FormatData	Dd	-1
	Dd	-1
	Dd	-1
	Dd	-1
	Dd	-1
	Dd	-1
	Db	"!"

SpString	Db	"Mooookaw",0

Buffer	Times 256 Db 0

