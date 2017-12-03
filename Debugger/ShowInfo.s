;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ShowInfo.s V1.0.0
;
;     Displays some info in the debugger.
;


	Struc DebugSIStruc
DSI_AllocatedMem	ResD	1	; Allocated memory in kb
DSI_FreeMemory	ResD	1	; Free memory in kb
DSI_IdleCount	ResD	1	; Idle count
DSI_DispatchCount	ResD	1	; Dispatch count
DSI_ProcessCount	ResD	1	; Process count
DSI_AllocCount	ResD	1	; Allocation node count
DSI_FreeCount	ResD	1	; Memoryfree node count
DSI_UpDays	ResD	1	; Uptime, days
DSI_UpHours	ResD	1	; Uptime, hours
DSI_UpMinutes	ResD	1	; Uptime, minutes
DSI_UpSeconds	ResD	1	; Uptime, seconds
DSI_Buffer	ResB	512	; String buffer..
DSI_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DebShowInfo	LINK	DSI_SIZE
	;
	Mov	eax,[SysBase+SB_MemoryTotal]
	Sub	eax,[SysBase+SB_MemoryFree]
	Shr	eax,10
	Mov	[ebp+DSI_AllocatedMem],eax
	;
	Mov	eax,[SysBase+SB_MemoryFree]
	Shr	eax,10
	Mov	ebx,[SysBase+SB_IdleCount]
	Mov	ecx,[SysBase+SB_DispatchCount]
	Mov	edx,[SysBase+SB_ProcessCount]
	Mov	[ebp+DSI_FreeMemory],eax
	Mov	[ebp+DSI_IdleCount],ebx
	Mov	[ebp+DSI_DispatchCount],ecx
	Mov	[ebp+DSI_ProcessCount],edx

	Call	.CountAllocs
	Call	.CountFrees
	Call	.GetUptime

	Lea	eax,[DumpStr]
	Mov	ebx,ebp
	Lea	ecx,[ebp+DSI_Buffer]
	XOr	edx,edx
	LIBCALL	Sprintf,UteBase

	Lea	esi,[ebp+DSI_Buffer]
	Call	DebWriteLines
	;
	UNLINK	DSI_SIZE
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.CountAllocs	Mov dword	[ebp+DSI_AllocCount],0
	Lea	eax,[SysBase+SB_AllocatedMemList]
.L1	NEXTNODE	eax,.NoMoreAllocs
	Inc dword	[ebp+DSI_AllocCount]
	Jmp	.L1
.NoMoreAllocs	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.CountFrees	Mov dword	[ebp+DSI_FreeCount],0
	Lea	eax,[SysBase+SB_MemoryFreeList]
.L2	NEXTNODE	eax,.NoMoreFrees
	Inc dword	[ebp+DSI_FreeCount]
	Jmp	.L2
.NoMoreFrees	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.GetUptime	Mov	edi,[SysBase+SB_Uptime]
	Mov	eax,edi
	XOr	edx,edx
	Mov	ebx,60*60*24
	Div	ebx
	Mov	[ebp+DSI_UpDays],eax
	;
	Mul	ebx
	Sub	edi,eax
	Mov	eax,edi
	Mov	ebx,60*60
	XOr	edx,edx
	Div	ebx
	Mov	[ebp+DSI_UpHours],eax
	;
	Mul	ebx
	Sub	edi,eax
	Mov	eax,edi
	Mov	ebx,60
	XOr	edx,edx
	Div	ebx
	Mov	[ebp+DSI_UpMinutes],eax
	;
	Mul	ebx
	Sub	edi,eax
	Mov	[ebp+DSI_UpSeconds],edi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DumpStr	Db	10
	Db	"System information",10
	Db	"------------------",10
	Db	"Allocated memory : %ld kb",10
	Db	"     Free memory : %ld kb",10
	Db	"      Idle count : %ld",10
	Db	"  Dispatch count : %ld",10
	Db	"   Process count : %ld",10
	Db	" Allocated nodes : %ld",10
	Db	" Freealloc nodes : %ld",10
	Db	"          Uptime : %ld days %ld hours %ld minutes %ld seconds",10
	Db	0

