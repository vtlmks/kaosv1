;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     MGA.s V1.0.0
;
;     Driver for Matrox Millennium/Mystique/G100/G200/G400/G450 graphiccards.
;
;

	%Include	"Drivers\Graphics\Matrox\MGA_G400.I"
	%Include	"Drivers\Graphics\Matrox\MGA_Gxxx.I"


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	XOr	eax,eax
	Ret

MGAVersion	Equ	1
MGARevision	Equ	0


MGADriverTags	Dd	DT_FLAGS,0
	Dd	DT_VERSION,MGAVersion
	Dd	DT_REVISION,MGARevision
	Dd	DT_TYPE,NT_DRIVER
	Dd	DT_PRIORITY,0
	Dd	DT_NAME,MGADriverN
	Dd	DT_IDSTRING,MGADriverIDN
	Dd	DT_TABLE,MGABase

MGADriverN	Db	"mgagx00.driver",0
MGADriverIDN	Db	"mgagx00.driver 1.0 (2001-12-03)",0

MGAMsgPort	Dd	0
MGAOpenCount	Dd	0
MGABASE1	Dd	0

	Dd	MGA_SetScreenMode		; -44
	Dd	MGA_SetPalette		; -40
	;Dd	MGA_BltBitmap		; -36
	Dd	MGA_RectFill		; -32
	Dd	MGA_DrawLine		; -28
	;-
	Dd	0		; -24
	Dd	0		; -20
	Dd	0		; -16
	Dd	MGAExit		; -12
	Dd	MGAClose		; -8
	Dd	MGAOpen		; -4
MGABase:

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGAInit	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGAOpen	Mov	eax,MGAMemory.SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	ebp,eax

	Inc dword	[MGAOpenCount]

	Mov	eax,GDE_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	Mov dword	[edi+GDE_Base],MGABase
	Mov	[ScreenStruct+SC_Driver],edi	; Fix this..
	Mov dword	[edi+LN_NAME],MGADriverN	; Make new entry in driverlist
	Mov byte	[edi+LN_TYPE],NT_DRIVER
	Lea	eax,[SysBase+SB_GfxDriverList]
	SPINLOCK	eax
	Push	eax
	Mov	ebx,edi
	ADDTAIL
	Pop	eax
	SPINUNLOCK	eax

	Call	MGA_FindCard
	Call	MGA_MapMemory
	Call	MGA_SetMode

	Mov	eax,[ebp+MGAMemory.MGABASE1]
	Mov	[MGABASE1],eax

	Mov	eax,ebp
	LIBCALL	FreeMem,ExecBase

	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGAExit	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGAClose	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; This is the core of the driver
;


	Struc MGAHWParameters
.CRTC0	ResB	1	; Horizontal total
.CRTC1	ResB	1	; Horizontal display enable end
.CRTC2	ResB	1	; Horizontal blanking start
.CRTC3	ResB	1	; Horizontal blanking end
.CRTC4	ResB	1	; Horizontal retrace pulse start
.CRTC5	ResB	1	; Horizontal retrace pulse end
.CRTC6	ResB	1	; Vertical total
.CRTC7	ResB	1	; Overflow
.CRTC8	ResB	1	; Preset row scan
.CRTC9	ResB	1	; Maximum scan line
.CRTCC	ResB	1	; Start address high
.CRTCD	ResB	1	; Start address low
.CRTC10	ResB	1	; Vertical retrace start
.CRTC11	ResB	1	; Vertical retrace end
.CRTC12	ResB	1	; Vertical display enable end
.CRTC13	ResB	1	; Offset
.CRTC14	ResB	1	; Underline location
.CRTC15	ResB	1	; Vertical blank start
.CRTC16	ResB	1	; Vertical blank end
.CRTC17	ResB	1	; CRTC mode control
.CRTC18	ResB	1	; Line compare
	;
.CRTCEXT0	ResB	1	; Address generator extensions
.CRTCEXT1	ResB	1	; Horizontal counter extensions
.CRTCEXT2	ResB	1	; Vertical counter extensions
.CRTCEXT3	ResB	1	; Miscellaneous
.SEQ1	ResB	1	; Clocking mode
.XMULCTRL	ResB	1	; Multiplex control
.XMISCCTRL	ResB	1	; Miscellaneous control
.XZOOMCTRL	ResB	1	; Zoom control
.XPIXPLLM	ResB	1	; PIXPLL M value
.XPIXPLLN	ResB	1	; PIXPLL N value
.XPIXPLLP	ResB	1	; PIXPLL P value
.SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc MGAMemory
.MGABASE1	ResD	1	; MGA Control Aparture Base
.MGAPCIAccess	ResD	1	; PCI Device, Function and Bus or'd and rolled together for easy PCI writing
	;

.XRes	ResD	1	; X-resolution, max 2048, min 512
.XShift	ResD	1	; X-shift
.YRes	ResD	1	; Y-resolution, max 1536, min 350
.YShift	ResD	1	; Y-shift
.BPP	ResD	1	; bitplanes, 8,15,16,24 or 32
	;
.HTotal	ResD	1
.HDispEnd	ResD	1
.HBlkStr	ResD	1
.HBlkEnd	ResD	1
.HSyncStr	ResD	1
.HSyncEnd	ResD	1
	;
.VTotal	ResD	1
.VDispEnd	ResD	1
.VBlkStr	ResD	1
.VBlkEnd	ResD	1
.VSyncStr	ResD	1
.VSyncEnd	ResD	1
.LineComp	ResD	1
.Scale	ResD	1
.Depth	ResD	1
.StartAddFactor	ResD	1
.VGA8Bit	ResD	1
.NormalPixelClock	ResD	1	; Normal pixelclock
.BestPixelClock	ResD	1	; Trimmed pixelclock
.RefreshRate	ResD	1	; Hz
.BestN	ResD	1	; Pxclk temp
.BestM	ResD	1	; Pxclk temp
.BestP	ResD	1	; Pxclk temp
.BestS	ResD	1	; Pxclk temp
.PixN	ResD	1	; Pxclk temp
.PixM	ResD	1	; Pxclk temp
.PixP	ResD	1	; Pxclk temp
.VCO	ResD	1	; Pxclk temp
.ByteDepth	ResD	1
.Offset	ResD	1
.MGAHWParams	ResB	MGAHWParameters.SIZE
.SIZE	EndStruc






;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGA_MapMemory	Mov	eax,[ebp+MGAMemory.MGABASE1]
	Mov	ebx,0x4000
	LIBCALL	MapMemory,ExecBase
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGA_FindCard	Lea	ebx,[SysBase+SB_PCIList]
.L	NEXTNODE	ebx,.NoCards
	Lea	esi,[MatroxCards]
.Search	Lodsd
	Test	eax,eax
	Jz	.L
	;
	Cmp	[ebx+PCI_VendorID],eax
	Je	.FoundMatch
	Lodsd
	Jmp	.Search

.FoundMatch	Lodsd
	Int	0xff
	;
	XOr	eax,eax
	Add	al,[ebx+PCI_Bus]
	Shl	eax,5
	Add	al,[ebx+PCI_Device]
	Shl	eax,3
	Add	al,[ebx+PCI_Function]
	Shl	eax,8
	Mov	[ebp+MGAMemory.MGAPCIAccess],eax
	;
	Mov	eax,[ebx+PCI_SIZE+PCIN_BaseAddress1]
	Mov	[ebp+MGAMemory.MGABASE1],eax
	Ret

.NoCards	Lea	eax,[MtxNoCardTxt]
	Int	0xff
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

MatroxCards	Dd	0x0518102b,Mtx0518N	; MGA-PX2085 Ultima/Atlas GUI Accelerator
	Dd	0x0519102b,Mtx0519N	; MGA-2064W Millenium GUI Accelerator
	Dd	0x051B102b,Mtx051BN	; MGA-21164W Millenium II
	Dd	0x051F102b,Mtx051FN	; MGA2164WA-B Matrox Millenium II AGP
	Dd	0x0520102b,Mtx0520N	; MGA-G200B Millennium/Mystique G200 AGP
	Dd	0x0521102b,Mtx0521N	; MGA-G200 Millennium/Mystique G200 AGP
	Dd	0x0525102b,Mtx0525N	; MGA-G400 Millennium G400 AGP
	Dd	0x0D10102b,Mtx0D10N	; MGA-I Ultima/Impression GUI accelerator
	Dd	0x1000102b,Mtx1000N	; MGA-G100 Productiva G100 Multi-Monitor
	Dd	0x1001102b,Mtx1001N	; MGA-G100 AGP
	Dd	0

Mtx0518N	Db	0xa,"MGA-PX2085 Ultima/Atlas GUI Accelerator",0xa,0
Mtx0519N	Db	0xa,"MGA-2064W Millenium GUI Accelerator",0xa,0
Mtx051BN	Db	0xa,"MGA-21164W Millenium II",0xa,0
Mtx051FN	Db	0xa,"MGA2164WA-B Matrox Millenium II AGP",0xa,0
Mtx0520N	Db	0xa,"MGA-G200B Millennium/Mystique G200 AGP",0xa,0
Mtx0521N	Db	0xa,"MGA-G200 Millennium/Mystique G200 AGP",0xa,0
Mtx0525N	Db	0xa,"MGA-G400 Millennium G400 AGP",0xa,0
Mtx0D10N	Db	0xa,"MGA-I Ultima/Impression GUI accelerator",0xa,0
Mtx1000N	Db	0xa,"MGA-G100 Productiva G100 Multi-Monitor",0xa,0
Mtx1001N	Db	0xa,"MGA-G100 AGP",0xa,0
MtxNoCardTxt	Db	0xa,"No Matrox cards found!",0xa,0

MtxBusTxt	Db	"Matrox-BUS  = ",0
MtxFuncTxt	Db	"Matrox-FUNC = ",0
MtxDevTxt	Db	"Matrox-DEV  = ",0
MtxBaseTxt	Db	"MGABASE1    = ",0
MtxPCIOrdTxt	Db	"MGA PCIAX   = ",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	%Include	"Drivers\Graphics\Matrox\MGA_CRTC.i"
	%Include	"Drivers\Graphics\Matrox\MGA_SetMode.s"

	%Include	"Drivers\Graphics\Matrox\DrawLine.s"
	%Include	"Drivers\Graphics\Matrox\RectFill.s"
	%Include	"Drivers\Graphics\Matrox\BltBitmap.s"
	%Include	"Drivers\Graphics\Matrox\SetPalette.s"
	%Include	"Drivers\Graphics\Matrox\SetScreenMode.s"



