;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Switch.s V1.0.0
;
;     This source is to be renamed to something else, starts to expand to
;     something like Exec.Library on a well known computer...
;
; 1999-12-24-26	Rewrote most of the TimerIRQ, Switch, Schedule, CheckQuantum, CheckTimer.
;	Scheduler, renamed to TimerIRQ
;
; 1999-12-27	Started coding on the Memory handling routines, rewriting everything from
;	scratch, since we implemented the support for paged memory, we have to redo
;	the code, since the allocation routines were made for flat memory.
;	This will probably not be finished in less than three days.
;
; 2000-03-20	Rewrote most parts of this source, such as TimerIRQ and Switch. It now
;	handles interpriviledge ring switching using some heavy magic poking (poke poke)
;	with the TSS's to gain some speed and control.
;
; 2000-04-30	UserSwitch makes sets the Waiting flag within the function (interrupt) now.
;
; 2000-05-15	Added new processkiller.
;
; 2000-05-16	Added protected Wait stub to protect the exec.library Wait() call to prevent
;	both the "master" and "slave" process to appear in the procwaitlist.
;
; 2001-08-18	Removed some partial register stalls
;
; Some other ideas:
; - If a process hangs, and for more than a second is unable to respond, we should remove it and
;   simply tell the user that we did so.
;
; - We should provide utilities similar to Kill/Killall so that users easily can kill processes.
;
; - All System/Kernel processes should have a flag set so we CANT remove them from the system, that
;   would give us some great problems if for example the Input-Handler was removed.
;
;
;Taglist items for Process creation function!
;
;PCT_PRIORITY	Equ	+1
;PCT_FLAGS	Equ	+2
;PCT_QUANTUM	Equ	+3	; System only, user processes will be filtered.
;PCT_PROCPTR	Equ	+4
;PCT_STACKSIZE	Equ	+5
;PCT_USERDATA	Equ	+6
;
;
;
; Note 20010718	We should rewrite this code. now or later depends, but preferably now since we have
;	problems with the system.   We should also recode the Allocmem/Freemem routines
;	and have special kernel allocation routines that does not link the memory to the
;	current process's memorylist. we should also add the possibility to have SMP in the
;	switcher, that the switcher checks what processor it is (enumerated ofcourse).
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	FXPSAVE	0
	Bt dword	[SysBase+SB_CPUID+CPUID_FEATURE],CPUIDB_XMM
	Jc	.FxSave
	FSave	[ebx+PC_Registers+RS_FXP]
	Jmp	.NoFxSave
.FxSave	FXSave	[ebx+PC_Registers+RS_FXP]
.NoFxSave
%EndMacro

%Macro	FXPLOAD	0
	Bt dword	[SysBase+SB_CPUID+CPUID_FEATURE],CPUIDB_XMM
	Jc	.FxLoad
	FRStor	[ebx+PC_Registers+RS_FXP]
	Jmp	.NoFxLoad
.FxLoad	FXRStor	[ebx+PC_Registers+RS_FXP]
.NoFxLoad
%EndMacro



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TimerIRQ	PUSHX	gs,fs,es,ds
	PushAD
	Mov	eax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax

	Mov	ebx,[SysBase+SB_CurrentProcess]
	Bt dword	[ebx+PC_Flags],PCB_NOSWITCH
	Jc near	.NoSwitch

	Dec dword	[Quantum]
	Jnz near	.NoSwitch

	Lea	esi,[esp]
	Lea	edi,[ebx+PC_Registers]
	Mov	ecx,17
	Cld
	Rep Movsd
	Add	esp,68


;	;test code
;	Cmp dword	[ebx+PC_Name],"idle"
;	Jne near	.NotIdle
;	Sub	esp,8
;	Lea	edi,[ebx+PC_Registers]
;	Mov dword	[edi+RS_SS],SYSDATA_SEL
;	Mov dword	[edi+RS_Esp],esp
;.NotIdle
	;test code

;	FXPSAVE			; Store FP/MMX/SIMD registers

	Call	Switch

	Mov	ebx,[SysBase+SB_CurrentProcess]
	Mov	[KernelTSSStack],esp
	And dword	[ebx+PC_Flags],~PCF_SLEEP	; Set process as Ready again *!*
	Inc dword	[SysBase+SB_DispatchCount]
	Lea	esp,[ebx+PC_Registers]
;	FXPLOAD			; Restore FP/MMX/SIMD registers
	;
.NoSwitch	POUT	PIC_M,PIC_EOI
	PopAD
	POPX	gs,fs,es,ds
	IRetd

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_WaitStub	Push	ebx
	Mov	ebx,[SysBase+SB_CurrentProcess]
	Btr dword	[ebx+PC_Flags],PCB_NOSWITCH
	Jnc	.NoSwitch

	Mov dword	[SysBase+SB_DisableTemp],1

.NoSwitch	Or dword	[ebx+PC_Flags],PCF_SLEEP	; Set process as Sleeping.. this needs to be protected so the kernel
	Pop	ebx		; doesn't switch between the bitset and the actual contextswitch.
	;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_UserSwitch	PUSHX	gs,fs,es,ds
	PushAD
	Mov	eax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax

	Lea	esi,[esp]
	Mov	ebx,[SysBase+SB_CurrentProcess]
	Mov	ecx,17
	Lea	edi,[ebx+PC_Registers]
	Cld
	Rep Movsd
	Add	esp,68

;	FXPSAVE

	Call	Switch

	Mov	ebx,[SysBase+SB_CurrentProcess]
	Mov	[KernelTSSStack],esp
	And dword	[ebx+PC_Flags],~PCF_SLEEP	; Set process as Ready again *!*
	Inc dword	[SysBase+SB_DispatchCount]
	Lea	esp,[ebx+PC_Registers]
;	FXPLOAD
	;
	POUT	PIC_M,PIC_EOI
	;
	PopAD
	POPX	gs,fs,es,ds
	IRetd

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Switch{};
;
; The switcher:
; The power command, This routine switches the running process to a new ready process.
; The switch() should also, in a near future, set/clear some flags, so we know
; what processes are running/waiting/ready when we browse the queues.
;
; We probably need to have several lists, one which covers all tasks in the system
; one for each of the ready/wait/whatever queue.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Switch	Mov	eax,[SysBase+SB_CurrentProcess]
	REMOVE
	;
	Mov	ebx,[SysBase+SB_CurrentProcess]
	Bt dword	[ebx+PC_Flags],PCB_KILL
	Jnc	.NoKill
	Lea	eax,[SysBase+SB_DeadProcList]
	Jmp	.Done

.NoKill	Bt dword	[ebx+PC_Flags],PCB_SLEEP
	Jnc	.NoSleep
	Lea	eax,[SysBase+SB_ProcWaitList]
	Jmp	.Done

.NoSleep	Mov	eax,[SysBase+SB_ProcTempList]

.Done	ADDTAIL

	Mov	ebx,[SysBase+SB_ProcReadyList]	; Get next ready process
	SUCC	ebx
	Cmp dword	[ebx+LN_SUCC],0
	Jne	.NewProc
	;
	Push dword	[SysBase+SB_ProcTempList]
	Push dword	[SysBase+SB_ProcReadyList]
	Pop dword	[SysBase+SB_ProcTempList]
	Pop dword	[SysBase+SB_ProcReadyList]

	; check if there are some processes in the wait list that want to be in the ready queue.

	Lea	eax,[SysBase+SB_ProcWaitList]
.WaitLoop	NEXTNODE	eax,.NoUnSleep
	Bt dword	[eax+PC_Flags],PCB_SLEEP
	Jc	.WaitLoop
	Push	eax
	REMOVE
	Pop	ebx
	Push	eax
	Mov	eax,[SysBase+SB_ProcReadyList]
	ADDTAIL			; should be inserted to the correct priority later..
	Pop	eax
	Jmp	.WaitLoop

.NoUnSleep	Mov	ebx,[SysBase+SB_ProcReadyList]
	SUCC	ebx

.NewProc	Mov	[SysBase+SB_CurrentProcess],ebx	; Save the new Current process
	Push dword	[ebx+PC_Quantum]
	Pop dword	[Quantum]
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
Quantum	Dd	1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Schedule();
;
; Dummy for now, This routine should when applied:
; - Sort the ReadyQueue in correct order, Priority order preferably.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Schedule	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Removes the current process from the processlist and halts the processor
;
; OBS! Due to change, this routine should just put a flag in the Process_Flag field, telling
; the scheduler to remove the process from the ready/wait lists and to put it into some
; kind of cleanup queue, and signal a waiting system process that cleans (frees) up the
; allocations and resources, allocated by the process.
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ProcessKiller	Mov	eax,[SysBase+SB_CurrentProcess]
	Or dword	[eax+PC_Flags],PCF_KILL
	LIBCALL	Switch,ExecBase

;-   -  - -- ---=--=-==-===-====-=============-====-===-==-=--=--- -- -  -   -
; - -  -- REMOVE ALL BELOW THIS LINE WHEN EVERYTHING WORKS LIKE A WOK -- -  -
;-   -  - -- ---=--=-==-===-====-=============-====-===-==-=--=--- -- -  -   -

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; IdleTask(0), never to be removed.
;
; This is to be run in Ring 0 only!
;
; should preferably have a Quantum of one. so it doesn't impact on other programs.
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdleProcess	Inc dword	[SysBase+SB_IdleCount]
	Mov	eax,0xdeadbeef
	Mov	ebx,0xdeadbeef
	Mov	ecx,0xdeadbeef
	Mov	edx,0xdeadbeef
	Mov	esi,0xdeadbeef
	Mov	edi,0xdeadbeef
	Mov	ebp,0xdeadbeef
	;Hlt			; Hlt can only be issued when CPL=0
	;Sti
.L	Hlt
	Jmp	.L

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Test tasks, to be removed later on, these are here to add some "fart o flekt" into the environment..
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Task1Count	Dd	0

Task1:
	%IFNDEF SERIAL_DEBUG
	Push dword	[DebugXPos]
	Push dword	[DebugYPos]
	Mov dword	[DebugXPos],0
	Mov dword	[DebugYPos],0
	Inc dword	[Task1Count]
	Mov	eax,[Task1Count]
	PRINTLONG	eax
	Pop dword	[DebugYPos]
	Pop dword	[DebugXPos]
	%ENDIF
	Int	0x60		; Remove me..
;	HLT			; RING 0 MUUH
	Jmp	Task1
