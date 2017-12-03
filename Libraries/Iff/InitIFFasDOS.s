;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     InitIFFAsDOS.S V1.0.0
;
;     InitIFFAsDOS.
;
; Input:
;  eax = IFF
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IFF_InitIFFAsDOS	PUSHX	ebx,ecx
	PushFD

	Mov	ebx,IFFF_FSEEK|IFFF_RSEEK	; Flags ?SEEK flags.
	Lea	ecx,[IFFDOSStreamHook]	; Hook Taglist
	LIBCALL	InitIFF,IFFLibrary

	XOr	eax,eax

	PopFD
	POPX	ebx,ecx
	Ret

IFFDosStreamHook	Dd	IFFDosStream
	Dd	0
	Dd	0

; Every time we are called, we will be supplied with the following structures.
;
;	eax:	pointer to streamhook. If we are to start a HLL hook...
;	ebx:	pointer to IFFHandle structure.
;	ecx:	pointer to IFFStreamCmd structure.
;
;	Struc IFFSTREAMCMD
;ISC_COMMAND	ResD	1
;ISC_BUFFER	ResD	1
;ISC_NUMBYTES	ResD	1
;ISC_SIZE	EndStruc
;
;	Struc IFFHANDLE
;IFF_STREAM	ResD	1
;IFF_FLAGS	ResD	1
;IFF_DEPTH	ResD	1
;IFF_STREAMHOOK	ResB	MLH_SIZE
;IFF_ENTRYHOOKLIST	ResB	MLH_SIZE
;IFF_EXITHOOKLIST	ResB	MLH_SIZE
;IFF_CONTEXTLIST	ResB	MLH_SIZE
;IFF_LCILIST	ResB	MLH_SIZE
;IFF_SIZE	EndStruc
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IFFDOS_MAXFUNC	Equ	7
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IFFDOSStream	PUSHX	edx
	PushFD

	Mov	edx,[ecx+ISC_COMMAND]
	Cmp	edx,IFFDOS_MAXFUNC
	Ja	.Outside
	Call	[IFFDOS_Table+edx*5]

.Outside	PopFD
	POPX	edx
	Ret

IFFDOS_Table	Jmp	IFFDOS_Init
	Jmp	IFFDOS_Cleanup
	Jmp	IFFDOS_Read
	Jmp	IFFDOS_Write
	Jmp	IFFDOS_Seek
	Jmp	IFFDOS_Entry
	Jmp	IFFDOS_Exit
	Jmp	IFFDOS_PurgeLCI

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Prepare the stream for a session
;
IFFDOS_Init	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Terminate stream session
;
IFFDOS_Cleanup	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Read bytes from stream
;
;  eax - Filehandler, as returned by Open()
;  ebx - Length, in bytes
;  ecx - Buffer
;
IFFDOS_Read	PUSHX	ebx,ecx
	Mov	eax,[ebx+IFF_STREAM]
	Mov	ebx,[ecx+ISC_NUMBYTES]
	Mov	ecx,[ecx+ISC_BUFFER]
	LIBCALL	Read,DosBase
	XOr	eax,eax		; Null for success
	POPX	ebx,ecx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Write bytes to stream
;
IFFDOS_Write	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Seek in stream
;
;  eax - Filehandler, as returned by Open()
;  ebx - Position, in bytes
;  ecx - Mode (OFFSET_BEGINNING, OFFSET_CURRENT, OFFSET_END)
;
IFFDOS_Seek	PUSHX	ebx,ecx
	Mov	eax,[ebx+IFF_STREAM]
	Mov	ebx,[ecx+ISC_NUMBYTES]
	Mov	ecx,OFFSET_CURRENT
	LIBCALL	Seek,DosBase
	XOr	eax,eax		; Null for success
	POPX	ebx,ecx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Just entered a new context
;
IFFDOS_Entry	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; About to leave a context
;
IFFDOS_Exit	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Purge a LocalContextItem
;
IFFDOS_PurgeLCI	XOr	eax,eax
	Ret

