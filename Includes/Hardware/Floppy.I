%ifndef Includes_Hardware_Floppy_I
%define Includes_Hardware_Floppy_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Floppy.I V1.0.0
;
;     Floppy drive includes, compatible with the 82078 controller
;     and other compatibles such as the 82077SL.
;

	Struc FDCGeometric
fdc_Heads	ResB	1	; Heads
fdc_Tracks	ResB	1	; Number of tracks
fdc_Sectors	ResB	1	; Sectors per track
fdc_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Geometrics for different drive sizes
;
; Rate 0 - 500kb/s
; Rate 1 - 250kb/s
; Rate 2 - 300kb/s
;
; Supported drives as of yet:
;
; 360kb
; 720kb, 720kb w/ 360kb
; 1.20mb, 1.20mb w/ 720kb, 1.20mb w/ 360kb
; 1.44mb, 1.44mb w/ 720kb
; 1.68mb
;


FD1440_SECTORS	Equ	18	; Sectors per track
FD1440_HEADS	Equ	2	; Heads per drive
FD1440_TRACKS	Equ	80	; Number of tracks
FD1440_GAP3RW	Equ	0x1b	; GAP3 while reading/writing
FD1440_GAP3FMT	Equ	0x54	; GAP3 while formatting
FD1440_RATE	Equ	0	;

FD1680_SECTORS	Equ	21	;
FD1680_HEADS	Equ	2	;
FD1680_TRACKS	Equ	80	;
FD1680_GAP3RW	Equ	0x1c	;
FD1680_GAP3FMT	Equ	0x0c	;
FD1680_RATE	Equ	0	;

FD360_SECTORS	Equ	9	;
FD360_HEADS	Equ	2	;
FD360_TRACKS	Equ	40	;
FD360_GAP3RW	Equ	0x2a	;
FD360_GAP3RW1200	Equ	0x23	; GAP in 1.2mb drive
FD360_RATE	Equ	2	; Rate in 360/720kb drive
FD360_RATE1200	Equ	1	; Rate in 1.2mb drive

FD1200_SECTORS	Equ	15	;
FD1200_HEADS	Equ	2	;
FD1200_TRACKS	Equ	80	;
FD1200_GAP3RW	Equ	0x1b	;
FD1200_RATE	Equ	0	;

FD720_SECTORS	Equ	9	;
FD720_HEADS	Equ	2	;
FD720_TRACKS	Equ	80	;
FD720_GAP3RW	Equ	0x2a	;
FD720_GAP3W1200	Equ	0x23	; GAP in 1.2mb drive
FD720_RATE	Equ	2	; Rate in 720/1440kb drive
FD720_RATE1200	Equ	1	; Rate in 1.2mb drive


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Floppy I/O port offsets
;

FDCPORT_STA	Equ	0	; Controller status A
FDCPORT_STB	Equ	1	; Controller status B
FDCPORT_DOR	Equ	2	; Digital output register
FDCPORT_TDR	Equ	3	; Tape drive register
FDCPORT_MSR	Equ	4	; Main status register, read
FDCPORT_DRS	Equ	4	; Data rate select, write
FDCPORT_ST0	Equ	5	; Status Register 0 (ST0)
FDCPORT_ST1	Equ	5	; Status Register 1 (ST0)
FDCPORT_ST2	Equ	5	; Status Register 2 (ST0)
FDCPORT_ST3	Equ	5	; Status Register 3 (ST0)
FDCPORT_DATA	Equ	5	; Data register
FDCPORT_DIR	Equ	7	; Digital input register
FDCPORT_CCR	Equ	7	; Configuration control register, output


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Controller status A bits
;
	BITDEF	FDCSTA,INT,7	; Interrupt pending
	BITDEF	FDCSTA,DRV2,6	; Second drive installed
	BITDEF	FDCSTA,STEP,5	;
	BITDEF	FDCSTA,TRACk0,4	;
	BITDEF	FDCSTA,HEAD1SEL,3	; Head 1 select
	BITDEF	FDCSTA,INDEX,2	; Index
	BITDEF	FDCSTA,WRITEP,1	; Write protect
	BITDEF	FDCSTA,DIR,0	; Direction

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Controller status B bits
;
	BITDEF	FDCSTB,DRV2,7	; Second drive installed
	BITDEF	FDCSTB,DS1,6	;
	BITDEF	FDCSTB,DS0,5	;
	BITDEF	FDCSTB,WRITE,4	; Write data F/F
	BITDEF	FDCSTB,READ,3	; Read data F/F
	BITDEF	FDCSTB,ENABLEWR,2	; Write enable F?F
	BITDEF	FDCSTB,DS3,1	;
	BITDEF	FDCSTB,DS2,0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Digital Output Register (DOR) bitfield
;
	BITDEF	FDCDOR,DRIVE3,7	; Drive 3 motor enable (reserved on PS/2)
	BITDEF	FDCDOR,DRIVE2,6	; Drive 2 motor enable (reserved on PS/2)
	BITDEF	FDCDOR,DRIVE1,5	; Drive 1 motor enable
	BITDEF	FDCDOR,DRIVE0,4	; Drive 0 motor enable
	BITDEF	FDCDOR,DMA,3	; Enable DMA (reserved on PS/2)
	BITDEF	FDCDOR,FDCRESET,2	; FDC enable/Controller reset when set, else hold FDC at reset
	BITDEF	FDCDOR,DRSEL1,1	; Drive select 1
	BITDEF	FDCDOR,DRSEL0,0	; Drive select 0, 00=Drive 0, 01=Drive 01 etc..

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Digital Input Register (DIR) bitfield
;
	BITDEF	FDCDIR,CHANGE,7	; Disk change
	BITDEF	FDCDIR,RATE1,2	; Datarate select 1
	BITDEF	FDCDIR,RATE0,1	; Datarate select 0
	BITDEF	FDCDIR,DENSITY,0	; High density select if clear


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Main Status Register (MSR) bitfield
;

	BITDEF	FDCMSR,READY,7	; Set if ready, clear=no access is permitted
	BITDEF	FDCMSR,MODE,6	; 1=Transfer from controller to system, 0=System to controller
	BITDEF	FDCMSR,DMA,5	; non-DMA mode
	BITDEF	FDCMSR,BUSY,4	; Controller is busy
	BITDEF	FDCMSR,DRV3BUSY,3	; Drive 3 busy (reserved on PS/2)
	BITDEF	FDCMSR,DRV2BUSY,2	; Drive 2 busy (reserved on PS/2)
	BITDEF	FDCMSR,DRV1BUSY,1	; Drive 1 busy
	BITDEF	FDCMSR,DRV0BUSY,0	; Drive 0 busy

FDCMSR_BUSYMASK	Equ	0xf	; Drive busy mask

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Data Rate Select Register (DRS) bitfield
;
; NOTE: Bits 7-2 are reserved on 8272
;
	BITDEF	FDCDRS,RESET,7	; Software reset, self clearing (82072/82077AA)
	BITDEF	FDCDRS,POWERDWN,6	; Power down (82072/82077AA)
	BITDEF	FDCDRS,PLL,5	; PLL select bit (82072 only)
	BITDEF	FDCDRS,WRITEC2,4	; Write precompensation value 2, 000=default
	BITDEF	FDCDRS,WRITEC1,3	; Write precompensation value 1, 000=default
	BITDEF	FDCDRS,WRITEC0,2	; Write precompensation value 0, 000=default
	BITDEF	FDCDRS,RATESEL1,1	; Rate select, 00=500kb, 01=300kb, 10=250kb, 11=1m
	BITDEF	FDCDRS,RATESEL0,0	; Rate select

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Status Register 0 (ST0) bitfield
;
	BITDEF	FDCST0,LCMD1,7	; Last command status, 0=Command terminated succ, 1=Command terminated abnormally
	BITDEF	FDCST0,LCMD0,6	; Last command status, 10=Invalid command, 11=Terminated abonrmally by change in ready signal
	BITDEF	FDCST0,SEEKDONE,5	; Seek completed
	BITDEF	FDCST0,EQCHECK,4	; Equipment check occured after error
	BITDEF	FDCST0,NOTREADY,3	; Not ready
	BITDEF	FDCST0,HEADNUM,2	; Head number at interrupt
	BITDEF	FDCST0,UNITSEL1,1	; Unit select 1
	BITDEF	FDCST0,UNITSEL0,0	; Unit select 0

FDCST0_DRIVESEL	Equ	0x3	; Drive select mask

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Status Register 1 (ST1) bitfield
;
	BITDEF	FDCST1,ENDOFCYL,7	; End of cylinder, sectornumber greater than sectors/track
	BITDEF	FDCST1,CRCERROR,5	; CRC error in ID or data field
	BITDEF	FDCST1,OVERRUN,4	; Overrun
	BITDEF	FDCST1,IDNOTFND,2	; Sector ID not found
	BITDEF	FDCST1,WRITEPDW,1	; Write protection detected during write
	BITDEF	FDCST1,IDMARKNF,0	; ID address mark not found


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Status Register 2 (ST2) bitfield
;
	BITDEF	FDCST2,DDAM,6	; Deleted Data Address Mark detect
	BITDEF	FDCST2,CRCERROR,5	; CRC error in data
	BITDEF	FDCST2,WRONGCYL,4	; Wrong cylinder detected
	BITDEF	FDCST2,SCANEQ,3	; Scan command equal condition satisfied
	BITDEF	FDCST2,SCANFAIL,2	; Scan command failed, sector not found
	BITDEF	FDCST2,BADCYL,1	; Bad cylinder, ID not found
	BITDEF	FDCST2,MISSDAM,0	; Missing Data Address Mark

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Status Register 3 (ST3) bitfield
;
	BITDEF	FDCST3,FSS,7	; Fault Status Signal
	BITDEF	FDCST3,WRITEPST,6	; Write Protect Status
	BITDEF	FDCST3,RDYSTAT,5	; Ready Status
	BITDEF	FDCST3,TZSTAT,4	; Track Zero Status
	BITDEF	FDCST3,TWSTAT,3	; Two sided status signal
	BITDEF	FDCST3,HEADSEL,2	; Head select (side select)
	BITDEF	FDCST3,UNITSEL1,1	; Unit select 1
	BITDEF	FDCST3,UNITSEL0,0	; Unit select 0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Floppy commands
;

FDCCMD_SPECIFY	Equ	0x03	; Specify timings for the drive
FDCCMD_WRITE	Equ	0xc5	; Write data
FDCCMD_READ	Equ	0xe6	; Read data
FDCCMD_RECALIBRATE Equ	0x07	; Recalibrate
FDCCMD_SENSEINT	Equ	0x08	; Sense interrupt status
FDCCMD_FORMAT	Equ	0x4d	; Format track
FDCCMD_SEEK	Equ	0x0f	; Seek track
FDCCMD_VERSION	Equ	0x10	; Version


FDCCMD_DMAREAD	Equ	0x46	; DMA read
FDCCMD_DMAWRITE	Equ	0x4a	; DMA write


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
