%ifndef Includes_Fs_Partition_I
%define Includes_Fs_Partition_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Partition.I V1.0.0
;
;     Partition structures and types.
;



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Partition table structure
;

	Struc PTStruct
PTS_Indicator	ResB	1	; 00 Active indicator, 0x80 if active
PTS_Heads	ResB	1	; 01 Starting head
PTS_Sector	ResB	1	; 02 Starting sector
PTS_Cylinder	ResB	1	; 03 Starting cylinder
PTS_Type	ResB	1	; 04 Partition type, see below
PTS_EndHead	ResB	1	; 05 End head
PTS_EndSector	ResB	1	; 06 End sector
PTS_EndCyl	ResB	1	; 07 End cylinder
PTS_StartSector	ResD	1	; 08 Starting sector
PTS_NumSects	ResD	1	; 12 Number of sectors in partition
PTS_SIZE	EndStruc

PTS_OFFSET	Equ	446	; Offset to start of PTStruct in sector

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Partition types
;

PT_EMPTY	Equ	0x0	; Empty partition

PT_EXTENDED1	Equ	0x05	; Extended partition (DOS)
PT_EXTENDED2	Equ	0x0f	; Extended partition (Win98)
PT_EXTENDED3	Equ	0x85	; Extended partition (EXT2)

PT_EXT2	Equ	0x83	; EXT2 native partition

PT_FAT32	Equ	0x0b	; FAT-32
PT_FAT32LBA	Equ	0x0c	; FAT-32 LBA mapped
PT_FAT16	Equ	0x06	; FAT-16
PT_FAT16LBA	Equ	0x0e	; FAT-16 LBA mapped

PT_NTFS	Equ	0x07	; NTFS


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
