%ifndef Includes_Macros_I
%define Includes_Macros_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Macros.I V1.0.0
;
;     Miscellaneous macros that are used globally.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; MACRO NAME	  DESCRIPTION		ARGUMENT 1	ARGUMENT 2
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; LINK	- Allocate memory on stack	Size in bytes
; PIN	- Port readbyte		Port
; POPRS	- Pop struct entrys	Struct pointer	Offsets as arg 2-n, same order as PUSHRS
; POPX	- Pop x registers		Registers to Pop 1-n, same order as PUSHX
; POUT	- Port writebyte		Port	Data
; PRINTLONG	- Print longword in debugger	Value (long)
; PRINTTEXT	- Send string to debugger	String ptr
; PUSHRS	- Push struct entrys	Struct pointer	Offsets as arg 2-n
; PUSHX	- Push x registers	Registers to Push 1-n
; RETURN	- Return eax within PushAD/PopAD	Value
; UNLINK	- Free memory allocated on stack	Size in bytes
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	POUT 2	; Port write (word or byte), Data
	Mov	al,%2
	%IF %1>0xFF
	Mov	dx,%1
	Out	dx,al
	%ELSE
	Out	%1,al
	%ENDIF
%EndMacro

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%Macro	PIN 2	; Port read (word or byte), Data
	Mov	al,%2
	%IF %1>0xFF
	Mov	dx,%1
	In	al,dx
	%ELSE
	In	al,%1
	%ENDIF
%EndMacro

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%Macro	PUSHX 1-*	; Push x registers
	%Rep %0
	Push %1
	%Rotate 1
	%Endrep
%Endmacro

%Macro	POPX 1-*	; Pop x registers
	%Rep %0
	%Rotate -1
	Pop %1
	%EndRep
%Endmacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	PUSHRS 2-*	; Push struct entrys, first arg is pointer, 2-n is offsets
%Define	PUSHRSTEMP	%1
	%Rotate 1
	%Rep %0-1
	Push dword	[PUSHRSTEMP+%1]
	%Rotate 1
	%Endrep
%EndMacro

%Macro	POPRS 2-*	; Pop struct entrys, first arg is pointer, 2-n is offsets
%Define	POPRSTEMP	%1
	%Rep %0-1
	%Rotate -1
	Pop dword	[POPRSTEMP+%1]
	%EndRep
%EndMacro


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	LINK 1	; Allocate memory on stack...
	Lea	esp,[esp-%1]
	Lea	ebp,[esp]
%Endmacro

%Macro	UNLINK 1	; Free allocated memory from stack.
	Lea	esp,[esp+%1]
%Endmacro

%Macro	RETURN 1	; Return in eax, for use within a PushAD/PopAD session
	Mov	[esp+28],dword %1
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	PRINTTEXT 1	; Output text in debugger
	PushAD
	PushFD
	Mov	esi,%1
	Call	DebWriteLines
	PopFD
	PopAD
%EndMacro

%Macro	PRINTLONG 1	; Output longword to debugger
	PushAD
	PushFD
	Mov	eax,%1
	Lea	edi,[DebuggerPrintBuffer]
	Call	Hex2AscII
	Lea	esi,[DebuggerPrintBuffer]
	Call	DebWriteLines
	PopFD
	PopAD
%EndMacro

%Macro	PRINTLONGSER 1	; Output longword to serial
	PushAD
	PushFD
	Mov	eax,%1
	Lea	edi,[DebuggerPrintBuffer]
	Call	Hex2AscII
	Lea	esi,[DebuggerPrintBuffer]
	Call	WriteDebugCom
	PopFD
	PopAD
%EndMacro



%Macro	PRINTLONGSTR 2	; Output string and longword to debugger
	PRINTTEXT %1
	PRINTLONG %2
%EndMacro


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	SPINLOCK 1	; list to be locked
%%.sl	Bt dword	[%1+LH_FLAGS],LHB_SLOCK
	Jc	%%.sl
	Bts dword	[%1+LH_FLAGS],LHB_SLOCK
%EndMacro

%Macro	SPINUNLOCK 1	; list to be unlocked
	Btr dword	[%1+LH_FLAGS],LHB_SLOCK
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	CMP2 4	; a, b, value, routine if outside boundary
	Cmp	%1,%3
	Ja	%4
	Cmp	%2,%3
	Jb	%4
%EndMacro



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif

