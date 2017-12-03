

	Struc F32Read
F32R_MESSAGE	ResD	1	; Pointer to message
F32R_FH	ResD	1	; Pointer to Filehandle
F32R_FILESIZE	ResD	1	; Size of the file
F32R_CURRCLUSTER	ResD	1	; File position (cluster)
F32R_LENGTH	ResD	1	; Length, in bytes, to read
F32R_RESULT	ResD	1	; Result to reply with
F32R_BUFFER	ResD	1	; Pointer to buffer to fill
F32R_CLUSTERS	ResD	1	; Number of complete clusters to read
F32R_PARTIAL	ResD	1	; Number of remaining bytes
F32R_CLUSTERBUF	ResD	1	; Buffer for remain
F32R_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; FAT-32 Read
;
; Inputs:
;
; DP_ARG0	- Number of bytes to read
; FH_BUFFER	- Pointer to buffer, must hold atleast the size of DP_ARG0
;
; Output:
;
; DP_RES0	- Number of bytes read
;
; FH modifications
;
; FH_Buffer
; FH_CurrentBlock
; FH_Offset
; FH_Position
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	; edx - pointer to message..
	; esi - fs-daemon memory
	;
F32PktRead	PUSHX	edx,esi
	;
	Push	edx
	Mov	eax,F32R_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx
	;
	Mov	[edx+F32R_MESSAGE],ebx
	Mov	ecx,[ebx+DP_FH]
	Mov	[edx+F32R_FH],ecx
	Mov	eax,[ecx+FH_BUFFER]
	Mov	[edx+F32R_BUFFER],eax
	Mov	eax,[ecx+FH_CURRENTBLOCK]
	Mov	[edx+F32R_CURRCLUSTER],eax

	Mov	eax,[ecx+FH_FILESIZE]
	Mov	[edx+F32R_FILESIZE],eax

	Mov	eax,[ebx+DP_ARG0]
	Mov	[edx+F32R_LENGTH],eax
	;
	Mov	ecx,[edx+F32R_FH]
	Mov	ecx,[ecx+FH_OFFSET]
	Add	ecx,eax
	Mov	ebx,[edx+F32R_FILESIZE]
	Cmp	ebx,ecx
	Jb	.Failure
	;
	Mov	eax,[esi+F32FS_ClusterSize]
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[edx+F32R_CLUSTERBUF],eax

	Call	F32RReadHead
	Call	F32RGetRemains
	Call	F32RReadClusters
	Call	F32RReadTail

.Failure	Mov	eax,[edx+F32R_MESSAGE]
	Mov	ecx,[edx+F32R_RESULT]
	Mov	[eax+DP_RES0],ecx		; DP_RES0 = Length read

	Mov	eax,[edx+F32R_FH]
	Mov	ebx,[edx+F32R_CURRCLUSTER]
	Mov	[eax+FH_CURRENTBLOCK],ebx
	;--

	Mov	eax,[edx+F32R_CLUSTERBUF]
	LIBCALL	FreeMem,ExecBase
	Mov	eax,edx
	LIBCALL	FreeMem,ExecBase
	POPX	edx,esi
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32RReadHead	Mov	eax,[edx+F32R_FH]
	Mov	ebx,[eax+FH_OFFSET]
	Test	ebx,ebx
	Jz near	.NoHead
	;--
	Mov	eax,[esi+F32FS_ClusterSize]	; Clustersize
	Sub	eax,ebx
	Mov	ecx,[edx+F32R_LENGTH]
	Cmp	ecx,eax
	Jae	.CopyWhole
	;--
.CopyPart	Mov	ebp,ebx
	Mov	eax,[edx+F32R_CURRCLUSTER]
	Mov	ebx,[edx+F32R_CLUSTERBUF]
	Call	ReadCluster

	Mov	ecx,[edx+F32R_LENGTH]
	Push	ecx
	Push	esi
	Mov	esi,[edx+F32R_CLUSTERBUF]
	Lea	esi,[esi+ebp]		; Copy from blockoffset
	Mov	edi,[edx+F32R_BUFFER]
	Cld
	Rep Movsb
	Pop	esi
	Mov	[edx+F32R_BUFFER],edi	; Update destination
	Pop	ecx
	Mov dword	[edx+F32R_LENGTH],0
	Mov	eax,[edx+F32R_FH]
	Add	[eax+FH_POSITION],ecx
	Add	[eax+FH_OFFSET],ecx
	Add	[edx+F32R_RESULT],ecx
	Ret
	;--
.CopyWhole	Mov	ecx,eax
	Push	ecx
	Mov	eax,[edx+F32R_CURRCLUSTER]
	Mov	ebx,[edx+F32R_CLUSTERBUF]
	Call	ReadCluster
	Push	esi
	Mov	esi,[edx+F32R_CLUSTERBUF]
	Mov	edi,[edx+F32R_BUFFER]
	Cld
	Rep Movsb
	Pop	esi
	Mov	[edx+F32R_BUFFER],edi	; Update destination
	Pop	ecx
	Sub	[edx+F32R_LENGTH],ecx
	Mov	eax,[edx+F32R_FH]
	Add	[eax+FH_POSITION],ecx
	Mov dword	[eax+FH_OFFSET],0
	Add	[edx+F32R_RESULT],ecx
.NoHead	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; F32RGetRemains -- Calculate the remaining number of total clusters
;                   and tailing bytes to copy.
;

F32RGetRemains	Push	edx
	Mov	eax,[edx+F32R_LENGTH]
	XOr	edx,edx
	Div dword	[esi+F32FS_ClusterSize]
	Pop	edx
	Push	edx
	Mov	[edx+F32R_CLUSTERS],eax	; Total clusters
	XOr	edx,edx
	Mul dword	[esi+F32FS_ClusterSize]
	Pop	edx
	Mov	ebx,[edx+F32R_LENGTH]
	Sub	ebx,eax
	Mov	[edx+F32R_PARTIAL],ebx	; Total tailing bytes
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; F32RReadClusters -- Copy the amount of complete clusters directly into
;                     the FH_BUFFER
;

F32RReadClusters	Cmp dword	[edx+F32R_CLUSTERS],0
	Je	.NoClusters
	Mov	eax,[edx+F32R_CURRCLUSTER]
	Mov	ebx,[edx+F32R_BUFFER]
	Call	ReadCluster
	Mov	ecx,[edx+F32R_FH]
	Mov	edi,[esi+F32FS_ClusterSize]
	Add dword	[ecx+FH_POSITION],edi	; Clustersize
	Add dword	[edx+F32R_BUFFER],edi	; ""
	Add dword	[edx+F32R_RESULT],edi
	Mov	eax,[edx+F32R_CURRCLUSTER]
	Call	GetNextCluster
	Mov	[edx+F32R_CURRCLUSTER],eax
	Dec dword	[edx+F32R_CLUSTERS]
	Jmp	F32RReadClusters
	;
.NoClusters	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; F32RReadTail -- Copy the tailing bytes.

F32RReadTail	Cmp dword	[edx+F32R_PARTIAL],0
	Je	.NoRemain
	;
	Mov	eax,[edx+F32R_CURRCLUSTER]
	Mov	ebx,[edx+F32R_CLUSTERBUF]
	Call	ReadCluster
	Mov	ecx,[edx+F32R_PARTIAL]
	Push	esi
	Mov	esi,[edx+F32R_CLUSTERBUF]
	Mov	edi,[edx+F32R_BUFFER]
	Cld
	Rep Movsb
	Pop	esi
	;
	Mov	ecx,[edx+F32R_FH]
	Mov	eax,[edx+F32R_PARTIAL]
	Add	[ecx+FH_POSITION],eax
	Add	[ecx+FH_OFFSET],eax
	Add	[edx+F32R_RESULT],eax
.NoRemain	Ret

