%ifndef Includes_Hardware_VGA_I
%define Includes_Hardware_VGA_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     VGA.I V1.0.0
;
;     VGA hardware includes.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

VGAREG_SEQINDEX	Equ	0x3c4	; Sequence Address Register, Index Port
VGAREG_SEQACCESS	Equ	0x3c5	; Sequence Address Register, Access Port

VGASEQ_RESET	Equ	0x0	; Reset register
VGASEQ_CLOCKING	Equ	0x1	; Clocking mode register
VGASEQ_MAPMASK	Equ	0x2	; Map mask register
VGASEQ_CHARMAP	Equ	0x3	; Character map select register
VGASEQ_MEMMODE	Equ	0x4	; Sequencer memory mode register
VGASEQ_HWVERSION	Equ	0xb	; Hardware version register (new definition) (read only)
VGASEQ_VERSELECT	Equ	0xb	; Version selector register (old definition) (write only)
VGASEQ_CONFIGPORT	Equ	0xc	; Configuration port register
VGASEQ_MODECTRL2	Equ	0xd	; Mode control register 2
VGASEQ_MODECTRL1	Equ	0xe	; Mode control register 1
VGASEQ_POWERUP	Equ	0xf	; Power-up mode register 2

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VGAREG_CRT1INDEX	Equ	0x3b4	; CRT controller address register, index port
VGAREG_CRT1ACCESS	Equ	0x3b5	; CRT controller address register, access port
VGAREG_CRT2INDEX	Equ	0x3d4	; CRT controller address register, index port
VGAREG_CRT2ACCESS	Equ	0x3d5	; CRT controller address register, access port

VGACRT_HORTOTAL	Equ	0x0	; Horizontal total register
VGACRT_HENDENABLE	Equ	0x1	; Horizontal Display Enable End Register
VGACRT_HSTABLANK	Equ	0x2	; Start Horizontal Blanking Register
VGACRT_HENDBLANK	Equ	0x3	; End Horizontal Blanking Register
VGACRT_HSTARETR	Equ	0x4	; Start Horizontal Retrace Pulse Register
VGACRT_HENDRETR	Equ	0x5	; End Horizontal Retrace Register
VGACRT_VERTOTAL	Equ	0x6	; Vertical Total Register
VGACRT_OVERFLOW	Equ	0x7	; CRT Controller Overfow Register
VGACRT_PREROWSCAN	Equ	0x8	; Preset Row Scan Register
VGACRT_MAXSCLINE	Equ	0x9	; Maximum Scan Line Register
VGACRT_CURSTART	Equ	0xa	; Cursor Start Register
VGACRT_CUREND	Equ	0xb	; Cursor End Register
VGACRT_STARTHIGH	Equ	0xc	; Start Address High Register
VGACRT_STARTLOW	Equ	0xd	; Start Address Low Register
VGACRT_CURSORHIGH	Equ	0xe	; Cursor Location High Register
VGACRT_CURSORLOW	Equ	0xf	; Cursor Location Low Register
VGACRT_VRTSTART	Equ	0x10	; Vertical Retrace Start Register
VGACRT_VRTEND	Equ	0x11	; Vertical Retrace End Register
VGACRT_DISPEND	Equ	0x12	; Vertical Display Enable End Register
VGACRT_OFFSET	Equ	0x13	; Offset Register
VGACRT_UNDERLINE	Equ	0x14	; Underline Location Register
VGACRT_VBLSTART	Equ	0x15	; Start Vertical Blanking Register
VGACRT_VBLEND	Equ	0x16	; End Vertical Blanking Register
VGACRT_CRTCMODE	Equ	0x17	; CRTC Mode Control Register
VGACRT_LINECMP	Equ	0x18	; Line Compare Register
VGACRT_CRTCMTEST	Equ	0x1e	; CRTC Module Testing Register
VGACRT_SOFTPRG	Equ	0x1f	; Software Programming Register
VGACRT_CPULATCH	Equ	0x22	; CPU Latch Read Back Register
VGACRT_ATTRIBSRB	Equ	0x24	; Attribute State Read Back Register
VGACRT_ATTRIBIRB	Equ	0x26	; Attribute Index Read Back Register

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VGAREG_GFXINDEX	Equ	0x3ce	; Graphics Address Register, Index Port
VGAREG_GFXACCESS	Equ	0x3cf	; Graphics Address Register, Access Port

VGAGFX_SETRESET	Equ	0x0	; Set/Reset Register
VGAGFX_ENABLESR	Equ	0x1	; Enable Set/Reset Register
VGAGFX_COLORCMP	Equ	0x2	; Colour Compare Register
VGAGFX_DATAROTATE	Equ	0x3	; Data Rotate Register
VGAGFX_READMAPSEL	Equ	0x4	; Read Map Select Register
VGAGFX_MODE	Equ	0x5	; Graphics Mode Register
VGAGFX_MISC	Equ	0x6	; Miscellaneous Register
VGAGFX_COLORNCARE	Equ	0x7	; Color Don't Care Register
VGAGFX_BITMASK	Equ	0x8	; Bit Mask Register
VGAGFX_SRC	Equ	0xe	; Source Address Register
VGAGFX_SRCENABLE	Equ	0xf	; Source Address Enable Register

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VGAREG_ATRREAD	Equ	0x3c0	; Attribute Address Register, Read
VGAREG_ATRWRITE	Equ	0x3c1	; Attribute Address Register, Write

VGAATR_PALETTE0	Equ	0x0	; Palette Register 0
VGAATR_PALETTE1	Equ	0x1	; Palette Register 1
VGAATR_PALETTE2	Equ	0x2	; Palette Register 2
VGAATR_PALETTE3	Equ	0x3	; Palette Register 3
VGAATR_PALETTE4	Equ	0x4	; Palette Register 4
VGAATR_PALETTE5	Equ	0x5	; Palette Register 5
VGAATR_PALETTE6	Equ	0x6	; Palette Register 6
VGAATR_PALETTE7	Equ	0x7	; Palette Register 7
VGAATR_PALETTE8	Equ	0x8	; Palette Register 8
VGAATR_PALETTE9	Equ	0x9	; Palette Register 9
VGAATR_PALETTE10	Equ	0xa	; Palette Register 10
VGAATR_PALETTE11	Equ	0xb	; Palette Register 11
VGAATR_PALETTE12	Equ	0xc	; Palette Register 12
VGAATR_PALETTE13	Equ	0xd	; Palette Register 13
VGAATR_PALETTE14	Equ	0xe	; Palette Register 14
VGAATR_PALETTE15	Equ	0xf	; Palette Register 15
VGAATR_MODECTRL	Equ	0x10	; Attribute Mode Control
VGAATR_OSCANCOL	Equ	0x11	; Overscan Color Register
VGAATR_COLPLANE	Equ	0x12	; Color Plane Enable Register
VGAATR_HORPELPAN	Equ	0x13	; Horizontal PEL Panning Register
VGAATR_COLSELECT	Equ	0x14	; Colour Select Register

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VGAREG_MISCOUTW	Equ	0x3c2	; Miscellaneous Output Register (Write)
VGAREG_MISCOUTR	Equ	0x3cc	; Miscellaneous Output Register (Read)
VGAREG_INPUTST0	Equ	0x3c2	; Input Status Register Zero
VGAREG_INPUTST1	Equ	0x3ba	; Input Status Register One (see doc for port select)
VGAREG_INPUTST2	Equ	0x3da	; Input Status Register One
VGAREG_VIDSUBSYS	Equ	0x3c3	; Video Subsystem Enable Register
VGAREG_DAENABLE	Equ	0x46e8	; Display Adapter Enable Register

VGAREG_DACPMASK	Equ	0x3c6	; DAC Pixel Mask Register
VGAREG_DACSTATUS	Equ	0x3c7	; DAC Status Register (Read)
VGAREG_DACREAD	Equ	0x3c7	; DAC Read Data Register (Write)
VGAREG_DACWRITE	Equ	0x3c8	; DAC Write Data Address Register
VGAREG_DACDATA	Equ	0x3c9	; DAC Data Register








;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
