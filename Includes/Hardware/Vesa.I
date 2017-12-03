%ifndef Includes_Hardware_VESA_I
%define Includes_Hardware_VESA_I





VESA_VBEInfo	Equ	0x4f00	; Return VBE infoblock
VESA_ModeInfo	Equ	0x4f01	; Return VBE modeinfo
VESA_SetMode	Equ	0x4f02	; Set displaymode, see below for screenmode numbers
VESA_ReturnMode	Equ	0x4f03	; Return current VBE mode
VESA_State	Equ	0x4f04	; Save/Restore state
VESA_WindowCtrl	Equ	0x4f05	; Display window control
VESA_ScanLength	Equ	0x4f06	; Set/get logical scan line length
VESA_DisplayStart	Equ	0x4f07	; Set/get display start
VESA_DACPalette	Equ	0x4f08	; Set/get DAC palette format
VESA_PaletteData	Equ	0x4f09	; Set/get palette data
VESA_ReturnPMI	Equ	0x4f0a	; Return VBE protectedmode interface
VESA_PixelClock	Equ	0x4f0b	; Set/get pixel clock




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc VBEInfoB ; VBE Infoblock returned by VESA_VBEInfo function (0x4f00)
VBE_Signature	ResB	4	; VESA identifier, should contain "VESA"
VBE_Version	ResW	1	; Version number, i.e. 0x0200 for VESA v2.0
VBE_OEMStrPtr	ResD	1	; OEM string pointer
VBE_Capabil	ResB	4	; Capabilities
VBE_VideoMPtr	ResD	1	; Videomem pointer
VBE_TotalMem	ResW	1	; Totalmemory in 64kb chunks
VBE_OEMSoftRv	ResW	1	; OEM software revision
VBE_OEMVendNP	ResD	1	; OEM vendor name pointer
VBE_OEMProdNP	ResD	1	; OEM product name pointer
VBE_OEMProdRP	ResD	1	; OEM product revision pointer
	ResB	222	; *RESERVED*
VBE_OEMData	ResB	256	; OEM data
VBEInfoB_Size	EndStruc

;
; VESA screenmode numbers
;

; 0x108	- Textmode 80x60
; 0x109	- Textmode 132x25
; 0x10a	- Textmode 132x43
; 0x10b	- Textmode 132x50
; 0x10c	- Textmode 132x60
;
; 0x100	- 640x400, 8 bit
; 0x101	- 640x480, 8 bit
; 0x102	- 800x600, 4 bit
; 0x103	- 800x600, 8 bit
; 0x104	- 1024x768, 4 bit
; 0x105	- 1024x768, 8 bit
; 0x106	- 1280x1024, 4 bit
; 0x107	- 1280x1024, 8 bit
; 0x10d	- 320x200, 15 bit
; 0x10e	- 320x200, 16 bit
; 0x10f	- 320x200, 24 bit
; 0x110	- 640x480, 15 bit
; 0x111	- 640x480, 16 bit
; 0x112	- 640x480, 24 bit
; 0x113	- 800x600, 15 bit
; 0x114	- 800x600, 16 bit
; 0x115	- 800x600, 24 bit
; 0x116	- 1024x768, 15 bit
; 0x117	- 1024x768, 16 bit
; 0x118	- 1024x768, 24 bit
; 0x119	- 1280x1024, 15 bit
; 0x11a	- 1280x1024, 16 bit
; 0x11b	- 1280x1024, 24 bit
; 0x81ff	- Special mode

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc VBEModeB ; VBE Modeinfoblock, returned by VESA_ModeInfo function (0x4f01)
MD_Attribs	ResW	1	; Mode attributes
MD_WinAAttrib	ResB	1	; WinA attributes
MD_WinBAttrib	ResB	1	; WinB attributes
MD_Granul	ResW	1	; Win granularity
MD_Size	ResW	1	; Win size
MD_WinASeg	ResW	1	; WinA segment
MD_WinBSeg	ResW	1	; WinB segment
MD_WinFuncPtr	ResD	1	; WinFunc pointer
MD_BytesPSL	ResW	1	; Bytes Per Scan Line (BPSL)
	; 1.2+ below
MD_XRes	ResW	1	; X resolution
MD_YRes	ResW	1	; Y resolution
MD_XCharSize	ResB	1	; X char size
MD_YCharSize	ResB	1	; Y char size
MD_NumPlanes	ResB	1	; Number of planes
MD_BitsPPixel	ResB	1	; Bits per pixel
MD_NumBanks	ResB	1	; Number of banks
MD_MemModel	ResB	1	; Memory model
MD_BankSize	ResB	1	; Banksize
MD_NumIPages	ResB	1	; Number of image pages
	ResB	1	; *RESERVED*
MD_RedMSize	ResB	1	; Red mask size
MD_RedFPos	ResB	1	; Red field position
MD_GreenMSize	ResB	1	; Green mask size
MD_GreenFPos	ResB	1	; Green field position
MD_BlueMSize	ResB	1	; Blue mask size
MD_BlueFPos	ResB	1	; Blue field position
MD_RsvdMSize	ResB	1	; Reserved mask size
MD_RsvdFPos	ResB	1	; Reserved field position
MD_DCModeInfo	ResB	1	; DirectColor mode info
	; 2.0+ below
MD_PhyBasePtr	ResD	1	; Physical VRAM basepointer
MD_OScMemOff	ResD	1	; Offscreen memory offset
MD_OScMemSize	ResD	1	; Offscreen memory size
	ResB	206	; *RESERVED*
VBEModeB_Size	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc CRTCInfo
CRTC_HTotal	ResW	1	; Horizontal total in pixels
CRTC_HSyncBeg	ResW	1	; Horizontal sync start in pixels
CRTC_HSyncEnd	ResW	1	; Horizontal sync end in pixels
CRTC_VTotal	ResW	1	; Vertical total in lines
CRTC_VSyncBeg	ResW	1	; Vertical sync start in pixels
CRTC_VSyncEnd	ResW	1	; Vertical sync end in pixels
CRTC_Flags	ResB	1	; Flags (Interlaced, Doublescan etc.)
CRTC_PixelClk	ResD	1	; Pixel clock in units of Hz
CRTC_Refresh	ResW	1	; Refresh rate in units of 0.01 Hz
CRTC_RESERVED	ResB	40	; *RESERVED*
CRTCInfo_Size	EndStruc




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
