
	Struc F32Seek
F32S_CLUSTERSIZE	ResD	1	; Size of a cluster in bytes
F32S_MESSAGE	ResD	1	; Pointer to message
F32S_OFFSET	ResD	1	; Seek offset
F32S_MODE	ResD	1	; Seek mode
F32S_FH	ResD	1	; Pointer to FileHandle
F32S_ABSPOS	ResD	1	; New absolute position
F32S_RESULT	ResD	1	; Result for DosPacket
F32S_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; FAT-32 Seek
;
; Inputs:
;
; DP_ARG0	- Offset
; DP_ARG1	- Mode
;
; Output:
;
; DP_RES0	- Old position or -1 for failure
;
; FH modifications
;
; FH_CurrentBlock
; FH_Offset
; FH_Position
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32PktSeek	PUSHX	edx,esi
	Push	edx

	Mov	eax,F32S_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx
	Mov	[edx+F32S_MESSAGE],ebx
	Mov	ecx,[ebx+DP_FH]
	Mov	edi,[ecx+FH_POSITION]
	Mov	[edx+F32S_RESULT],edi	; Old position
	Mov	[edx+F32S_FH],ecx
	Mov	ecx,[ebx+DP_ARG0]
	Mov	[edx+F32S_OFFSET],ecx
	Mov	ecx,[ebx+DP_ARG1]
	Mov	[edx+F32S_MODE],ecx
	Mov	eax,[esi+F32FS_ClusterSize]
	Mov	[edx+F32S_CLUSTERSIZE],eax
	;-
	Call	F32SCheckLimit
	Jc	.Done
	Call	F32SSeekOffset
	;-
.Done	Mov	eax,[edx+F32S_MESSAGE]
	Mov	ecx,[edx+F32S_RESULT]
	Mov	[eax+DP_RES0],ecx		; DP_RES0 = Old-position or -1 for failure
	Mov	eax,edx
	LIBCALL	FreeMem,ExecBase
	POPX	edx,esi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32SCheckLimit	Mov	ebp,[edx+F32S_FH]
	Mov	ebx,[ebp+FH_FILESIZE]
	Mov	ecx,[edx+F32S_OFFSET]
	Clc
	Cmp dword	[edx+F32S_MODE],OFFSET_CURRENT
	Je	.CheckCurrent
	Cmp dword	[edx+F32S_MODE],OFFSET_BEGINNING
	Je	.CheckBeginning

	Cmp dword	[edx+F32S_MODE],OFFSET_END
	Jne	.Failure
	Mov	[edx+F32S_ABSPOS],ebx
	Ret

.Failure	Mov dword	[edx+F32S_RESULT],-1	; Old-position = -1 on error
	Stc
	Ret
	;--
.CheckCurrent	Add	ecx,[ebp+FH_POSITION]
.CheckBeginning	Cmp	ecx,ebx
	Ja	.Failure
	Cmp	ecx,0
	Jb	.Failure
	Mov	[edx+F32S_ABSPOS],ecx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32SSeekOffset	Mov	eax,[edx+F32S_CLUSTERSIZE]
	Bsr	eax,eax
	Mov	ebp,[edx+F32S_FH]
	Mov	ebx,[ebp+FH_POSITION]
	Mov	ecx,[edx+F32S_ABSPOS]
	;-
	Sub	ecx,ebx
	Add	ecx,[ebp+FH_OFFSET]
	Cmp	ecx,ebx
	Jb	.Positive
	;-
	Mov	ecx,[edx+F32S_ABSPOS]
	Mov	edi,[ebp+FH_STARTBLOCK]
	Mov	[ebp+FH_CURRENTBLOCK],edi
	;
	;--------
.Positive	Push	eax
	Mov	eax,ecx
	Pop	ecx
	Shr	eax,cl
	Mov	ecx,eax
	Test	eax,eax
	Jz	.NoClusters
	;--
.GetNext	Mov	eax,[ebp+FH_CURRENTBLOCK]
	PushAD
	Push	ebp
	Call	GetNextCluster
	Pop	ebp
	Mov	[ebp+FH_CURRENTBLOCK],eax
	PopAD
	Loop	.GetNext
	;
.NoClusters	Mov	eax,[edx+F32S_ABSPOS]
	Mov	[ebp+FH_POSITION],eax
	Mov	ebx,[edx+F32S_CLUSTERSIZE]
	Dec	ebx
	And	eax,ebx
	Mov	[ebp+FH_OFFSET],eax
	Ret

