;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     MGA_SetMode.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGA_SetMode	Call	MGA_CalcMode
	Call	CGx00CRTC_WaitVBlank
	Call	CGx00CRTC_DisplayBlank
	Call	CGx00CRTC_SetMGAMode
	Call	CGx00CRTC_WriteEnable

	; Set up the registers calculated by CalcMode()

	Mov	al,0xef		; outp( 0x3C2, 0xEF );
	Mov	dx,VGAREG_MISCOUTW
	Out	dx,al
	;
	Mov	al,6		; GCTL_Write( 0x06, 0x05 );
	Mov	bl,5
	Call	CGx00_GCTLWrite
	;
	Lea	edi,[ebp+MGAMemory.MGAHWParams]
	MGACRTCWRITE	0x00,[edi+MGAHWParameters.CRTC0]	; Horizontal total
	MGACRTCWRITE	0x01,[edi+MGAHWParameters.CRTC1]	; Horizontal display end
	MGACRTCWRITE	0x02,[edi+MGAHWParameters.CRTC2]	; Start horizontal blanking
	MGACRTCWRITE	0x03,[edi+MGAHWParameters.CRTC3]	; End horizontal blanking
	MGACRTCWRITE	0x04,[edi+MGAHWParameters.CRTC4]	; Start horizontal retrace pulse
	MGACRTCWRITE	0x05,[edi+MGAHWParameters.CRTC5]	; End horizontal retrace pulse
	MGACRTCWRITE	0x06,[edi+MGAHWParameters.CRTC6]	; Vertical total
	MGACRTCWRITE	0x07,[edi+MGAHWParameters.CRTC7]	; Overflow
	MGACRTCWRITE	0x08,[edi+MGAHWParameters.CRTC8]	; Preset row scan
	MGACRTCWRITE	0x09,[edi+MGAHWParameters.CRTC9]	; Maximum scan line
	MGACRTCWRITE	0x0c,[edi+MGAHWParameters.CRTCC]	; Start address high
	MGACRTCWRITE	0x0d,[edi+MGAHWParameters.CRTCD]	; Start address low
	MGACRTCWRITE	0x10,[edi+MGAHWParameters.CRTC10]	; Vertical retrace start
	MGACRTCWRITE	0x11,[edi+MGAHWParameters.CRTC11]	; Vertical retrace end
	MGACRTCWRITE	0x12,[edi+MGAHWParameters.CRTC12]	; Vertical display enable end
	MGACRTCWRITE	0x13,[edi+MGAHWParameters.CRTC13]	; Offset
	MGACRTCWRITE	0x14,[edi+MGAHWParameters.CRTC14]	; Underline location
	MGACRTCWRITE	0x15,[edi+MGAHWParameters.CRTC15]	; Start vertical blank
	MGACRTCWRITE	0x16,[edi+MGAHWParameters.CRTC16]	; End vertical blank
	MGACRTCWRITE	0x17,[edi+MGAHWParameters.CRTC17]	; CRTC mode control
	MGACRTCWRITE	0x18,[edi+MGAHWParameters.CRTC18]	; Line compare

	MGACRTCEXTWRITE	0x00,[edi+MGAHWParameters.CRTCEXT0]	; Address generator extensions
	MGACRTCEXTWRITE	0x01,[edi+MGAHWParameters.CRTCEXT1]	; Horizontal counter extensions
	MGACRTCEXTWRITE	0x02,[edi+MGAHWParameters.CRTCEXT2]	; Vertical counter extensions
	MGACRTCEXTWRITE	0x03,[edi+MGAHWParameters.CRTCEXT3]	; Miscellaneous
	MGACRTCEXTWRITE	0x04,0		; Memory page

	MGASEQWRITE	0x01,[edi+MGAHWParameters.SEQ1]	; Clocking mode
	MGASEQWRITE	0x00,0x03		; SEQ0
	MGASEQWRITE	0x02,0x0f		; Map mask
	MGASEQWRITE	0x03,0x00		; Character map select
	MGASEQWRITE	0x04,0x0e		; Memory mode
	MGASEQWRITE	0x04,0x0e		; Memory mode

	MGAXWRITE	0x19,[edi+MGAHWParameters.XMULCTRL]
	MGAXWRITE	0x1e,[edi+MGAHWParameters.XMISCCTRL]
	MGAXWRITE	0x38,[edi+MGAHWParameters.XZOOMCTRL]
	MGAXWRITE	0x4c,[edi+MGAHWParameters.XPIXPLLM]
	MGAXWRITE	0x4d,[edi+MGAHWParameters.XPIXPLLN]
	MGAXWRITE	0x4e,[edi+MGAHWParameters.XPIXPLLP]

	Call	SetupVGALUT
	Call	CGx00CRTC_WaitVBlank
	Call	CGx00CRTC_DisplayUnBlank
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGA_CalcMode	PushAD
	Mov dword	[ebp+MGAMemory.XRes],1024
	Mov dword	[ebp+MGAMemory.YRes],768
	Mov dword	[ebp+MGAMemory.BPP],8
	Mov dword	[ebp+MGAMemory.RefreshRate],75
	;
	Call	ScaleXRes
	Call	ScaleYRes
	Call	ScaleLimits
	Jc	.ModeFailure
	Call	SetupHorizontal
	Call	SetupVertical
	Call	SetupDepth
	Call	SetupPixelClock
	Call	SetupMGAConfig
.ModeFailure	PopAD
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupMGAConfig	Lea	edi,[ebp+MGAMemory.MGAHWParams]
	;
	Mov	eax,[ebp+MGAMemory.BPP]	; short bytedepth=short((pParms->iBPP+1)>>3);
	Inc	eax
	Shr	eax,3
	Mov	[ebp+MGAMemory.ByteDepth],eax
	;
	Mov	eax,[ebp+MGAMemory.XRes]	; short offset=short((pParms->iXRes*bytedepth+15)>>4);
	Mov	ebx,[ebp+MGAMemory.ByteDepth]
	XOr	edx,edx
	Mul	ebx
	Add	eax,15
	Shr	eax,4
	Mov	[ebp+MGAMemory.Offset],eax
	;
	Mov	eax,[ebp+MGAMemory.HTotal]	; CRTC0=UBYTE(htotal);
	Mov	[edi+MGAHWParameters.CRTC0],al
	;
	Mov	eax,[ebp+MGAMemory.HDispEnd]	; CRTC1=UBYTE(hdispend);
	Mov	[edi+MGAHWParameters.CRTC1],al
	;
	Mov	eax,[ebp+MGAMemory.HBlkStr]	; CRTC2=UBYTE(hblkstr);
	Mov	[edi+MGAHWParameters.CRTC2],al
	;
	Mov	eax,[ebp+MGAMemory.HBlkEnd]	; CRTC3=UBYTE(hblkend&0x1F);
	And	eax,0x1f
	Mov	[edi+MGAHWParameters.CRTC3],al
	;
	Mov	eax,[ebp+MGAMemory.HSyncStr]	; CRTC4=UBYTE(hsyncstr);
	Mov	[edi+MGAHWParameters.CRTC4],al
	;
	Mov	eax,[ebp+MGAMemory.HSyncEnd]	; CRTC5=UBYTE((hsyncend&0x1F)|((hblkend&0x20)<<2));
	And	eax,0x1f
	Mov	ebx,[ebp+MGAMemory.HBlkEnd]
	And	ebx,0x20
	Shl	ebx,2
	Or	eax,ebx
	Mov	[edi+MGAHWParameters.CRTC5],al
	;
	Mov	eax,[ebp+MGAMemory.VTotal]	; CRTC6=UBYTE(vtotal&0xFF);
	And	eax,0xff
	Mov	[edi+MGAHWParameters.CRTC6],al
	;
	Mov	eax,[ebp+MGAMemory.VTotal]	; CRTC7=UBYTE(((vtotal&0x100)>>8)|((vtotal&0x200)>>4)|((vdispend&0x100)>>7)|((vdispend&0x200)>>3)|((vblkstr&0x100)>>5)|((vsyncstr&0x100)>>6)|((vsyncstr&0x200)>>2)|((linecomp&0x100)>>4));
	And	eax,0x100
	Shr	eax,8
	Mov	ebx,[ebp+MGAMemory.VTotal]
	And	ebx,0x200
	Shr	ebx,4
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VDispEnd]
	And	ebx,0x100
	Shr	ebx,7
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VDispEnd]
	And	ebx,0x200
	Shr	ebx,3
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VBlkStr]
	And	ebx,0x100
	Shr	ebx,5
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VSyncStr]
	And	ebx,0x100
	Shr	ebx,6
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VSyncStr]
	And	ebx,0x200
	Shr	ebx,2
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.LineComp]
	And	ebx,0x100
	Shr	ebx,4
	Or	eax,ebx
	Mov	[edi+MGAHWParameters.CRTC7],al
	;
	Mov byte	[edi+MGAHWParameters.CRTC8],0	; CRTC8=0
	;
	Mov	eax,[ebp+MGAMemory.VBlkStr]	; CRTC9=UBYTE(((vblkstr&0x200)>>4)|((linecomp&0x200)>>3)|(iYShift&0x1F));
	And	eax,0x200
	Shr	eax,4
	Mov	ebx,[ebp+MGAMemory.LineComp]
	And	ebx,0x200
	Shr	ebx,3
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.YShift]
	And	ebx,0x1f
	Or	eax,ebx
	Mov	[edi+MGAHWParameters.CRTC9],al
	;
	Mov byte	[edi+MGAHWParameters.CRTCC],0	; CRTCC=0
	;
	Mov byte	[edi+MGAHWParameters.CRTCD],0	; CRTCD=0
	;
	Mov	eax,[ebp+MGAMemory.VSyncStr]	; CRTC10=UBYTE(vsyncstr);
	Mov	[edi+MGAHWParameters.CRTC10],al
	;
	Mov	eax,[ebp+MGAMemory.VSyncEnd]	; CRTC11=UBYTE((vsyncend&0x0F)|0x20);
	And	eax,0xf
	Or	eax,0x20
	Mov	[edi+MGAHWParameters.CRTC11],al
	;
	Mov	eax,[ebp+MGAMemory.VDispEnd]	; CRTC12=UBYTE(vdispend);
	Mov	[edi+MGAHWParameters.CRTC12],al
	;
	Mov	eax,[ebp+MGAMemory.Offset]	; CRTC13=UBYTE(offset)
	Mov	[edi+MGAHWParameters.CRTC13],al
	;
	Mov byte	[edi+MGAHWParameters.CRTC14],0	; CRTC14=0;
	;
	Mov	eax,[ebp+MGAMemory.VBlkStr]	; CRTC15=UBYTE(vblkstr);
	Mov	[edi+MGAHWParameters.CRTC15],al
	;
	Mov	eax,[ebp+MGAMemory.VBlkEnd]	; CRTC16=UBYTE(vblkend);
	Mov	[edi+MGAHWParameters.CRTC16],al
	;
	Mov byte	[edi+MGAHWParameters.CRTC17],0xc3	; CRTC17=0xc3;
	;
	Mov	eax,[ebp+MGAMemory.LineComp]	; CRTC18=UBYTE(linecomp);
	Mov	[edi+MGAHWParameters.CRTC18],al
	;
	Mov	eax,[ebp+MGAMemory.Offset]	; CRTCEXT0=UBYTE((offset&0x300)>>4);
	And	eax,0x300
	Shr	eax,4
	Mov	[edi+MGAHWParameters.CRTCEXT0],al
	;
	Mov	eax,[ebp+MGAMemory.HTotal]	; CRTCEXT1=UBYTE(((htotal&0x100)>>8)|((hblkstr&0x100)>>7)|((hsyncstr&0x100)>>6)|(hblkend&0x40));
	And	eax,0x100
	Shr	eax,8
	Mov	ebx,[ebp+MGAMemory.HBlkStr]
	And	ebx,0x100
	Shr	ebx,7
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.HSyncStr]
	And	ebx,0x100
	Shr	ebx,6
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.HBlkEnd]
	And	ebx,0x40
	Or	eax,ebx
	Mov	[edi+MGAHWParameters.CRTCEXT1],al
	;
	Mov	eax,[ebp+MGAMemory.VTotal]	; CRTCEXT2=UBYTE(((vtotal&0xC00)>>10)|((vdispend&0x400)>>8)|((vblkstr&0xC00)>>7)|((vsyncstr&0xC00)>>5)|((linecomp&0x400)>>3));
	And	eax,0xc00
	Shr	eax,10
	Mov	ebx,[ebp+MGAMemory.VDispEnd]
	And	ebx,0x400
	Shr	ebx,8
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VBlkStr]
	And	ebx,0xc00
	Shr	ebx,7
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.VSyncStr]
	And	ebx,0xc00
	Shr	ebx,5
	Or	eax,ebx
	Mov	ebx,[ebp+MGAMemory.LineComp]
	And	ebx,0x400
	Shr	ebx,3
	Or	eax,ebx
	Mov	[edi+MGAHWParameters.CRTCEXT2],al
	;
	Mov	eax,[ebp+MGAMemory.Scale]	; CRTCEXT3=UBYTE(0x80|(scale&7));
	And	eax,7
	Or	eax,0x80
	Mov	[edi+MGAHWParameters.CRTCEXT3],al
	;
	Mov byte	[edi+MGAHWParameters.SEQ1],0x21	; SEQ1=0x21
	;
	Mov	eax,[ebp+MGAMemory.Depth]	; XMULCTRL=UBYTE(depth&7);
	And	eax,7
	Mov	[edi+MGAHWParameters.XMULCTRL],al
	;
	Mov	eax,[ebp+MGAMemory.VGA8Bit]	; XMISCCTRL=UBYTE(vga8bit|0x17);
	Or	eax,0x17
	Mov	[edi+MGAHWParameters.XMISCCTRL],al
	;
	Mov	eax,[ebp+MGAMemory.XShift]	; XZOOMCTRL=UBYTE(iXShift&3);
	And	eax,3
	Mov	[edi+MGAHWParameters.XZOOMCTRL],al
	;
	Mov	eax,[ebp+MGAMemory.BestM]	; XPIXPLLM=UBYTE(iBestM);
	Mov	[edi+MGAHWParameters.XPIXPLLM],al
	;
	Mov	eax,[ebp+MGAMemory.BestN]	; XPIXPLLN=UBYTE(iBestN);
	Mov	[edi+MGAHWParameters.XPIXPLLN],al
	;
	Mov	eax,[ebp+MGAMemory.BestP]	; XPIXPLLP=UBYTE(iBestP);
	Mov	[edi+MGAHWParameters.XPIXPLLP],al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ScaleXRes	Mov dword	[ebp+MGAMemory.XShift],0
	Mov	eax,[ebp+MGAMemory.XRes]	; Create a min X size of 512
.L	Cmp	eax,512
	Jae	.Done
	Inc dword	[ebp+MGAMemory.XShift]
	Shl	eax,1
	Jmp	.L
.Done	Mov	[ebp+MGAMemory.XRes],eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ScaleYRes	Mov dword	[ebp+MGAMemory.YShift],0
	Mov	eax,[ebp+MGAMemory.YRes]
.L	Cmp	eax,350
	Jae	.Done
	Inc dword	[ebp+MGAMemory.YShift]
	Shl	eax,1
	Jmp	.L
.Done	Mov	[ebp+MGAMemory.YRes],eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ScaleLimits	Cmp dword	[ebp+MGAMemory.XShift],2
	Ja	.Failure
	Cmp dword	[ebp+MGAMemory.YShift],2
	Ja	.Failure
	Cmp dword	[ebp+MGAMemory.XShift],2
	Jne	.NoXCorrect
	Mov dword	[ebp+MGAMemory.XShift],3
.NoXCorrect	Cmp dword	[ebp+MGAMemory.YShift],2
	Jne	.NoYCorrect
	Mov dword	[ebp+MGAMemory.YShift],3
.NoYCorrect	Cmp dword	[ebp+MGAMemory.XRes],2048	; Max 2048x1536
	Ja	.Failure
	Cmp dword	[ebp+MGAMemory.YRes],1536
	Ja	.Failure
	Clc
	Ret
	;
.Failure	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupHorizontal	Mov	eax,[ebp+MGAMemory.XRes]	; htotal=(iXRes>>3)+20;
	Shr	eax,3
	Add	eax,20
	Mov	[ebp+MGAMemory.HTotal],eax	; 148
	;
	Cmp dword	[ebp+MGAMemory.XRes],1280	; if( iXRes>=1280 ) htotal+=htotal>>4;
	Jb	.No1280
	Mov	eax,[ebp+MGAMemory.HTotal]
	Shr	eax,4
	Add	eax,[ebp+MGAMemory.HTotal]
	Mov	[ebp+MGAMemory.HTotal],eax
	Jmp	.XResFixed
.No1280	Cmp dword	[ebp+MGAMemory.XRes],1024	; if( iXRes>=1024 ) htotal+=htotal>>3;
	Jb	.No1024
	Mov	eax,[ebp+MGAMemory.HTotal]
	Shr	eax,3
	Add	eax,[ebp+MGAMemory.HTotal]
	Mov	[ebp+MGAMemory.HTotal],eax	; 37
	Jmp	.XResFixed
.No1024:
.XResFixed	Sub dword	[ebp+MGAMemory.HTotal],5	; htotal-=5;	32
	;
	Mov	eax,[ebp+MGAMemory.XRes]	; hdispend=(iXRes>>3)-1;
	Shr	eax,3
	Dec	eax
	Mov	[ebp+MGAMemory.HDispEnd],eax
	;
	Mov	[ebp+MGAMemory.HBlkStr],eax	; hblkstr=hdispend
	;
	Mov	eax,[ebp+MGAMemory.HTotal]	; hblkend=htotal+5-1;
	Add	eax,5-1
	Mov	[ebp+MGAMemory.HBlkEnd],eax
	;
	Mov	eax,[ebp+MGAMemory.XRes]	; hsyncstr=(iXRes>>3)+1;
	Shr	eax,3
	Inc	eax
	Mov	[ebp+MGAMemory.HSyncStr],eax
	;
	Mov	eax,[ebp+MGAMemory.HSyncStr]	; hsyncend=(hsyncstr+12)&0x1F;
	Add	eax,12
	And	eax,0x1f
	Mov	[ebp+MGAMemory.HSyncEnd],eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupVertical	Mov	eax,[ebp+MGAMemory.YRes]	; vtotal=(iYRes)+45-2;
	Add	eax,45-2
	Mov	[ebp+MGAMemory.VTotal],eax
	;
	Mov	eax,[ebp+MGAMemory.YRes]	; vdispend=iYRes-1;
	Dec	eax
	Mov	[ebp+MGAMemory.VDispEnd],eax
	;
	Mov	eax,[ebp+MGAMemory.YRes]
	Dec	eax
	Mov	[ebp+MGAMemory.VBlkStr],eax
	;
	Mov	eax,[ebp+MGAMemory.VBlkStr]	; vblkend=(vblkstr-1+46)&0xFF;
	Add	eax,45
	And	eax,0xff
	Mov	[ebp+MGAMemory.VBlkEnd],eax
	;
	Mov	eax,[ebp+MGAMemory.YRes]	; vsyncstr=iYRes+9;
	Add	eax,9
	Mov	[ebp+MGAMemory.VSyncStr],eax
	;
	Mov	eax,[ebp+MGAMemory.VSyncStr]	; vsyncend=(vsyncstr+2)&0x0F;
	Add	eax,2
	And	eax,0xf
	Mov	[ebp+MGAMemory.VSyncEnd],eax
	;
	Mov dword	[ebp+MGAMemory.LineComp],1023	; linecomp=1023
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupDepth	Mov	eax,[ebp+MGAMemory.BPP]
	Mov dword	[ebp+MGAMemory.StartAddFactor],3
	Mov dword	[ebp+MGAMemory.VGA8Bit],8
	;
	Cmp	eax,8
	Jne	.No8Bit
	Mov dword	[ebp+MGAMemory.Scale],0
	Mov dword	[ebp+MGAMemory.Depth],0
	Mov dword	[ebp+MGAMemory.VGA8Bit],0
	Jmp	.Done
	;
.No8Bit	Cmp	eax,15
	Jne	.No15Bit
	Mov dword	[ebp+MGAMemory.Scale],1
	Mov dword	[ebp+MGAMemory.Depth],1
	Jmp	.Done
	;
.No15Bit	Cmp	eax,16
	Jne	.No16Bit
	Mov dword	[ebp+MGAMemory.Scale],1
	Mov dword	[ebp+MGAMemory.Depth],2
	Jmp	.Done
	;
.No16Bit	Cmp	eax,24
	Jne	.No24Bit
	Mov dword	[ebp+MGAMemory.Scale],2
	Mov dword	[ebp+MGAMemory.Depth],3
	Jmp	.Done
.No24Bit	Mov dword	[ebp+MGAMemory.Scale],3	; default to 32 if others failed
	Mov dword	[ebp+MGAMemory.Depth],7
.Done	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupPixelClock	Mov	ecx,[ebp+MGAMemory.HTotal]	; NormalPixelClock=((htotal+5)<<3)*(vtotal+2)*pParms->fRefreshRate;
	Add	ecx,5
	Shl	ecx,3
	;
	Mov	eax,[ebp+MGAMemory.VTotal]
	Add	eax,2
	XOr	edx,edx
	Mul	ecx
	;
	Mov	ecx,[ebp+MGAMemory.RefreshRate]
	Mul	ecx
	Mov	[ebp+MGAMemory.NormalPixelClock],eax

	Call	TrimPixelClock
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TrimPixelClock	Mov dword	[ebp+MGAMemory.VCO],0
	Mov dword	[ebp+MGAMemory.PixM],0
.Main	Inc dword	[ebp+MGAMemory.PixM]
	Cmp dword	[ebp+MGAMemory.PixM],31
	Je near	.Done

	XOr	edi,edi	; Inner looper
.Inner	Cmp	edi,3
	Je	.Main

	Test	edi,edi
	Jz	.ZC
	Mov	eax,edi
	Shl	eax,1
	Dec	eax
.ZC	Mov	eax,edi
	Mov	[ebp+MGAMemory.PixP],eax
	Inc	edi

	Mov	eax,[ebp+MGAMemory.PixP]
	Inc	eax
	Mov	ebx,[ebp+MGAMemory.PixM]
	Inc	ebx
	Mul	ebx
	; n
	Mov	ebx,[ebp+MGAMemory.NormalPixelClock]
	IMul	ebx
	Mov	ebx,27000000
	IDiv	ebx
	; n
	Mov	[ebp+MGAMemory.PixN],eax
	And dword	[ebp+MGAMemory.PixN],0xff
	Dec dword	[ebp+MGAMemory.PixN]

	Cmp dword	[ebp+MGAMemory.PixN],7
	Jb	.Inner
	Cmp dword	[ebp+MGAMemory.PixN],127
	Ja	.Inner

	Mov	eax,27000000
	Mov	ebx,[ebp+MGAMemory.PixN]
	Inc	ebx
	IMul	ebx
	Mov	ebx,[ebp+MGAMemory.PixM]
	Inc	ebx
	IDiv	ebx

	Mov	[ebp+MGAMemory.VCO],eax
	Xor	edx,edx
	Mov	ebx,[ebp+MGAMemory.PixP]
	Inc	ebx
	IDiv	ebx

	Mov	ebx,[ebp+MGAMemory.BestPixelClock]
	Sub	ebx,[ebp+MGAMemory.NormalPixelClock]
	Mov	ecx,eax
	Sub	ecx,[ebp+MGAMemory.NormalPixelClock]

	Cmp	ebx,0
	Jb	.NoNeg
	Neg	ebx
.NoNeg	Cmp	ecx,0
	Jb	.NoNeg2
	Neg	ecx
.NoNeg2	Cmp	ebx,ecx
	Jb near	.Inner

	Mov	[ebp+MGAMemory.BestPixelClock],eax
	Mov	eax,[ebp+MGAMemory.PixM]
	Mov	ebx,[ebp+MGAMemory.PixN]
	Mov	ecx,[ebp+MGAMemory.PixP]
	Mov	[ebp+MGAMemory.BestM],eax
	Mov	[ebp+MGAMemory.BestN],ebx
	Mov	[ebp+MGAMemory.BestP],ecx
	Jmp	.Inner
	;
.Done	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupVGALUT	Mov	edx,[ebp+MGAMemory.BPP]	; Set up the VGA LUT. We could implement a gamma for
	;			; 15, 16, 24 and 32 bit if we wanted because they use the LUT
	;----
	Cmp	edx,4
	Jne	.Try8Bit
	Jmp	.Done
	;----
.Try8Bit	Cmp	edx,8
	Jne	.Try15Bit
	Jmp	.Done
	;----
.Try15Bit	Cmp	edx,15
	Jne	.Try16Bit

	Mov	dx,VGAREG_DACWRITE
	XOr	al,al
	Out	dx,al
	;
	XOr	ecx,ecx
	Mov	dx,VGAREG_DACDATA
.L15	Cmp	ecx,256
	Je	.Done
	Mov	eax,ecx
	Shl	eax,3
	Out	dx,al
	Inc	ecx
	Jmp	.L15
	;----
.Try16Bit	Cmp	edx,16
	Jne	.Try2432Bit
	Mov	dx,VGAREG_DACWRITE
	XOr	al,al
	Out	dx,al
	;
	XOr	ecx,ecx
	Mov	dx,VGAREG_DACDATA
.L16	Cmp	ecx,256
	Je	.Done
	Mov	eax,ecx
	Shl	eax,3
	Out	dx,al
	Mov	eax,ecx
	Shl	eax,2
	Out	dx,al
	Mov	eax,ecx
	Shl	eax,3
	Out	dx,al
	Inc	ecx
	Jmp	.L16
	;----
.Try2432Bit	Mov	dx,VGAREG_DACWRITE
	XOr	al,al
	Out	dx,al
	;
	XOr	ecx,ecx
	Mov	dx,VGAREG_DACDATA
.L2432	Cmp	ecx,256
	Mov	ax,cx
	Out	dx,al
	Inc	ecx
	Jmp	.L2432
	;----
.Done	Ret

