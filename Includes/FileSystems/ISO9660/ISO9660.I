%ifndef Includes_FileSystems_ISO9660_ISO9660_I
%define Includes_FileSystems_ISO9660_ISO9660_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     ISO9660.I V1.0.0
;
;     ISO 9660 / High Sierra filesystem includes.
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc ISO9660Root
.VDType	ResB	1	; Must be 1 for primary volume descriptor
.VSStdID	ResB	5	; Must be "CD001"
.VSStdVersion	ResB	1	; Must be 1
.volumeFlags	ResB	1	; 0 in primary volume descriptor
.systemIdentifier	ResB	32	; What system this CD-ROM is meant for
.volumeIdentifier	ResB	32	; The volume name
.Reserved	ResB	8	; Must be 0's
.lsbVolumeSpace	ResD	1	; Volume size, least-significant-byte order
.msbVolumeSpace	ResD	1	; Volume size, most-significant-byte order
.escapeSequences	ResB	32	; 0's in primary volume descriptor
.lsbVolumeSetSize	ResW	1	; Number of volumes in volume set (must be 1)
.msbVolumeSetSize	ResW	1
.lsbVolumeSetSeqN	ResW	1	; Which volume in volume set (not used)
.msbVolumeSetSeqN	ResW	1
.lsbLogicalBlkSz	ResW	1	; We'll assume 2048 for block size
.msbLogicalBlkSz	ResW	1
.lsbPathTableSize	ResD	1	; How many bytes in path table
.msbPathTableSize	ResD	1
.lsbPathTable1	ResD	1	; Mandatory occurrence
.lsbPathTable2	ResD	1	; Optional occurrence
.msbPathTable1	ResD	1	; Mandatory occurrence
.msbPathTable2	ResD	1	; Optional occurrence
.rootDirRecord	ResB	34	; Duplicate root directory entry
.volumeSetIdent	ResB	128	; Various copyright and control fields follow
.publisherIdent	ResB	128
.dataPreparerId	ResB	128
.applicationId	ResB	128
.copyrightFileId	ResB	37
.abstractFileId	ResB	37
.bibliograpFileId	ResB	37
.volumeCreation	ResB	17
.volumeModif	ResB	17
.volumeExpiration	ResB	17
.volumeEffective	ResB	17
.FileStrucStdVer	ResB	1
.Reserved4	ResB	1	; Must be 0
.ApplicationUse	ResB	512
.FutureStandard	ResB	653
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc ISO9660PathTable
.len_di	ResB	1	; Length of directory identifier
.XARlength	ResB	1	; Extended attribute record length
.dirLocation	ResD	1	; First logical block where directory is stored
.parentDN	ResW	1	; Parent directory number
.dirIDArray	ResB	8	; Directory identifier
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc ISO9660DirRecordExtension
.signature	ResB	2	; $41 $41 - 'AA' famous value
.extensionLength	ResB	1	; $0E for this ID
.systemUseID	ResB	1	; 02 = HFS
.fileType	ResB	4	; Such as 'TEXT' or 'STAK'
.fileCreator	ResB	4	; Such as 'hscd' or 'WILD'
.finderFlags	ResB	2
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc ISO9660DirRecord
.len_dr	ResB	1	; Directory record length
.XARlength	ResB	1	; Extended attribute record length
.lsbStart	ResD	1	; First logical block where file starts
.msbStart	ResD	1
.lsbDataLength	ResD	1	; Number of bytes in file
.msbDataLength	ResD	1
.year	ResB	1	; Since 1900
.month	ResB	1
.day	ResB	1
.hour	ResB	1
.minute	ResB	1
.second	ResB	1
.gmtOffset	ResB	1	; 15-minute offset from Universal Time
.fileFlags	ResB	1	; Attributes of a file or directory
.interleaveSize	ResB	1	; Used for interleaved files
.interleaveSkip	ResB	1	; Used for interleaved files
.lsbVolSetSeqNum	ResW	1	; Which volume in volume set contains this file
.msbVolSetSeqNum	ResW	1
.len_fi	ResB	1	; Length of file identifier that follows
.fi	ResB	37	; File identifier: actual is len_fi. Contains extra blank byte if len_fi odd
.AppleExtension	ResB	ISO9660DirRecordExtension.SIZE
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
             