%ifndef Includes_Process_I
%define Includes_Process_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Process.I V1.0.0
;
;     Process creation stuff.
;


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Process context structure, currently bound to the internal layout of popad and iretd.
;

	Struc RS_Struc
RS_Edi	ResD	1
RS_Esi	ResD	1
RS_Ebp	ResD	1
RS_Esp0	ResD	1	; Task esp, ignore
RS_Ebx	ResD	1
RS_Edx	ResD	1
RS_Ecx	ResD	1
RS_Eax	ResD	1	; Contains exec.library pointer at process start
RS_DS	ResD	1
RS_ES	ResD	1
RS_FS	ResD	1
RS_GS	ResD	1
	;
	; below is the structure poked on the stack before iretd'ing..
	;
RS_Eip	ResD	1	; Process Instruction pointer
RS_CS	ResD	1	; Process Codesegment selector
RS_EFlags	ResD	1	; Process EFlags, should be set to 0x200 to keep interrupts
RS_Esp	ResD	1	; Process Stack pointer
RS_SS	ResD	1	; Process Stacksegment selector
	;
	AlignB	16
RS_FXP	ResB	512	; Floating Point, MMX and SIMD registers
	;
RS_DR0	ResD	1	; Debug registers #0 - #7
RS_DR1	ResD	1
RS_DR2	ResD	1
RS_DR3	ResD	1
RS_DR4	ResD	1
RS_DR5	ResD	1
RS_DR6	ResD	1
RS_DR7	ResD	1
RS_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Struc PC_Struct
PC_ListHead	ResB	LN_SIZE	; Doubly linked list
	AlignB	16
PC_Registers	ResB	RS_SIZE	; Context structure
	;
PC_Flags	ResD	1	; Flags
PC_Pid	ResD	1	; ProcessID, Current implementation, Add one for each new process.
PC_Quantum	ResD	1	; Process Quantum, the bigger, the more time on the system.
PC_ProcessPtr	ResD	1	; Pointer to process.
PC_Owner	ResD	1	; next of kin.
PC_StackHead	ResD	1	; The ptr to the stack
PC_StackSize	ResD	1	; PC_StackHead-PC_StackSize = StackStart
PC_PortList	ResB	MLH_SIZE	; Ports opened for this process.
PC_NullPort	ResB	MP_SIZE	; Null port, the port that all processes has from the beginning.
PC_UserData	ResD	1	; Well, something to be thought of.
PC_CurrentDir	ResD	1	; CurrentDir lock (read) pointer
PC_ProgDir	ResD	1	; ProgramDir lock (read) pointer
PC_Name	ResB	32+2	; Process name
PC_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Bit definitions for PC_Flags
;

	BITDEF	PC,SLEEP,0	; Will go into sleepmode
	BITDEF	PC,KILL,1	; Will die...
	BITDEF	PC,NOSWITCH,2	; Disable is activated

%endif
