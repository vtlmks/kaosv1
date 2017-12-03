%ifndef Includes_Dos_Dos_I
%define Includes_Dos_Dos_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Dos.I V1.0.0
;
;     Dos.library includes.
;
;     This file mainly contains internal structures that the Dos.library
;     is based on. Most of it is considered internal and private only, hence
;     users should keep their hands off and not read structures and other
;     things directly. Users must use dos.library provided functions and
;     not peek & poke on their own; hands off..


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Datestamp structure

	Struc DateStamp
	;
DS_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; FileInfoBlock


	Struc FileInfoBlock
FIB_TYPE	ResD	1	; Entry type
FIB_FLAGS	ResD	1	; Protection flags etc.
FIB_LENGTH	ResD	1	; Length of file in bytes
FIB_CREATIONDATE	ResB	DS_SIZE	; Creation date
FIB_ACCESSDATE	ResB	DS_SIZE	; Last access date
FIB_MODIFYDATE	ResB	DS_SIZE	; Modify date
FIB_FILENAME	ResB	256+1	; Filename
FIB_SIZE	EndStruc


	BITDEF	FIB,READ,0
	BITDEF	FIB,WRITE,1
	BITDEF	FIB,EXECUTE,2
	BITDEF	FIB,DELETE,3
	BITDEF	FIB,ARCHIVE,4
	BITDEF	FIB,SCRIPT,5
	BITDEF	FIB,PURE,6
	BITDEF	FIB,HIDDEN,7
	BITDEF	FIB,COMPRESSED,8
	BITDEF	FIB,ENCRYPTED,9


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; LN_NAME -> Name of entry
; DE_Data -> Start of a Taglist, look below for Tag information.
;
	Struc DosEntry	; Volume dosentry
DE_NODE	ResB	LN_SIZE
DE_TYPE	ResD	1	; DosEntry type
DE_PORT	ResD	1	; Filesystem handler port
DE_DATA:
DE_SIZE	EndStruc


	Struc DosEntryAssign
DEA_HEAD	ResB	DE_SIZE
DEA_DOSENTRY	ResD	1	; DosEntry pointer
DEA_PATH	ResD	1	; Path remainder pointer
DEA_ADDLIST	ResB	MLH_SIZE	; List of assign-adds
DEA_SIZE	EndStruc



;
; General considerations for doslists:
;
; If DE_TYPE = DLT_VOLUME:
;
;  - DE_DATA will point to a taglist containing DosEntry tagitems.
;  - LN_NAME contains the volumename excluding delimiter, i.e. "System".
;
; If DE_TYPE = DLT_ASSIGN:
;
;  - DE_DATA contains a pointer to a DLT_VOLUME type DosEntry
;  - DE_DATA+4 contains the remains of the path, i.e. "System/Libraries/".
;  - LN_NAME contains the name of the assign, i.e. "Libs:".
;





	;
	; DosEntry types
	;

	ENUMERATE
	EITEM	DLT_VOLUME	; Volume/partition entry
	EITEM	DLT_ASSIGN	; Assign entry (to directory)
	EITEM	DLT_ASSIGNADD	; Assign entry additions


	; DosEntry tagitems
	;

	TAGINIT	0x10000000
	TAGDEF	DL_NAME		; DosEntry name
	TAGDEF	DL_DEVNAME		; Device name, i.e, ide.device
	TAGDEF	DL_HANDLERNAME		; Handler name
	TAGDEF	DL_PARTITIONSTART		; Partition start sector
	TAGDEF	DL_PARTITIONEND		; Partition end sector
	TAGDEF	DL_DEVUNIT		; Device unit
	TAGDEF	DL_FLAGS		; Flags, see below




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Dos FileHandle/FH structure
;

	Struc FileHandle
FH_PORT	ResD	1	; FileHandle messageport
FH_DOSENTRY	ResD	1	; Pointer to the dosentry
FH_MODE	ResD	1	; Open mode
FH_NAME	ResD	1	; Filename
FH_FILESIZE	ResD	1	; Size in bytes of the file
FH_LOCK	ResD	1	; Pointer to lock
FH_PARTITIONNAME	ResB	34	; Partitionname, including colon and null
FH_STARTBLOCK	ResD	1	; First block of the file
FH_CURRENTBLOCK	ResD	1	; Current block of the file
FH_POSITION	ResD	1	; Absolute position in the file
FH_OFFSET	ResD	1	; Offset in the current block
FH_END	ResD	1	;
FH_BUFFER	ResD	1	; Buffer for read/write
FH_SIZE	EndStruc

	;
	; Open modes, these modes are used when opening a file with Open(),
	; the modes are exclusive and should not be or'd together
	;

	BITDEF	OPEN,OLDFILE,0	; Open existing file as read or write
	BITDEF	OPEN,NEWFILE,1	; Open new file, deletes old file if it already exists, read/write
	BITDEF	OPEN,SHARED,2	; Open existing file with shared lock, creates file if it doesn't exist


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Dos lock handle node
;

	Struc LockHandle
	ResB	LN_SIZE
LOCK_MODE	ResD	1	; Lock flags, see below
LOCK_DOSENTRY	ResD	1	; Pointer to dosentry for this lock
LOCK_PATH	ResB	256	; Lock path excluding volume name and volume delimiter
LOCK_SIZE	EndStruc


	;
	; Lock modes, these modes are used when locking a file or directory with Lock(),
	; the modes are exclusive and should not be or'd together.
	;

	BITDEF	LOCK,READ,0	; Lock file or directory as read
	BITDEF	LOCK,WRITE,1	; Lock file or directory as read/write


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Seek modes, these modes are parameters to the Seek() function.
;

OFFSET_CURRENT	Equ	0	; Seek relative to current position
OFFSET_BEGINNING	Equ	1	; Seek relative to beginning of the file
OFFSET_END	Equ	2	; Seek relative to end of the file

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Dos Packet structure
;

	Struc DosPacket
DP_MESSAGE	ResB	MN_SIZE	; Packet message
DP_TYPE	ResD	1	; Packet type, see below for types
DP_FH	ResD	1	; Pointer to FileHandler
DP_RES0	ResD	1	; Result 1
DP_RES1	ResD	1	; Result 2
DP_ARG0	ResD	1	; Argument 1
DP_ARG1	ResD	1	; ..
DP_ARG2	ResD	1
DP_ARG3	ResD	1
DP_ARG4	ResD	1
DP_SIZE	EndStruc


	;
	; Dos Packet types

	ENUMERATE
	EITEM	DOSPKT_DUMMY	; Dummy
	EITEM	DOSPKT_KILL	; Kill FileSystem
	EITEM	DOSPKT_OPEN	; Open(File,Mode)
	EITEM	DOSPKT_CLOSE	; Close(Fh)
	EITEM	DOSPKT_READ	; Read(Fh,Length,Buffer)
	EITEM	DOSPKT_WRITE	; Write(Fh,Length,Buffer)
	EITEM	DOSPKT_RENAME
	EITEM	DOSPKT_DELETE
	EITEM	DOSPKT_SEEK	; Seek(Fh,Position,Mode)
	EITEM	DOSPKT_FORMAT
	EITEM	DOSPKT_LOCK	; Lock(LockPtr)
	EITEM	DOSPKT_UNLOCK	; Unlock(LockPtr)


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
