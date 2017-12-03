%ifndef Includes_Devices_3C90X_I
%define Includes_Devices_3C90X_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     3C90X.I V1.0.0
;
;     3COM 3C90X and 3C90XB NIC includes.
;





;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90x NICs PCI IDs
;

PCI_ID_3C90X_100BASETX	Equ	0x9000	; PCI 10/100 Mbps; shared 10BASE-T/100BASE-TX connector
PCI_ID_3C90X_100BASET4	Equ	0x9001	; PCI 10/100 Mbps; shared 10BASE-T/100BASE-T4 connector
PCI_ID_3C90X_10BASETPO	Equ	0x9050	; PCI 10BASE-T(TPO)
PCI_ID_3C90X_10BASECBO	Equ	0x9051	; PCI 10BASE-T/10BASE2/AUI(COMBO)

; 3C90xB NICs PCI IDs

PCI_ID_3C90XB_100BASETX	Equ	0x9055	; PCI 10/100 Mbps; shared 10BASE-T/100BASE-TX connector
PCI_ID_3C90XB_100BASET4	Equ	0x9056	; PCI 10/100 Mbps; shared 10BASE-T/100BASE-T4 connector
PCI_ID_3C90XB_10BASETPO	Equ	0x9004	; PCI 10BASE-T(TPO)
PCI_ID_3C90XB_10BASECBO	Equ	0x9005	; PCI 10BASE-T/10BASE2/AUI(COMBO)
PCI_ID_3C90XB_10BASETPC	Equ	0x9006	; PCI 10BASE-T/10BASE2(TPC)
PCI_ID_3C90XB_10BASEFL	Equ	0x900a	; PCI 10BASE-FL
PCI_ID_3C90XB_10BASEFX	Equ	0x905a	; PCI 10BASE-FX

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90X NICs Commands
;

; Reset commands


NIC3C90XCMD_GlobalReset	Equ	0000000000000000B	; Perfom an overall reset of NIC
NIC3C90XCMD_RxReset	Equ	0010100000000000B	; Reset the receive logic
NIC3C90XCMD_TxReset	Equ	0101100000000000B	; Reset the transmit logic

; Transmit commands

NIC3C90XCMD_DnStall	Equ	0011000000000010B	; Stall the download engine
NIC3C90XCMD_DnUnstall	Equ	0011000000000011B	; Unstall the download engine
NIC3C90XCMD_SetTxReclaimThresh	Equ	1100000000000000B	; Set the value of the TxReclaimThresh register. 3C90XB only.
NIC3C90XCMD_SetTxStartThresh	Equ	1001100000000000B	; Set the value of the TxStartThresh register
NIC3C90XCMD_TxDisable	Equ	0101000000000000B	; Disable packet transmission
NIC3C90XCMD_TxEnable	Equ	0100100000000000B	; Enable packet transmission

; Recieve commands

NIC3C90XCMD_RxDisable	Equ	0001100000000000B	; Disable packet reception
NIC3C90XCMD_RxEnable	Equ	0010000000000000B	; Enable packet reception
NIC3C90XCMD_SetHashFilterBit	Equ	1100100000000000B	; Program a particular bit in the hash filter
NIC3C90XCMD_SetRxEarlyThresh	Equ	1000100000000000B	; Set the value of the RxEarlyThresh register
NIC3C90XCMD_SetRxFilter	Equ	1000000000000000B	; Set the value of the RxFilter register, see below for values

NIC3C90XCMD_FIL_Individual	Equ	1	; Filter types	
NIC3C90XCMD_FIL_Multicast	Equ	2
NIC3C90XCMD_FIL_Broadcast	Equ	4
NIC3C90XCMD_FIL_ProMisc	Equ	8

NIC3C90XCMD_UpStall	Equ	0011000000000000B	; Stall the upload engine
NIC3C90XCMD_UpUnstall	Equ	0011000000000001B	; Unstall the upload engine

; Interrupt commands

NIC3C90XCMD_AcknowledgeInterrupt	Equ	0110100000000000B	; Acknowledge active interrupts
NIC3C90XCMD_RequestInterrupt	Equ	0110000000000000B	; Cause the NIC to generate an interrupt
NIC3C90XCMD_SetIndicationEnable	Equ	0111100000000000B	; Set the value of the IndicationEnable register
NIC3C90XCMD_SetInterruptEnable	Equ	0111000000000000B	; Set the value of the InterruptEnable register

; Other commands

NIC3C90XCMD_DisableDcConverter	Equ	1011100000000000B	; Disable the 10BASE2 DC-DC converter. 3C90xB only
NIC3C90XCMD_EnableDcConverter	Equ	0001000000000000B	; Enable the 10BASE2 DC-DC converter. 3C90xB only
NIC3C90XCMD_SelectRegisterWindow	Equ	0000100000000000B	; Change the visible window
NIC3C90XCMD_StatisticsDisable	Equ	1011000000000000B	; Disable collection of statistics
NIC3C90XCMD_StatisticsEnable	Equ	1010100000000000B	; Enable collection of statistics

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90x NICs Register Layout
;

	Struc NIC3C90X
.Window	ResD	4	; Register Windows 0-7
	ResD	1
	ResD	1
	ResW	1
.Timer	ResB	1
.TxStatus	ResB	1
	ResW	1
.Command	ResW	1	; IntStatus/Command
.DmaCtrl	ResD	1
.DnListPtr	ResD	1
	ResD	1
	ResB	3
.TxFreeThresh	ResB	1
.UpPktStatus	ResD	1
.FreeTimer	ResW	1
.CountDown	ResW	1
.UpListPtr	ResD	1
	ResD	1
.SIZE	EndStruc

;
; Default registers

NIC3C90XCMD	Equ	0xe
NIC3C90XSTATUS	Equ	0xe

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90x NICs Register Window Layout
;



	Struc NIC3C90XWIN0
	ResB	10	; Reserved
.EepromCommand	ResW	1
.EepromData	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XWIN1
	ResD	1
.RxError	ResB	1
	ResB	3
.RxStatus	ResW	1
.Timer	ResB	1
.TxStatus	ResB	1
.TxFree	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XWIN2
.StationAddrLo	ResW	1
.StationAddrMid	ResW	1
.StationAddrHi	ResW	1
.StationMaskLo	ResW	1
.StationMaskMid	ResW	1
.StationMaskHi	ResW	1
	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XWIN3
.InternalConfig	ResD	1
	ResW	1
.MacControl	ResW	1
.ResetOptions	ResW	1
.RxFree	ResW	1
.TxFree	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XWIN4
	ResW	1
.VcoDiagnostic	ResW	1	; Not supported
.FifoDiagnostic	ResW	1
.NetDiagnostic	ResW	1	; Network diagnostic
.PhysicalMgmt	ResW	1
.MediaStatus	ResW	1	; Mediastatus, see definitiosn below
.BadSSD	ResB	1
.UpperBytesOk	ResB	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

NIC3C90XWIN4_MS_SQE_ENABLE	Equ	0x08	;	Enables SQE on AUI ports
NIC3C90XWIN4_MS_JABBER_GUARD_ENABLE	Equ	0x40
NIC3C90XWIN4_MS_LINKBEAT_ENABLE	Equ	0x80
NIC3C90XWIN4_MS_DISABLE_UTP	Equ	0
NIC3C90XWIN4_MS_LINKBEAT_DETECT	Equ	0x800



	Struc NIC3C90XWIN5
.TxStartThresh	ResW	1
.TxAvailThresh	ResW	1	; TxAvailableThresh
.RxFilter	ResB	1
	ResB	1
.InterruptEnable	ResW	1
.IndicationEnable	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XWIN6
.CarrierLost	ResB	1
.SqeErrors	ResB	1
.MultCollisions	ResB	1	; MultipleCollisions
.SingleCollisions	ResB	1	; SingleCollisions
.LateCollisions	ResB	1
.RxOverruns	ResB	1
.FramesXmittedOk	ResB	1
.FramesRcvdOk	ResB	1
.FramesDeferred	ResB	1
.UpperFrameOk	ResB	1
.BytesRcvdOk	ResW	1
.BytesXmittedOk	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XWIN7
	ResB	12
.Timer	ResB	1
.TxStatus	ResB	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc





;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90xB NICs Register Layout
;

	Struc NIC3C90XB
.Window	ResD	4	; Register Windows 0-7
	ResD	1
	ResD	1
.TxPktld	ResB	1
	ResB	1
.Timer	ResB	1
.TxStatus	ResB	1
	ResW	1
.IntStatusAuto	ResW	1
.DmaCtrl	ResD	1
.DnListPtr	ResD	1
	ResW	1
.DnBurstThresh	ResB	1
	ResB	1
.DnPriorityThresh	ResB	1
.DnPoll	ResB	1
	ResW	1
.UpPktStatus	ResD	1
.FreeTimer	ResW	1
.CountDown	ResW	1
.UpListPtr	ResD	1
.UpPriorityThresh	ResB	1
.UpPoll	ResB	1
.UpBurstThresh	ResB	1
	ResB	1
.RealTimeCnt	ResD	1
	ResD	11
.DebugData	ResD	1
.DebugControl	ResW	1
	ResW	1
.DnMaxBurst	ResW	1
.UpMaxBurst	ResW	1
.PowerMgmtCtrl	ResW	1	; Write-only
	ResW	1
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90x NICs Register Window Layout
;


	Struc NIC3C90XBWIN0
	Resd	1	; Reserved
.BiosRomData	ResB	1
	ResB	1
.EepromCommand	ResW	1
.EepromData	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN1
	ResB	12
	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN2
.StationAddrLo	ResW	1
.StationAddrMid	ResW	1
.StationAddrHi	ResW	1
.StationMaskLo	ResW	1
.StationMaskMid	ResW	1
.StationMaskHi	ResW	1
.ResetOptions	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN3
.InternalConfig	ResD	1
.MaxPktSize	ResB	1
.MacControl	ResW	1
.MediaOptions	ResW	1
.RxFree	ResW	1
.TxFree	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN4
	ResW	1
.VcoDiagnostic	ResW	1	; Not supported
.FifoDiagnostic	ResW	1
.NetDiagnostic	ResW	1	; Network diagnostic
.PhysicalMgmt	ResW	1
.MediaStatus	ResW	1
.BadSSD	ResB	1
.UpperBytesOk	ResB	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN5
.TxStartThresh	ResW	1
	ResW	2
.RxEarlyThresh	ResW	1
.RxFilter	ResB	1
.TxReclaimThresh	ResB	1
.InterruptEnable	ResW	1
.IndicationEnable	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN6
.CarrierLost	ResB	1
.SqeErrors	ResB	1
.MultCollisions	ResB	1	; MultipleCollisions
.SingleCollisions	ResB	1	; SingleCollisions
.LateCollisions	ResB	1
.RxOverruns	ResB	1
.FramesXmittedOk	ResB	1
.FramesRcvdOk	ResB	1
.FramesDeferred	ResB	1
.UpperFrameOk	ResB	1
.BytesRcvdOk	ResW	1
.BytesXmittedOk	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc

	Struc NIC3C90XBWIN7
.VlanMask	ResW	1
	ResW	1
.VlanEtherType	ResW	1
	ResW	3
.PowerMgmtEvent	ResW	1
.Command	ResW	1	; IntStatus/Command
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; 3C90xB NICs EEPROM contents
;

ELINK_EEPROMREAD	Equ	128


	Struc NIC3C90XBEEPROM
.3COMNodeAddress0	ResB	1
.3COMNodeAddress1	ResB	1
.3COMNodeAddress2	ResB	1
.DeviceID	ResB	1
.MFDataDate	ResB	1	; Manufacturing Data - Date
.MFDataDivision	ResB	1	; Manufacturing Data - Division
.MFDataProdCode	ResB	1	; Manufacturing Data - Product Code
.MFDataID	ResB	1	; Manufacturing Data ID
.PciParm	ResB	1
.RomInfo	ResB	1
.OEMNodeAddress0	ResB	1
.OEMNodeAddress1	ResB	1
.OEMNodeAddress2	ResB	1
.SoftwareInfo	ResB	1
.CompWord	ResB	1	; Compatibility word
.SoftwareInfo2	ResB	1
.CapabilitiesWord	ResB	1
	ResB	1	; Reserved
.InternalConfig0	ResB	1
.InternalConfig1	ResB	1
.AnalogDiagnostic	ResB	1
.SoftwareInfo3	ResB	1
.LANWorksData	ResB	1
.SubsysVendorID	ResB	1	; Subsystem Vendor ID
.SubsysID	ResB	1	; Subsystem ID
.MediaOptions	ResB	1
	ResB	6	; Reserved
.Checksum	ResB	1
.SIZE	EndStruc




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
