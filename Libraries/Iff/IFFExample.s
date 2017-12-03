;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; This is just some dummy code that I made to be sure what kind of
; IFF stuff really had to be made to make it work... There are a lot of
; hidden stuff lurcing behind these relatively easy calls.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LoadExe	LIBCALL	AllocIFF,IFFBase
;	LIBCALL	Open,DosBase	; DOSBase <- Do not worry about this one...
	LIBCALL	InitIFFAsDos,IFFBase
	LIBCALL	OpenIFF,IFFBase
.Loop	LIBCALL	ParseIFF,IFFBase
	LIBCALL	CurrentChunk,IFFBase
	LIBCALL	ReadChunkBytes,IFFBase
	Jmp	.Loop
	LIBCALL	CloseIFF,IFFBase
;	LIBCALL	Close,DosBase	; DOSBase <- Do not worry about this one...
	LIBCALL	FreeIFF,IFFBase
	Ret

