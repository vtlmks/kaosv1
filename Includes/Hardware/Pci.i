%ifndef Includes_Hardware_PCI_I
%define Includes_Hardware_PCI_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     PCI.I V1.0.0
;
;     PCI architecture includes.
;





PCI_CONFIGADDRESS	Equ	0xcf8	; Config addressport (write)
PCI_CONFIGDATA	Equ	0xcfc	; Config dataport (read)


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI Config Space Layout structure, each PCI devices has 256 bytes of configuration space,
; the first 64 bytes are always contain the following structure.
;

	Struc PCIConfigSpaceStruct
	ResB	LN_SIZE
PCI_Bus	ResB	1	; Extracted by kernel
PCI_Device	ResB	1	; Extracted by kernel
PCI_Function	ResB	1	; Extracted by kernel
	;
PCI_VendorID	ResW	1	; Vendor ID
PCI_DeviceId	ResW	1	; Device ID
PCI_CommandReg	ResW	1	; Command register
PCI_StatusReg	ResW	1	; Status register
PCI_RevisionID	ResB	1	;
PCI_ProgIF	ResB	1
PCI_SubClass	ResB	1
PCI_ClassCode	ResB	1
PCI_CachelineSize	ResB	1
PCI_Latency	ResB	1
PCI_HeaderType	ResB	1
PCI_BIST	ResB	1
	; Union of either NonBridge, Bridge or CardBus structure follows here
PCI_SIZE	EndStruc


	Struc PCINonBridge
PCIN_BaseAddress0	ResD	1
PCIN_BaseAddress1	ResD	1
PCIN_BaseAddress2	ResD	1
PCIN_BaseAddress3	ResD	1
PCIN_BaseAddress4	ResD	1
PCIN_BaseAddress5	ResD	1
PCIN_CardBusCIS	ResD	1
PCIN_SubsysVID	ResW	1	; Subsystem vendor ID
PCIN_SubsysDID	ResW	1	; Subsystem device ID
PCIN_ExpROM	ResD	1	; ExpansionRom
PCIN_CapPtr	ResB	1
PCIN_RESERVED1	ResB	3
PCIN_RESERVED2	ResD	1
PCIN_IntLine	ResB	1	; Interrupt line
PCIN_IntPin	ResB	1	; Interrupt pin
PCIN_MinGrant	ResB	1
PCIN_MaxLatency	ResB	1
PCIN_DevSpecific	ResB	192	; Device specific
	;
PCIN_SIZE	EndStruc



	Struc PCIBridge
PCIB_BaseAddress0	ResD	1
PCIB_BaseAddress1	ResD	1
PCIB_PrimaryBus	ResB	1
PCIB_SecondaryBus	ResB	1
PCIB_SubordBus	ResB	1	; Subordinate bus
PCIB_SecondaryLat	ResB	1	; Secondary latency
PCIB_IOBaseLow	ResB	1
PCIB_IOLimitLow	ResB	1
PCIB_SecondStatus	ResW	1	; Secondary status
PCIB_MemBaseLow	ResW	1	; Memory base low
PCIB_MemLimitLow	ResW	1	; Memory limit low
PCIB_PrBaseLow	ResW	1	; Prefetch base low
PCIB_PrLimitLow	ResW	1	; Prefetch limit low
PCIB_PrBaseHigh	ResD	1	; Prefetch base high
PCIB_PrLimitHigh	ResD	1	; Prefetch limit high
PCIB_IOBaseHigh	ResW	1	; I/O base high
PCIB_IOLimitHigh	ResW	1	; I/O limit high
PCIB_RESERVED2	ResD	1
PCIB_ExpansionROM	ResD	1
PCIB_IntLine	ResB	1	; Interrupt line
PCIB_InttPin	ResB	1	; Interrupt pin
PCIB_BridgeCtrl	ResW	1	; Bridge control
PCIB_DevSpecific	ResB	192
PCIB_SIZE	Endstruc

	Struc PCICardBus
PCIC_ExCaBase	ResD	1
PCIC_CapPtr	ResB	1
PCIC_RESERVED5	ResB	1
PCIC_SecondStatus	ResW	1	; Secondary status
PCIC_PCIBus	ResB	1
PCIC_CardBusBus	ResB	1
PCIC_SubordBus	ResB	1	; Subordinate bus
PCIC_LatencyTimer	ResB	1
PCIC_MemoryBase0	ResD	1
PCIC_MemoryLimit0	ResD	1
PCIC_MemoryBase1	ResD	1
PCIC_MemoryLimit1	ResD	1
PCIC_IOBase0Low	ResW	1
PCIC_IOBase0High	ResW	1
PCIC_IOLimit0Low	ResW	1
PCIC_IOlimit0High	ResW	1
PCIC_IOBase1Low	ResW	1
PCIC_IOBase1High	ResW	1
PCIC_IOLimit1Low	ResW	1
PCIC_IOLimit1High	ResW	1
PCIC_IntLine	ResB	1	; Interrupt line
PCIC_IntPin	ResB	1	; Interrupt pin
PCIC_BridgeCtrl	ResW	1	; Bridge control
PCIC_SubsysVID	ResW	1	; Subsystem vendor ID
PCIC_SubsysDID	ResW	1	; Subsystem device ID
PCIC_LegacyBaseAd	ResD	1	; Legacy base address
PCIC_CBRESERVED	ResD	56	; Cardbus reserved
PCIC_VendorSpec	ResD	128	; Vendor specific
PCIC_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; PCI baseaddress contents
;
;
; Bit 0 = Cleared if baseaddress is a memoryspace and set if it's i/o space
;
; Memoryspace :
;
; BaseAddress is memory space
;
;  Bit 0  :  0 = Memoryspace identifier
;  Bit 1-2: 00 = locate anywhere in 32-bit address space
;           01 = reserved
;           10 = locate anywhere in 64-bit address space
;           11 = reserved
;  Bit 3       = Set if prefetchable
;  Bit 4-31    = Memoryaddress
;
; BaseAddress is I/O space
;
;  Bit 0     1 = I/O space identifier
;  Bit 1       = RESERVED
;  Bit 2 - 32  = I/O space address



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI commands from PCI_Command in the PCI Configspace structure.
;

 BITDEF	PCICMD,IO,0
 BITDEF	PCICMD,MEMORY,1		; Enable response in memory space
 BITDEF	PCICMD,MASTER,2		; Enable bus mastering
 BITDEF	PCICMD,SPECIAL,3		; Enable response to special cycles
 BITDEF	PCICMD,INVALIDATE,4	; Use memory write and invalidate
 BITDEF	PCICMD,VGAPALETTE,5	; Enable palette snooping
 BITDEF	PCICMD,PARITY,6		; Enable parity checking
 BITDEF	PCICMD,WAIT,7		; Enable address/data stepping
 BITDEF	PCICMD,SERR,8		; Enable SERR
 BITDEF	PCICMD,FASTBACK,9		; Enable back-to-back writes


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI status from PCI_Status in the PCI Configspace structure.
;

 BITDEF	PCISTAT,CAPLIST,4		; Support capability list
 BITDEF 	PCISTAT,66MHZ,5		; Support 66 MHz PCI 2.1 bus
 BITDEF	PCISTAT,UDF,6		; Support user definable features
 BITDEF	PCISTAT,FASTBACK,7	; Accept fast-back to back
 BITDEF	PCISTAT,PARITY,8		; Parity error detected

PCISTAT_DSMASK	Equ	0x600	; DEVSEL timing
PCISTAT_DSFAST	Equ	0x000
PCISTAT_DSMEDIUM	Equ	0x200
PCISTAT_DSSLOW	Equ	0x400
PCISTAT_SIGTABORT	Equ	0x800	; Set on target abort
PCISTAT_RECTABORT	Equ	0x1000	; Master ack of
PCISTAT_RECMABORT	Equ	0x2000	; Set on master abort
PCISTAT_SIGSERROR	Equ	0x4000	; System error, set when drive SERR
PCISTAT_DETPARITY	Equ	0x8000	; Set on parity error

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI header types, from PCI_HeaderType in the PCI Configspace structure.
;

PCIHEAD_NORMAL	Equ	0	; Normal header type
PCIHEAD_BRIDGE	Equ	1	; Bridge header type
PCIHEAD_CARDBUS	Equ	2	; Cardbus header type


; Header type 0, normal devices

PCIHT0_CBUSCIS	Equ	0x28	; Cardbus CIS
PCIHT0_SUBSVID	Equ	0x2c	; Subsystem Vendor ID
PCIHT0_SUBSID	Equ	0x2e	; Subsystem ID
PCIHT0_ROMADDRESS	Equ	0x30	; Rom address (Bits 11-31)
PCIHT0_ROMADDMASK	Equ	0x7ff

; Header type 1, PCI-to-PCI bridges

PCIHT1_PRIMARYBUS	Equ	0x18	; Primary bus number
PCIHT1_SECONDBUS	Equ	0x19	; Secondary bus number
PCIHT1_SUBORDBUS	Equ	0x1a	; Highest bus number behind the bridge
PCIHT1_SECLTTIMER	Equ	0x1b	; Latency timer for secondary interface

PCIHT1_IOBASE	Equ	0x1c	; I/O range behind the bridge
PCIHT1_IOLIMIT	Equ	0x1d	;
PCIHT1_IORTM	Equ	0xf	; I/O bridging type
PCIHT1_IORTYPE16	Equ	0x0	; I/O range type 16
PCIHT1_IORTYPE32	Equ	0x1	; I/O range type 32
PCIHT1_IORTMASK	Equ	0xf	; I/O range type mask

PCIHT1_SECSTATUS	Equ	0x1e	; Secondary status register, only bit 14 used
PCIHT1_MEMBASE	Equ	0x20	; Memory range behind
PCIHT1_MEMLIMIT	Equ	0x22	; Memory limit
PCIHT1_MEMRTMASK 	Equ	0x0f	; Memory range type mask
PCIHT1_MEMRMASK	Equ	0x0f	; Memory range mask
PCIHT1_PRMEMBASE	Equ	0x24	; Prefetchable memory range behind
PCIHT1_PRMEMLIMIT	Equ	0x26	; Prefetchable memory limit
PCIHT1_PRRTMASK	Equ	0x0f	; Prefetchable range type mask
PCIHT1_PRRT32	Equ	0x00	; Prefetchable range type 32
PCIHT1_PRRT64	Equ	0x01	; Prefetchable range type 64
PCIHT1_PRRMASK	Equ	0x0f	; Prefetchable range mask
PCIHT1_PRBASEU32	Equ	0x28	; Upper half of prefetchable memory range
PCIHT1_PRIOLIMU32	Equ	0x2c	; Upper half of prefetchable I/O limit
PCIHT1_PRBASEU16	Equ	0x30	; Lower half of prefetchable memory range
PCIHT1_PRIOLIM16	Equ	0x32	; Lower half of prefetchable I/O limit

; Header type 2, CardBus bridges

PCIHT2_SECSTAT	Equ	0x16	; Secondary status
PCIHT2_PRIMBUS	Equ	0x18	; PCI bus number
PCIHT2_CARDBUS	Equ	0x19	; CardBus bus number
PCIHT2_SUBORDBUS	Equ	0x1a	; Subordinate bus number
PCIHT2_LATTIMER	Equ	0x1b	; CardBus latency timer
PCIHT2_MEMBASE0	Equ	0x1c
PCIHT2_MEMLIMIT0	Equ	0x20
PCIHT2_MEMBASE1	Equ	0x24
PCIHT2_MEMLIMIT1	Equ	0x28
PCIHT2_IOBASE0	Equ	0x2c
PCIHT2_IOBASE0HI	Equ	0x2e
PCIHT2_IOLIMIT0	Equ	0x30
PCIHT2_IOLIMIT0HI	Equ	0x32
PCIHT2_IOBASE1	Equ	0x34
PCIHT2_IOBASE1HI	Equ	0x36
PCIHT2_IOLIMIT1	Equ	0x38
PCIHT2_IOLIMIT1HI	Equ	0x3a
PCIHT2_IORMASK	Equ	0x03

PCIHT2_BRCTL	Equ	0x3e	; Bridge control
PCIHT2_BRCTLPARIT	Equ	0x01	; Similar to standard bridge control register
PCIHT2_BRCTLSERR	Equ	0x02
PCIHT2_BRCTLISA	Equ	0x04
PCIHT2_BRCTLVGA	Equ	0x08
PCIHT2_BRCTLMAB	Equ	0x20	; Master abort
PCIHT2_BRCTLCBRES	Equ	0x40	; CardBus reset
PCIHT2_BRCTL16INT	Equ	0x80	; Enable interrupt for 16-bit cards
PCIHT2_BRCTLPRM0	Equ	0x100	; Prefetch enable for both memory regions
PCIHT2_BRCTLPRM1	Equ	0x200
PCIHT2_BRCTLPOSTW	Equ	0x400	; Post writes
PCIHT2_SUBSVID	Equ	0x40	; Subsystem vendor id
PCIHT2_SUBSID	Equ	0x42	; Subsystem id
PCIHT2_LEGACYMB	Equ	0x44	; 16-bit PC Card legacy mode base address (ExCa)


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI BIST, from PCI_BIST in the PCI Configspace structure.
;

PCIBIST_CODEMASK	Equ	0x0f	; Return result
PCIBIST_START	Equ	0x40	; Set to start BIST, 2 s or less
PCIBIST_CAPABLE	Equ	0x80	; Set if BIST capable

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI base addresses. Base addresses specify locations in memory or I/O space.
; A decoded size may be determined by writing a value of -1L (0xffffffff) to the
; register, and reading it back. Note that only 1 bits are decoded.
;

PCIBAD_ADDSP	Equ	0x1	; Set = Memory, Clr = I/O
PCIBAD_ADDSPIO	Equ	0x1	;
PCIBAD_ADDSPMEM	Equ	0x6	;

PCIBAD_MTMASK	Equ	0x6	; Memtype
PCIBAD_MT32	Equ	0x0	; 32 bit address
PCIBAD_MT1M	Equ	0x2	; Below 1MB
PCIBAD_MT64	Equ	0x4	; 64 bit address
PCIBAD_MPREFETCH	Equ	0x8	; Memory prefetchable
PCIBAD_MMASK	Equ	0xf	; Memory mask
PCIBAD_IOMASK	Equ	0x3	; IO mask


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI capability lists
;

PCICAP_PM	Equ	1	; Power management
PCICAP_AGP	Equ	2	; AGP (Accelerated graphics port)


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI Subclass names, class constants are defined below
;

;PCI_Class0Name	Db	"Unknown",0
;PCI_Class1Name	Db	"Storage",0
;PCI_Class2Name	Db	"Network",0
;PCI_Class3Name	Db	"Display",0
;PCI_Class4Name	Db	"Multimedia",0
;PCI_Class5Name	Db	"Memory",0
;PCI_Class6Name	Db	"Bridge",0
;PCI_Class7Name	Db	"Communication",0
;PCI_Class8Name	Db	"System",0
;PCI_Class9Name	Db	"Input",0
;PCI_Class10Name	Db	"Docking",0
;PCI_Class11Name	Db	"Processor",0
;PCI_Class12Name	Db	"Serial",0
;PCI_Class13Name	Db	"Wireless",0
;PCI_Class14Name	Db	"Intelligent I/O",0
;PCI_Class15Name	Db	"Satellite",0
;PCI_Class16Name	Db	"En/decryption",0
;PCI_Class17Name	Db	"Data aquisition, signal processing",0


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI bit definitions
;

PCIB_MULTIFUNC	Equ	0x80


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI RootClasses
;
PCI_RCStorage	Equ	1	; Storagedevices
PCI_RCNetwork	Equ	2	; Network
PCI_RCDisplay	Equ	3	; Displaydevices
PCI_RCMultiMedia	Equ	4	; Multimedia
PCI_RCMemory	Equ	5	; Memory
PCI_RCBridge	Equ	6	; Bridgeboard
PCI_RCComm	Equ	7	; Communication
PCI_RCSystem	Equ	8	; Systemdevices
PCI_RCInput	Equ	9	; Inputdevices
PCI_RCDocking	Equ	10	; Dockingdevices
PCI_RCProcessor	Equ	11	; Processor
PCI_RCSerial	Equ	12	; Serialdevices


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; PCI SubClasses
;
PCI_SCUnknown	Equ	0x000	; Undefined class
PCI_SCUnknownVGA	Equ	0x001	; Undefined class (VGA)
	;
PCI_SCStoraeSCSI	Equ	0x100	; Storage, SCSI
PCI_SCStoreIDE	Equ	0x101	; Storage, IDE/ATA
PCI_SCStoreFloppy	Equ	0x102	; Storage, Floppy
PCI_SCStoreIPI	Equ	0x103	; Storage, IPI
PCI_SCStoreRAID	Equ	0x104	; Storage, RAID
PCI_SCStoreOther	Equ	0x180	; Storage, Other
	;
PCI_SCNetEthernet	Equ	0x200	; Network, Ethernet
PCI_SCNetToken	Equ	0x201	; Network, Token-ring
PCI_SCNetFDDI	Equ	0x202	; Network, FDDI
PCI_SCNetATM	Equ	0x203	; Network, ATM
PCI_SCNetOther	Equ	0x280	; Network, Other

PCI_SCVideoVGA	Equ	0x300	; Display, VGA
PCI_SCVideoSVGA	Equ	0x301	; Display, SVGA
PCI_SCVideo3D	Equ	0x302	; Display, 3D
PCI_SCVideoOther	Equ	0x380	; Display, Other

PCI_SCMmVideo	Equ	0x400	; MultiMedia, Video
PCI_SCMmAudio	Equ	0x401	; MultiMedia, Audio
PCI_SCMmOther	Equ	0x480	; MultiMedia, Other

PCI_SCMemRAM	Equ	0x500	; Memory, RAM
PCI_SCMemFlash	Equ	0x501	; Memory, Flash
PCI_SCMemOther	Equ	0x580	; Memory, Other

PCI_SCBrHost	Equ	0x600	; Bridge, Host
PCI_SCBrISA	Equ	0x601	; Bridge, ISA
PCI_SCBrEISA	Equ	0x602	; Bridge, EISA
PCI_SCBrMC	Equ	0x603	; Bridge, MicroChannel
PCI_SCBrPCI	Equ	0x604	; Bridge, PCI
PCI_SCBrPCMCIA	Equ	0x605	; Bridge, PCMCIA
PCI_SCBrNUBUS	Equ	0x606	; Bridge, NUBUS
PCI_SCBrCARDBUS	Equ	0x607	; Bridge, CARDBUS
PCI_SCBrRaceWay	Equ	0x608	; Bridge, RACEway
PCI_SCBrOther	Equ	0x680	; Bridge, Other

PCI_SCCommSerial	Equ	0x700	; Communication, Serial
PCI_SCCommPar	Equ	0x701	; Communication, Parallel
PCI_SCCommMPort	Equ	0x702	; Communication, Serial multiport
PCI_SCCommHayes	Equ	0x703	; Communication, Hayes-compatible modem
PCI_SCCommOther	Equ	0x780	; Communication, Other

PCI_SCSysPIC	Equ	0x800	; System, PIC
PCI_SCSysDMA	Equ	0x801	; System, DMA
PCI_SCSysTimer	Equ	0x802	; System, Timer
PCI_SCSysRTC	Equ	0x803	; System, RTC
PCI_SCSysOther	Equ	0x880	; System, Other

PCI_SCInpKeyboard	Equ	0x900	; Input, Keyboard
PCI_SCInpPen	Equ	0x901	; Input, Pen
PCI_SCInpMouse	Equ	0x902	; Input, Mouse
PCI_SCInpScanner	Equ	0x903	; Input, Scanner
PCI_SCInpGamePort	Equ	0x904	; Input, Gameport
PCI_SCInpOther	Equ	0x980	; Input, Other

PCI_SCDockGeneric	Equ	0xa00	; Docking, Generic
PCI_SCDockOther	Equ	0xa01	; Docking, Other

PCI_SCCPU386	Equ	0xb00	; Processor, 386
PCI_SCCPU486	Equ	0xb01	; Processor, 486
PCI_SCCPUPentium	Equ	0xb02	; Processor, Pentium
PCI_SCCPUPentPro	Equ	0xb03	; Processor, Pentium Pro
PCI_SCCPUAlpha	Equ	0xb10	; Processor, Alpha
PCI_SCCPUPowerPC	Equ	0xb20	; Processor, PowerPC
PCI_SCCPUCO	Equ	0xb40	; Processor, Coprocessor
PCI_SCCPUOther	Equ	0xb80	; Processor, Other

PCI_SCSerFireWire	Equ	0xc00	; Serial, Firewire
PCI_SCSerAccess	Equ	0xc01	; Serial, Access
PCI_SCSerSSA	Equ	0xc02	; Serial, SSA
PCI_SCSerUSB	Equ	0xc03	; Serial, USB
PCI_SCSerFiber	Equ	0xc04	; Serial, Fiber
PCI_SCSerSMBus	Equ	0xc05	; Serial, SMBus controller
PCI_SCSerOther	Equ	0xc80	; Serial, Other

PCI_HotSwapCtrl	Equ	0xff00	; Other, Hotswap controller

PCI_Other	Equ	0xff	; Other

PCI_NotInUse	Equ	0xffff	; Free slot



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
