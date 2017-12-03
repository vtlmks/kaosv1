%ifndef Includes_Hardware_IDE_I
%define Includes_Hardware_IDE_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Ide.I V1.0.0
;
;     IDE/ATA hardware includes.
;


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Command descriptions
;
IDEC_ReCalib	Equ	0x10	; Recalibrate ** 0x1X **
IDEC_RSWR	Equ	0x20	; Read Sectors With Retry
IDEC_RSWOR	Equ	0x21	; Read Sectors WithOut Retry
IDEC_RLSWR	Equ	0x22	; Read Long Sectors With Retry
IDEC_RLSWOR	Equ	0x23	; Read Long Sectors WithOut Retry
IDEC_WSWR	Equ	0x30	; Write Sectors With Retry
IDEC_WSWOR	Equ	0x31	; Write Sectors WithOut Retry
IDEC_WLSWR	Equ	0x32	; Write Long Sectors With Retry
IDEC_WLSWOR	Equ	0x33	; Write Long Sectors WithOut Retry
IDEC_RVSWR	Equ	0x40	; Read Verify Sector With Retry
IDEC_RVSWOR	Equ	0x41	; Read Verify Sector WithOut Retry
IDEC_Format	Equ	0x50	; Format track
IDEC_Seek	Equ	0x70	; Seek ** 0x7X **
IDEC_EDD	Equ	0x90	; Execute drive diagnostics
IDEC_InitDP	Equ	0x91	; Initialize drive parameters
IDEC_ReadBuf	Equ	0xe4	; Read buffer
IDEC_WriteBuf	Equ	0xe8	; Write Buffer
IDEC_Identify	Equ	0xec	; Identify drive
IDEC_SetFeat	Equ	0xef	; Set features

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Ports
;


IDEP_DataPort	Equ	0	; R - Data port      W - Data port
IDEP_ErrorReg	Equ	1	; R - Error register W - Precomp
IDEP_SectCnt	Equ	2	; R - Sector count   W - Sector count
IDEP_SectNumb	Equ	3	; R - Sector number  W - Sector number
IDEP_CylLow	Equ	4	; R - Cylinder low   W - Cylinder low
IDEP_CylHigh	Equ	5	; R - Cylinder high  W - Cylinder high
IDEP_Head	Equ	6	; R - Drive / Head   W - Drive / Head
IDEP_Status	Equ	7	; R - Status
IDEP_Command	Equ	7	; W - Command

IDEP_AltStat	Equ	0x3f6	; R - Altern status
IDEP_DevCtrl	Equ	0x3f6	; W - Device control
IDEP_DrivAddr	Equ	0x3f7	; R - Drive address


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; IDE_ErrorReg [Read] bits
;
IDEErr_BBK	Equ	7	; Bad block mark detected in the requested sector's ID field
IDEErr_UNC	Equ	6	; Uncorrectable data error encountered [Not used]
IDEErr_IDNF	Equ	4	; Requested sector's ID field not found
IDEErr_ABRT	Equ	2	; Command aborted due to drive status error or invalid command
IDEErr_TK0NF	Equ	1	; Track 0 not found during execution of Recalibrate command
IDEErr_AMNF	Equ	0	; Data address mark not found after correct ID field found

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; IDE_Head [Read/Write] bits
;
IDEHead_DRV	Equ	4	; 0 to select primary drive, 1 to select secondary drive
IDEHead_HS3	Equ	3	; MSB of head number
IDEHead_HS2	Equ	2	;
IDEHead_HS1	Equ	1	;
IDEHead_HS0	Equ	0	; LSB of head number


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; IDE_Status [Read] bits
;

 BITDEF	IDE,Error,	0	; Error bit
 BITDEF	IDE,DRQ,	3	; Data request bit
 BITDEF	IDE,Ready,	6	; Drive ready bit
 BITDEF	IDE,Busy,	7	; Busy bit

 BITDEF	IDE,Index,	1	; Index bit		** OBSOLETE, REMOVE **
 BITDEF	IDE,CORR,	2	; Corrected data bit	** OBSOLETE, REMOVE **
 BITDEF	IDE,DSC,	4	; Drive seek complete bit	** OBSOLETE, REMOVE **
 BITDEF	IDE,DWF,	5	; Drive write fault bit	** OBSOLETE, REMOVE **


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; IDE_Command [Write] bits
;
; **TO BE INCLUDED SOON..**

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; IDE_DevCtrl [Write] bits
;
IDEDevC_SRST	Equ	2	; Host software reset bit
IDEDevC_NIEN	Equ	1	; Drive interrupt enable bit

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; IDE_DrivAddr [Read] bits
;
IDEDrivA_HIZ	Equ	7	; This bit is in high impedance when read
IDEDrivA_WGT	Equ	6	; Write gate bit
IDEDrivA_HS3	Equ	5	; Negated MSB of head number
IDEDrivA_HS2	Equ	4	;
IDEDrivA_HS1	Equ	3	;
IDEDrivA_HS0	Equ	2	; Negated LSB of head number
IDEDrivA_DS1	Equ	1	; Drive 1 select bit. When 0, drive 1 is selected
IDEDrivA_DS0	Equ	0	; Drive 0 select bit. When 0, drive 0 is selected


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
