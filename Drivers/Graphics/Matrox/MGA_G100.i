
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
;	Equ	0x1c48	; Reserved
;	Equ	0x1c4c	; Reserved
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
;	Equ	0x1cb4	; Reserved
;	Equ	0x1cb8	; Reserved
;	Equ	0x1cbc	; Reserved
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
;	Equ	0x1d00	; Reserved
;	Equ	0x1d04	; Reserved
;	Equ	0x1d08	; Reserved
;	Equ	0x1d0c	; Reserved
;	Equ	0x1d10	; Reserved
;	Equ	0x1d14	; Reserved
;	Equ	0x1d18	; Reserved
;	Equ	0x1d1c	; Reserved
;	Equ	0x1d20	; Reserved
;	Equ	0x1d24	; Reserved
;	Equ	0x1d28	; Reserved
;	Equ	0x1d2c	; Reserved
;	Equ	0x1d30	; Reserved
;	Equ	0x1d34	; Reserved
;	Equ	0x1d38	; Reserved
;	Equ	0x1d3c	; Reserved
;	Equ	0x1d40	; Reserved
;	Equ	0x1d44	; Reserved
;	Equ	0x1d48	; Reserved
;	Equ	0x1d4c	; Reserved
;	Equ	0x1d50	; Reserved
;	Equ	0x1d54	; Reserved
;	Equ	0x1d58	; Reserved
;	Equ	0x1d5c	; Reserved
;	Equ	0x1d60	; Reserved
;	Equ	0x1d64	; Reserved
;	Equ	0x1d68	; Reserved
;	Equ	0x1d6c	; Reserved
;	Equ	0x1d70	; Reserved
;	Equ	0x1d74	; Reserved
;	Equ	0x1d78	; Reserved
;	Equ	0x1d7c	; Reserved
;	Equ	0x1d80	; Reserved
;	Equ	0x1d84	; Reserved
;	Equ	0x1d88	; Reserved
;	Equ	0x1d8c	; Reserved
;	Equ	0x1d90	; Reserved
;	Equ	0x1d94	; Reserved
;	Equ	0x1d98	; Reserved
;	Equ	0x1d9c	; Reserved
;	Equ	0x1da0	; Reserved
;	Equ	0x1da4	; Reserved
;	Equ	0x1da8	; Reserved
;	Equ	0x1dac	; Reserved
;	Equ	0x1db0	; Reserved
;	Equ	0x1db4	; Reserved
;	Equ	0x1db8	; Reserved
;	Equ	0x1dbc	; Reserved
;	Equ	0x1dc0	; Reserved
;	Equ	0x1dc4	; Reserved
;	Equ	0x1dc8	; Reserved
;	Equ	0x1dcc	; Reserved
;	Equ	0x1dd0	; Reserved
;	Equ	0x1dd4	; Reserved
;	Equ	0x1dd8	; Reserved
;	Equ	0x1ddc	; Reserved
;	Equ	0x1de0	; Reserved
;	Equ	0x1de4	; Reserved
;	Equ	0x1de8	; Reserved
;	Equ	0x1dec	; Reserved
;	Equ	0x1df0	; Reserved
;	Equ	0x1df4	; Reserved
;	Equ	0x1df8	; Reserved
;	Equ	0x1dfc	; Reserved

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x1e00 -> 0x1eff = HSTREG ; Host Registers
;

;	Equ	0x1e00	; Reserved
;	Equ	0x1e04	; Reserved
;	Equ	0x1e08	; Reserved
;	Equ	0x1e0c	; Reserved
MGA_FIFOSTATUS	Equ	0x1e10	; Bus FIFO Status
MGA_STATUS	Equ	0x1e14	; Status
MGA_ICLEAR	Equ	0x1e18	; Interrupt Clear
MGA_IEN	Equ	0x1e1c	; Interrupt Enable
MGA_VCOUNT	Equ	0x1e20	; Vertical Count
;	Equ	0x1e24	; Reserved
;	Equ	0x1e28	; Reserved
;	Equ	0x1e2c	; Reserved
MGA_DMAMAP30	Equ	0x1e30	; DMA Map 0x3 to 0x0
MGA_DMAMAP74	Equ	0x1e34	; DMA Map 0x7 to 0x4
MGA_DMAMAPb8	Equ	0x1e38	; DMA Map 0xb to 0x8
MGA_DMAMAPfc	Equ	0x1e3c	; DMA Map 0xf to 0xc
MGA_RST	Equ	0x1e40	; Reset
;	Equ	0x1e44	; Reserved
;	Equ	0x1e48	; Reserved
;	Equ	0x1e4c	; Reserved
;	Equ	0x1e50	; Reserved
MGA_OPMODE	Equ	0x1e54	; Operating Mode
MGA_PRIMADDRESS	Equ	0x1e58	; Primary DMA Current Address
MGA_PRIMEND	Equ	0x1e5c	; Primary DMA End Address
;	Equ	0x1e60	; Reserved
;	Equ	0x1e64	; Reserved
;	Equ	0x1e68	; Reserved
;	Equ	0x1e6c	; Reserved
;	Equ	0x1e70	; Reserved
;	Equ	0x1e74	; Reserved
;	Equ	0x1e78	; Reserved
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
;	Equ	0x1ec0	; Reserved
;	Equ	0x1ec4	; Reserved
;	Equ	0x1ec8	; Reserved
;	Equ	0x1ecc	; Reserved
;	Equ	0x1ed0	; Reserved
;	Equ	0x1ed4	; Reserved
;	Equ	0x1ed8	; Reserved
;	Equ	0x1edc	; Reserved
;	Equ	0x1ee0	; Reserved
;	Equ	0x1ee4	; Reserved
;	Equ	0x1ee8	; Reserved
;	Equ	0x1eec	; Reserved
;	Equ	0x1ef0	; Reserved
;	Equ	0x1ef4	; Reserved
;	Equ	0x1ef8	; Reserved
;	Equ	0x1efc	; Reserved

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
; 0x2000 -> 0x2bff = Reserved
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
;	Equ	0x2c38	; Reserved
;	Equ	0x2c3c	; Reserved
MGA_SECADDRESS	Equ	0x2c40	; Secondary DMA Current Address
MGA_SECEND	Equ	0x2c44	; Secondary DMA End Address
MGA_SOFTRAP	Equ	0x2c48	; Soft Trap Handle
;	Equ	0x2c4c	; Reserved
MGA_DR0_Z32LSB	Equ	0x2c50	; Extended Data ALU 0
MGA_DR0_Z32MSB	Equ	0x2c54	; Extended Data ALU 0
MGA_TEXFILTER	Equ	0x2c58	; Texture Filtering
;	Equ	0x2c5c	; Reserved
MGA_DR2_Z32LSB	Equ	0x2c60	; Extended Data ALU 2
MGA_DR2_Z32MSB	Equ	0x2c64	; Extended Data ALU 2
MGA_DR3_Z32LSB	Equ	0x2c68	; Extended Data ALU 3
MGA_DR3_Z32MSB	Equ	0x2c6c	; Extended Data ALU 3
MGA_ALPHASTART	Equ	0x2c70	; Alpha Start
MGA_ALPHAXINC	Equ	0x2c74	; Alpha X Inc
MGA_ALPHAYINC	Equ	0x2c78	; Alpha Y Inc
MGA_ALPHACTRL	Equ	0x2c7c	; Alpha CTRL
;	Equ	0x2c80	; Reserved
;	Equ	0x2c84	; Reserved
;	Equ	0x2c8	; Reserved
;	Equ	0x2c8c	; Reserved
;	Equ	0x2c90	; Reserved
;	Equ	0x2c94	; Reserved
;	Equ	0x2c98	; Reserved
;	Equ	0x2c9c	; Reserved
;	Equ	0x2ca0	; Reserved
;	Equ	0x2ca4	; Reserved
;	Equ	0x2ca8	; Reserved
;	Equ	0x2cac	; Reserved
;	Equ	0x2cb0	; Reserved
;	Equ	0x2cb4	; Reserved
;	Equ	0x2cb8	; Reserved
;	Equ	0x2cbc	; Reserved
;	Equ	0x2cc0	; Reserved
;	Equ	0x2cc4	; Reserved
;	Equ	0x2cc8	; Reserved
;	Equ	0x2ccc	; Reserved
;	Equ	0x2cd0	; Reserved
;	Equ	0x2cd4	; Reserved
;	Equ	0x2cd8	; Reserved
;	Equ	0x2cdc	; Reserved
;	Equ	0x2ce0	; Reserved
;	Equ	0x2ce4	; Reserved
;	Equ	0x2ce8	; Reserved
;	Equ	0x2cec	; Reserved
;	Equ	0x2cf0	; Reserved
;	Equ	0x2cf4	; Reserved
;	Equ	0x2cf8	; Reserved
;	Equ	0x2cfc	; Reserved

;	Equ	0x2d00	; Same As 0x2cxx
;	Equ	0x2d04	; Same As 0x2cxx
;	Equ	0x2d08	; Same As 0x2cxx
;	Equ	0x2d0c	; Same As 0x2cxx
;	Equ	0x2d10	; Same As 0x2cxx
;	Equ	0x2d14	; Same As 0x2cxx
;	Equ	0x2d18	; Same As 0x2cxx
;	Equ	0x2d1c	; Same As 0x2cxx
;	Equ	0x2d20	; Same As 0x2cxx
;	Equ	0x2d24	; Same As 0x2cxx
;	Equ	0x2d28	; Same As 0x2cxx
;	Equ	0x2d2c	; Same As 0x2cxx
;	Equ	0x2d30	; Same As 0x2cxx
;	Equ	0x2d34	; Same As 0x2cxx
;	Equ	0x2d38	; Same As 0x2cxx
;	Equ	0x2d3c	; Same As 0x2cxx
;	Equ	0x2d40	; Same As 0x2cxx
;	Equ	0x2d44	; Same As 0x2cxx
;	Equ	0x2d48	; Same As 0x2cxx
;	Equ	0x2d4c	; Same As 0x2cxx
;	Equ	0x2d50	; Same As 0x2cxx
;	Equ	0x2d54	; Same As 0x2cxx
;	Equ	0x2d58	; Same As 0x2cxx
;	Equ	0x2d5c	; Same As 0x2cxx
;	Equ	0x2d60	; Same As 0x2cxx
;	Equ	0x2d64	; Same As 0x2cxx
;	Equ	0x2d68	; Same As 0x2cxx
;	Equ	0x2d6c	; Same As 0x2cxx
;	Equ	0x2d70	; Same As 0x2cxx
;	Equ	0x2d74	; Same As 0x2cxx
;	Equ	0x2d78	; Same As 0x2cxx
;	Equ	0x2d7c	; Same As 0x2cxx
;	Equ	0x2d80	; Same As 0x2cxx
;	Equ	0x2d84	; Same As 0x2cxx
;	Equ	0x2d88	; Same As 0x2cxx
;	Equ	0x2d8c	; Same As 0x2cxx
;	Equ	0x2d90	; Same As 0x2cxx
;	Equ	0x2d94	; Same As 0x2cxx
;	Equ	0x2d98	; Same As 0x2cxx
;	Equ	0x2d9c	; Same As 0x2cxx
;	Equ	0x2da0	; Same As 0x2cxx
;	Equ	0x2da4	; Same As 0x2cxx
;	Equ	0x2da8	; Same As 0x2cxx
;	Equ	0x2dac	; Same As 0x2cxx
;	Equ	0x2db0	; Same As 0x2cxx
;	Equ	0x2db4	; Same As 0x2cxx
;	Equ	0x2db8	; Same As 0x2cxx
;	Equ	0x2dbc	; Same As 0x2cxx
;	Equ	0x2dc0	; Same As 0x2cxx
;	Equ	0x2dc4	; Same As 0x2cxx
;	Equ	0x2dc8	; Same As 0x2cxx
;	Equ	0x2dcc	; Same As 0x2cxx
;	Equ	0x2dd0	; Same As 0x2cxx
;	Equ	0x2dd4	; Same As 0x2cxx
;	Equ	0x2dd8	; Same As 0x2cxx
;	Equ	0x2ddc	; Same As 0x2cxx
;	Equ	0x2de0	; Same As 0x2cxx
;	Equ	0x2de4	; Same As 0x2cxx
;	Equ	0x2de8	; Same As 0x2cxx
;	Equ	0x2dec	; Same As 0x2cxx
;	Equ	0x2df0	; Same As 0x2cxx
;	Equ	0x2df4	; Same As 0x2cxx
;	Equ	0x2df8	; Same As 0x2cxx
;	Equ	0x2dfc	; Same As 0x2cxx

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
;	Equ	0x3c04	; Reserved
;	Equ	0x3c08	; Reserved
MGA_X_DATAREG	Equ	0x3c0a	; Indexed Data Register <This is a cool one>
;	Equ	0x3c0b	; Reserved
MGA_CURPOSXL	Equ	0x3c0c	; Cursor Position X LSB
MGA_CURPOSXH	Equ	0x3c0d	; Cursor Position X MSB
MGA_CURPOSYL	Equ	0x3c0e	; Cursor Position Y LSB
MGA_CURPOSYH	Equ	0x3c0f	; Cursor Position Y MSB

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3c10 -> 0x3dff = Reserved
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 0x3e00 -> 0x3fff = EXP ; Expansion
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








