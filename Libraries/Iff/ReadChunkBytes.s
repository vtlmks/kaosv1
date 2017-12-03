;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ReadChunkBytes.S V1.0.0
;
;     ReadChunkBytes.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; ReadChunkBytes
;
; Input:
;  eax = IFF
;  ebx = Buffer
;  ecx = NumBytes
;
IFF_ReadChunkBytes	PUSHX	ebx,ecx

	Mov	edx,eax
	Lea	eax,[ReadChunkCmdMem]
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoMemory
	Mov	[eax+ISC_BUFFER],ebx
	Mov	[eax+ISC_NUMBYTES],ecx
	Mov	ebx,edx
	Lea	ecx,eax
	Mov	eax,[eax+IFF_STREAMHOOK]
	LIBCALL	CallHook,ExecBase

.NoMemory	POPX	ebx,ecx
	Ret

AllocCmdMem	Dd	MMA_SIZE,ISC_SIZE		; This structure should be used by all the routines allocating a iff_hookcommand.
	Dd	TAG_DONE

;	Struc IFFSTREAMCMD
;ISC_COMMAND	ResD	1
;ISC_BUFFER	ResD	1
;ISC_NUMBYTES	ResD	1
;ISC_SIZE	EndStruc

;  eax - Hook
;  ebx - Object
;  ecx - Packet

; read max  CN_LENGTH, update CN_SCAN.

