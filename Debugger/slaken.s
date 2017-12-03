


Doitdeluxe	Lea	ecx,[RunProcTags2]
	LIBCALL	AddProcess,ExecBase
.Done	Ret

RunProcTags2	Dd	AP_PROCESSPOINTER,Brakmiddag
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,8192
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,Runp
	Dd	TAG_DONE

Runp	Db	"Run proc (I'm rambo)",0

Brakmiddag	Mov dword	[0x400000],0
	LINK	RFP_SIZE
	Mov dword	[ebp+RFP_Window],WindowStruct
	Mov dword	[ebp+RFP_LeftEdge],0x100
	Mov dword	[ebp+RFP_TopEdge],0x100
	Mov dword	[ebp+RFP_Width],0x300
	Mov dword	[ebp+RFP_Height],0x200
	Mov dword	[ebp+RFP_Color],0x0
.Loop	Lea	ecx,[ebp]
	Call	VESA_RectFill
	Inc dword	[ebp+RFP_Color]
	Inc dword	[0x400000]
	Jmp	.Loop
