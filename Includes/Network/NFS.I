%ifndef Includes_FileSystems_NFS_NFS_I
%define Includes_FileSystems_NFS_NFS_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     NFS.I V1.0.0
;
;     Network FileSystem (NFS) includes and definitions.
;     Based on the RFC 1094 specification.
;
;     NFS is Copyright © Sun Microsystems, Inc.
;




NFS_MAXDATA	Equ	8192	; Maximum number of bytes of data in a READ or WRITE request
NFS_MAXPATHLEN	Equ	1024	; Maximum number of bytes in a pathname argument
NFS_MAXNAMLEN	Equ	255	; Maximum number of bytes in a file name argument
NFS_COOKIESIZE	Equ	4	; The size in bytes of the opaque "cookie" passed by READDIR
NFS_FHSIZE	Equ	32	; The size in bytes of the opaque file handle



NFSPRC_NULL	Equ	0
NFSPRC_GETATTR	Equ	1
NFSPRC_SETATTR	Equ	2
NFSPRC_ROOT	Equ	3
NFSPRC_LOOKUP	Equ	4
NFSPRC_READLINK	Equ	5
NFSPRC_READ	Equ	6
NFSPRC_WRITECACHE	Equ	7
NFSPRC_WRITE	Equ	8
NFSPRC_CREATE	Equ	9
NFSPRC_REMOVE	Equ	10
NFSPRC_RENAME	Equ	11
NFSPRC_LINK	Equ	12
NFSPRC_SYMLINK	Equ	13
NFSPRC_MKDIR	Equ	14
NFSPRC_RMDIR	Equ	15
NFSPRC_READDIR	Equ	16
NFSPRC_STATFS	Equ	17





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSFileHandler
.INode	ResD	1
.Device	ResD	1
.Handle	ResW	1
.SIZE	EndStruc

	Struc NFSPacketHeader
.Command	ResW	1
.SeqNumber	ResW	1
.SIZE	EndStruc


	Struc NFSPacketReply
	ResB	NFSPacketHeader.SIZE
.Error	ResW	1	; Packet or handle
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSOpen
	ResB	NFSPacketHeader.SIZE
.Parent	ResW	1
.Path	ResB	NFS_MAXPATHLEN
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSClose
	ResB	NFSPacketHeader.SIZE
.Handle	ResW	1
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSCreate
	ResB	NFSPacketHeader.SIZE
.Parent	ResW	1
.Permissions	ResW	1
.Path	ResB	NFS_MAXNAMLEN
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSMkDir
	ResB	NFSPacketHeader.SIZE
.Parent	ResW	1
.Permissions	ResW	1
.Path	ResB	NFS_MAXNAMLEN
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSRmDir
	ResB	NFSPacketHeader.SIZE
.Parent	ResW	1
.Path	ResB	NFS_MAXNAMLEN
.SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSUnlink
	ResB	NFSPacketHeader.SIZE
.Parent	ResW	1
.Path	ResB	NFS_MAXNAMLEN
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSStat
	ResB	NFSPacketHeader.SIZE
.Handle	ResW	1
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSReadLink
	ResB	NFSPacketHeader.SIZE
.Handle	ResW	1
.SIZE	EndStruc


	Struc NFSReadLinkReply
	ResB	NFSPacketHeader.SIZE
.Error	ResW	1
.Buffer	ResB	NFS_MAXDATA
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSRead
	ResB	NFSPacketHeader.SIZE
.Handle	ResW	1
.Position	ResW	1
.Length	ResW	1
.SIZE	EndStruc

	Struc NFSReadReply
	ResB	NFSPacketHeader.SIZE
.Error	ResW	1
.Buffer	ResB	NFS_MAXDATA
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSWrite
	ResB	NFSPacketHeader.SIZE
.Handle	ResW	1
.Position	ResW	1
.Length	ResW	1
.Buffer	ResB	NFS_MAXDATA
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSReadDir
	ResB	NFSPacketHeader.SIZE
.Handle	ResW	1
.Position	ResW	1
.SIZE	EndStruc

	Struc NFSReadDirReply
	ResB	NFSPacketHeader.SIZE
.Error	ResW	1
.Path	ResB	NFS_MAXPATHLEN
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSRename
	ResB	NFSPacketHeader.SIZE
.OldDir	ResW	1
.NewDir	ResW	1
.OldName	ResB	NFS_MAXNAMLEN
.NewName	ResB	NFS_MAXNAMLEN
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc NFSPendingRequest
.Next	ResD	1
.SeqNumber	ResW	1
.ID	ResD	1
.ReplySize	ResW	1
.Reply	ResD	1
.Finished	ResB	1
.SIZE	EndStruc

	Struc NFSINode
.Next	ResD	1
.FirstChild	ResD	1
.Parent	ResD	1
.Name	ResB	NFS_MAXNAMLEN
.INode	ResD	1
.Lock	ResD	1
.ServerHandle	ResW	1
.Valid	ResB	1
.SIZE	EndStruc

	Struc NFSVolume
.ID	ResW	1
.Root	ResD	1
.RxPort	ResW	1
.TxPort	ResW	1
.CurSequence	ResW	1
.ListSema	ResD	1
.FirstPendingReq	ResD	1
.Socket	ResW	1
.SIZE	EndStruc

	Struc NFSDirEntry
.Next	ResD	1	; Pointer to next entry
.Name	ResB	NFS_MAXNAMLEN
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
