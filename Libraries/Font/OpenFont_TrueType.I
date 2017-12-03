;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;


; edi contains FS structure



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OpenTTF	Call	ConvertChunks
	Ret





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertChunks	Call	ConvertTableDir
	Call	ConvertTable
	Call	ConvertMaxp
	Call	ConvertHead
	Call	ConvertLoca
	Call	ConvertPost
	Call	ConvertGlyf

	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	;eax=chunkname (4 bytes)

FindChunk	Mov	esi,[edi+FS_FontData]
	Lea	esi,[esi+tabledir.SIZE]
.L	Cmp	[esi+table.tag],eax
	Je	.Found

	Lea	esi,[esi+table.SIZE]
	Jmp	.L
	;
.Found	Mov	esi,[esi+table.offset]
	Add	esi,[edi+FS_FontData]	; return pointer to chunk
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertTableDir	PRINTTXT	TableDirTxt
	Mov	esi,[edi+FS_FontData]
	SWAPLONG	[esi+tabledir.sfntversion]
	SWAPWORD	[esi+tabledir.numTables]
	SWAPWORD	[esi+tabledir.searchRange]
	SWAPWORD	[esi+tabledir.entrySelector]
	SWAPWORD	[esi+tabledir.rangeShift]
	Ret

TableDirTxt	Db	"* Converting tabledir",0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertTable	PRINTTXT	TableTxt
	Mov	esi,[edi+FS_FontData]
	Movzx	ecx,word [esi+tabledir.numTables]
	Lea	esi,[esi+tabledir.SIZE]
.L	SWAPLONG	[esi+table.checkSum]
	SWAPLONG	[esi+table.offset]
	SWAPLONG	[esi+table.length]
	Lea	esi,[esi+table.SIZE]
	Dec	ecx
	Jnz	.L
	Ret

TableTxt	Db	"* Converting table",0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertMaxp	PRINTTXT	MaxpTxt
	Mov	eax,"maxp"
	Call	FindChunk
	;
	SWAPLONG	[esi+maxp.Tableversionnumber]
	SWAPWORD	[esi+maxp.numGlyphs]
	SWAPWORD	[esi+maxp.maxPoints]
	SWAPWORD	[esi+maxp.maxContours]
	SWAPWORD	[esi+maxp.maxCompositePoints]
	SWAPWORD	[esi+maxp.maxCompositeContours]
	SWAPWORD	[esi+maxp.maxZones]
	SWAPWORD	[esi+maxp.maxTwilightPoints]
	SWAPWORD	[esi+maxp.maxStorage]
	SWAPWORD	[esi+maxp.maxFunctionDefs]
	SWAPWORD	[esi+maxp.maxInstructionDefs]
	SWAPWORD	[esi+maxp.maxStackElements]
	SWAPWORD	[esi+maxp.maxSizeOfInstructions]
	SWAPWORD	[esi+maxp.maxComponentElements]
	SWAPWORD	[esi+maxp.maxComponentDepth]
	Ret

MaxpTxt	Db	"* Converting maxp",0xa,0

MaxpAt	Db	"* Maxp table @ ",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertHead	PRINTTXT	HeadTxt
	Mov	eax,"head"
	Call	FindChunk
	;
	SWAPLONG	[esi+head.Tableversionnumber]
	SWAPLONG	[esi+head.fontRevision]
	SWAPLONG	[esi+head.checkSumAdjustment]
	SWAPLONG	[esi+head.magicNumber]
	SWAPWORD	[esi+head.flags]
	SWAPWORD	[esi+head.unitsPerEm]
	SWAPLONG	[esi+head.created]
	SWAPLONG	[esi+head.modified]
	SWAPWORD	[esi+head.xMin]
	SWAPWORD	[esi+head.yMin]
	SWAPWORD	[esi+head.xMax]
	SWAPWORD	[esi+head.yMax]
	SWAPWORD	[esi+head.macStyle]
	SWAPWORD	[esi+head.lowestRecPPEM]
	SWAPWORD	[esi+head.fontDirectionHint]
	SWAPWORD	[esi+head.indexToLocFormat]
	SWAPWORD	[esi+head.glyphDataFormat]
	Ret

HeadTxt	Db	"* Converting head",0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertLoca	PRINTTXT	LocaTxt
	Mov	eax,"maxp"
	Call	FindChunk
	Movzx	ecx,word [esi+maxp.numGlyphs]
	Mov	eax,"head"
	Call	FindChunk
	Movzx	ebx,word [esi+head.indexToLocFormat]
	Mov	eax,"loca"
	Call	FindChunk
	Test	ebx,ebx
	Jz	.Short
	;
.Long	SWAPLONG	[esi]
	Lea	esi,[esi+4]
	Dec	ecx
	Jnz	.Long
	Ret
	;
.Short	SWAPWORD	[esi]
	Lea	esi,[esi+2]
	Dec	ecx
	Jnz	.Short
	Ret

LocaTxt	Db	"* Converting loca",0xa,0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertPost	PRINTTXT	PostTxt
	Mov	eax,"post"
	Call	FindChunk
	;
	SWAPLONG	[esi+post.Formattype]
	SWAPLONG	[esi+post.italicAngle]
	SWAPWORD	[esi+post.underlinePosition]
	SWAPWORD	[esi+post.underlineThickness]
	SWAPLONG	[esi+post.isFixedPitch]
	SWAPLONG	[esi+post.minMemType42]
	SWAPLONG	[esi+post.maxMemType42]
	SWAPLONG	[esi+post.minMemType1]
	SWAPLONG	[esi+post.maxMemType1]
	;
	Cmp dword	[esi+post.Formattype],0x00020000	; Convert 2.0 post's
	Je	.Convert
	Ret

.Convert	Lea	esi,[esi+post.SIZE]
	Movzx	ecx,word [esi]		; Number of glyphs in post
	SWAPWORD	cx
.L	Lea	esi,[esi+2]
	SWAPWORD	[esi]
	Dec	ecx
	Jnz	.L
	Ret

PostTxt	Db	"* Converting post",0xa,0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ConvertGlyf	PRINTTXT	GlyfTxt

	Mov	eax,"glyf"
	Call	FindChunk
	;

	;----
	PRINTTXT	GlyfAt
	Mov	eax,esi
	Int	0xfe
	;----


	SWAPWORD	[esi+glyf.numberOfContours]
	SWAPWORD	[esi+glyf.xMin]
	SWAPWORD	[esi+glyf.yMin]
	SWAPWORD	[esi+glyf.xMax]
	SWAPWORD	[esi+glyf.yMax]
	;
	Lea	esi,[esi+glyf.SIZE]
	Movzx	ecx,word [esi+glyf.numberOfContours]
.L	SWAPWORD	[esi]
	Lea	esi,[esi+2]
	Dec	ecx
	Jnz	.L
	;
	Movzx	edx,word [esi-2]	; Number of flags-1
	Inc	edx
	;
	SWAPWORD	[esi]	; Number of instructions
	Movzx	eax,word [esi]
	Lea	esi,[esi+eax]	; Skip instructions
	Mov	ebx,esi	; ebx=start of flags
	Lea	esi,[esi+edx]	; esi=start of x/y array
	XOr	ecx,ecx
	Shr	edx,1
	;

	;----
	PRINTTXT	GlyfArray
	Mov	eax,esi
	Int	0xfe
	;----


	;---------


.LoopX	Bt dword	[ebx+ecx],SGDB_X_SHORT
	Jnc	.XShort
	Bt dword	[ebx+ecx],SGDB_X_SAME
	Jc	.NextX
	SWAPWORD	[esi]
	Inc	esi
.XShort	Inc	esi
.NextX	Inc	ecx
	Cmp	ecx,edx
	Jne	.LoopX

	;--
	XOr	ecx,ecx
.LoopY	Bt dword	[ebx+ecx],SGDB_Y_SHORT
	Jnc	.YShort
	Bt dword	[ebx+ecx],SGDB_Y_SAME
	Jc	.NextY
	SWAPWORD	[esi]
	Inc	esi
.YShort	Inc	esi
.NextY	Inc	ecx
	Cmp	ecx,edx
	Jne	.LoopY
	Ret


GlyfTxt	Db	"* Converting glyf",0xa,0
GlyfAt	Db	"Glyf starts @",0
GlyfArray	Db	"Glyf values @",0



