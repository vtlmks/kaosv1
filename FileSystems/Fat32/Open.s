

	Struc F32Open
F32O_MESSAGE	ResD	1	; Pointer to message
F32O_FILENAME	ResD	1	; Filename to open
F32O_MODE	ResD	1	; Mode to open file with
F32O_TEMPNAME	ResB	32	; Temp, short filename
F32O_TEMPDIR	ResB	32	; Temp, short dirname
	;
F32O_OPENNAME	ResB	260+1	; Filename
F32O_OPENPATH	ResB	512	; Path to file or null
F32O_OPENPTR	ResD	1	; Temp ptr
	;
F32O_UNIPOSITION	ResD	1	; Unicode position
F32O_UNIBUFFER	ResB	768	; Unicode buffer (including FAT bogus bytes, 32/entry)
F32O_LFNBUFFER	ResB	260+1	; LFN (UTF8) buffer
	;
F32O_FLAGSET	ResD	1	; Flagset, see below
F32O_ROOTSECTOR	ResD	1	; Rootsector of the partition
F32O_CURRSECTOR	ResD	1	; Current sector, temporary..
F32O_SIZE	EndStruc

	; Flagset

LFN_NAME	Equ	0	; Set when we deal with a long filename


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; FAT-32 Open
;
; Inputs:
;
; DP_ARG0 - Pointer to filename, including path and excluding the volumename.
; DP_ARG1 - Mode
;
; Output:
;
; FH_POSITION - File position or -1 for failure.
;
;-   -  - -- ---=--=-==-===-===-==============-====-===-==-=--=--- -- -  -   -
	; edx - pointer to message..
	;
F32PktOpen	PUSHX	edx,esi
	;
	Push	edx

	Mov	eax,F32O_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx
	Mov	[edx+F32O_MESSAGE],ebx
	Mov	eax,[esi+F32FS_DataSector]
	Mov	[edx+F32O_ROOTSECTOR],eax
	Mov	eax,[ebx+DP_ARG0]
	Mov	[edx+F32O_FILENAME],eax
	Mov	eax,[ebx+DP_ARG1]
	Mov	[edx+F32O_MODE],eax
	;
	Call	F32OExtractNames
	Call	F32OConvertNames
	;--
	PUSHAD
	Lea	esi,[edx+F32O_OPENNAME]
	PRINTTEXT	esi
	PRINTTEXT	BajsTxt
	PRINTTEXT	LFTxt
	POPAD
	;--
	Call	F32OFindDirectory
	Test	eax,eax
	Jz	.NoRootFile
	Cmp	eax,-1
	Je	.Failed
	;
	Mov	eax,[edx+F32O_ROOTSECTOR]
	Mov	[edx+F32O_CURRSECTOR],eax
.NoRootFile	Lea	ebp,[edx+F32O_OPENNAME]	; ebp = name to search for
	Call	F32OSearchDir
	;
.Failed	Mov	ebp,[edx+F32O_MESSAGE]
	Mov	ebp,[ebp+DP_FH]
	Mov	[ebp+FH_CURRENTBLOCK],eax
	Mov	[ebp+FH_STARTBLOCK],eax
	Mov	[ebp+FH_FILESIZE],ebx
	;
	Mov	eax,edx
	LIBCALL	FreeMem,ExecBase
	POPX	edx,esi
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32OConvertNames	Push	esi
	Lea	eax,[edx+F32O_OPENNAME]
	Lea	ebx,[esi+F32FS_TempBuffer]
	Call	F32ConvShortName
	Jc	.LongName
	Lea	esi,[esi+F32FS_TempBuffer]
	Lea	edi,[edx+F32O_OPENNAME]
.L	Lodsb
	Stosb
	Test	al,al
	Jnz	.L
.LongName	Pop	esi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; F32OExtractName -- Extracts the filename and the path.
;
F32OExtractNames	Push	esi
	;
	Mov	eax,[edx+F32O_FILENAME]
	Lea	ebx,[edx+F32O_OPENPATH]
	LIBCALL	PathPart,DosBase
	;
	Mov	eax,[edx+F32O_FILENAME]
	LIBCALL	FilePart,DosBase
	Mov	esi,eax
	Lea	edi,[edx+F32O_OPENNAME]
.L	Lodsb
	Stosb
	Test	al,al
	Jnz	.L
	;
	Pop	esi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; F32OFindDirectory -- Steps to the correct directory if the file doesn't
;                      reside in the root directory of the partition.
;
; Returncodes:
;
; eax:	1  = No directory, file is in the root
;	0  = Found directory and updated the cluster pointer
;	-1 = Failed to find directory
;

F32OFindDirectory	Cmp byte	[edx+F32O_OPENPATH],0
	Je near	.NoDirectory
	;
	Mov	eax,[edx+F32O_ROOTSECTOR]	; Start in the root
	Mov	[edx+F32O_CURRSECTOR],eax

	Lea	eax,[edx+F32O_OPENPATH]
	Mov	[edx+F32O_OPENPTR],eax

.Main	Mov	eax,[edx+F32O_OPENPTR]
	Test	eax,eax
	Jz near	.Done
	Call	F32OGetNext
	Mov	[edx+F32O_OPENPTR],eax
	;

	PRINTTEXT	LFTxt
	PRINTTEXT	ebx
	PRINTTEXT	BajsTxt

	Push	ebx
	Mov	eax,ebx
	Lea	ebx,[esi+F32FS_TempBuffer]
	Call	F32ConvShortName
	Pop	ebx
	Jc	.LongName

	PushAD
	PRINTTEXT	LFTxt
	Lea	esi,[esi+F32FS_TempBuffer]
	PRINTTEXT	esi
	PRINTTEXT	BajsTxt
	PopAD


	Push	esi
	Lea	esi,[esi+F32FS_TempBuffer]
	Lea	edi,[edx+F32O_TEMPDIR]
.L	Lodsb
	Stosb
	Test	al,al
	Jnz	.L
	Pop	esi
	Lea	ebx,[edx+F32O_TEMPDIR]

.LongName	Mov	ebp,ebx	; ebp = name to search for
	Call	F32OSearchDir
	Cmp	eax,-1
	Je	.Failure

	Call	GetSector
	Mov	[edx+F32O_CURRSECTOR],eax
	Jmp	.Main

.Done	PRINTTEXT	FoundDirTxt
	XOr	eax,eax
	Ret

.NoDirectory	PRINTTEXT	NoDirTxt
	Mov	eax,1
	Ret

.Failure	PRINTTEXT	FailDirTxt
	Mov	eax,-1
	Ret


FoundDirTxt	Db	0xa,"** Found dir..",0xa,0
NoDirTxt	Db	0xa,"** No dir given...",0xa,0
FailDirTxt	Db	0xa,"** Could not find dir..",0xa,0
BajsTxt	Db	"|",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32OGetNext	Push	esi
	Mov	esi,eax
	Push	esi
.L	Lodsb
	Test	al,al
	Jz	.Last
	Cmp	al,"/"
	Jne	.L
.Done	Mov byte	[esi-1],0
	Mov	eax,esi	; eax=ptr to next
	Pop	ebx	; ebx=ptr to current
	Pop	esi
	Ret
.Last	XOr	eax,eax	; eax=null if this is the last
	Pop	ebx	; ebx=ptr to current
	Pop	esi
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; F32OSearchDir -- Search the given directory for a file/dir name.
;
; Inputs:
;
; ebp	- Name of file/dir to search for
; F32O_CURRSECTOR	- Start sector of the directory
;
; Outputs:
;
; eax - Cluster number or -1 for failure
; ebx - Filesize
;

F32OSearchDir	PUSHX	edx,esi		; Search current directory
	Call	.GetNextSector
	; ebp = file/dirname
	Lea	ecx,[esi+F32FS_SectorData]
	;--
.Main	Cmp byte	[ecx+edi+FAT32DE.Attributes],FATATR_LONGN
	Jne	.NoLongname
	Call	F32OGetLFN		; add to unicode buffer
	Jmp	.NoMatch
	;--
.NoLongname	Bt dword	[edx+F32O_FLAGSET],LFN_NAME
	Jnc	.NoLongCompare
	Call	F32OConvertLFN		; translate unicode into utf8
	Call	F32OCompareLFN		; check if name to open matches the lfn
	Jc	.FoundMatch

.NoLongCompare	Mov	eax,[ebp]
	Cmp dword	[ecx+edi],0
	Je near	.EOD

	Call	F32OCompareShort
	Test	eax,eax
	Jnz	.NoMatch

.FoundMatch	Mov	ax,[ecx+edi+FAT32DE.ClusterHigh]
	Rol	eax,16
	Mov	ax,[ecx+edi+FAT32DE.ClusterLow]
	Mov	ebx,[ecx+edi+FAT32DE.FileSize]
	PRINTLONGSTR	FDBGClusterTxt,eax			; ** remove
	PRINTLONGSTR	FDBGFileSizeTxt,ebx			; ** remove
	POPX	edx,esi
	Ret

	;
.NoMatch	Lea	edi,[edi+32]
	Cmp	edi,512
	Jne near	.Main
	Call	.GetNextSector
	Jmp	.Main

	;
.GetNextSector	XOr	edi,edi
	Mov	eax,[edx+F32O_CURRSECTOR]
	Call	ReadSector
	Inc dword	[edx+F32O_CURRSECTOR]
	Ret

	;
.EOD	Mov dword	eax,-1	; End of directory, no match was found
	XOr	ebx,ebx
	POPX	edx,esi
	Ret

FDBGClusterTxt	Db	"FAT32Read() - Cluster position = 0x",0
FDBGFileSizeTxt	Db	"FAT32Read() - File size = 0x",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Compare the shortname form
;
F32OCompareShort	PUSHX	esi,edi,ecx
	Lea	esi,[ecx+edi]
	Lea	edi,[edx+F32O_TEMPNAME]
	Mov	ecx,11
	Rep Movsb
	POPX	esi,edi,ecx
	Lea	eax,[edx+F32O_TEMPNAME]
	Mov	ebx,ebp
	Push	ebp
	LIBCALL	StriCmp,UteBase
	Pop	ebp
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Copy the current DirectoryEntry to Unicode buffer for later translation
;
F32OGetLFN	PushAD
	Lea	esi,[ecx+edi]
	Lea	edi,[edx+F32O_UNIBUFFER]
	Mov	eax,[edx+F32O_UNIPOSITION]
	Lea	edi,[edi+eax]
	Mov	ecx,8
	Cld
	Rep Movsd
	Add dword	[edx+F32O_UNIPOSITION],32
	Bts dword	[edx+F32O_FLAGSET],LFN_NAME
	PopAD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Convert Unicode buffer into UTF8
;
F32OConvertLFN	PushAD
	Mov	ebp,[edx+F32O_UNIPOSITION]
	Lea	edi,[edx+F32O_LFNBUFFER]
.L	Test	ebp,ebp
	Jz	.Done
	Sub	ebp,32
	Lea	ebx,[edx+F32O_UNIBUFFER]
	Lea	ebx,[ebx+ebp]
	Call	F32OAppendUnicode
	Jmp	.L
	;
.Done	Mov dword	[edx+F32O_UNIPOSITION],0
	Btr dword	[edx+F32O_FLAGSET],LFN_NAME
	PopAD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32OCompareLFN	Lea	eax,[edx+F32O_OPENNAME]
	Lea	ebx,[edx+F32O_LFNBUFFER]
	Push	ebp
	LIBCALL	StriCmp,UteBase
	Pop	ebp
	Test	eax,eax
	Jnz	.NoMatch
	Stc
	Ret
.NoMatch	Clc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Fake Unicode -> UTF8 translation..
;
F32OAppendUnicode	Cld
	Lea	esi,[ebx+FAT32LFN.Name1]
	Mov	ecx,5
	Call	.UnicodeConvert
	Lea	esi,[ebx+FAT32LFN.Name2]
	Mov	ecx,6
	Call	.UnicodeConvert
	Lea	esi,[ebx+FAT32LFN.Name3]
	Mov	ecx,2
	Call	.UnicodeConvert
	Ret
	;
.UnicodeConvert	Lodsb
	Stosb
	Inc	esi
	Dec	ecx
	Jnz	.UnicodeConvert
	Ret


