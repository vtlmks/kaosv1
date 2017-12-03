%ifndef Includes_LVO_Exec_I
%define Includes_LVO_Exec_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Exec.I V1.0.0
;
;     Library Vector Offsets for Exec library
;


	LIBINIT
	LIBDEF	LVOAllocMem
	LIBDEF	LVOFreeMem
	LIBDEF	LVOAvailMem
	LIBDEF	LVOCreateMsgPort
	LIBDEF	LVODeleteMsgPort
	LIBDEF	LVOPutMsg
	LIBDEF	LVOGetMsg
;	LIBDEF	LVOGetMsgFromPort
	LIBDEF	LVOReplyMsg

	LIBDEF	LVOAddProcess
	LIBDEF	LVOSwitch

	LIBDEF	LVOOpenLibrary
	LIBDEF	LVOCloseLibrary
	LIBDEF	LVOOpenDevice
	LIBDEF	LVOCloseDevice

	LIBDEF	LVOAbortIO
	LIBDEF	LVOAllocIORequest
	LIBDEF	LVOCheckIO
	LIBDEF	LVOFreeIORequest
	LIBDEF	LVOSendIO
	LIBDEF	LVOWaitIO

	LIBDEF	LVOWait

	LIBDEF	LVOEnable
	LIBDEF	LVODisable

	LIBDEF	LVOFindProcess
	LIBDEF	LVOAddPort
	LIBDEF	LVORemovePort
	LIBDEF	LVOFindPort

	LIBDEF	LVOCallHook

	LIBDEF	LVOPrint	; REMOVE!!!!

	LIBDEF	LVOAddIRQHandler
	LIBDEF	LVORemoveIRQHandler

	LIBDEF	LVOAwake
	LIBDEF	LVOSleep

	LIBDEF	LVOOpenClass
	LIBDEF	LVOCloseClass

	LIBDEF	LVOSelectMsgPort
	LIBDEF	LVOMapMemory

	LIBDEF	LVOAllocDMA
	LIBDEF	LVOFreeDMA
	LIBDEF	LVOInitDMA
	LIBDEF	LVOAllocMsg
	LIBDEF	LVOFreeMsg

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
