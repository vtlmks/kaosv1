%ifndef Includes_Fs_Fat_I
%define Includes_Fs_Fat_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Fat.I V1.0.0
;
;     FAT12/16/32 File System includes.
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT Signatures and their offsets
;

FATBB_SIGNATURE	Equ	0xaa55	; Bootblock end signature
FATBB_SIGNOFFSET	Equ	0x1fe	; Bootblock end signature offset (relative)

FATFS_INFO	Equ	0x61417272	; (Little endian "rrAa")
FATFS_INFOFFSET	Equ	0x1e4

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT max/min cluster sizes
;

FAT12MIN_CLUSTERS	Equ	0x00000001
FAT12MAX_CLUSTERS	Equ	0x00000fff-11	; 4084
FAT16MIN_CLUSTERS	Equ	0x00000fff-10	; 4085
FAT16MAX_CLUSTERS	Equ	0x0000ffff-11	; 65524
FAT32MIN_CLUSTERS	Equ	0x0000ffff-10	; 65525
FAT32MAX_CLUSTERS	Equ	0x0fffffff-11	; 268435444

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT cluster markers
;

FATCLUSTER_FREE0	Equ	0x0	; Cluster marked as free
FATCLUSTER_FREE1	Equ	0x10000000	; Cluster marked as free
FATCLUSTER_FREE2	Equ	0xF0000000	; Cluster marked as free

FAT12CLUSTER_BAD	Equ	0x00000FF7	; Cluster marked as bad
FAT16CLUSTER_BAD	Equ	0x0000FFF7	; Cluster marked as bad
FAT32CLUSTER_BAD	Equ	0x0FFFFFF7	; Cluster marked as bad, 28 bit only - Preserve upper 4 bits

FAT12CLUSTER_EOC	Equ	0x00000FF8	; EOC, End Of Cluster chain for FAT12
FAT16CLUSTER_EOC	Equ	0x0000FFF8	; EOC, End Of Cluster chain for FAT16
FAT32CLUSTER_EOC	Equ	0x0FFFFFF8	; EOC, End Of Cluster chain for FAT32

FAT12CLUSTER_EOC0	Equ	0x00000FFF	; EOC, End Of Cluster chain for FAT12, MS convention
FAT16CLUSTER_EOC0	Equ	0x0000FFFF	; EOC, End Of Cluster chain for FAT16, MS convention
FAT32CLUSTER_EOC0	Equ	0x0FFFFFFF	; EOC, End Of Cluster chain for FAT32, MS convention



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; BIOS Parameter Block (BPB) for FAT-12

	Struc	FAT12BPB
.BSJMPBoot	ResB	3	; Jump instruction to bootcode
.BSOEMName	ResB	8	; OEM name
	;
.BytesPerSector	ResW	1	; Bytes per sector
.SectorsPerClust	ResB	1	; Sectors per cluster
.ReservedSectors	ResW	1	; Reserved sectors
.NumFats	ResB	1	; Number of Fats
.RootEntries	ResW	1	; Root entries
.TotalSectors	ResW	1	; Total sectors
.Media	ResB	1	; Media type
.SectorsPerFat	ResW	1	; Sectors per Fat
.SectorsPerTrack	ResW	1	; Sectors per track
.HeadsPerCyl	ResW	1	; Heads per cylinder
.HiddenSectors	ResD	1	; Hidden sectors
.TotalSectorsBig	ResD	1	; Total sectors
	;
.DriveNumber	ResB	1	; Drive number, e.g. 0x80 to be used with BIOS Int 0x13
.Reserved	ResB	1	; Reserved, set to null
.BootSig	ResB	1	; Extended boot signature (0x29). Indicates that the following three fields are available
.VolumeID	ResD	1	; Volume serial number
.VolumeLabel	ResB	11	; Volume label, matches the 11-byte volume label in the root directory
.FileSystemType	ResB	8	; Usually contains FAT12, FAT16 or FAT with trailing spaces
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; BIOS Parameter Block (BPB) for FAT-16
;

	Struc	FAT16BPB
.BSJMPBoot	ResB	3	; Jump instruction to bootcode
.BSOEMName	ResB	8	; OEM name
	;
.BytesPerSector	ResW	1	; Bytes per sector
.SectorsPerClust	ResB	1	; Sectors per cluster
.ReservedSectors	ResW	1	; Reserved sectors
.NumFats	ResB	1	; Number of Fats
.RootEntries	ResW	1	; Root entries
.TotalSectors	ResW	1	; Total sectors
.Media	ResB	1	; Media type
.SectorsPerFat	ResW	1	; Sectors per Fat
.SectorsPerTrack	ResW	1	; Sectors per track
.HeadsPerCyl	ResW	1	; Heads per cylinder
.HiddenSectors	ResD	1	; Hidden sectors
.TotalSectorsBig	ResD	1	; Total sectors
	;
.DriveNumber	ResB	1	; Drive number, e.g. 0x80 to be used with BIOS Int 0x13
.Reserved	ResB	1	; Reserved, set to null
.BootSig	ResB	1	; Extended boot signature (0x29). Indicates that the following three fields are available
.VolumeID	ResD	1	; Volume serial number
.VolumeLabel	ResB	11	; Volume label, matches the 11-byte volume label in the root directory
.FileSystemType	ResB	8	; Usually contains FAT12, FAT16 or FAT with trailing spaces
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; BIOS Parameter Block (BPB) for FAT-32
;

	Struc	FAT32BPB
.BSJMPBoot	ResB	3	; Jump instruction to bootcode
.BSOEMName	ResB	8	; OEM name
	;
.BytesPerSector	ResW	1	; Bytes per sector
.SectorsPerClust	ResB	1	; Sectors per cluster
.ReservedSectors	ResW	1	; Reserved sectors
.NumFats	ResB	1	; Number of Fats
.RootEntries	ResW	1	; Root entries
.TotalSectors	ResW	1	; Total sectors
.Media	ResB	1	; Media type
.SectorsPerFat	ResW	1	; Sectors per Fat
.SectorsPerTrack	ResW	1	; Sectors per track
.HeadsPerCyl	ResW	1	; Heads per cylinder
.HiddenSectors	ResD	1	; Hidden sectors
.TotalSectorsBig	ResD	1	; Total sectors
	;
.SectorsPerFat32	ResD	1	; Sectors per Fat
.Flags	ResW	1	; Flagset
.Version	ResW	1	; Version
.RootCluster	ResD	1	; Root cluster
.InfoSector	ResW	1	; Info sector
.BootBackupStart	ResW	1	; Boot backup start
.Reserved1	ResB	12	; RESERVED
	;
.DriveNumber	ResB	1	; Drive number, e.g. 0x80 to be used with BIOS Int 0x13
.Reserved2	ResB	1	; Reserved, set to null
.BootSig	ResB	1	; Extended boot signature (0x29). Indicates that the following three fields are available
.VolumeID	ResD	1	; Volume serial number
.VolumeLabel	ResB	11	; Volume label, matches the 11-byte volume label in the root directory
.FileSystemType	ResB	8	; Usually contains FAT32 with trailing spaces
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT-32 File System Information (FSI) structure 

	Struc	FAT32FSI
.LeadSig	ResD	1	; Lead Signature, used to validate that this an FSInfo sector
.Reserved1	ResB	480	; Reserved
.StrucSig	ResD	1	; Struc Signature
.FreeCount	ResD	1	; Free cluster count, set to 0xffffffff it's unknown and must be computed
.NextFree	ResD	1	; Next cluster, if 0xffffffff then the driver should search from cluster 2 and forward
.Reserved2	ResD	3	; RESERVED
.TrailSig	ResD	1	; Trail signature, used to validate that this is an FSInfo sector
.SIZE	EndStruc

FATFSI_LEADSIG	Equ	0x41615252	; Lead signature
FATFSI_STRUCSIG	Equ	0x61417272	; Struc signature
FATFSI_TRAILSIG	Equ	0xaa550000	; Trail signature

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT-32 Directory Entry (DE) Structure

	Struc	FAT32DE
.DirName	ResB	11	; Short name (see below, for special cases for the first byte in DirName)
.Attributes	ResB	1	; File attributes, see below
.Reserved	ResB	1	; Reserved for use by WinNT, should be set to null.
.CreateTimeTenth	ResB	1	; Millisecond stamp at file creation time
.CreateTime	ResW	1	; Creation time
.CreateDate	ResW	1	; Creation date
.LastAccess	ResW	1	; Last access date
.ClusterHigh	ResW	1	; High word of this entry's first cluster number (0 for FAT12/16)
.Time	ResW	1	; Time of last write (see below)
.Date	ResW	1	; Date of last write (see below)
.ClusterLow	ResW	1	; Low word of this entry's first cluster number
.FileSize	ResD	1	; Filesize in bytes
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT Directory Entry Attributes
; Note, the upper two bits are reserved and should be set to null when file is created.

FATATR_READONLY	Equ	0x01	; Writes to the file should fail
FATATR_HIDDEN	Equ	0x02	; Normal directory listings should not show this file
FATATR_SYSTEM	Equ	0x04	; Operating system file
FATATR_VOLID	Equ	0x08	; Name of this file is the label for the volume, cluster hi/lo should be 0 for this
FATATR_DIR	Equ	0x10	; Directory for further files
FATATR_ARCHIVE	Equ	0x20	; Set by FAT when a file is created, renamed or written to
FATATR_LONGN	Equ	FATATR_READONLY|FATATR_HIDDEN|FATATR_SYSTEM|FATATR_VOLID


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT identifiers for the first byte of DirName

FAT32DE_FREE	Equ	0x05	; Directory entry is free
FAT32DE_KANJI	Equ	0xe5	; Japanese KANJI leadbyte
FAT32DE_BAD	Equ	0x20	; Name may not begin with a space

FAT32DE_DIR1	Equ	0x2e	; First directory entry name (dot), points to itself
FAT32DE_DIR2	Equ	0x2e2e	; Second directory entry name (dotdot), points to starting cluster of parent directory,
			; which is null if this directory parent is the root

FAT32DE_BAD01	Equ	0x22	; The following bytes and all bytes below 0x20 are illegal
FAT32DE_BAD02	Equ	0x2a	; to use anywhere in the DirName
FAT32DE_BAD03	Equ	0x2b
FAT32DE_BAD04	Equ	0x2c
FAT32DE_BAD05	Equ	0x2e
FAT32DE_BAD06	Equ	0x2f
FAT32DE_BAD07	Equ	0x3a
FAT32DE_BAD08	Equ	0x3b
FAT32DE_BAD09	Equ	0x3c
FAT32DE_BAD10	Equ	0x3d
FAT32DE_BAD11	Equ	0x3e
FAT32DE_BAD12	Equ	0x3f
FAT32DE_BAD13	Equ	0x5b
FAT32DE_BAD14	Equ	0x5c
FAT32DE_BAD15	Equ	0x5d
FAT32DE_BAD16	Equ	0x7c

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT Date and Time formats
;

; Date format
;
; Bit  0 -  4 : Day of month, valid value range 1-31
; Bit  5 -  8 : Month of year, 1=January, valid value range 1-12
; Bit  9 - 15 : Count of years from 1980, valid range 0-127 (1980-2107)
;
;
; Time format
;
; Bit  0 -  4 : 2-second count, valid value range 0-29 (0-58 seconds)
; Bit  5 - 10 : Minutes, valid value range 0-59
; Bit 11 - 15 : Hours, valid value range 0-23
;
; Valid time range is from midnight 00:00:00 to 23:59:58
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FAT-32 Long File Name (LFN) Entry Format
;

	Struc	FAT32LFN
.Sequence	ResB	1
.Name1	ResB	10
.Attr	ResB	1
.Reserved	ResB	1
.Checksum	ResB	1
.Name2	ResB	12
.Cluster	ResW	1
.Name3	ResB	4
.SIZE	EndStruc


FAT32LFN_MAXNAME	Equ	251
FAT32LFN_MAXPATH	Equ	260

FAT32LFN_TAGATTR	Equ	0x0f
FAT32LFN_TAGMASK	Equ	0x0f

FAT32LFN_SEQDEL	Equ	0x80
FAT32LFN_SEQLAST	Equ	0x40
FAT32LFN_SEQMASK	Equ	0x3f


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
