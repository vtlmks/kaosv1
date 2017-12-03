

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Load	Call	DebGetParams
	Mov	eax,[DbgFuncArray]
	Mov	ebx,OPENF_OLDFILE
	LIBCALL	Open,DosBase
	Test	eax,eax
	Jz	.Failure

	PRINTTEXT	DBFFoundFileTxt

	Mov	ebx,4126
	Mov	ecx,0x400000
	LIBCALL	Read,DosBase

	PRINTLONGSTR	DBFBytesReadTxt,eax

;	Lea	ecx,[LoadTags]
;	LIBCALL	AddProcess,ExecBase
.Failure	Ret

DBFFoundFileTxt	Db	"Debugger - Found file, attempting to read",0xa,0
DBFBytesReadTxt	Db	"Debugger - Num.bytes read : ",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LoadTags	Dd	AP_PROCESSPOINTER,LoadProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,LoadProcN
	Dd	TAG_DONE

LoadProcN	Db	'Load',0

LoadProc	Call	DebGetParams
	Mov	eax,[DbgFuncArray]
	Mov	ebx,OPENF_OLDFILE
	LIBCALL	Open,DosBase
	Test	eax,eax
	Jz	.Failure

	Mov	ebx,4126
	Mov	ecx,0x400000
	LIBCALL	Read,DosBase
.Failure	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
