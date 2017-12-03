;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Map memory
;
;  eax = memory pointer - This will be rounded to nearest (lower) 4k boundary.
;  ebx = Size of mapping - This will be rounded to nearest (higher) 4k boundary.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc MapMem
MM_Lenght	ResD	1	; how much memory should be mapped.
MM_Pointer	ResD	1	; pointer to memory to be mapped...
MM_MemPtr	ResD	1	; MemPtr, returned when allocating PT's
MM_PDPosition	ResD	1	; first position to fill... rounded to fit into the first 4kb block...
MM_PDEntrys	ResD	1	; number of entrys in the PD..
MM_PTPosition	ResD	1	; First position to fill out in the PD...
MM_PTPointer	ResD	1	; Pointer to allocated PT memory. This pointer HAS to be 4kb aligned!!!
MM_PTEntrys	ResD	1	; Number of entrys in the PD.
MM_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_MapMemory	PushAD
	PushFD
	LINK	MM_SIZE
	Cld		; Paranoia
	Mov	[ebp+MM_Pointer],eax
	Mov	[ebp+MM_Lenght],ebx

	Call	MM_CalcOffsets

	Mov	eax,[ebp+MM_PDEntrys]
	Inc	eax	; Add one so that we can round of the allocation to nearest 4k boundary...
	Shl	eax,12
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoMemory
	Mov	[ebp+MM_MemPtr],eax
	Add	eax,0xfff
	And	eax,0xfffff000
	Mov	[ebp+MM_PTPointer],eax ; Rounded to nearest 4k boundary for pt's.

	Call	MM_FillPTs
	Call	MM_FillPD

	;Mov	eax,cr3	; This is made to invalidate the TLB, so that the
	;Mov	cr3,eax	; processor fetches the new pages before we exit this routine.

	Lea	eax,[MM_TLBInvalidate]
	Int	0x40


.NoMemory	UNLINK	MM_SIZE
	PopFD
	PopAD
	Ret

MM_TLBInvalidate	Mov	eax,cr3
	Mov	cr3,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;-- calculate offsets in tables and directory.
;
MM_CalcOffsets	Mov	eax,[ebp+MM_Pointer]
	Shr	eax,12	; discard low 12 bits.
	Mov	ebx,eax
	And	eax,0x3ff
	Shr	ebx,10	; Dont try to optimize this with an 8!!
	Shl	eax,2	; first pt entry
	Shl	ebx,2	; first pd entry
	Mov	[ebp+MM_PTPosition],eax
	Mov	[ebp+MM_PDPosition],ebx
	Mov	eax,[ebp+MM_Lenght]
;	Add	eax,0x3ff	; this has to be wrong!!! should be $0xfff and !0x3ff
	Add	eax,0xfff	; REMOVE ME IF BURNING SAUSAGES ARE SEEN
	Shr	eax,12	; round it off to 4kb blocks
	Mov	ebx,eax
	Shr	ebx,10
	Inc	ebx	; Make sure we at least have one here..
	Mov	[ebp+MM_PTEntrys],eax
	Mov	[ebp+MM_PDEntrys],ebx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MM_FillPTs	Mov	edi,[ebp+MM_PTPointer]
	Add	edi,[ebp+MM_PTPosition]
	Mov	ecx,[ebp+MM_PTEntrys]
	Mov	eax,[ebp+MM_Pointer]
	Or	eax,100010111b		; Cache disabled, User/Supervisor, Read/Write, Present
.Loop	Stosd
	Lea	eax,[eax+4096]	; Size of a page.
	Dec	ecx
	Jnz	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MM_FillPD	Mov	edi,[SysBase+SB_PDPointer]
	Add	edi,[ebp+MM_PDPosition]
	Mov	ecx,[ebp+MM_PDEntrys]
	Mov	eax,[ebp+MM_PTPointer]
	Or	eax,7		; User/Supervisor, Read/Write, Present
.Loop	Stosd
	Lea	eax,[eax+4096]	; Size of a pagetable.
	Dec	ecx
	Jnz	.Loop
	Ret
