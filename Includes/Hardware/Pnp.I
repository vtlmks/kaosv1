%ifndef Includes_Hardware_PNP_I
%define Includes_Hardware_PNP_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     PnP.I V1.0.0
;
;     Plug And Play (PnP) includes.
;


	Struc PNPIStructure
PNPSignature	ResB	4	; "$PnP"
PNPVersion	ResB	1	; PnP version, major in highnibble. (0x10 is current)
PNPLength	ResB	1	; Length of Istruct
PNPControlField	ResW	1	; Controlfield
PNPChecksum	ResB	1	; Checksum, 8-bit sum of all bytes in structure
PNPPhysENAddress	ResD	1	; Physical address of event notification flag if using polling
PNPRMEntryPoint	ResW	1	; Realmode entry offset
PNPRMCodeSegment	ResW	1	; Realmode code segment
PNPPMEntryPoint	ResW	1	; 16-bit protectedmode entry point
PNPPMEntrySegment	ResD	1	; 16-bit protectedmode code segment
PNPOEM	ResD	1	; OEM device identifier
PNPRMDataSegment	ResW	1	; Realmode data segment
PNPPMDataSegment	ResD	1	; 16-bit protectedmode data segment
PNP_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; PnP functions
;

PNP_GETNUMNODES	Equ	0x0	; Get number of system device nodes
PNP_GETSYSDEVNODE	Equ	0x1	; Get system device nodes
PNP_SETSYSDEVNODE	Equ	0x2	; Set system device node
PNP_GETEVENT	Equ	0x3	; Get event
PNP_SENDMESSAGE	Equ	0x4	; Send message
PNP_GETDOCKINFO	Equ	0x5	; Get docking station information
PNP_RESERVED1	EQu	0x6	; *RESERVED*
PNP_RESERVED2	EQu	0x7	; *RESERVED*
PNP_RESERVED3	Equ	0x8	; *RESERVED*
PNP_SETSARI	Equ	0x9	; Set statically allocated resource information
PNP_GETSARI	Equ	0xa	; Get statically allocated resource information
PNP_GETISACONFIG	Equ	0x40	; Get Plug & Play ISA configuration structure
PNP_GETESCDINFO	Equ	0x41	; Get Extended System Configuration Data (ESCD) info
PNP_READESCDDATA	EQu	0x42	; Read Extended System Configuration Data (ESCD)
PNP_WRITEESCDDATA	Equ	0x43	; Write Extended System Configuration Data (ESCD)

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Node data:
;

; Byte 0	- Length
; Byte 5-6	- DeviceID
; BYte 7	- BAsetype
; Byte 8	- Subtype

	Struc PNPDeviceNode
PNPDN_LENGTH	ResW	1	; Node length in bytes
PNPDN_NUMBER	ResB	1	; Device node number/handle
PNPDN_ID	ResD	1	; Device product identifier
PNPDN_TYPECODE	ResB	3	; Device type code
PNPDN_ATTRIBUTES	ResW	1	; Device node attribute bit-field
	; variable descriptor blocks follow here
	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; PNP Descriptor field byte:
;
; Bit 7   = Small(/large descriptor)
; Bit 6-3 = Type, see below
; Bit 2-0 = Length in bytes
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Small resource items
;


PNPTYPE_VERSION	Equ	0x1	; Plug and Play version number
PNPTYPE_LOGDEVID	Equ	0x2	; Logical device ID
PNPTYPE_COMPDEVID	Equ	0x3	; Compatible device ID
PNPTYPE_IRQFORMAT	Equ	0x4	; IRQ format
PNPTYPE_DMAFORMAT	Equ	0x5	; DMA format
PNPTYPE_STARTDEP	Equ	0x6	; Start dependent function
PNPTYPE_ENDDEP	Equ	0x7	; End dependent function
PNPTYPE_IOPORT	Equ	0x8	; I/O port descriptor
PNPTYPE_FIXEDIO	Equ	0x9	; Fixed location I/O port descriptor
PNPTYPE_VENDORDEF	Equ	0xe	; Vendor defined
PNPTYPE_ENDTAG	Equ	0xf	; End tag

	Struc PNPDVersionNumber
PNPDVER_SINAME	ResB	1	; Value 00001010B (Type = 0, small item name = 1, length = 2)
PNPDVER_BCDVER	ResB	1	; Plug and Play version number (packed BCD), (I.e V2.1 = 0x21)
PNPDVER_VENDOR	ResB	1	; Vendor specific number
	EndStruc

	Struc PNPDLogicalDeviceID
PNPDLDI_SINAME	ResB	1	;
PNPDLDI_DEVID	ResD	1	; Logical device
PNPDLDI_FLAGS1	ResB	1	; Bit 7-1: Indicate commands supported per logical device for registers in the range of 0x31 to 0x37 respectively.
			; Bit   0: Indicates this logical device is capable of participating in the boot process
PNPDLDI_FLAGS2	ResB	1	; Bit 7-0: If set, indicate commands supported per logical device for registers in the  range of 0x38 to 0x3F respectively
	EndStruc


	Struc PNPDCompatibleDeviceID
PNPDCDI_SINAME	ResB	1	;
PNPDCDI_DEVID	ResD	1	; Compatible device ID
	EndStruc

	Struc PNPDIRQFormat
PNPDIRQ_SINAME	ResB	1	;
PNPDIRQ_MASK	ResW	1	; IRQ mask bits, Bit0 = IRQ 0, Bit1 = IRQ 1 ..
PNPDIRQ_INFO	ResB	1	; IRQ information:
			; Bit 7-4 - Reserved
			; Bit   3 - Low true level sensitive
			; Bit   2 - High true level sensitive
			; Bit   1 - Low true edge sensitive
			; Bit   0 - High true edge sensitive (Must be supported for ISA compatibility)
	EndStruc


	Struc PNPDDMAFormat
PNPDDMA_SINAME	ResB	1	;
PNPDDMA_CHMASK	ResB	1	; DMA channel mask bits. Bit 0 = Channel 0
PNPDDMA_CHMODE	ResB	1	; DMA channel speed and modes
	EndStruc


	Struc PNPDStartDependent
PNPDSDP_SINAME	ResB	1	;
	EndStruc


	Struc PNPDEndDependent
PNPDEDP_SINAME	ResB	1	;
	EndStruc


	Struc PNPDIOPortDescriptor
PNPDIOP_SINAME	ResB	1	;
PNPDIOP_INFO	ResB	1	; Information
PNPDIOP_MINBASE0	ResB	1	; Range minimum base address, bits 7-0
PNPDIOP_MINBASE1	ResB	1	; Range minimum base address, bits 15-8
PNPDIOP_MAXBASE0	ResB	1	; Range maximum base address, bits 7-0
PNPDIOP_MAXBASE1	ResB	1	; Range maximum base address, bits 15-8
PNPDIOP_BASEALIGN	ResB	1	; Base alignment
PNPDIOP_RANGELEN	ResB	1	; Range length, number of contiguous I/O ports requested
	EndStruc


	Struc PNPDFixedIODescriptor
PNPDFIO_SINAME	ResB	1	;
PNPDFIO_RANGE0	ResB	1	; Range base address, bits 7-0
PNPDFIO_RANGE1	ResB	1	; Range base address, bits 9-8
PNPDFIO_RANGELEN	ResB	1	; Range length, number of contiguous I/O ports requested
	EndStruc


	Struc PNPDVendorDefined
PNPDVDF_SINAME	ResB	1	;
PNPDVDF_VENDOR0	ResB	1	; Vendor defined byte 0
PNPDVDF_VENDOR1	ResB	1	; Vendor defined byte 1
PNPDVDF_VENDOR2	ResB	1	; Vendor defined byte 2
PNPDVDF_VENDOR3	ResB	1	; Vendor defined byte 3
PNPDVDF_VENDOR4	ResB	1	; Vendor defined byte 4
PNPDVDF_VENDOR5	ResB	1	; Vendor defined byte 5
PNPDVDF_VENDOR6	ResB	1	; Vendor defined byte 6
	EndStruc


	Struc PNPDEndTag
PNPDEND_SINAME	ResB	1	;
PNPDEND_CHECKSUM	ResB	1	; Checksum, adding it to the sum of all the data bytes will produce a zero sum
	EndStruc







;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Large resource data types
;
;


	Struc PNPDLargeResource
PNPDLD_LINAME	ResB	1	; Large itemname bit 6-0
PNPDLD_LENGTH0	ResB	1	; Length of data items, bits 7-0
PNPDLD_LENGTH1	ResB	1	; Length of data items, bits 15-8
PNPDLD_ACTUALDATA:		; Actual data, byte 3->n
	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Large resource items
;

PNPTYPE_MEMRANGE	Equ	0x1	; Memory range descriptor
PNPTYPE_IDANSI	Equ	0x2	; Identifier string (ANSI)
PNPTYPE_IDUNICODE	Equ	0x3	; Identifier string (Unicode)
PNPTYPE_VENDORLDF	Equ	0x4	; Vendor defined (large)
PNPTYPE_MEMR32	Equ	0x5	; 32-bit memory range descriptor
PNPTYPE_MEMR32FIX	Equ	0x6	; 32-bit fixed location memory range descriptor


	Struc PNPDMemoryRangeDescriptor
PNPDMRD_LINAME	ResB	1	;
PNPDMRD_LENGTH	ResW	1	; Length
PNPDMRD_INFO	ResB	1	; Extra information
PNPDMRD_MINBASE	ResW	1	; Range minimumbase
PNPDMRD_MAXBASE	ResW	1	; Range maximumbase
PNPDMRD_BASEALIGN	ResW	1	; Base alignment
PNPDMRD_RANGELEN	ResW	1	; Range length
	EndStruc


	Struc PNPDANSIIdentifier
PNPDIDA_LINAME	ResB	1
PNPDIDA_LENGTH	ResW	1	; String length
PNPDIDA_IDSTRING:			; Device description as an ANSI string, N bytes.
	EndStruc


	Struc PNPDUnicodeIdentifier
PNPDIDU_LINAME	ResB	1	;
PNPDIDU_LENGTH	ResW	1	; String length
PNPDIDU_COUNTRYID	ResW	1	; Country identifier
PNPDIDU_IDSTRING:			; Device description as an ANSI string, N bytes
	EndStruc


	Struc PNPDVendorDefinedLarge
PNPDVDL_LINAME	ResB	1	;
PNPDVDL_LENGTH	ResW	1	; Length of vendor defined data
PNPDVDL_DATA:			; Vendor defined data bytes
	EndStruc


	Struc PNPDMemoryRangeDescriptor32
PNPDMRL_LINAME	ResB	1	;
PNPDMRL_LENGTH	ResW	1	; Length
PNPDMRL_INFO	ResB	1	; Extra information
PNPDMRL_MINBASE	ResD	1	; Minimum base address
PNPDMRL_MAXBASE	ResD	1	; Maximum base address
PNPDMRL_BASEALIGN	ResD	1	; Base alignment
PNPDMRL_RANGELEN	ResD	1	; Range length
	EndStruc


	Struc PNPDMemoryRangeFixed32
PNPDMFL_LINAME	ResB	1	;
PNPDMFL_LENGTH	ResW	1	; Length
PNPDMFL_INFO	ResB	1	; Extra information
PNPDMFL_RANGEBASE	ResD	1	; Range base address
PNPDMFL_RANGELEN	ResD	1	; Range length
	EndStruc






;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
