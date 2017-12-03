
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FreeMem - Free allocated memory, and return it to the system.
;
; eax - pointer to memory to free.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_FreeMem	PUSHX	ebx,ecx
	PushFD
	Test	eax,eax
	Jz	.NoMem

	Lea	eax,[eax-ME_SIZE]

	Mov	ecx,[eax+ME_LENGTH]
	Add	[SysBase+SB_MemoryFree],ecx

	Lea	ecx,[SysBase+SB_AllocatedMemList]
	SPINLOCK	ecx
	Push	eax
	REMOVE
	Pop	ebx
	SPINUNLOCK	ecx

	Lea	eax,[SysBase+SB_MemoryFreeList]
	SPINLOCK	eax
	Push	eax
	ADDTAIL
	Pop	eax
	SPINUNLOCK	eax

.NoMem	PopFD
	POPX	ebx,ecx
	Ret



