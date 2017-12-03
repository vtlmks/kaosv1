%ifndef Includes_Fs_Ext2_INode_I
%define Includes_Fs_Ext2_INode_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     INode.I V1.0.0
;
;     EXT2 FS (Second Extended Filesystem) includes.
;

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

EXT2_NDIR_BLOCKS	Equ	12
EXT2_IND_BLOCK	Equ	EXT2_NDIR_BLOCKS
EXT2_DIND_BLOCK	Equ	EXT2_IND_BLOCK+1
EXT2_TIND_BLOCK	Equ	EXT2_DIND_BLOCK+1
EXT2_N_BLOCKS	Equ	EXT2_TIND_BLOCK+1


	Struc Ext2_INode
i_Mode	ResW	1	; File mode
i_UID	ResW	1	; Owner UID
i_Size	ResD	1	; Size in bytes
i_ATime	ResD	1	; Access time
i_CTime	ResD	1	; Creation time
i_MTime	ResD	1	; Modification time
i_DTime	ResD	1	; Deletion time
i_GID	ResW	1	; Group Id
i_LinksCnt	ResW	1	; Links count
i_Blocks	ResD	1	; Blocks count
i_Flags	ResD	1	; File flags
	ResD	1	; *RESERVED*
i_Block	ResD	EXT2_N_BLOCKS	; Pointers to blocks
i_Version	ResD	1	; File version (for NFS)
i_FileACL	ResD	1	; File ACL
i_DirACL	ResD	1	; Dir ACL
i_FAddr	ResD	1	; Fragment address
i_Frag	ResB	1	; Fragment number
i_FSize	ResB	1	; Fragment size
	ResW	1	; *PAD*
	ResD	2	; *RESERVED*
Ext2_INodeSize	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
