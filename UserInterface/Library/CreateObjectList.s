;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CreateObjectList.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Create a new objectlist
;
;  Inputs:
;   ecx = List of objects to create
;
;  Output:
;   eax = Root object or null for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc UICreateObj
UICO_Owner	ResD	1	; Owner object or null for root
UICO_Tags	ResD	1	; Taglist given as parameter
UICO_TagList	ResD	1	; Taglist for creation of object
UICO_Class	ResD	1	; Pointer to class
UICO_Root	ResD	1	; Root to return
UICO_Type	ResD	1	; Currenttype
	;
UICO_AppName	ResD	1	; Applicationname
UICO_ConfigName	ResD	1	; Configname
UICO_ConfigMem	ResD	1	; Configmemory, either default or app specific
UICO_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_CreateObjectList	PushFD
	PushAD
	LINK	UICO_SIZE
	Mov dword	[ebp+UICO_Root],0		; Set root to null
	Mov	[ebp+UICO_Tags],ecx
	;
	Call	COParseTags
	Jc	.Failure
	Call	COLoadConfig
	Jc	.NoReloc
	Call	CORelocConfig
.NoReloc	Call	COSetupObjectList
	;
.Done	UNLINK	UICO_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret

.Failure	UNLINK	UICO_SIZE
	RETURN	0
	PopAD
	PopFD
	Ret

;Tags	Dd	CLASS_WINDOW,WindowTags
;	Dd	CLASS_GROUP,GroupTags
;	Dd	CLASS_OBJECT,Button1Tags
;	Dd	CLASS_OBJECT,Button2Tags
;	Dd	CLASS_OBJECT,Button3Tags
;	Dd	CLASS_GROUP,Group2Tags
;	Dd	CLASS_OBJECT,Button3Tags
;	Dd	CLASS_OBJECT,Button4Tags
;	Dd	CLASS_OBJECT,Button5Tags
;	Dd	CLASS_GROUPEND,0
;	Dd	CLASS_GROUPEND,0
;	Dd	TAG_DONE


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
COParseTags	Mov	eax,COT_APPNAME
	Mov	ebx,[ebp+UICO_Tags]
	LIBCALL	GetTagData,UteBase
	Mov	[ebp+UICO_AppName],eax

	Mov	eax,COT_CONFIGNAME
	Mov	ebx,[ebp+UICO_Tags]
	LIBCALL	GetTagData,UteBase
	Mov	[ebp+UICO_ConfigName],eax
	Test	eax,eax
	Jz	.Failure
	Mov	eax,COT_OBJECTLIST
	Mov	ebx,[ebp+UICO_Tags]
	LIBCALL	GetTagData,UteBase
	Test	eax,eax
	Jz	.Failure
	Mov	[ebp+UICO_TagList],eax
	Clc
	Ret
.Failure	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
COLoadConfig	Lea	eax,[DefaultConfigN]
	Mov	ebx,OPENF_OLDFILE
	LIBCALL	Open,DosBase
	Test	eax,eax
	Jz near	.Failure
	;
	Mov	edx,eax
	XOr	ebx,ebx
	Mov	ecx,OFFSET_END
	LIBCALL	Seek,DosBase
	XOr	ebx,ebx
	Mov	eax,edx
	Mov	ecx,OFFSET_BEGINNING
	LIBCALL	Seek,DosBase
	Test	eax,eax
	Jz	.Failure
	;
	Push	eax		; Save length
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+UICO_ConfigMem],eax
	Mov	ecx,eax		; Buffer
	Mov	eax,edx		; FH
	Pop	ebx		; Length
	LIBCALL	Read,DosBase
	Mov	eax,edx
	LIBCALL	Close,DosBase
	Clc
	Ret
.Failure	Stc
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CORelocConfig	Mov	esi,[ebp+UICO_ConfigMem]
	Mov	ecx,[ebp+UICO_ConfigMem]
.L	Lodsd
	Test	eax,eax
	Jz	.Done
	Add	[esi],ecx
	Lodsd
	Jmp	.L
.Done	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
COSetupObjectList	Cld
	Mov	esi,[ebp+UICO_TagList]
.Loop	Lodsd
	Cmp	eax,-1		; check for GROUPEND too
	Je near	.Done
	;
	Mov	[ebp+UICO_Type],eax
	Call	COOpenObject
	;--
	Cmp dword	[ebp+UICO_Type],CLASS_WINDOW
	Jne	.NoWindow
	Mov	[ebp+UICO_Root],eax
	Mov	[ebp+UICO_Owner],eax
	Jmp	.Loop
	;
.NoWindow	Cmp dword	[ebp+UICO_Type],CLASS_GROUP
	Jne	.NoGroup
	Push dword	[ebp+UICO_Owner]
	Push	eax
	Mov	ebx,eax
	Mov	eax,[ebp+UICO_Owner]
	Inc dword	[eax+CD_NumObjects]
	Lea	eax,[eax+LN_SIZE]
	ADDTAIL
	Pop dword	[ebp+UICO_Owner]
	Jmp	.Loop
	;
.NoGroup	Cmp dword	[ebp+UICO_Type],CLASS_GROUPEND
	Jne	.AttachObject
	Pop dword	[ebp+UICO_Owner]
	Jmp	.Loop
	;--
.AttachObject	Mov	ebx,eax
	Mov	eax,[ebp+UICO_Owner]
	Inc dword	[eax+CD_NumObjects]
	Lea	eax,[eax+LN_SIZE]
	ADDTAIL
	Jmp	.Loop

.Done	Mov	eax,[ebp+UICO_Root]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
COOpenObject	Lodsd
	Mov	edi,eax
	Mov	ebx,eax
	Mov	eax,CT_CLASSNAME
	LIBCALL	GetTagData,UteBase
	Test	eax,eax
	Jz	.Failure
	;
	Push	eax
	Mov	eax,CT_CLASSVERSION
	Mov	ebx,edi
	LIBCALL	GetTagData,UteBase
	Mov	ebx,eax
	Pop	eax
	LIBCALL	OpenClass,ExecBase
	Mov	[ebp+UICO_Class],eax
	;
	Mov	ecx,edi			; Class taglist
	LIBCALL	CreateObject,UIBase
	;
	Mov	ecx,[ebp+UICO_Class]		; Set classbase
	Mov	[eax+CD_ClassBase],ecx
	Mov	ecx,[ebp+UICO_Type]		; Set type
	Mov	[eax+CD_Type],ecx
	Mov	ecx,[ebp+UICO_Root]		; Set hierachy root
	Mov	[eax+CD_Root],ecx
	Mov	ecx,[ebp+UICO_Owner]		; Set owner
	Mov	[eax+CD_Owner],ecx
	Mov	ecx,[ebp+UICO_ConfigMem]		; Set configfile
	Mov	[eax+CD_Config],ecx
.Failure	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DefaultConfigN	Db	"default.config",0

