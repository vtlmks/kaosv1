
;
; This is a preliminary include file, the structures should be renamed, just used some
; name to avoid duplicates at first....  Will shorten them later....
;
; Some names are not set yet either... we need to figure out some good names and prefixes for them...
;
; This is no fun shit... I want to puke on it actually...
;

	Struc TTF_TableDirectory
.sfntVersion	ResD	1	; 0x00010000 for version 1.0
.numTables	ResW	1	; Number of tables
.searchRange	ResW	1	; (Maximum power of 2<= numTables)*16
.entrySelector	ResW	1	; Log2(maximum power of 2<= numTables)
.rangeShift	ResW	1	; NumTables *  16 - searchRange
.size	Endstruc

	Struc TTF_TableDirectoryEntries
.tag	ResD	1	; 4-byte identifier
.checkSum	ResD	1	; CheckSum for this table.
.offset	ResD	1	; Offset from beginning of TrueType font file.
.length	ResD	1	; Length of this table.
.size	EndStruc

; Required tables
CMAP	Db	"cmap"	; Character to glyphg mapping
GLYF	Db	"glyf"	; Glyph data
HEAD	Db	"head"	; Font header
HHEA	Db	"hhea"	; Horizontal headers
HMTX	Db	"hmtx"	; Horizontal metrics
LOCA	Db	"loca"	; Index to location
MAXP	Db	"maxp"	; Maximum profile
NAME	Db	"name"	; Naming table
POST	Db	"post"	; PostScript information
OS2	Db	"OS/2"	; OS/2 and Windows specific metrics

; Optional tables
CVT	Db	"cvt "	; Control Value Table
EBDT	Db	"EBDT"	; Embedded bitmap data
EBLC	Db	"EBLC"	; Embedded bitmap location data
EBSC	Db	"EBSC"	; Embedded bitmap scaling data
FPGM	Db	"fpgm"	; Font program
GASP	Db	"gasp"	; Grid-fitted and scan conversion procedure (grayscale)
HDMX	Db	"hdmx"	; Horizontal device metrics
KERN	Db	"kern"	; kerning
LTSH	Db	"LTSH"	; Linear treshold table
PREP	Db	"prep"	; CVT program
PCLT	Db	"PCLT"	; PCL5
VDMX	Db	"VDMX"	; Vertical Device Metrics table
VHEA	Db	"vhea"	; Vertical Metrics Header
VMTX	Db	"vmtx"	; Vertical Metrics




