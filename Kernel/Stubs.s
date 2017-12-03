;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Stubs.s V1.0.0
;
;     This file contains various kernel source stubs, that are
;     needed at several places until we have real library support.
;
;
;
;
; Hex2AscII	- Hex2AscII conversion
; AscII2Hex	- AscII2Hex conversion
; ClearScreen	- Clears the textmode screen


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Hex2AscII()
;
; Input  : eax = Longword to be converted
;          edi = Pointer to 8 byte buffer for result
;
; Output : Buffer contains converted string
;
Hex2AscII	Cld
	Pushad
	Mov	ecx,8
.L	Rol	eax,4
	Push	eax
	And	al,0x0f
	Cmp	al,0x0a
	Sbb	al,0x69
	Das
	Mov	ah,7
	Stosb
	Pop	eax
	Dec	ecx
	Jnz	.L
	Popad
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; AscII2Hex()
;
; Input  : eax = Ascii String
;
; Output : eax = Converted Hex value
;
AscII2Hex	XOr	ecx,ecx
	XOr	ebx,ebx
.Loop	Mov byte	bl,[eax]
	Test	bl,bl
	Jz	.Exit
	Sub	bl,0x30
	Cmp	bl,10
	Jle	.L
	Sub	bl,0x27
.L	Shl	ecx,4
	Inc	eax
	Add	ecx,ebx
	Jmp	.Loop
.Exit	Mov	eax,ecx
	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Clear the text screen.

ClearScreen	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Mov	ecx,(1024*768)/4
	XOR	eax,eax
	Rep Stosd
	Mov dword	[DebugXPos],0
	Mov dword	[DebugYPos],3
	Ret
