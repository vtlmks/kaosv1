
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

KCMD_SetWPort	Equ	0xd1	; Set write mode to 804x output port for the next byte.
KCMD_SetA20	Equ	0xdf	; Enable address line A20
KEYBP_DATA	Equ	0x60	; Keyboard dataport (input)
KEYBP_STAT	Equ	0x61	; Keyboard status

Integer	Equ	0
String	Equ	1
Plain	Equ	2
StringPtr	Equ	3
TAG_DONE	Equ	0


%MACRO	PRINT	1
	Mov	dx,%1
	Call	PrintStr
%ENDM


%DEFINE	DEBUG		; Remove this for release versions


	Org	0x100
	Bits	16
	Section	.text
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Start	Mov	ax,cs
	Mov	ds,ax
	Mov	es,ax
	Call	CheckSystemState
	Call	GetBIOSEqList
	Call	GetCPUID
	Call	GetMemory
	Call	GetVesaInfo
	;
	Call	OutputData
	Call	ProbePCI
Exit	Mov	ah,0x4c
	Int	0x21


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CheckSystemState
	%IFNDEF DEBUG
	Mov	eax,cr0
	Bt	eax,0
	Jc	.Failure
	Ret

.Failure	Mov	ah,9
	Mov	dx,MainTxt
	Int	0x21
	Mov	ah,9
	Mov	dx,SysFailTxt
	Int	0x21
	Add	sp,4
	Mov	ah,0x4c
	Int	0x21
	%ENDIF
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
GetBIOSEqList	Int	0x11
	Mov	[_BIOSEquip],eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
GetCPUID	Mov	eax,1
	CPUID
	Mov	[_CPUStepping],al
	And dword	[_CPUStepping],0xf
	And	al,0xf0
	Shr	al,4
	Mov byte	[_CPUModel],al
	And	ax,0xf00
	Shr	ax,8
	Mov byte	[_CPUType],al
	;
	Mov	[_CPUFeatures],edx

	Mov	eax,1
	CPUID
	Shr	ax,12
	And	ax,0x3
	Mov	esi,[ProcTypeTable+eax*4]
	Mov	edi,_ProcType
	Mov	ecx,28
	Rep Movsb
	;
	XOr	eax,eax
	CPUID
	Mov	[_CPUName],ebx
	Mov	[_CPUName+4],edx
	Mov	[_CPUName+8],ecx
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
GetMemory
	%IFNDEF DEBUG
	Pushad
	Call	EnableA20
	XOr	ebx,ebx
	Mov	bx,cs
	Shl	ebx,4
	Lea	eax,[GDTTable+ebx]
	Mov	[GDTLimit+2],eax
	LGDT	[cs:GDTLimit]
	Mov	ecx,1
	Mov	cr0,ecx
	Push	ds
	Push word	SYSDATA_SEL
	Pop	ds
	Mov	eax,0x100000
.L	Mov dword	[ds:eax],0xDEADBEEF
	Cmp dword	[ds:eax],0XDEADBEEF
	Jne	.Done
	Lea	eax,[eax+0x100000]
	Jmp	.L
.Done	XOr	ecx,ecx
	Mov	cr0,ecx
	Pop	ds
	Mov	[_TotalMemory],eax
	Popad
	%ENDIF
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
GetVesaInfo	Mov	ax,0x4f00
	Mov	di,CardInfoBuf
	Int	0x10
	Movzx	eax,word [CardInfoBuf+VBE_Version]
	Mov	[_VESAVersion],eax
	Movzx	eax,word [CardInfoBuf+VBE_TotalMem]
	Shl	eax,6
	Mov	[_VESATotalMem],eax
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
PCIDeviceMax	Equ	32
PCIFunctionMax	Equ	7

ProbePCI	Cmp byte	[BusNumber],15
	Je	.Done
	Call	TestPCI
	Inc byte	[BusNumber]
	Jmp	ProbePCI
.Done	Ret


TestPCI	XOr	dx,dx
.Loop	Cmp	dh,PCIDeviceMax
	Je	.NextFunction
	XOr	bx,bx
	Mov	bl,dh	; Device
	Shl	bx,3
	Add	bl,dl	; Function
	Mov	bh,[BusNumber]	; Bus number
	Mov	ax,0xb10a
	XOr	di,di
	Push	bx
	Push	dx
	Int	0x1a
	Pop	dx
	Pop	bx
	Test	ecx,ecx
	Jz	.Skip
	Cmp	ecx,-1
	Je	.Skip
	Cmp	ah,0x87
	Je	.Skip
	Call	PCIDump
.Skip	Inc	dh
	Jmp	.Loop
.NextFunction	Cmp	dl,PCIFunctionMax
	Je	.Done
	Inc	dl
	XOr	dh,dh
	Jmp	.Loop
.Done	Ret

PCIDump	Pushad
	XOr	eax,eax
	Mov	al,bh
	Mov	di,PCIBuffer
	Call	Hex2AscII
	PRINT	PCIBusTxt
	Mov	dx,PCIBuffer
	Call	PrintByte
	;
	XOr	eax,eax
	Push	bx
	Mov	al,bl
	And	al,11111000B
	Shr	al,3
	Mov	di,PCIBuffer
	Call	Hex2AscII
	PRINT	PCIDeviceTxt
	Mov	dx,PCIBuffer
	Call	PrintByte
	Pop	bx
	;
	XOr	eax,eax
	Mov	al,bl
	And	al,7
	Mov	di,PCIBuffer
	Call	Hex2AscII
	PRINT	PCIFunctionTxt
	Mov	dx,PCIBuffer
	Call	PrintByte

	Push	ecx
	Mov	eax,ecx
	Mov	di,PCIBuffer
	Call	Hex2AscII
	PRINT	PCIVendorTxt
	Mov	dx,PCIBuffer+4
	Call	PrintStr
	PRINT	PCIProductTxt
	Mov	edx,PCIBuffer
	Mov byte	[edx+4],"$"
	Call	PrintStr
	Pop	ecx	; Vendor/Product ID

	;;

	Lea	esi,[PCITable]
.L	Lodsd
	Cmp	eax,-1
	Je	.Done
	Cmp	eax,ecx
	Je	.Found
	Lodsd
	Jmp	.L
.Found	Lodsd
	Mov	edx,eax
	Call	PrintStr


.Done	PRINT	LineFeedTxt
	Popad
	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EnableA20	Cli
.L	In	al,KEYBP_STAT
	Test	al,2
	Jnz	.L
	Mov	al,KCMD_SetWPort
	Out	KEYBP_STAT,al
.L1	In	al,KEYBP_STAT
	Test	al,2
	Jnz	.L1
	Mov	al,KCMD_SetA20
	Out	KEYBP_DATA,al
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Hex to AscII
; eax = Longword to be converted
; edi = Pointer to 8 byte buffer for result

Hex2AscII	Cld
	Pushad
	Mov	ecx,8
.L	Rol	eax,4
	Push	eax
	And	al,0xf
	Cmp	al,0xa
	Sbb	al,0x69
	Das
	Mov	ah,7
	Stosb
	Pop	eax
	Loop	.L
	Popad
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
OutputData	XOr	ebx,ebx
	Mov	esi,OutputTable
.Loop	Mov	eax,[esi]
	Test	eax,eax
	Jz	.Done
	Mov	ecx,[esi+4]
	Cmp	cl,Integer
	Je	.Integer
	Cmp	cl,String
	Je	.String
.Next	Lea	esi,[esi+12]
	Jmp	.Loop
.Done	Ret
	;
.Integer	Mov	edx,[esi+8]
	Call	PrintStr
	Mov	di,IntegerBuffer
	Mov	eax,[eax]
	Call	Hex2AscII
	Mov	edx,IntegerStr
	Call	PrintInt
	Jmp	.Next
	;
.String	Mov	edx,eax
	Call	PrintStr
	Mov	edx,[esi+8]
	Test	edx,edx
	Jz	.NoString
	Call	PrintStr
.NoString	Jmp	.Next

PrintStr	Pushad
	Mov	ah,9
	;dx = sheit to output
	Int	0x21
	Popad
	Ret


PrintInt	Cmp dword	[edx],"0000"
	Jne	.No
	Cmp dword	[edx+4],"0000"
	Jne	.No
	Mov	edx,NullTxt
	Jmp	PrintStr
.No	Cmp byte	[edx],"0"
	Jne	PrintStr
	Inc	edx
	Jmp	.No

PrintByte	Add	dx,6
	Mov	ah,9
	Int	0x21
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
_CPUType	Dd	0
_CPUModel	Dd	0
_CPUStepping	Dd	0
_CPUFeatures	Dd	0
_CPUName	Dd	0,0,0
	Db	"$"
	Dd	0
_ProcType	Times 28 Db 	0

_BIOSEquip	Dd	0
_TotalMemory	Dd	0
_VESAVersion	Dd	0
_VESATotalMem	Dd	0

OutputTable	Dd	MainTxt,String,0
	Dd	_CPUType,Integer,CPUTypeTxt
	Dd	_CPUModel,Integer,CPUModelTxt
	Dd	_CPUStepping,Integer,CPUSteppingTxt
	Dd	_CPUFeatures,Integer,CPUFeaturesTxt
	Dd	CPUStringTxt,String,_CPUName
	Dd	LineFeedTxt,String,0
	Dd	CPUFieldTxt,String,_ProcType
	Dd	LineFeedTxt,String,0
	Dd	_BIOSEquip,Integer,BIOSEquipTxt
	Dd	LineFeedTxt,String,0
	Dd	_TotalMemory,Integer,TotalMemTxt
	Dd	LineFeedTxt,String,0
	Dd	_VESAVersion,Integer,VesaVersionTxt
	Dd	_VESATotalMem,Integer,VesaTotalMemTxt
	Dd	LineFeedTxt,String,0
	Dd	TAG_DONE

BusNumber	Db	0

SysFailTxt	Db	"** Error: Processor is running in protectedmode. Please reboot to DOS.",0xd,0xa,"$"

CPUTypeTxt	Db	"Processor type      : $"
CPUModelTxt	Db	"Processor model     : $"
CPUSteppingTxt	Db	"Processor stepping  : $"
CPUStringTxt	Db	"Processor string    : $"
CPUFieldTxt	Db	"Processor typefield : $"
CPUFeaturesTxt	Db	"Processor features  : $"
BIOSEquipTxt	Db	"Equipment bitfield  : $"
TotalMemTxt	Db	"Total memory        : $"
VesaVersionTxt	Db	"VESA version        : $"
VesaTotalMemTxt	Db	"VESA totalmemory    : $"



ProcTypeTable	Dd	ProcType1N
	Dd	ProcType2N
	Dd	ProcType3N
	Dd	ProcType4N

ProcType1N	Db	"Original OEM Processor     $"
ProcType2N	Db	"Intel OverDrive Processor  $"
ProcType3N	Db	"Dual processor             $"
ProcType4N	Db	"Intel reserved             $"


IntegerStr
IntegerBuffer	Times 8 Db	0
	Db	13,10,"$"

LineFeedTxt	Db	13,10,"$"

NullTxt	Db	"0",13,10,"$"

PCIBusTxt	Db	"B: ","$"
PCIDeviceTxt	Db	"D: ","$"
PCIFunctionTxt	Db	"F: ","$"
PCIVendorTxt	Db	"V: ","$"
PCIProductTxt	Db	"P: ","$"

PCIBuffer	Times 8 Db	0
	Db	" $"

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
MainTxt	Db	13,10
	Db	"KAOS (IA32) Systemprober V1.0.0.",13,10
	Db	"Copyright (c)1995-2001 Mindkiller Systems inc.",13,10
	Db	"All rights reserved.",13,10,13,10,13,10,"$"

	; Omicron, Platinum


 ;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GDTLimit	Dw	GDTLength-GDTTable-1
	Dd	GDTTable

GDTTable	Dd	0,0
GDTSysCode	Dw	0xFFFF,0
	Db	0,10011010b,11001111b,0
GDTSysData	Dw	0xFFFF,0
	Db	0,10010010b,11001111b,0
GDTLength

SYSCODE_SEL	EQU	GDTSysCode-GDTTable
SYSDATA_SEL	EQU	GDTSysData-GDTTable

CardInfoBuf	Times VBEInfoB_Size Db 0

PCITable
	Dd	0x4C421002,ATI3DRageAGP133

	Dd	0x0518102b,MatroxMGA2
	Dd	0x0519102b,MatroxMill
	Dd	0x051a102b,MatroxMyst
	Dd	0x051b102b,MatroxMil2
	Dd	0x051f102b,MatroxMil2AGP
	Dd	0x0d10102b,MatroxMGAIMP
	Dd	0x1000102b,MatroxG100MM
	Dd	0x1001102b,MatroxG100AGP
	Dd	0x0520102b,MatroxG200PCI
	Dd	0x0521102b,MatroxG200AGP
	Dd	0x0525102b,MatroxG400
	Dd	0x4536102b,MatroxVIA

	Dd	0xAC1C104C,TexasPCI1225
	Dd	0x8019104C,TexasIEEE1394

	Dd	0x000110b7,ECOM0001
	Dd	0x339010b7,ECOM3390
	Dd	0x359010b7,ECOM3590
	Dd	0x450010b7,ECOM4500
	Dd	0x505510b7,ECOM5055
	Dd	0x505710b7,ECOM5057
	Dd	0x5a5710b7,ECOM5a57
	Dd	0x515710b7,ECOM5157
	Dd	0x5b5710b7,ECOM5b57
	Dd	0x525710b7,ECOM5257
	Dd	0x590010b7,ECOM5900
	Dd	0x592010b7,ECOM5920
	Dd	0x595010b7,ECOM5950
	Dd	0x595110b7,ECOM5951
	Dd	0x595210b7,ECOM5952
	Dd	0x597010b7,ECOM5970
	Dd	0x656010b7,ECOM6560
	Dd	0x656210b7,ECOM6562
	Dd	0x656410b7,ECOM6564
	Dd	0x764610b7,ECOM7646
	Dd	0x881110b7,ECOM8811
	Dd	0x900010b7,ECOM9000
	Dd	0x900110b7,ECOM9001
	Dd	0x900410b7,ECOM9004
	Dd	0x900510b7,ECOM9005
	Dd	0x900610b7,ECOM9006
	Dd	0x900a10b7,ECOM900a
	Dd	0x905010b7,ECOM9050
	Dd	0x905110b7,ECOM9051
	Dd	0x905510b7,ECOM9055
	Dd	0x905610b7,ECOM9056
	Dd	0x905810b7,ECOM9058
	Dd	0x905a10b7,ECOM905a
	Dd	0x920010b7,ECOM9200
	Dd	0x100010b7,ECOM1000
	Dd	0x980010b7,ECOM9800
	Dd	0x980510b7,ECOM9805

	Dd	0x000810de,NVidia0008
	Dd	0x000910de,NVidia0009
	Dd	0x001010de,NVidia0010
	Dd	0x002010de,NVidia0020
	Dd	0x002810de,NVidia0028
	Dd	0x002910de,NVidia0029
	Dd	0x002a10de,NVidia002a
	Dd	0x002b10de,NVidia002b
	Dd	0x002c10de,NVidia002c
	Dd	0x002d10de,NVidia002d
	Dd	0x002e10de,NVidia002e
	Dd	0x002f10de,NVidia002f
	Dd	0x00a010de,NVidia00a0
	Dd	0x010010de,NVidia0100
	Dd	0x010110de,NVidia0101
	Dd	0x010310de,NVidia0103
	Dd	0x011010de,NVidia0110
	Dd	0x011110de,NVidia0111
	Dd	0x011310de,NVidia0113
	Dd	0x015010de,NVidia0150
	Dd	0x015110de,NVidia0151
	Dd	0x015210de,NVidia0152
	Dd	0x015310de,NVidia0153

	Dd	0x802910ec,RealTek8029
	Dd	0x812910ec,RealTek8129
	Dd	0x813910ec,RealTek8139

	Dd	0x00021102,CLSBLiveEMU10000
	Dd	0x70021102,CLSBLive
	Dd	0x00201102,CLCT4850
	Dd	0x00211102,CLCT4620
	Dd	0x002f1102,CLSBLiveMainB
	Dd	0x40011102,CLEmuAps
	Dd	0x80221102,CLCT4780
	Dd	0x80231102,CLCT4790
	Dd	0x80241102,CLCT4760
	Dd	0x80251102,CLCTSBLiveMainB2
	Dd	0x80261102,CLCT4830
	Dd	0x80271102,CLCT4832
	Dd	0x80311102,CLCT4831
	Dd	0x80401102,CLCT47602
	Dd	0x80511102,CLCT48502
	Dd	0x00201102,CLCTGamePort

	Dd	0x00031103,TTIHPT343
	Dd	0x00041103,TTIHPT366

	Dd	0x1978125D,ESSES1978

	Dd	0x12298086,Intel82557
	Dd	0x71108086,Intel82371AB_0
	Dd	0x71118086,Intel82371AB
	Dd	0x71128086,Intel82371AB_2
	Dd	0x71138086,Intel82371AB_3
	Dd	0x71908086,Intel82443BX_0
	Dd	0x71918086,Intel82443BX_1
	Dd	0x71928086,Intel82443BX_2

	Dd	0x00089004,Adaptec90040008
	Dd	0x00099004,Adaptec90040009
	Dd	0x00109004,Adaptec90040010
	Dd	0x00189004,Adaptec90040018
	Dd	0x00209004,Adaptec90040020
	Dd	0x00289004,Adaptec90040028
	Dd	0x10789004,Adaptec90041078
	Dd	0x11609004,Adaptec90041160
	Dd	0x21789004,Adaptec90042178
	Dd	0x38609004,Adaptec90043860
	Dd	0x3b789004,Adaptec90043b78
	Dd	0x50759004,Adaptec90045075
	Dd	0x50789004,Adaptec90045078
	Dd	0x51759004,Adaptec90045175
	Dd	0x51789004,Adaptec90045178
	Dd	0x52759004,Adaptec90045275
	Dd	0x52789004,Adaptec90045278
	Dd	0x53759004,Adaptec90045375
	Dd	0x53789004,Adaptec90045378
	Dd	0x54759004,Adaptec90045475
	Dd	0x54789004,Adaptec90045478
	Dd	0x55759004,Adaptec90045575
	Dd	0x55789004,Adaptec90045578
	Dd	0x56759004,Adaptec90045675
	Dd	0x56789004,Adaptec90045678
	Dd	0x57759004,Adaptec90045775
	Dd	0x57789004,Adaptec90045778
	Dd	0x58009004,Adaptec90045800
	Dd	0x59009004,Adaptec90045900
	Dd	0x59059004,Adaptec90045905
	Dd	0x60389004,Adaptec90046038
	Dd	0x60759004,Adaptec90046075
	Dd	0x60789004,Adaptec90046078
	Dd	0x61789004,Adaptec90046178
	Dd	0x62789004,Adaptec90046278
	Dd	0x63789004,Adaptec90046378
	Dd	0x64789004,Adaptec90046478
	Dd	0x65789004,Adaptec90046578
	Dd	0x66789004,Adaptec90046678
	Dd	0x67789004,Adaptec90046778
	Dd	0x69159004,Adaptec90046915
	Dd	0x70789004,Adaptec90047078
	Dd	0x71789004,Adaptec90047178
	Dd	0x72789004,Adaptec90047278
	Dd	0x73789004,Adaptec90047378
	Dd	0x74789004,Adaptec90047478
	Dd	0x75789004,Adaptec90047578
	Dd	0x76789004,Adaptec90047678
	Dd	0x77789004,Adaptec90047778
	Dd	0x78109004,Adaptec90047810
	Dd	0x78159004,Adaptec90047815
	Dd	0x78409004,Adaptec90047840
	Dd	0x78509004,Adaptec90047850
	Dd	0x78559004,Adaptec90047855
	Dd	0x78609004,Adaptec90047860
	Dd	0x78619004,Adaptec90047861
	Dd	0x78709004,Adaptec90047870
	Dd	0x78719004,Adaptec90047871
	Dd	0x78729004,Adaptec90047872
	Dd	0x78739004,Adaptec90047873
	Dd	0x78749004,Adaptec90047874
	Dd	0x78809004,Adaptec90047880
	Dd	0x78819004,Adaptec90047881
	Dd	0x78879004,Adaptec90047887
	Dd	0x78909004,Adaptec90047890
	Dd	0x78919004,Adaptec90047891
	Dd	0x78929004,Adaptec90047892
	Dd	0x78939004,Adaptec90047893
	Dd	0x78949004,Adaptec90047894
	Dd	0x78959004,Adaptec90047895
	Dd	0x78969004,Adaptec90047896
	Dd	0x78979004,Adaptec90047897
	Dd	0x80089004,Adaptec90048008
	Dd	0x80099004,Adaptec90048009
	Dd	0x80109004,Adaptec90048010
	Dd	0x80189004,Adaptec90048018
	Dd	0x80209004,Adaptec90048020
	Dd	0x80289004,Adaptec90048028
	Dd	0x80789004,Adaptec90048078
	Dd	0x81789004,Adaptec90048178
	Dd	0x82789004,Adaptec90048278
	Dd	0x83789004,Adaptec90048378
	Dd	0x84789004,Adaptec90048478
	Dd	0x85789004,Adaptec90048578
	Dd	0x86789004,Adaptec90048678
	Dd	0x87789004,Adaptec90048778
	Dd	0x88789004,Adaptec90048878
	Dd	0x8b789004,Adaptec90048b78
	Dd	0xec789004,Adaptec9004ec78

	Dd	0x00109005,Adaptec0010
	Dd	0x00119005,Adaptec0011
	Dd	0x00139005,Adaptec0013
	Dd	0x00039005,Adaptec0003
	Dd	0x001f9005,Adaptec001f
	Dd	0x000f9005,Adaptec000f
	Dd	0xa1809005,Adapteca180
	Dd	0x00209005,Adaptec0020
	Dd	0x002f9005,Adaptec002f
	Dd	0x00309005,Adaptec0030
	Dd	0x003f9005,Adaptec003f
	Dd	0x00509005,Adaptec0050
	Dd	0x00519005,Adaptec0051
	Dd	0x00539005,Adaptec0053
	Dd	0xffff9005,Adaptecffff
	Dd	0x005f9005,Adaptec005f
	Dd	0x00809005,Adaptec0080
	Dd	0x00819005,Adaptec0081
	Dd	0x00839005,Adaptec0083
	Dd	0x008f9005,Adaptec008f
	Dd	0x00c09005,Adaptec00c0
	Dd	0x00c19005,Adaptec00c1
	Dd	0x00c39005,Adaptec00c3
	Dd	0x00cf9005,Adaptec00cf

	Dd	0x0710fffe,VMWareSVGA

	;---
	Dd	0x00000000,Illegal
	Dd	0x0000ffff,Illegal
	;---
	Dd	-1


Serial	Db	" Communication Serial $",0

CLSBLive	Db	" CreativeLabs SB Live! $"
CLSBLiveEMU10000	Db	" SB Live! EMU10000 $"
CLCT4850	Db	" CreativeLabs CT4850 SBLive! Value $"
CLCT4620	Db	" CreativeLabs CT4620 SBLive! $"
CLSBLiveMainB	Db	" CreativeLabs SBLive! mainboard implementation $"
CLEmuAps	Db	" CreativeLabs E-mu APS $"
CLCT4780	Db	" CreativeLabs CT4780 SBLive! Value $"
CLCT4790	Db	" CreativeLabs CT4790 SoundBlaster PCI512 $"
CLCT4760	Db	" CreativeLabs CT4760 SBLive! $"
CLCTSBLiveMainB2	Db	" CreativeLabs SBLive! Mainboard Implementation $"
CLCT4830	Db	" CreativeLabs CT4830 SBLive! Value $"
CLCT4832	Db	" CreativeLabs CT4832 SBLive! Value $"
CLCT4831	Db	" CreativeLabs CT4831 SBLive! Value $"
CLCT47602	Db	" CreativeLabs CT4760 SBLive! $"
CLCT48502	Db	" CreativeLabs CT4850 SBLive! Value $"
CLCTGamePort	Db	" CreativeLabs Gameport Joystick $"


TTIHPT343	Db	" TTI HPT343 $"
TTIHPT366	Db	" TTI HPT366/370 $"

Intel82371AB_0	Db	" Intel 82371AB 0 $"
Intel82371AB	Db	" Intel 82371AB $"
Intel82371AB_2	Db	" Intel 82371AB 2 $"
Intel82371AB_3	Db	" Intel 82371AB 3 $"
Intel82443BX_0	Db	" Intel 82443BX 0 $"
Intel82443BX_1	Db	" Intel 82443BX 1 $"
Intel82443BX_2	Db	" Intel 82443BX 2 $"
Intel82557	Db	" Intel 82557 $"

MatroxMGA2	Db	" Matrox MGA 2 $"
MatroxMill	Db	" Matrox Millenium $"
MatroxMyst	Db	" Matrox Mystique $"
MatroxMil2	Db	" Matrox Millenium 2 $"
MatroxMil2AGP	Db	" Matrox Millenium 2 AGP $"
MatroxMGAIMP	Db	" Matrox MGA IMP $"
MatroxG100MM	Db	" Matrox G100 MM $"
MatroxG100AGP	Db	" Matrox G100 AGP $"
MatroxG200PCI	Db	" Matrox G200 PCI $"
MatroxG200AGP	Db	" Matrox G200 AGP $"
MatroxG400	Db	" Matrox G400 $"
MatroxVIA	Db	" Matrox VIA $"

RealTek8029	Db	" RealTek 8029 $"
RealTek8129	Db	" RealTek 8129 $"
RealTek8139	Db	" RealTek 8139 $"

TexasPCI1225	Db	" Texas Instruments PCI1225 $"
TexasIEEE1394	Db	" Texas Instruments IEEE-1394 Controller $"

ESSES1978	Db	" ESS Technology ES1978 Maestro 2E $"

ATI3DRageAGP133	Db	" ATI 3D Rage LT Pro AGP-133 $"

NVidia0008	Db	" nVidia EDGE 3D [NV1] $"
NVidia0009	Db	" nVidia EDGE 3D [NV1] $"
NVidia0010	Db	" nVidia Mutara V08 [NV2] $"
NVidia0020	Db	" nVidia Riva TnT 128 [NV04] $"
NVidia0028	Db	" nVidia Riva TnT2 [NV5] $"
NVidia0029	Db	" nVidia Riva TnT2 Ultra [NV5] $"
NVidia002a	Db	" nVidia Riva TnT2 [NV5] $"
NVidia002b	Db	" nVidia Riva TnT2 [NV5] $"
NVidia002c	Db	" nVidia Vanta [NV6] $"
NVidia002d	Db	" nVidia Vanta [NV6] $"
NVidia002e	Db	" nVidia Vanta [NV6] $"
NVidia002f	Db	" nVidia Vanta [NV6] $"
NVidia00a0	Db	" nVidia Riva TNT2 $"
NVidia0100	Db	" nVidia GeForce 256 $"
NVidia0101	Db	" nVidia GeForce 256 DDR $"
NVidia0103	Db	" nVidia Quadro (GeForce 256 GL) $"
NVidia0110	Db	" nVidia NV11 $"
NVidia0111	Db	" nVidia NV11 DDR $"
NVidia0113	Db	" nVidia NV11 GL $"
NVidia0150	Db	" nVidia NV15 (Geforce2 GTS) $"
NVidia0151	Db	" nVidia NV15 DDR (Geforce2 GTS) $"
NVidia0152	Db	" nVidia NV15 Bladerunner (Geforce2 GTS) $"
NVidia0153	Db	" nVidia NV15 GL (Quadro2) $"

ECOM0001	Db	" 3COM 3c985 1000BaseSX $"
ECOM3390	Db	" 3COM Token Link Velocity $"
ECOM3590	Db	" 3COM 3c359 TokenLink Velocity XL $"
ECOM4500	Db	" 3COM 3c450 Cyclone/unknown $"
ECOM5055	Db	" 3COM 3c555 Laptop Hurricane $"
ECOM5057	Db	" 3COM 3c575 [Megahertz] 10/100 LAN CardBus $"
ECOM5a57	Db	" 3COM 3C575 Megahertz 10/100 LAN Cardbus PC Card $"
ECOM5157	Db	" 3COM 3c575 [Megahertz] 10/100 LAN CardBus $"
ECOM5b57	Db	" 3COM 3C575 Megahertz 10/100 LAN Cardbus PC Card $"
ECOM5257	Db	" 3COM 3CCFE575CT Cyclone CardBus $"
ECOM5900	Db	" 3COM 3c590 10BaseT [Vortex] $"
ECOM5920	Db	" 3COM 3c592 EISA 10mbps Demon/Vortex $"
ECOM5950	Db	" 3COM 3c595 100BaseTX [Vortex] $"
ECOM5951	Db	" 3COM 3c595 100BaseT4 [Vortex] $"
ECOM5952	Db	" 3COM 3c595 100Base-MII [Vortex] $"
ECOM5970	Db	" 3COM 3c597 EISA Fast Demon/Vortex $"
ECOM6560	Db	" 3COM 3CCFE656 Cyclone CardBus $"
ECOM6562	Db	" 3COM 3CCFEM656 [id 6562] Cyclone CardBus $"
ECOM6564	Db	" 3COM 3CCFEM656 [id 6564] Cyclone CardBus $"
ECOM7646	Db	" 3COM 3cSOHO100-TX Hurricane $"
ECOM8811	Db	" 3COM Token ring $"
ECOM9000	Db	" 3COM 3c900 10BaseT [Boomerang] $"
ECOM9001	Db	" 3COM 3c900 Combo [Boomerang] $"
ECOM9004	Db	" 3COM 3c900B-TPO [Etherlink XL TPO] $"
ECOM9005	Db	" 3COM 3c900B-Combo [Etherlink XL Combo] $"
ECOM9006	Db	" 3COM 3c900B-TPC [Etherlink XL TPC] $"
ECOM900a	Db	" 3COM 3c900B-FL [Etherlink XL FL] $"
ECOM9050	Db	" 3COM 3c905 100BaseTX [Boomerang] $"
ECOM9051	Db	" 3COM 3c905 100BaseT4 $"
ECOM9055	Db	" 3COM 3c905B 100BaseTX [Cyclone] $"
ECOM9056	Db	" 3COM 3c905B-T4 $"
ECOM9058	Db	" 3COM 3c905B-Combo [Deluxe Etherlink XL 10/100] $"
ECOM905a	Db	" 3COM 3c905B-FX [Fast Etherlink XL FX 10/100] $"
ECOM9200	Db	" 3COM 3c905C-TX [Fast Etherlink] $"
ECOM1000	Db	" 3COM 3C905C-TX Fast Etherlink for PC Management NIC $"
ECOM9800	Db	" 3COM 3c980-TX [Fast Etherlink XL Server Adapter] $"
ECOM9805	Db	" 3COM 3c980-TX 10/100baseTX NIC [Python-T] $"



Adaptec90040008	Db	" Adaptec ANA69011A/TX 10/100 $"
Adaptec90040009	Db	" Adaptec ANA69011A/TX 10/100 $"
Adaptec90040010	Db	" Adaptec ANA62022 2-port 10/100 $"
Adaptec90040018	Db	" Adaptec ANA62044 4-port 10/100 $"
Adaptec90040020	Db	" Adaptec ANA62022 2-port 10/100 $"
Adaptec90040028	Db	" Adaptec ANA69011A/TX 10/100 $"
Adaptec90041078	Db	" Adaptec AIC-7810 $"
Adaptec90041160	Db	" Adaptec AIC-1160 [Family Fiber Channel Adapter] $"
Adaptec90042178	Db	" Adaptec AIC-7821 $"
Adaptec90043860	Db	" Adaptec AHA-2930CU $"
Adaptec90043b78	Db	" Adaptec AHA-4844W/4844UW $"
Adaptec90045075	Db	" Adaptec AIC-755x $"
Adaptec90045078	Db	" Adaptec AHA-7850 $"
Adaptec90045175	Db	" Adaptec AIC-755x $"
Adaptec90045178	Db	" Adaptec AIC-7851 $"
Adaptec90045275	Db	" Adaptec AIC-755x $"
Adaptec90045278	Db	" Adaptec AIC-7852 $"
Adaptec90045375	Db	" Adaptec AIC-755x $"
Adaptec90045378	Db	" Adaptec AIC-7850 $"
Adaptec90045475	Db	" Adaptec AIC-2930 $"
Adaptec90045478	Db	" Adaptec AIC-7850 $"
Adaptec90045575	Db	" Adaptec AVA-2930 $"
Adaptec90045578	Db	" Adaptec AIC-7855 $"
Adaptec90045675	Db	" Adaptec AIC-755x $"
Adaptec90045678	Db	" Adaptec AIC-7850 $"
Adaptec90045775	Db	" Adaptec AIC-755x $"
Adaptec90045778	Db	" Adaptec AIC-7850 $"
Adaptec90045800	Db	" Adaptec AIC-5800 $"
Adaptec90045900	Db	" Adaptec ANA-5910/5930/5940 ATM155 & 25 LAN Adapter $"
Adaptec90045905	Db	" Adaptec ANA-5910A/5930A/5940A ATM Adapter $"
Adaptec90046038	Db	" Adaptec AIC-3860 $"
Adaptec90046075	Db	" Adaptec AIC-1480 / APA-1480 $"
Adaptec90046078	Db	" Adaptec AIC-7860 $"
Adaptec90046178	Db	" Adaptec AIC-7861 $"
Adaptec90046278	Db	" Adaptec AIC-7860 $"
Adaptec90046378	Db	" Adaptec AIC-7860 $"
Adaptec90046478	Db	" Adaptec AIC-786 $"
Adaptec90046578	Db	" Adaptec AIC-786x $"
Adaptec90046678	Db	" Adaptec AIC-786 $"
Adaptec90046778	Db	" Adaptec AIC-786x $"
Adaptec90046915	Db	" Adaptec ANA620xx/ANA69011A $"
Adaptec90047078	Db	" Adaptec AHA-294x / AIC-7870 $"
Adaptec90047178	Db	" Adaptec AHA-294x / AIC-7871 $"
Adaptec90047278	Db	" Adaptec AHA-3940 / AIC-7872 $"
Adaptec90047378	Db	" Adaptec AHA-3985 / AIC-7873 $"
Adaptec90047478	Db	" Adaptec AHA-2944 / AIC-7874 $"
Adaptec90047578	Db	" Adaptec AHA-3944 / AHA-3944W / 7875 $"
Adaptec90047678	Db	" Adaptec AHA-4944W/UW / 7876 $"
Adaptec90047778	Db	" Adaptec AIC-787x $"
Adaptec90047810	Db	" Adaptec AIC-7810 $"
Adaptec90047815	Db	" Adaptec AIC-7815 RAID+Memory Controller IC/ARO-1130U2 RAID Controller $"
Adaptec90047840	Db	" Adaptec AIC-7815 RAID+Memory Controller IC $"
Adaptec90047850	Db	" Adaptec AHA-2904/Integrated AIC-7850 (AIC-7850)$"
Adaptec90047855	Db	" Adaptec AHA-2930 $"
Adaptec90047860	Db	" Adaptec AIC-7860 $"
Adaptec90047861	Db	" Adaptec AHA-2940AU Single $"
Adaptec90047870	Db	" Adaptec AIC-7870 $"
Adaptec90047871	Db	" Adaptec AHA-2940 $"
Adaptec90047872	Db	" Adaptec AHA-3940 $"
Adaptec90047873	Db	" Adaptec AHA-3980 $"
Adaptec90047874	Db	" Adaptec AHA-2944 $"
Adaptec90047880	Db	" Adaptec AIC-7880P (Ultra/Ultra Wide SCSI Chipset) $"
Adaptec90047881	Db	" Adaptec AHA-2940UW SCSI Host Adapter $"
Adaptec90047887	Db	" Adaptec 2940UW Pro Ultra-Wide SCSI Controller $"
Adaptec90047890	Db	" Adaptec AIC-7890 $"
Adaptec90047891	Db	" Adaptec AIC-789x $"
Adaptec90047892	Db	" Adaptec AIC-789x $"
Adaptec90047893	Db	" Adaptec AIC-789x $"
Adaptec90047894	Db	" Adaptec AIC-789x $"
Adaptec90047895	Db	" Adaptec AHA-2940U/UW /AHA-39xx/AIC-7895/AHA-2940U/2940UW Dual AHA-394xAU/AUW/AUWD AIC-7895B $"
Adaptec90047896	Db	" Adaptec AIC-789x $"
Adaptec90047897	Db	" Adaptec AIC-789x $"
Adaptec90048008	Db	" Adaptec ANA69011A/TX 64 bit 10/100 $"
Adaptec90048009	Db	" Adaptec ANA69011A/TX 64 bit 10/100 $"
Adaptec90048010	Db	" Adaptec ANA62022 2-port 64 bit 10/100 $"
Adaptec90048018	Db	" Adaptec ANA62044 4-port 64 bit 10/100 $"
Adaptec90048020	Db	" Adaptec ANA62022 2-port 64 bit 10/100 $"
Adaptec90048028	Db	" Adaptec ANA69011A/TX 64 bit 10/100 $"
Adaptec90048078	Db	" Adaptec AIC-7880U $"
Adaptec90048178	Db	" Adaptec AIC-7881U $"
Adaptec90048278	Db	" Adaptec AHA-3940U/UW / AIC-7882U $"
Adaptec90048378	Db	" Adaptec AHA-3940U/UW / AIC-7883U $"
Adaptec90048478	Db	" Adaptec AHA-294x / AIC-7884U $"
Adaptec90048578	Db	" Adaptec AHA-3944U / AHA-3944UWD / 7885 $"
Adaptec90048678	Db	" Adaptec AHA-4944UW / 7886 $"
Adaptec90048778	Db	" Adaptec AIC-788x $"
Adaptec90048878	Db	" Adaptec 7888 $"
Adaptec90048b78	Db	" Adaptec ABA-1030 $"
Adaptec9004ec78	Db	" Adaptec AHA-4944W/UW $"

Adaptec0010	Db	" Adaptec AHA-2940U2/W $"
Adaptec0011	Db	" Adaptec 2930U2 $"
Adaptec0013	Db	" Adaptec 78902 $"
Adaptec0003	Db	" Adaptec AAA-131U2 Array1000 1 Channel RAID Controller $"
Adaptec001f	Db	" Adaptec AHA-2940U2/W / 7890 $"
Adaptec000f	Db	" Adaptec 2940U2W SCSI Controller $"
Adapteca180	Db	" Adaptec 2940U2W SCSI Controller $"
Adaptec0020	Db	" Adaptec AIC-7890 $"
Adaptec002f	Db	" Adaptec AIC-7890 $"
Adaptec0030	Db	" Adaptec AIC-7890 $"
Adaptec003f	Db	" Adaptec AIC-7890 $"
Adaptec0050	Db	" Adaptec 3940U2 $"
Adaptec0051	Db	" Adaptec 3950U2D $"
Adaptec0053	Db	" Adaptec AIC-7896 SCSI Controller $"
Adaptecffff	Db	" Adaptec AIC-7896 SCSI Controller mainboard implementation $"
Adaptec005f	Db	" Adaptec 7896 $"
Adaptec0080	Db	" Adaptec 7892A $"
Adaptec0081	Db	" Adaptec 7892B $"
Adaptec0083	Db	" Adaptec 7892D $"
Adaptec008f	Db	" Adaptec 7892P $"
Adaptec00c0	Db	" Adaptec 7899A $"
Adaptec00c1	Db	" Adaptec 7899B $"
Adaptec00c3	Db	" Adaptec 7899D $"
Adaptec00cf	Db	" Adaptec 7899P $"

VMWareSVGA	Db	" VMWare Inc Virtual SVGA $"


Illegal	Db	" Illegal ! $"
