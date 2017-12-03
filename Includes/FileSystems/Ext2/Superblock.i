%ifndef Includes_Fs_Ext2_SuperBlock_I
%define Includes_Fs_Ext2_SuperBlock_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     SuperBlock.I V1.0.0
;
;     EXT2 FS (Second Extended Filesystem) includes.
;

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

;
; Note: The superblock is always located at the partition
; startsector + 2 (offset 1024), 
;


	Struc Ext2_SBlk ; EXT2 FS Superblock structure
sb_INodesCnt	ResD	1	; Inodes count
sb_BlkCnt	ResD	1	; Blocks count
sb_RBlkCnt	ResD	1	; Reserved blocks count
sb_FBlkCnt	ResD	1	; Free blocks count
sb_FINodesCnt	ResD	1	; Free inodes count
sb_FirstDBlk	ResD	1	; First data block
sb_LBlkSize	ResD	1	; Block size
sb_LFragSize	ResD	1	; Fragment size
sb_BlkPerGrp	ResD	1	; Blocks per group
sb_FrgPerGrp	ResD	1	; Fragments per group
sb_INdPerGrp	ResD	1	; Inodes per group
sb_MTime	ResD	1	; Mount time
sb_WTime	ResD	1	; Write time
sb_MntCnt	ResW	1	; Mount count
sb_MaxMntCnt	ResW	1	; Maximal mount count
sb_Magic	ResW	1	; Magic signature
sb_State	ResW	1	; File system state
sb_Errors	ResW	1	; Behaviour when detecting errors
sb_MinRev	ResW	1	; Minor revision level
sb_LastCheck	ResD	1	; Time of last check
sb_CheckIntv	ResD	1	; Max. time between checks
sb_CreatorOS	ResD	1	; OS
sb_RevLevel	ResD	1	; Revision level
sb_DefResUID	ResW	1	; Default UID for reserved blocks
sb_DefResGID	ResW	1	; Default GID for reserved blocks
	;
sb_FirstINd	ResD	1	; First non-reserved inode
sb_INodeSize	ResW	1	; Size of inode structure
sb_BlkGrpNr	ResW	1	; Block group # of this superblock
sb_FtCompat	ResD	1	; Compatible feature set
sb_FtInCompat	ResD	1	; Incompatible feature set
sb_FtRoCompat	ResD	1	; Readonly-compatible feature set
sb_UUID	ResB	16	; 128-bit UUID for volume
sb_VolName	ResB	16	; Volume name
sb_LastMnted	ResB	64	; Directory where last mounted
sb_AlgBitmap	ResD	1	; For compression
	;
sb_PreAlBlks	ResB	1	; Nr of blocks to try to preallocate
sb_PreAlDBlks	ResB	1	; Nr to preallocate for dirs
	ResW	1	; *padding*
	ResD	204	; *reserved*
Ext2_SblkSize	EndStruc
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
