
	Bits	32

	Section	.text

Start	Mov	edx,eax
	Lea	eax,[String]
	Lea	edx,[edx+175]
	Call	edx		; EXEC_Print
	Ret

	Section	.data

String	Db	"Hello World!",0xa,0
