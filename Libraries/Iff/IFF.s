;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Iff.s V1.0.0
;
;     Iff Library.
;

	%Include	"Libraries\iff\AllocLocalItem.s"
	%Include	"Libraries\iff\CloseIFF.s"
	%Include	"Libraries\iff\CollectionChunk.s"
	%Include	"Libraries\iff\CollectionChunks.s"
	%Include	"Libraries\iff\CurrentChunk.s"
	%Include	"Libraries\iff\EntryHandler.s"
	%Include	"Libraries\iff\ExitHandler.s"
	%Include	"Libraries\iff\FindCollection.s"
	%Include	"Libraries\iff\FindLocalItem.s"
	%Include	"Libraries\iff\FindProp.s"
	%Include	"Libraries\iff\FindPropContext.s"
	%Include	"Libraries\iff\FreeIFF.s"
	%Include	"Libraries\iff\FreeLocalItem.s"
	%Include	"Libraries\iff\GoodID.s"
	%Include	"Libraries\iff\GoodType.s"
	%Include	"Libraries\iff\IDToStr.s"
	%Include	"Libraries\iff\InitIFF.s"
	%Include	"Libraries\iff\InitIFFasClip.s"
	%Include	"Libraries\iff\InitIFFasDOS.s"
	%Include	"Libraries\iff\LocalItemData.s"
	%Include	"Libraries\iff\OpenIFF.s"
	%Include	"Libraries\iff\ParentChunk.s"
	%Include	"Libraries\iff\ParseIFF.s"
	%Include	"Libraries\iff\PopChunk.s"
	%Include	"Libraries\iff\PropChunk.s"
	%Include	"Libraries\iff\PropChunks.s"
	%Include	"Libraries\iff\PushChunk.s"
	%Include	"Libraries\iff\ReadChunkBytes.s"
	%Include	"Libraries\iff\ReadChunkRecords.s"
	%Include	"Libraries\iff\SetLocalItemPurge.s"
	%Include	"Libraries\iff\StopChunk.s"
	%Include	"Libraries\iff\StopChunks.s"
	%Include	"Libraries\iff\StopOnExit.s"
	%Include	"Libraries\iff\StoreItemInContext.s"
	%Include	"Libraries\iff\StoreLocalItem.s"
	%Include	"Libraries\iff\WriteChunkBytes.s"
	%Include	"Libraries\iff\WriteChunkRecords.s"

	LIBINIT
	LIBDEF	LVOAllocIFF
	LIBDEF	LVOAllocLocalItem
	LIBDEF	LVOCloseIFF
	LIBDEF	LVOCollectionChunk
	LIBDEF	LVOCollectionChunks
	LIBDEF	LVOCurrentChunk
	LIBDEF	LVOEntryHandler
	LIBDEF	LVOExitHandler
	LIBDEF	LVOFindCollection
	LIBDEF	LVOFindLocalItem
	LIBDEF	LVOFindProp
	LIBDEF	LVOFindPropContext
	LIBDEF	LVOFreeIFF
	LIBDEF	LVOFreeLocalItem
	LIBDEF	LVOGoodID
	LIBDEF	LVOGoodType
	LIBDEF	LVOIDToStr
	LIBDEF	LVOInitIFF
	LIBDEF	LVOInitIFFasClip
	LIBDEF	LVOInitIFFasDOS
	LIBDEF	LVOLocalItemData
	LIBDEF	LVOOpenIFF
	LIBDEF	LVOParentChunk
	LIBDEF	LVOParseIFF
	LIBDEF	LVOPopChunk
	LIBDEF	LVOPropChunk
	LIBDEF	LVOPropChunks
	LIBDEF	LVOPushChunk
	LIBDEF	LVOReadChunkBytes
	LIBDEF	LVOReadChunkRecords
	LIBDEF	LVOSetLocalItemPurge
	LIBDEF	LVOStopChunk
	LIBDEF	LVOStopChunks
	LIBDEF	LVOStopOnExit
	LIBDEF	LVOStoreItemInContext
	LIBDEF	LVOStoreLocalItem
	LIBDEF	LVOWriteChunkBytes
	LIBDEF	LVOWriteChunkRecords

LIBIFF_OpenCount	Dd	1

OpenIFF	Mov	eax,IFFLibrary
	Ret

CloseIFF
ExpungeIFF	Mov	eax,-1
	Ret

NullIFF	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IFFLVOTable	Jmp	OpenIFF		;   0
	Jmp	CloseIFF		;   5
	Jmp	ExpungeIFF		;  10
	Jmp	NullIFF		;  15
	Jmp	NullIFF		;  20
	Jmp	NullIFF		;  25
	;-
	Jmp	IFF_AllocIFF		;  30
	Jmp	IFF_AllocLocalItem		;  35
	Jmp	IFF_CloseIFF		;  40
	Jmp	IFF_CollectionChunk		;  45
	Jmp	IFF_CollectionChunks		;  50
	Jmp	IFF_CurrentChunk		;  55
	Jmp	IFF_EntryHandler		;  60
	Jmp	IFF_ExitHandler		;  65
	Jmp	IFF_FindCollection		;  70
	Jmp	IFF_FindLocalItem		;  75
	Jmp	IFF_FindProp		;  80
	Jmp	IFF_FindPropContext		;  85
	Jmp	IFF_FreeIFF		;  90
	Jmp	IFF_FreeLocalItem		;  95
	Jmp	IFF_GoodID		; 100
	Jmp	IFF_GoodType		; 105
	Jmp	IFF_IDToStr		; 110
	Jmp	IFF_InitIFF		; 115
	Jmp	IFF_InitIFFasClip		; 120
	Jmp	IFF_InitIFFasDOS		; 125
	Jmp	IFF_LocalItemData		; 130
	Jmp	IFF_OpenIFF		; 135
	Jmp	IFF_ParentChunk		; 140
	Jmp	IFF_ParseIFF		; 145
	Jmp	IFF_PopChunk		; 150
	Jmp	IFF_PropChunk		; 155
	Jmp	IFF_PropChunks		; 160
	Jmp	IFF_PushChunk		; 165
	Jmp	IFF_ReadChunkBytes		; 170
	Jmp	IFF_ReadChunkRecords	; 175
	Jmp	IFF_SetLocalItemPurge		; 180
	Jmp	IFF_StopChunk		; 185
	Jmp	IFF_StopChunks		; 190
	Jmp	IFF_StopOnExit		; 195
	Jmp	IFF_StoreItemInContext		; 200
	Jmp	IFF_StoreLocalItem		; 205
	Jmp	IFF_WriteChunkBytes		; 210
	Jmp	IFF_WriteChunkRecords	; 215
