


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DumpMessages	Lea	esi,[ProcTable]
.NextProcList	Lodsd
	Test	eax,eax
	Jz	.Done
	Pushad
	Mov	edi,eax
.FetchProcs	NEXTNODE	edi,.NoMoreProcs
	Lea	esi,[edi+PC_PortList]
.FetchPorts	NEXTNODE	esi,.FetchProcs
	Lea	eax,[esi+MP_MSGLIST]
	Pushad
	Call	ShowListI
	Popad
	Jmp	.FetchPorts
	;
.NoMoreProcs	Popad
	Jmp	.NextProcList
.Done	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ProcTable	Dd	SB_ProcWaitList
	Dd	SB_ReadyList
	Dd	SB_TempList
	Dd	0
