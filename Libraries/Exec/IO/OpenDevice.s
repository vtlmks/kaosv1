;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     OpenDevice.s V1.0.0
;
;     Open a Device, from within the kernel or from disk.
;
;

; When OpenDevice is issued, the DeviceOpen function is called
; (within the device) which initiates and spawns the device "daemon"
; and then returns to the user.
;
; It's upto the device to wait for any processes (that it might start)
; to initiate before returning to the user, OpenDevice() will NOT
; do this for us anymore. This can easily be made by any method
; prefered.
;

	Struc OpenDevStruc
ODEV_TAGLISTPTR	ResD	1	; Taglist pointer
ODEV_NAME	ResD	1	; Devicename
ODEV_UNIT	ResD	1	; Unit number
ODEV_FLAGS	ResD	1	; Flagset
ODEV_IOREQUEST	ResD	1	; I/O request pointer
ODEV_LIBTAG	ResD	1	; Libtag returned by external device
ODEV_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Input:
;  ecx = Taglist
;
; Output:
;  eax = (Bool) null for failure, non-zero for success
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_OpenDevice	PUSHX	ebx,ecx,edx,esi,edi,ebp
	PushFD
	LINK	ODEV_SIZE
	;--
	Mov	[ebp+ODEV_TAGLISTPTR],ecx
	Call	ODFetchTags
	Test	eax,eax
	Jz	.Failed
	;
	Call	ODOpenDevice
	Jnc	.FoundInternal
	;
	Call	ODOpenExtDevice
	Jc	.Failed

.FoundInternal	Mov	eax,-1		; Return non-zero for success
.Done	UNLINK	ODEV_SIZE
	PopFD
	POPX	ebx,ecx,edx,esi,edi,ebp
	Ret
	;--
.Failed	XOr	eax,eax		; Return null for failure
	Jmp	.Done


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; - Finds the pointer to device and puts it in IO_DEVICE.
; - Calls the Device-Open() in the device.
;
; - If the device isn't found (not previously loaded), it should load it from media and execute the
; Device-Open() then. OpenDevice() must add the entry to the SysBase Devicelist and fill it out
; with the correct DEV_LIBTABLE, LN_NAME, LN_PRI etc.. so it can be found as an loaded device
; if it's opened again.
;

ODOpenDevice	Mov	eax,[ebp+ODEV_NAME]
	Lea	ebx,[SysBase+SB_DeviceList]
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jz	.LoadDevice
	;
	Mov	ebx,[ebp+ODEV_IOREQUEST]
	Mov	eax,[eax+DEV_LIBTABLE]
	Mov	[ebx+IO_DEVICE],eax
	;
	Push	ebp
	Mov	edx,eax
	Call	[eax-4]		; eax=DeviceOpen, ebx=IORequest
				; edx=LibBase ....
	Pop	ebp
	Clc
	Ret
	;--
.LoadDevice	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Loads a device from disk
;
ODOpenExtDevice	Mov	eax,[ebp+ODEV_NAME]
	LIBCALL	LoadSeg,DosBase
	Test	eax,eax
	Jz near	.NoDevice
	;
	Push	eax

	Mov	eax,DEV_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx
	Mov	[edx+DEV_LIBSEGLIST],ebx
	SUCC	ebx
	Lea	ebx,[ebx+HUNK_BUFFER]
	Call	ebx
	;
	Mov	[ebp+ODEV_LIBTAG],eax
	Mov	ebx,eax
	Mov	eax,LT_INIT
	LIBCALL	GetTagData,UteBase
	Mov	[edx+DEV_LIBTABLE],eax

	;
	Mov	eax,LT_NAME
	Mov	ebx,[ebp+ODEV_LIBTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LN_NAME],eax
	;
	Mov	eax,LT_PRIORITY
	Mov	ebx,[ebp+ODEV_LIBTAG]
	LIBCALL	GetTagData,UteBase
	Mov	[edx+LN_PRI],al
	Mov byte	[edx+LN_TYPE],NT_DEVICE
	;
	Mov	eax,[edx+DEV_LIBTABLE]
	Mov	eax,[eax+4]
	Call	ODBuildTable

	Mov	eax,[edx+DEV_LIBTABLE]
	PushAD
	Lea	ecx,[ExecBase]		; ExecBase in ecx
	Mov	edx,edi		; LibBase in edx
	Call	[eax+8]		; DeviceInit()
	RETURN	eax
	PopAD
	Test	eax,eax
	Jnz	.Failure
	;
	Mov	eax,[edx+DEV_LIBTABLE]
	Mov	eax,[eax+4]
	PushAD
	Mov	ebx,[ebp+ODEV_IOREQUEST]
	Lea	ecx,[ExecBase]		; ExecBase in ecx
	Mov	edx,edi		; LibBase in edx
	Call	[eax]		; DeviceOpen()
	PopAD
	;
	Mov	[edx+DEV_LIBTABLE],edi
	Mov	eax,[ebp+ODEV_IOREQUEST]
	Mov	[eax+IO_DEVICE],edi
	;
	Lea	eax,[SysBase+SB_DeviceList]
	Mov	ebx,edx
	ADDTAIL
	Mov	eax,edi
	Clc
	Ret
.NoDevice	Stc
	Ret


.Failure:	; unloadseg
	; freemem
	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ODBuildTable	Mov	esi,eax		; Pointer to vectortable
	Mov	ecx,-1
	Cld
.L	Lodsd
	Inc	ecx
	Cmp	eax,-1
	Jne	.L
	;
	PUSHX	esi,ecx
	Shl	ecx,2
	Mov	eax,[edx+DEV_LIBTABLE]
	Mov	eax,[eax]
	Lea	eax,[eax+ecx]

	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	POPX	esi,ecx
	;
	Std
	Sub	esi,8
.L1	Lodsd
	Mov	[edi],eax
	Lea	edi,[edi+4]
	Dec	ecx
	Jnz	.L1
	Cld
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ODFetchTags	Mov	eax,OD_NAME
	Mov	ebx,[ebp+ODEV_TAGLISTPTR]
	LIBCALL	GetTagData,UteBase
	Test	eax,eax
	Jz near	.TagFailure
	Mov	[ebp+ODEV_NAME],eax
	;
	Mov	eax,OD_IOREQUEST
	Mov	ebx,[ebp+ODEV_TAGLISTPTR]
	LIBCALL	GetTagData,UteBase
	Test	eax,eax
	Jz near	.TagFailure
	Mov	[ebp+ODEV_IOREQUEST],eax
	;
	Mov	eax,OD_UNIT
	Mov	ebx,[ebp+ODEV_TAGLISTPTR]
	LIBCALL	GetTagData,UteBase
	Mov	[ebp+ODEV_UNIT],eax
	;
	Mov	eax,OD_FLAGS
	Mov	ebx,[ebp+ODEV_TAGLISTPTR]
	LIBCALL	GetTagData,UteBase
	Mov	[ebp+ODEV_FLAGS],eax
	Mov	eax,-1
	Ret
.TagFailure	XOr	eax,eax
	Ret

