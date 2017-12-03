;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AssignTest.s V1.0.0
;
;     -
;

masterTest	Lea	ecx,[masterProcTags]
	LIBCALL	AddProcess,ExecBase
	Ret

masterProcTags	Dd	AP_PROCESSPOINTER,masterProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,masterProcN
	Dd	TAG_DONE

masterProcN	Db	'master',0

slaveTest	Lea	ecx,[slaveProcTags]
	LIBCALL	AddProcess,ExecBase
	Ret

slaveProcTags	Dd	AP_PROCESSPOINTER,slaveProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,slaveProcN
	Dd	TAG_DONE

slaveProcN	Db	'slave',0


	Struc	Fart
m_SysBase	ResD	1
m_MsgPort	ResD	1
m_SIZE	EndStruc

masterProc	LINK	m_SIZE
	Mov	[ebp+m_SysBase],eax

;	Mov dword	[0x400000],0

	LIB	CreateMsgPort,[ebp+m_SysBase]
	Mov	[ebp+m_MsgPort],eax
	Lea	ebx,[mPortN]
	Int	0xfe
	LIB	AddPort

.Main	LIB	Wait
.L	LIB	GetMsg
	Test	eax,eax
	Jz	.Main

;	Inc dword	[0x400000]
;	LIB	FreeMem
	Jmp	.L

mPortN	Db	'master.port',0


	Struc SlaveStruc
s_ExecBase	ResD	1
s_Port	ResD	1
s_Message	ResD	1
s_SIZE	EndStruc


slaveProc	LINK	s_SIZE
	Mov	[ebp+s_ExecBase],eax

	Lea	eax,[PortN]
	LIB	FindPort,[ebp+s_ExecBase]
	Mov	[ebp+s_Port],eax

	Int	0xfe

	XOr	edi,edi



.L	Mov	eax,500
	Mov	ebx,MEMF_NOCLEAR
	LIB	AllocMem
	Test	eax,eax
	Jz	.L

	Cmp	edi,40000
	Jne	.GetMore
	Jmp	$

.GetMore	Inc	edi


	Mov dword	[eax+MN_REPLYPORT],0
	Mov	[ebp+s_Message],eax

	Mov	eax,[ebp+s_Port]
	Mov	ebx,[ebp+s_Message]
	LIB	PutMsg
	Jmp	.L

PortN	Db	"master.port",0

