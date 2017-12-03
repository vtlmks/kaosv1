%ifndef Includes_Hardware_EISA_I
%define Includes_Hardware_EISA_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     EISA.I V1.0.0
;
;     Defines for EISA ESCD data
;





	Struc EISA_CFGHDR	; Same as ESCD_CFGHDR
.Length	ResW	1
.Signature	ResD	1		; Signature ("ACFG")
.MinorVersion	ResB	1
.MajorVersion	ResB	1
.BoardCount	ResB	1
.Reserved	ResB	3
.SIZE	EndStruc	; 12 bytes

	Struc EISA_CFG
	ResB	LN_SIZE
.Length	ResW	1		; Length in bytes
.SlotNumber	ResW	1		; Slotnumber (0=System resources, 1-15 = EISA/PnPISA/ISA, 16-64 - Virtual Adapter (PCI entrys etc)
.EISAID	ResD	1		; EISA ID number or null
.SlotInfo	ResW	1		; Slot info
.Version	ResW	1		; Version and revision
.SIZE	EndStruc	; 12 bytes + ln_size


	; Functionentry flags, must be parsed in the same order as they
	; appear below.
	;

	BITDEF	EISAFE,DISABLED,7
	BITDEF	EISAFE,FREEFORM,6
	; bit 0 - not implemented
	; bit 5 - not implemented
	BITDEF	EISAFE,MEMORY,1
	BITDEF	EISAFE,IRQ,2
	BITDEF	EISAFE,DMA,3
	BITDEF	EISAFE,IO,4

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Struc EISA_FUNCTIONENTRY
.Length	ResW	1	; Number of bytes of data AFTER this word
	ResW	1	;??
.Flags	ResB	1	; Functionentry flags
.SIZE	EndStruc	; 5 bytes


	Struc EISA_MEMORY
.MemFlags	ResW	1	; Bit 7 in first byte set if there're more entrys
.MemOffset	ResB	3	; Memory offset
.MemSize	ResW	1	; Length in kilobytes
.SIZE	EndStruc	; 7 bytes


	Struc EISA_IO
.PortRange	ResB	1	; Bit 7 set if there're more entrys
.PortOffset	ResW	1
.SIZE	EndStruc


	Struc EISA_DMA		; Bit 7 set if there're more entrys
.Channel	ResB	1
.Flags	ResB	1
.SIZE	EndStruc


	Struc EISA_IRQ
.IRQNumber	ResB	1	; Bit 7 set if there're more entrys
.Flags	ResB	1
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc ECD_FREEFORMBRDHDR
	ResB	1
.Length	ResB	1
.Signature	ResD	1	; "ACFG"
.MinorVersion	ResB	1
.MajorVersion	ResB	1
.BoardType	ResB	1
.Reserved	ResB	1
.DisabledFuncs	ResW	1	; Disabled Functions
.ConfigErrorFuncs	ResW	1	; ConfigurationErrorFunctions
.FunctionsReCfg	ResW	1	; FunctionsAreRe-configurable
	ResW	1	; Reserved!?
.PCIBus	ResB	1	; PCI bus number
.PCIFunc	ResB	1	; PCI function number
.PCIDeviceID	ResW	1	; PCI device ID
.PCIVendorID	ResW	1	; PCI vendor ID
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
