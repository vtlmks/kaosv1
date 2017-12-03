

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
;
;
;


	Struc F32Close
F32C_MESSAGE	ResD	1
F32C_FH	ResD	1
F32C_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32PktClose	PUSHX	edx,esi
	Push	edx

	Mov	eax,F32C_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx

	Mov	[edx+F32C_MESSAGE],ebx
	Mov	ecx,[ebx+DP_FH]
	Mov	[edx+F32C_FH],ecx

	; write-back the file if needed..
	; and then return so the FH can be free'd..

.Done	Mov	eax,[edx+F32R_MESSAGE]
	Mov dword	[eax+DP_RES0],0		; Null for success
	Mov	eax,edx
	LIBCALL	FreeMem,ExecBase
	POPX	edx,esi
	Ret


