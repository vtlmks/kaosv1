;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     OpenClass.s V1.0.0
;
;     Open a class, from within the kernel or from disk.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; OpenClass -
;
; Inputs:
;  eax - Class name
;  ebx - Class version (minimum)
;
; Output:
;  eax - Pointer to class vectortable or null for failure
;

	Struc OpenClass
OC_CLASSNAME	ResD	1	; Pointer to classname
OC_CLASSVERSION	ResD	1	; Class version (minimum)
	;
OC_CLASSTAG	ResD	1	; Class taglist pointer
OC_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_OpenClass	PushFD
	PUSHX	ebx,ecx,edx,edi,esi,ebp
	LINK	OC_SIZE
	Mov	[ebp+OC_CLASSNAME],eax
	Mov	[ebp+OC_CLASSVERSION],ebx
	;
	Call	OCOpenInternal
	Jc	.Done
	Call	OCOpenExternal
	;
.Done	UNLINK	OC_SIZE
	POPX	ebx,ecx,edx,edi,esi,ebp
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Search the librarylist if library is internal or already opened
;
OCOpenInternal	Mov	eax,[ebp+OC_CLASSNAME]
	Lea	ebx,[SysBase+SB_ClassList]
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jz	.NoLibrary
	;
	Mov	ebx,[eax+LE_LIBVERSION]
	Mov	ecx,[ebp+OC_CLASSVERSION]
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

OCOpenExternal	Mov	eax,[ebp+OC_CLASSNAME]
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

	Mov	[ebp+OC_CLASSTAG],eax
	Mov	ebx,eax
	Mov	eax,LT_INIT
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LE_LIBTABLE],eax	; LibraryVectorTable
	;
	Mov	eax,LT_VERSION
	Mov	ebx,[ebp+OC_CLASSTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LE_LIBVERSION],eax	; Set library version
	;
	Mov	eax,LT_NAME
	Mov	ebx,[ebp+OC_CLASSTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LN_NAME],eax		; Set library name
	;
	Mov	eax,LT_PRIORITY
	Mov	ebx,[ebp+OC_CLASSTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LN_PRI],al		; Set library priority
	;
	Mov byte	[edx+LN_TYPE],NT_LIBRARY

	; make check for version later.....
	;
	;
	Mov	eax,[edx+LE_LIBTABLE]	; Build new LibBase
	Mov	eax,[eax+4]
	Call	OCBuildTable

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
	Lea	eax,[SysBase+SB_ClassList]
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
OCBuildTable	Mov	esi,eax		; Pointer to vectortable
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
