;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     MemDump.s V1.0.0
;
;     Function stub for the debugger.
;




%MACRO	DUMPPRINT	1
	Pushad
	Mov	esi,%1
	Call	DebWriteLines
	Popad
%ENDM



MemDumpProc	Lea	ecx,[MemDumpTags]
	LIBCALL	AddProcess,ExecBase
	Ret

MemDumpTags	Dd	AP_PROCESSPOINTER,MemDump
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,3
	Dd	AP_QUANTUM,64
	Dd	AP_NAME,MemDumpProcN
	Dd	TAG_DONE

MemDumpProcN	Db	'Debugger, MemDump',0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Dump memory at given offset, called from the debugger.
;
; inputs - esi = address to dump
;          edx = length to dump, columns are at size 0x14.
;

MemDump	Call	DebGetParams
	Mov	eax,[DbgFuncArray]
	Call	AscII2Hex
	Mov	esi,eax		; Memory offset to dump..
	;
	Mov	eax,[DbgFuncArray+4]
	Call	AscII2Hex
	Mov	edx,eax
	;
	DUMPPRINT	MemfLF
	XOr	ebx,ebx	; Overall count
.Loop	XOr	ecx,ecx	; Column count
	Call	DumpMemPos
.Main	Mov	eax,[esi+ebx]
	Mov	edi,DumpMemBuf
	Call	Hex2AscII
	DUMPPRINT	DumpMemBuf
	Lea	ebx,[ebx+4]
	Inc	ecx
	Cmp	ecx,4
	Jne	.Main
	Call	DumpMemStr
	Cmp	ebx,edx	; Count
	Jle	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Dump the previous hex longs as a 20 byte ascii-string, strips non-printables.
;
DumpMemStr	Pushad
	XOr	eax,eax
	Mov	edi,MemfLineFeed+1
	Lea	ebx,[ebx-16]
	Mov	ecx,16
.L	Mov	al,[esi+ebx]
	Mov byte	al,[AsciiTable+eax]
	Stosb
	Inc	ebx
	Dec	ecx
	Jnz	.L
	DUMPPRINT	MemfLineFeed
	Popad
	Ret

DumpMemPos	Pushad
	Lea	eax,[esi+ebx]
	Mov	edi,PositionBuf
	Call	Hex2AscII
	DUMPPRINT	PositionStr
	Popad
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DumpMemBuf	Db	"         ",0
MemfLineFeed	Db	34,"................",34,0xa,0
MemfLF	Db	0xa,0xa,0

PositionStr	Db	"0x"
PositionBuf	Db	"        : ",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
AsciiTable	Times 32 Db 46
	Db	" !",34,"#$%&'()*"
	Db	"+,-./0123456789:;<=>?@ABCDEFGHIJ"
	Db	"KLMNOPQRSTUVWXYZ[/]^_`abcdefghijk"
	Db	"lmnopqrstuvwxyz{|}~"
	Times 110 Db 46
	Db	161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180
	Db	181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200
	Db	201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220
	Db	221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240
	Db	241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

