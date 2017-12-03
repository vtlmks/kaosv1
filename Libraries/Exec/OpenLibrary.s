;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     OpenLibrary.s V1.0.0
;
;     Open a library, from within the kernel or from disk.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; OpenLibrary -
;
; Inputs:
;  eax - Library name
;  ebx - Library version (minimum)
;
; Output:
;  eax - Pointer to library vectortable or null for failure
;

	Struc OpenLibrary
OL_LIBNAME	ResD	1	; Pointer to libraryname
OL_LIBVERSION	ResD	1	; Library version (minimum)
	;
OL_LIBTAG	ResD	1	; Library taglist pointer
OL_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_OpenLibrary	PushFD
	PUSHX	ebx,ecx,edx,edi,esi,ebp
	LINK	OL_SIZE
	Mov	[ebp+OL_LIBNAME],eax
	Mov	[ebp+OL_LIBVERSION],ebx
	;
	Call	OLOpenInternal
	Jc	.Done
	Call	OLOpenExternal
	;
.Done	UNLINK	OL_SIZE
	POPX	ebx,ecx,edx,edi,esi,ebp
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Search the librarylist if library is internal or already opened
;
OLOpenInternal	Mov	eax,[ebp+OL_LIBNAME]
	Lea	ebx,[SysBase+SB_LibraryList]
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jz	.NoLibrary
	;
	Mov	ebx,[eax+LE_LIBVERSION]
	Mov	ecx,[ebp+OL_LIBVERSION]
	Cmp	ebx,ecx
	Jb	.NoLibrary
	Mov	eax,[eax+LE_LIBTABLE]	; Vectortable ptr
	Call	[eax-4]		; LibOpen()
	Stc
	Ret

.NoLibrary	XOr	eax,eax
	Clc
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Try to open the library externally

OLOpenExternal	Mov	eax,[ebp+OL_LIBNAME]
	LIBCALL	LoadSeg,DosBase
	Test	eax,eax
	Jz near	.NoLibrary

	Push	eax
	Mov	eax,LE_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx
	Mov	[edx+LE_LIBSEGLIST],ebx
	SUCC	ebx
	Lea	ebx,[ebx+HUNK_BUFFER]
	Call	ebx

	Mov	[ebp+OL_LIBTAG],eax
	Mov	ebx,eax
	Mov	eax,LT_INIT
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LE_LIBTABLE],eax	; LibraryVectorTable
	;
	Mov	eax,LT_VERSION
	Mov	ebx,[ebp+OL_LIBTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LE_LIBVERSION],eax	; Set library version
	;
	Mov	eax,LT_NAME
	Mov	ebx,[ebp+OL_LIBTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LN_NAME],eax		; Set library name
	;
	Mov	eax,LT_PRIORITY
	Mov	ebx,[ebp+OL_LIBTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LN_PRI],al		; Set library priority
	;
	Mov byte	[edx+LN_TYPE],NT_LIBRARY

	; make check for version later.....
	;
	;
	Mov	eax,[edx+LE_LIBTABLE]	; Build new LibBase
	Mov	eax,[eax+4]
	Call	OLBuildTable

	Mov	eax,[edx+LE_LIBTABLE]
	PushAD
	Lea	ecx,[ExecBase]		; ExecBase in ecx
	Mov	edx,edi		; LibBase in edx
	Call	[eax+8]		; LibInit()
	PopAD
	Test	eax,eax
	Jz	.Error
	;
	Mov	eax,[edx+LE_LIBTABLE]
	Mov	eax,[eax+4]
	PushAD
	Call	[eax]		; LibOpen()
	PopAD
	;
	Mov	[edx+LE_LIBTABLE],edi
	Lea	eax,[SysBase+SB_LibraryList]
	Mov	ebx,edx
	ADDTAIL
	Mov	eax,edi
.NoLibrary	Ret

.Error:	; UnLoadSeg()
	; FreeMem()
	; ..
	XOr	eax,eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OLBuildTable	Mov	esi,eax		; Pointer to vectortable
	Mov	ecx,-1
	Cld
.L	Lodsd
	Inc	ecx
	Cmp	eax,-1
	Jne	.L
	;
	PUSHX	esi,ecx
	Shl	ecx,2
	Mov	eax,[edx+LE_LIBTABLE]
	Mov	eax,[eax]
	Lea	eax,[eax+ecx]
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	POPX	esi,ecx
	;
	Std
	Sub	esi,8
.L1	Lodsd
	Mov	[edi],eax
	Lea	edi,[edi+4]
	Dec	ecx
	Jnz	.L1
	Cld
	Ret
