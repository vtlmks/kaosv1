
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x1c00 -> 0x1dff = DWGREG0 ; First Drawing Registers
;

MGA_DWGCTL	Equ	0x1c00	; Drawing Control
MGA_MACCESS	Equ	0x1c04	; Memory Access
MGA_MCTLWTST	Equ	0x1c08	; Memory Control Wait State
MGA_ZORG	Equ	0x1c0c	; Z-Depth Origin
MGA_PAT0	Equ	0x1c10	; Pattern
MGA_PAT1	Equ	0x1c14	; Pattern
;	Equ	0x1c18	; Reserved
MGA_PLNTWT	Equ	0x1c1c	; Plane Write Mask
MGA_BCOL	Equ	0x1c20	; Background Color / Blit Color Mask
MGA_FCOL	Equ	0x1c24	; Foreground Color / Blit Color Key
;	Equ	0x1c28	; Reserved
;	Equ	0x1c2c	; Reserved (SRCBLT)
MGA_SRC0	Equ	0x1c30	; Source
MGA_SRC1	Equ	0x1c34	; Source
MGA_SRC2	Equ	0x1c38	; Source
MGA_SRC3	Equ	0x1c3c	; Source
MGA_XYSTRT	Equ	0x1c40	; XY Start Address
MGA_XYEND	Equ	0x1c44	; XY End Address
;	Equ	0x1c48 -> 0x1c4c	; Reserved
MGA_SHIFT	Equ	0x1c50	; Funnel Shifter Control
MGA_DMAPAD	Equ	0x1c54	; DMA Padding
MGA_SGN	Equ	0x1c58	; Sign
MGA_LEN	Equ	0x1c5c	; Length
MGA_AR0	Equ	0x1c60	; Multi-Purpose Address 0
MGA_AR1	Equ	0x1c64	; Multi-Purpose Address 1
MGA_AR2	Equ	0x1c68	; Multi-Purpose Address 2
MGA_AR3	Equ	0x1c6c	; Multi-Purpose Address 3
MGA_AR4	Equ	0x1c70	; Multi-Purpose Address 4
MGA_AR5	Equ	0x1c74	; Multi-Purpose Address 5
MGA_AR6	Equ	0x1c78	; Multi-Purpose Address 6
;	Equ	0x1c7c	; Reserved
MGA_CXBNDRY	Equ	0x1c80	; Clipper X Boundary
MGA_FXBNDRY	Equ	0x1c84	; X Address (Boundary)
MGA_YDSTLEN	Equ	0x1c88	; Y Destination and Length
MGA_PITCH	Equ	0x1c8c	; Memory Pitch
MGA_YDST	Equ	0x1c90	; Y Address
MGA_YDSTORG	Equ	0x1c94	; Memory Origin
MGA_YTOP	Equ	0x1c98	; Clipper Y Top Boundary
MGA_YBOT	Equ	0x1c9c	; Clipper Y Bottom Boundary
MGA_CXLEFT	Equ	0x1ca0	; Clipper X Minimum Boundary
MGA_CXRIGHT	Equ	0x1ca4	; Clipper X Maximum Boundary
MGA_FXLEFT	Equ	0x1ca8	; X Address (Left)
MGA_FXRIGHT	Equ	0x1cac	; X Address (Right)
MGA_XDST	Equ	0x1cb0	; X Destination Address
;	Equ	0x1cb4 -> 0x1cbc	; Reserved
MGA_DR0	Equ	0x1cc0	; Data ALU 0
MGA_FOGSTART	Equ	0x1cc4	; Fog Start
MGA_DR2	Equ	0x1cc8	; Data ALU 2
MGA_DR3	Equ	0x1ccf	; Data ALU 3
MGA_DR4	Equ	0x1cd0	; Data ALU 4
MGA_FOGXINC	Equ	0x1cd4	; Fog X Inc
MGA_DR6	Equ	0x1cd8	; Data ALU 6
MGA_DR7	Equ	0x1cdc	; Data ALU 7
MGA_DR8	Equ	0x1ce0	; Data ALU 8
MGA_FOGYINC	Equ	0x1ce4	; Fog Y Inc
MGA_DR10	Equ	0x1ce8	; Data ALU 10
MGA_DR11	Equ	0x1cec	; Data ALU 11
MGA_DR12	Equ	0x1cf0	; Data ALU 12
MGA_FOGCOL	Equ	0x1cf4	; Fog Color
MGA_DR14	Equ	0x1cf8	; Data ALU 14
MGA_DR15	Equ	0x1cfc	; Data ALU 15
;	Equ	0x1d00 -> 0x1dbc	; Reserved
MGA_WIADDR	Equ	0x1dc0	; WARP Instruction Address
MGA_WFLAG	Equ	0x1dc4	; WARP Flags
MGA_WGETMSB	Equ	0x1dc8	; WARP GetMSB Value
MGA_WVRTXSZ	Equ	0x1dcc	; WARP Vertex Size
;	Equ	0x1dd0 - 0x1dfc	; Reserved (WDBR)

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x1e00 -> 0x1eff = HSTREG ; Host Registers
;

;	Equ	0x1e00 -> 0x1e0c	; Reserved
MGA_FIFOSTATUS	Equ	0x1e10	; Bus FIFO Status
MGA_STATUS	Equ	0x1e14	; Status
MGA_ICLEAR	Equ	0x1e18	; Interrupt Clear
MGA_IEN	Equ	0x1e1c	; Interrupt Enable
MGA_VCOUNT	Equ	0x1e20	; Vertical Count
;	Equ	0x1e24 -> 0x1e2c	; Reserved
MGA_DMAMAP30	Equ	0x1e30	; DMA Map 0x3 to 0x0
MGA_DMAMAP74	Equ	0x1e34	; DMA Map 0x7 to 0x4
MGA_DMAMAPb8	Equ	0x1e38	; DMA Map 0xb to 0x8
MGA_DMAMAPfc	Equ	0x1e3c	; DMA Map 0xf to 0xc
MGA_RST	Equ	0x1e40	; Reset
MGA_MEMRDBK	Equ	0x1e44	; Memory Read Back
MGA_TEST0	Equ	0x1e48	; Test 0
MGA_AGP_PLL	Equ	0x1e4c	; AGP 2X PLL Control/Status
MGA_PRIMPTR	Equ	0x1e50	; Primary List Status Fetch Pointer
MGA_OPMODE	Equ	0x1e54	; Operating Mode
MGA_PRIMADDRESS	Equ	0x1e58	; Primary DMA Current Address
MGA_PRIMEND	Equ	0x1e5c	; Primary DMA End Address
MGA_WIADDRNB	Equ	0x1e60	; WARP Instruction Add. (Non Blocking)
MGA_WFLAGNB	Equ	0x1e64	; WARP Flags (Non Blocking)
MGA_WIMEMADDR	Equ	0x1e68	; WARP Instruction Memory Address
MGA_WCODEADDR	Equ	0x1e6c	; WARP Microcode Address
MGA_WMISC	Equ	0x1e70	; WARP Miscellaneous
;???	Equ	0x1e74	; Reserved ?
;???	Equ	0x1e78	; Reserved ?
;	Equ	0x1e7c	; Reserved
MGA_DWG_INDIR_WT0 Equ	0x1e80	; Drawing Register Indirect Write 0
MGA_DWG_INDIR_WT1 Equ	0x1e84	; Drawing Register Indirect Write 1
MGA_DWG_INDIR_WT2 Equ	0x1e88	; Drawing Register Indirect Write 2
MGA_DWG_INDIR_WT3 Equ	0x1e8c	; Drawing Register Indirect Write 3
MGA_DWG_INDIR_WT4 Equ	0x1e90	; Drawing Register Indirect Write 4
MGA_DWG_INDIR_WT5 Equ	0x1e94	; Drawing Register Indirect Write 5
MGA_DWG_INDIR_WT6 Equ	0x1e98	; Drawing Register Indirect Write 6
MGA_DWG_INDIR_WT7 Equ	0x1e9c	; Drawing Register Indirect Write 7
MGA_DWG_INDIR_WT8 Equ	0x1ea0	; Drawing Register Indirect Write 8
MGA_DWG_INDIR_WT9 Equ	0x1ea4	; Drawing Register Indirect Write 9
MGA_DWG_INDIR_WT10 Equ	0x1ea8	; Drawing Register Indirect Write 10
MGA_DWG_INDIR_WT11 Equ	0x1eac	; Drawing Register Indirect Write 11
MGA_DWG_INDIR_WT12 Equ	0x1eb0	; Drawing Register Indirect Write 12
MGA_DWG_INDIR_WT13 Equ	0x1eb4	; Drawing Register Indirect Write 13
MGA_DWG_INDIR_WT14 Equ	0x1eb8	; Drawing Register Indirect Write 14
MGA_DWG_INDIR_WT15 Equ	0x1ebc	; Drawing Register Indirect Write 15
;	Equ	0x1ec0 -> 0x1efc	; Reserved

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x1f00 -> 0x1fff = VGAREG ; VGA Registers
;

;	Equ	0x1f00	; Reserved
;	Equ	0x1f04	; Reserved
;	Equ	0x1f08	; Reserved
;	Equ	0x1f0c	; Reserved
;	Equ	0x1f10	; Reserved
;	Equ	0x1f14	; Reserved
;	Equ	0x1f18	; Reserved
;	Equ	0x1f1c	; Reserved
;	Equ	0x1f20	; Reserved
;	Equ	0x1f24	; Reserved
;	Equ	0x1f28	; Reserved
;	Equ	0x1f2c	; Reserved
;	Equ	0x1f30	; Reserved
;	Equ	0x1f34	; Reserved
;	Equ	0x1f38	; Reserved
;	Equ	0x1f3c	; Reserved
;	Equ	0x1f40	; Reserved
;	Equ	0x1f44	; Reserved
;	Equ	0x1f48	; Reserved
;	Equ	0x1f4c	; Reserved
;	Equ	0x1f50	; Reserved
;	Equ	0x1f54	; Reserved
;	Equ	0x1f58	; Reserved
;	Equ	0x1f5c	; Reserved
;	Equ	0x1f60	; Reserved
;	Equ	0x1f64	; Reserved
;	Equ	0x1f68	; Reserved
;	Equ	0x1f6c	; Reserved
;	Equ	0x1f70	; Reserved
;	Equ	0x1f74	; Reserved
;	Equ	0x1f78	; Reserved
;	Equ	0x1f7c	; Reserved
;	Equ	0x1f80	; Reserved
;	Equ	0x1f84	; Reserved
;	Equ	0x1f88	; Reserved
;	Equ	0x1f8c	; Reserved
;	Equ	0x1f90	; Reserved
;	Equ	0x1f94	; Reserved
;	Equ	0x1f98	; Reserved
;	Equ	0x1f9c	; Reserved
;	Equ	0x1fa0	; Reserved
;	Equ	0x1fa4	; Reserved
;	Equ	0x1fa8	; Reserved
;	Equ	0x1fac	; Reserved
;	Equ	0x1fb0	; Reserved
;	Equ	0x1fb4	; Reserved
;	Equ	0x1fb8	; Reserved
;	Equ	0x1fbc	; Reserved
;MGA_ATTR	Equ	0x1fc0	; Attribute Controller
;MGA_	Equ	0x1fc4	;
;MGA_	Equ	0x1fc8	;
;MGA_	Equ	0x1fcc	;
;	Equ	0x1fd0	; Reserved
;MGA_	Equ	0x1fd4	;
;MGA_	Equ	0x1fd8	;
;MGA_	Equ	0x1fdc	;
;MGA_	Equ	0x1fe0	;
;MGA_	Equ	0x1fe4	;
;MGA_	Equ	0x1fe8	;
;MGA_	Equ	0x1fec	;
;MGA_	Equ	0x1ff0	;
;MGA_	Equ	0x1ff4	;
;MGA_	Equ	0x1ff8	;
;MGA_	Equ	0x1ffc	;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x2000 -> 0x207f = WIMEMEDATA ; WARP Instruction Memory
;
MGA_WIMEMDATA	Equ	0x2000	; WARP Instruction Memory Data

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x2080 -> 0x2bff = Reserved
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x2c00 -> 0x2dff = DWGREG1 ; Second Drawing Registers
;
MGA_TMR0	Equ	0x2c00	; Texture Mapping ALU 0
MGA_TMR1	Equ	0x2c04	; Texture Mapping ALU 1
MGA_TMR2	Equ	0x2c08	; Texture Mapping ALU 2
MGA_TMR3	Equ	0x2c0c	; Texture Mapping ALU 3
MGA_TMR4	Equ	0x2c10	; Texture Mapping ALU 4
MGA_TMR5	Equ	0x2c14	; Texture Mapping ALU 5
MGA_TMR6	Equ	0x2c18	; Texture Mapping ALU 6
MGA_TMR7	Equ	0x2c1c	; Texture Mapping ALU 7
MGA_TMR8	Equ	0x2c20	; Texture Mapping ALU 8
MGA_TEXORG	Equ	0x2c24	; Texture Origin
MGA_TEXWIDTH	Equ	0x2c28	; Texture Width
MGA_TEXHEIGHT	Equ	0x2c2c	; Texture Height
MGA_TEXCTL	Equ	0x2c30	; Texture Map Control
MGA_TEXTRANS	Equ	0x2c34	; Texture Transparency
MGA_TEXTRANSHIGH Equ	0x2c38	; Texture Transparency
MGA_TEXCTL2	Equ	0x2c3c	; Texture Map Control 2
MGA_SECADDRESS	Equ	0x2c40	; Secondary DMA Current Address
MGA_SECEND	Equ	0x2c44	; Secondary DMA End Address
MGA_SOFTRAP	Equ	0x2c48	; Soft Trap Handle
MGA_DWGSYNC	Equ	0x2c4c	; Drawing Syncronisation
MGA_DR0_Z32LSB	Equ	0x2c50	; Extended Data ALU 0
MGA_DR0_Z32MSB	Equ	0x2c54	; Extended Data ALU 0
MGA_TEXFILTER	Equ	0x2c58	; Texture Filtering
MGA_TEXBORDERCOL Equ	0x2c5c	; Texture border Color
MGA_DR2_Z32LSB	Equ	0x2c60	; Extended Data ALU 2
MGA_DR2_Z32MSB	Equ	0x2c64	; Extended Data ALU 2
MGA_DR3_Z32LSB	Equ	0x2c68	; Extended Data ALU 3
MGA_DR3_Z32MSB	Equ	0x2c6c	; Extended Data ALU 3
MGA_ALPHASTART	Equ	0x2c70	; Alpha Start
MGA_ALPHAXINC	Equ	0x2c74	; Alpha X Inc
MGA_ALPHAYINC	Equ	0x2c78	; Alpha Y Inc
MGA_ALPHACTRL	Equ	0x2c7c	; Alpha CTRL
MGA_SPECRSTART	Equ	0x2c80	; Specular Lightning Red Start
MGA_SPECRXINC	Equ	0x2c84	; Specular Lightning Red X Inc
MGA_SPECRYINC	Equ	0x2c88	; Specular Lightning Red Y Inc
MGA_SPECGSTART	Equ	0x2c8c	; Specular Lightning Green Start
MGA_SPECGXINC	Equ	0x2c90	; Specular Lightning Green X Inc
MGA_SPECGYINC	Equ	0x2c94	; Specular Lightning Green Y Inc
MGA_SPECBSTART	Equ	0x2c98	; Specular Lightning Blue Start
MGA_SPECBXINC	Equ	0x2c9c	; Specular Lightning Blue X Inc
MGA_SPECBYINC	Equ	0x2ca0	; Specular Lightning Blue Y Inc
MGA_TEXORG1	Equ	0x2ca4	; Texture Origin 1
MGA_TEXORG2	Equ	0x2ca8	; Texture Origin 2
MGA_TEXORG3	Equ	0x2cac	; Texture Origin 3
MGA_TEXORG4	Equ	0x2cb0	; Texture Origin 4
MGA_SRCORG	Equ	0x2cb4	; Source Origin
MGA_DSTORG	Equ	0x2cb8	; Destination Origin
;	Equ	0x2cbc -> 2ccc	; Reserved
MGA_SETUPADDRESS Equ	0x2cd0	; Setup DMA Current Address
MGA_SETUPEND	Equ	0x2cd4	; Setup DMA End Address
;	Equ	0x2cd8 -> 0x2cfc	; Reserved

MGA_WR0	Equ	0x2d00	; WARP Register 0
MGA_WR1	Equ	0x2d04	; WARP Register 1
MGA_WR2	Equ	0x2d08	; WARP Register 2
MGA_WR3	Equ	0x2d0c	; WARP Register 3
MGA_WR4	Equ	0x2d10	; WARP Register 4
MGA_WR5	Equ	0x2d14	; WARP Register 5
MGA_WR6       	Equ	0x2d18	; WARP Register 6
MGA_WR7	Equ	0x2d1c	; WARP Register 7
MGA_WR8	Equ	0x2d20	; WARP Register 8
MGA_WR9       	Equ	0x2d24	; WARP Register 9
MGA_WR10	Equ	0x2d28	; WARP Register 10
MGA_WR11	Equ	0x2d2c	; WARP Register 11
MGA_WR12       	Equ	0x2d30	; WARP Register 12
MGA_WR13	Equ	0x2d34	; WARP Register 13
MGA_WR14	Equ	0x2d38	; WARP Register 14
MGA_WR15	Equ	0x2d3c	; WARP Register 15
MGA_WR16	Equ	0x2d40	; WARP Register 16
MGA_WR17	Equ	0x2d44	; WARP Register 17
MGA_WR18	Equ	0x2d48	; WARP Register 18
MGA_WR19	Equ	0x2d4c	; WARP Register 19
MGA_WR20	Equ	0x2d50	; WARP Register 20
MGA_WR21	Equ	0x2d54	; WARP Register 21
MGA_WR22	Equ	0x2d58	; WARP Register 22
MGA_WR23	Equ	0x2d5c	; WARP Register 23
MGA_WR24	Equ	0x2d60	; WARP Register 24
MGA_WR25	Equ	0x2d64	; WARP Register 25
MGA_WR26	Equ	0x2d68	; WARP Register 26
MGA_WR27	Equ	0x2d6c	; WARP Register 27
MGA_WR28	Equ	0x2d70	; WARP Register 28
MGA_WR29	Equ	0x2d74	; WARP Register 29
MGA_WR30	Equ	0x2d78	; WARP Register 30
MGA_WR31	Equ	0x2d7c	; WARP Register 31
MGA_WR32	Equ	0x2d80	; WARP Register 32
MGA_WR33	Equ	0x2d84	; WARP Register 33
MGA_WR34	Equ	0x2d88	; WARP Register 34
MGA_WR35	Equ	0x2d8c	; WARP Register 35
MGA_WR36	Equ	0x2d90	; WARP Register 36
MGA_WR37	Equ	0x2d94	; WARP Register 37
MGA_WR38	Equ	0x2d98	; WARP Register 38
MGA_WR39	Equ	0x2d9c	; WARP Register 39
MGA_WR40	Equ	0x2da0	; WARP Register 40
MGA_WR41	Equ	0x2da4	; WARP Register 41
MGA_WR42	Equ	0x2da8	; WARP Register 42
MGA_WR43	Equ	0x2dac	; WARP Register 43
MGA_WR44	Equ	0x2db0	; WARP Register 44
MGA_WR45	Equ	0x2db4	; WARP Register 45
MGA_WR46	Equ	0x2db8	; WARP Register 46
MGA_WR47	Equ	0x2dbc	; WARP Register 47
MGA_WR48	Equ	0x2dc0	; WARP Register 48
MGA_WR49	Equ	0x2dc4	; WARP Register 49
MGA_WR50	Equ	0x2dc8	; WARP Register 50
MGA_WR51	Equ	0x2dcc	; WARP Register 51
MGA_WR52	Equ	0x2dd0	; WARP Register 52
MGA_WR53	Equ	0x2dd4	; WARP Register 53
MGA_WR54	Equ	0x2dd8	; WARP Register 54
MGA_WR55	Equ	0x2ddc	; WARP Register 55
MGA_WR56	Equ	0x2de0	; WARP Register 56
MGA_WR57	Equ	0x2de4	; WARP Register 57
MGA_WR58	Equ	0x2de8	; WARP Register 58
MGA_WR59	Equ	0x2dec	; WARP Register 59
MGA_WR60	Equ	0x2df0	; WARP Register 60
MGA_WR61	Equ	0x2df4	; WARP Register 61
MGA_WR62	Equ	0x2df8	; WARP Register 62
MGA_WR63	Equ	0x2dfc	; WARP Register 63

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x2e00 -> 0x3bff = Reserved
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3c00 -> 0x3c0f = DAC ; DAC
;
MGA_PALWTADD	Equ	0x3c00	; Palette RAM Addr. Write/Load Index
MGA_PALDATA	Equ	0x3c01	; Palette RAM Data Register
MGA_PIXRDMSK	Equ	0x3c02	; Pixel Read Mask
MGA_PALRDADD	Equ	0x3c03	; Palette RAM Address - Read. This register is WO for I/O accesses.
;	Equ	0x3c04 -> 0x3c08	; Reserved
MGA_X_DATAREG	Equ	0x3c0a	; Indexed Data Register <This is a cool one>
;	Equ	0x3c0b	; Reserved
MGA_CURPOSXL	Equ	0x3c0c	; Cursor Position X LSB
MGA_CURPOSXH	Equ	0x3c0d	; Cursor Position X MSB
MGA_CURPOSYL	Equ	0x3c0e	; Cursor Position Y LSB
MGA_CURPOSYH	Equ	0x3c0f	; Cursor Position Y MSB

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3c10 -> 0x3cff = Reserved
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3d00 -> 0x3dff = BESREG ; Backend Scaler Register
;

MGA_BESA1ORG	Equ	0x3d00	; BES Buffer A-1 Org.
MGA_BESA2ORG	Equ	0x3d04	; BES Buffer A-2 Org.
MGA_BESB1ORG	Equ	0x3d08	; BES Buffer B-1 Org.
MGA_BESB2ORG	Equ	0x3d0c	; BES Buffer B-2 Org.
MGA_BESA1CORG	Equ	0x3d10	; BES Buffer A-1 Chroma Org.
MGA_BESA2CORG	Equ	0x3d14	; BES Buffer A-2 Chroma Org.
MGA_BESB1CORG	Equ	0x3d18	; BES Buffer B-1 Chroma Org.
MGA_BESB2CORG	Equ	0x3d1c	; BES Buffer B-2 Chroma Org.
MGA_BESCTL	Equ	0x3d20	; BES Control
MGA_BESPITCH	Equ	0x3d24	; BES Pitch
MGA_BESHCOORD	Equ	0x3d28	; BES Horizontal Coordinates
MGA_BESVCOORD	Equ	0x3d2c	; BES Vertical Coordinates
MGA_BESHISCAL	Equ	0x3d30	; BES Horizontal Inv. Scaling Factor
MGA_BESVISCAL	Equ	0x3d34	; BES Vertical Inv. Scaling Factor
MGA_BESHSRCST	Equ	0x3d38	; BES Horizontal Source Start
MGA_BESHSRCEND	Equ	0x3d3c	; BES Horizontal Source Ending
;	Equ	0x3d40 -> 0x3d44	; Reserved
MGA_BES1WGHT	Equ	0x3d48	; BES Field 1 Vertical Weight Start
MGA_BES2WGHT	Equ	0x3d4c	; BES Field 2 Vertical Weight Start
MGA_BESHSRCLST	Equ	0x3d50	; BES Horizontal Source Last
MGA_BESV1SRCLST	Equ	0x3d54	; BES Field 1 Vertical Source Last Position
MGA_BESV2SRCLST	Equ	0x3d58	; BES Field 2 Vertical Source Last Position
;	Equ	0x3d5c -> 0x3dbc	; Reserved
MGA_BESGLOBCTL	Equ	0x3dC0	; BES Global Control
MGA_BESSTATUS	Equ	0x3dC4	; BES Status


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3e00 -> 0x3eff = VINCODEC ; Video-in And Codec Interface
;

MGA_VINCTL0	Equ	0x3e00	; Video Input Control Window 0
MGA_VINCTL1	Equ	0x3e04	; Video Inpuit Control Window 1
MGA_VBIADDR0	Equ	0x3e08	; VBI Address Window 0
MGA_VBIADDR1	Equ	0x3e0c	; VBI Address Window 1
MGA_VINADDR0	Equ	0x3e10	; Video Input Address Window 0
MGA_VINADDR1	Equ	0x3e14	; Video Input Address Window 1
MGA_VINNEXTWIN	Equ	0x3e18	; Video Input Next Window
MGA_VINCTL	Equ	0x3e1c	; Video Input Control
;	Equ	0x3e20	; Reserved
;	Equ	0x3e24	; Reserved
;	Equ	0x3e28	; Reserved
;	Equ	0x3e2c	; Reserved
MGA_VSTATUS	Equ	0x3e30	; Video Status
MGA_VICLEAR	Equ	0x3e34	; Video Interrupt Clear
MGA_VIEN	Equ	0x3e38	; Video Interrupt Enable
;	Equ	0x3e3c	; Reserved
MGA_CODECCTL	Equ	0x3e40	; CODEC Control
MGA_CODECADDR	Equ	0x3e44	; CODEC Buffer Start Address
MGA_CODECHOSTPTR Equ	0x3e48	; CODEC Host Pointer
MGA_CODECHARDPTR Equ	0x3e4c	; CODEC Hard Pointer
MGA_CODECLCODE	Equ	0x3e50	; CODEC LCODE Pointer
;			; Below this, everything is reserved...

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3f00 -> 0x3fff = EXP ; Expansion
;







