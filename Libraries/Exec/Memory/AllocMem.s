;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; AllocMem -- Allocate a chunk of memory.
;
;  In -- [Ecx] Taglist with specifications.
;
; Out -- [Eax] Pointer to memory, or NULL for error.
;
; Restrictions --	Only one process at a time can allocate memory, this is to
;	prevent two or more processes to allocate the same memory,
;	also to prevent problems with memory lists. This is particulary
;	important when dealing with multiprocessor machines.
;	The positive with this is that we can use static variables, and
;	flags, when we allocate memory.
;
; We might be forced to rewrite this routine when we add Multiprocessor support, since
; we might need to lock semaphores to be able to allocate memory just to make sure that
; we dont have two processes allocating memory at the same time. This adds some overhead,
; but will prevent race conditions. And is for sure better than a CLI/STI aswell...
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; ADDITIONS (To Be Added):
;	Add the MEMF_NOKEY function, If defined allocmem will not save a node with
;	the pointer to the allocated memory node to the process's allocatedmemory list.
;
;
	Struc AM_Structure
AM_Length	ResD	1
AM_Flags	ResD	1
AM_InternalFlags	ResD	1
AM_TAGListPTR	ResD	1
AM_Pointer	ResD	1
AM_Temp	ResD	1
AM_Pid	ResD	1
AM_Size	EndStruc

	BITDEF	AMI,EqualNode,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AllocMem	PushFD
	PUSHX	ebx,ecx,edx,edi,ebp

	LINK	AM_Size		; now reentrant...
	;
	Mov	[ebp+AM_Length],eax
	Test	eax,eax
	Jz	.NoTags
	Mov	[ebp+AM_Flags],ebx
	Mov dword	[ebp+AM_InternalFlags],0
	;
	Mov	[ebp+AM_TAGListPTR],ecx
	;
	Mov	eax,[SysBase+SB_CurrentProcess]
	Push dword	[eax+PC_Pid]
	Pop dword	[ebp+AM_Pid]
	;
	Call	am_FindNode
	Jnc	.NoMemory
	;
	Call	am_AllocNode
	Call	am_ClearMemory
	Call	am_PostNode
	;
	Mov	eax,[ebp+AM_Length]
	Sub	[SysBase+SB_MemoryFree],eax	; Update freemem in sysbase
	;
	Mov	eax,[ebp+AM_Pointer]
	Lea	eax,[eax+ME_SIZE]

.NoFail	UNLINK	AM_Size
	POPX	ebx,ecx,edx,edi,ebp
	PopFD
	Ret

.NoTags	XOr	eax,eax
	Jmp	.NoFail

.NoMemory	Lea	eax,[.NoMemTxt]
	Int	0xff
	Jmp	$

.NoMemTxt	Db	'** PANIC ** No memory available...',0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Zero for error, anything else for success.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
am_FindNode	Clc
	Mov	eax,[ebp+AM_Length]
	Lea	eax,[eax+1023+ME_SIZE]
	And	eax,0xfffffc00
	Mov	[ebp+AM_Length],eax	; Total, including the header.
	;
	Mov	ebx,[SysBase+SB_MemoryFree]	; Check if we have enough memory free.
	Sub	ebx,eax
	Jc	.NoMemory
	;
	Lea	eax,[SysBase+SB_MemoryFreeList]
	SPINLOCK	eax

	Call	am_FindEqual
	Jnc	.Found
	Call	am_FindLarger
	Jc	.NoLarge

.Found	Mov	[ebp+AM_Pointer],eax
	REMOVE			; Unlink node from FreeMemList
	Mov	[ebp+AM_Temp],eax
	Stc

.NoLarge	PushFD
	Lea	eax,[SysBase+SB_MemoryFreeList]
	SPINUNLOCK	eax
	PopFD

.NoMemory	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
am_FindEqual	Mov	ebx,[ebp+AM_Length]
	Lea	eax,[SysBase+SB_MemoryFreeList]
.Loop	NEXTNODE	eax,.NoEqual
	Cmp	[eax+ME_LENGTH],ebx
	Jne	.Loop
	Bts dword	[ebp+AM_InternalFlags],AMIB_EqualNode
	Clc
	Ret
	;
.NoEqual	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
am_FindLarger	Mov	ebx,[ebp+AM_Length]
	Lea	eax,[SysBase+SB_MemoryFreeList]
.Loop	NEXTNODE	eax,.NoMem
	Cmp	[eax+ME_LENGTH],ebx
	Jl	.Loop
	Clc
	Ret
	;
.NoMem	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Zero for error, anything else for success.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
am_AllocNode	Mov	eax,[ebp+AM_Pointer]
	Bt dword	[ebp+AM_InternalFlags],AMIB_EqualNode; Build a new node for the FreeMemList, unless the EqualNode bit was set.
	Jc	.EqualNode
	;
	Mov	ebx,eax
	Add	ebx,[ebp+AM_Length]
	;
	Mov	ecx,[eax+ME_LENGTH]	; Get new nodesize for the free node
	Sub	ecx,[ebp+AM_Length]
	Mov	[ebx+ME_LENGTH],ecx
	Mov byte	[ebx+LN_TYPE],NT_MEMORY
	Mov byte	[ebx+LN_PRI],0
	Mov dword	[ebx+LN_NAME],0
	;
;	Mov	eax,[ebp+AM_TEMP]
	Lea	eax,[SysBase+SB_MemoryFreeList]	;*** REMOVE	; remainder of the memory chunk that wasn't allocated.
	SPINLOCK	eax
	Push	eax
	ADDTAIL			;*** REMOVE
	Pop	eax
	SPINUNLOCK	eax
;	INSERT
	Mov	eax,[ebp+AM_Pointer]
.EqualNode	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
am_ClearMemory	Bt dword	[ebp+AM_Flags],MEMF_NOCLEAR
	Jc	.NoClear
	Mov	edi,[ebp+AM_Pointer]
	Mov	ecx,[ebp+AM_Length]
	Cld
	Shr	ecx,2
	XOr	eax,eax
	Rep Stosd
.NoClear	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
am_PostNode	Mov	ebx,[ebp+AM_Pointer]
	Mov	eax,[ebp+AM_Length]
	Mov	[ebx+ME_LENGTH],eax
	Mov byte	[ebx+LN_TYPE],NT_MEMORY
	Push dword	[ebp+AM_Pid]
	Pop dword	[ebx+ME_PID]
	;
	Lea	eax,[SysBase+SB_AllocatedMemList]
	SPINLOCK	eax
	Push	eax
	ADDTAIL
	Pop	eax
	SPINUNLOCK	eax
	Ret
