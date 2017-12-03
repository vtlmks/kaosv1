;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AllocIFF.S V1.0.0
;
;     AllocIFF.
;

IFF_AllocIFF	PUSHX	ecx
	;

	Lea	ecx,[AllocIFFMemTags]
	LIBCALL	AllocMem,ExecBase
	Push	eax
	Mov	ebx,eax
	INITLIST	[ebx+IFF_STREAMHOOK]
	INITLIST	[ebx+IFF_ENTRYHOOKLIST]
	INITLIST	[ebx+IFF_EXITHOOKLIST]
	INITLIST	[ebx+IFF_CONTEXTLIST]
	INITLIST	[ebx+IFF_LCILIST]
	Pop	eax
	;
	POPX	ecx
	Ret

AllocIFFMemTags	Dd	MMA_SIZE,IFF_SIZE
	Dd	TAG_DONE
