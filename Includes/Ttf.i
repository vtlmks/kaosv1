


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Glyph structures below

	Struc	glyf
.numberOfContours	ResW	1
.xMin	ResW	1
.yMin	ResW	1
.xMax	ResW	1
.yMax	ResW	1
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Simple glyph description
;
; Bit 6 and 7 is reserved, and thus are left out of this structure.
;
 BITDEF	SGD,ON_CURVE,0
 BITDEF	SGD,X_SHORT,1
 BITDEF	SGD,Y_SHORT,2
 BITDEF	SGD,REPEAT,3
 BITDEF	SGD,X_SAME,4
 BITDEF	SGD,Y_SAME,5


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; maxp - Maximum positions
;

	     struc	maxp
.Tableversionnumber    ResD	1	; 0x00010000 for version 1.0
.numGlyphs	     ResW	1	; The number of glyphs in the font.
.maxPoints	     ResW	1	; Maximum points in a non-composite glyph.
.maxContours	     ResW	1	; Maximum contours in a non composite glyph.
.maxCompositePoints    ResW	1	; Maximum points in a composite glyph.
.maxCompositeContours  ResW	1	; Maximum contours in a composite glyph.
.maxZones	     ResW	1	; 1 if instructions do not use the twilight zone (Z0),
			; or 2 if instructions do use Z0; should be set to 2 in most cases
.maxTwilightPoints     ResW	1	; Maximum points used in Z0.
.maxStorage	     ResW	1	; Number of Storage Area locations.
.maxFunctionDefs	     ResW	1	; Number of FDEFs.
.maxInstructionDefs    ResW	1	; Number of IDEFs.
.maxStackElements	     ResW	1	; Maximum stack depth.
.maxSizeOfInstructions ResW	1	; Maximum byte count for glyph instructions.
.maxComponentElements  ResW	1	; Maximum number of components references at "top level" for any composite glyph.
.maxComponentDepth     ResW	1	; Maximum levels onf recursion; 1 for simple components.
.SIZE	     EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; head - Font header
;

	  Struc	head
.Tableversionnumber ResD	1	; 0x00010000 for version 1.0
.fontRevision	  ResD	1	; Set by font manufacturer
.checkSumAdjustment ResD	1	; To compute: set it to 0, sum the entire font as ULONG, then store 0xB1B0AFBA - sum.
.magicNumber	  ResD	1	; Set to 0x5f0f3cf5
.flags	  ResW	1	; Bit 0 - baseline for font at y=0;
			; Bit 1 - left sidebearing at x=0;
			; Bit 2 - instructions may depend on point size;
			; Bit 3 - force ppem to integer values for all
			; internal scaler math; may use fractional ppem
			; sizes in this bit is clear;
			; Bit 4 - instructions may alter advance width
			; (the advance widths might not scale linearly);
			; NOTE: all other bits must be zero.
.unitsPerEm	  ResW	1	; Valid range is from 16 to 16384
.created	  ResD	2	; International date (8-byte field)
.modified	  ResD	2	; International date (8-byte field)
.xMin	  ResW	1	; For all glyph bounding boxes.
.yMin	  ResW	1	; For all glyph bounding boxes.
.xMax	  ResW	1	; For all glyph bounding boxes.
.yMax	  ResW	1	; For all glyph bounding boxes.
.macStyle	  ResW	1	; Bit 0 bold (if set to 1); Bit 1 italic (if set to 1)
			; Bits 2-15 reserved (set to 0).
.lowestRecPPEM	  ResW	1	; Smallest readable size in pixels.
.fontDirectionHint  ResW	1	;  0 Fully mixed directional glyphs;
			;  1 Only strongly left to right;
			;  2 Like 1 but also contains neutrals;
			; -1 Only strongly right to left;
			; -2 Like -1 but also contains neutrals;
.indexToLocFormat	  ResW	1	; 0 for short offsets, 1 for long.
.glyphDataFormat	  ResW	1	; 0 for current format.
.SIZE	  EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; post - Postscript
;

	  Struc	post
.Formattype	  ResD	1	; 0x00010000 for format 1.0, 0x00020000 for format 2.0, and so on...
.italicAngle	  ResD	1	; Italic angle in counter clockwise degrees from the vertical.
			; Zero for upright text, negative for text that leans to the right (forward).
.underlinePosition  ResW	1	; Suggested values for the underline position
			; (negative values indicate below the baseline).
.underlineThickness ResW	1	; Suggested values for the underline thickness.
.isFixedPitch	  ResD	1	; Set to 0 if the font is propotionally spaced, nonzero
			; if the font is not proportionally spaced (i.e. monospaced).
.minMemType42	  ResD	1	; Minimum memory usage when a TrueType font is downloaded.
.maxMemType42	  ResD	1	; Maximum memory usage when a TrueType font is downloaded.
.minMemType1	  ResD	1	; Minimum memory usage when a TrueType font is downloaded as a Type1 font.
.maxMemType1	  ResD	1	; Maximum memory usage when a TrueType font is downloaded as a Type1 font.
.SIZE	  EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; TableDir - Table Directory
;

	Struc	tabledir
.sfntversion	ResD	1	; 0x00010000 for version 1.0
.numTables	ResW	1	; Number of tables
.searchRange	ResW	1	; (maximum power of 2<=numTables) * 16
.entrySelector	ResW	1	; Log2(maximum power of 2<= numTables)
.rangeShift	ResW	1	; numTables * 16-searchRange
.SIZE	EndStruc

;
; Table - Table with tags..
;

	Struc	table
.tag	ResD	1	; 4-byte identifier
.checkSum	ResD	1	; CheckSum for this table
.offset	ResD	1	; Offset from beginning of TrueType font file
.length	ResD	1	; Length of this table
.SIZE	EndStruc

;
; Name of the possible Tags found in a Truetype font file
;

; Required tables
CMAP	Equ	"cmap"	; Character to glyphg mapping
GLYF	Equ	"glyf"	; Glyph data
HEAD	Equ	"head"	; Font header
HHEA	Equ	"hhea"	; Horizontal headers
HMTX	Equ	"hmtx"	; Horizontal metrics
LOCA	Equ	"loca"	; Index to location
MAXP	Equ	"maxp"	; Maximum profile
NAME	Equ	"name"	; Naming table
POST	Equ	"post"	; PostScript information
OS2	Equ	"OS/2"	; OS/2 and Windows specific metrics

; Optional tables
CVT	Equ	"cvt "	; Control Value Table
EBDT	Equ	"EBDT"	; Embedded bitmap data
EBLC	Equ	"EBLC"	; Embedded bitmap location data
EBSC	Equ	"EBSC"	; Embedded bitmap scaling data
FPGM	Equ	"fpgm"	; Font program
GASP	Equ	"gasp"	; Grid-fitted and scan conversion procedure (grayscale)
HDMX	Equ	"hdmx"	; Horizontal device metrics
KERN	Equ	"kern"	; kerning
LTSH	Equ	"LTSH"	; Linear treshold table
PREP	Equ	"prep"	; CVT program
PCLT	Equ	"PCLT"	; PCL5
VDMX	Equ	"VDMX"	; Vertical Device Metrics table
VHEA	Equ	"vhea"	; Vertical Metrics Header
VMTX	Equ	"vmtx"	; Vertical Metrics

