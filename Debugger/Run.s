
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Run <filename>, adds and run a new process from the debugger
;
;

RunProc	Call	DebGetParams
	Mov	eax,[DbgFuncArray]
	Test	eax,eax
	Jz	.Done
	LIBCALL	LoadSeg,DosBase
	Test	eax,eax
	Jz	.Done
	SUCC	eax
	Lea	eax,[eax+HUNK_BUFFER]

	Lea	ecx,[RunProcTags]
	Mov	[ecx+4],eax
	LIBCALL	AddProcess,ExecBase
.Done	Ret

RunProcTags	Dd	AP_PROCESSPOINTER,0
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,8192
	Dd	AP_RING,2
	Dd	AP_QUANTUM,40
	Dd	AP_NAME,RunPN
	Dd	TAG_DONE

RunPN	Db	"Run proc",0
