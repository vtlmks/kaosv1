
	Bits 16
	Org	0x7000
	Section	.text


;   V86Task	= 0x7200, IObitmap @ 0x7268
;   V86Stack	= 0x9268

	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Hardware\Keyboard.I"
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
V86System	Pop	eax
	Mov	al,0x10	; Int#
	Mov	[cs:.Int],al
	PopAD
	Add	esp,2		; flags
	Pop	es
	Pop	ds
	Pop	fs
	Pop	gs
	Db	0xcd
.Int	Db	0
	Push	gs
	Push	fs
	Push	ds
	Push	es
	PushF
	PushAD
	Sub	esp,4		; skip int num



	Jmp	$

	Int 	0xfd		; pseudo int, detected by exception handler

	Times 512-($-$$) Db 0

v86task	Times 104	Db 0	; Task structure
	Times 0x2000	Db 0	; IO bitmap

	Times 1024 Db	0
v86stack:




