%ifndef Includes_DOS_ELF_I
%define Includes_DOS_ELF_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     ELF.I V1.0.0
;
;     ELF (Executable and Linkable Format) includes
;






;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; ELF segment types, stored in the image headers
;

PT_NULL	Equ	0
PT_LOAD	Equ	1
PT_DYNAMIC	Equ	2
PT_INTERP	Equ	3
PT_NOTE	Equ	4
PT_SHLIB	Equ	5
PT_PHDR	Equ	6
PT_LOPROC	Equ	0x70000000
PT_HIPROC	Equ	0x7fffffff
PT_MIPS_REGINFO	Equ	0x70000000

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Flags in the e_flags field in the header
;

EF_MIPS_NOREORDER	Equ	0x00000001
EF_MIPS_PIC	Equ	0x00000002
EF_MIPS_CPIC	Equ	0x00000004
EF_MIPS_ARCH	Equ	0xf0000000

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; ELF file types
;


ET_NONE	Equ	0
ET_REL	Equ	1
ET_EXEC	Equ	2
ET_DYN	Equ	3
ET_CORE	Equ	4
ET_LOPROC	Equ	0xff00
ET_HIPROC	Equ	0xffff

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; ELF target machines


EM_NONE	Equ	0
EM_M32	Equ	1
EM_SPARC	Equ	2
EM_386	Equ	3
EM_68K	Equ	4
EM_88K	Equ	5
EM_486	Equ	6	;
EM_860	Equ	7
EM_MIPS	Equ	8	; MIPS R3000 (officially, big-endian only)
EM_MIPS_RS4_BE	Equ	10	; MIPS R4000 big-endian
EM_PARISC	Equ	15	; HPPA
EM_SPARC32PLUS	Equ	18	; SUN V8Plus
EM_PPC	Equ	20	; PowerPC
EM_SPARCV9	Equ	43	; SPARC v9 64-bit
EM_IA_64	Equ	50	; Intel64
EM_ALPHA	Equ	0x9026	; Interim value
EM_S390	Equ	0xa390	; Interim value

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Defines needed to parse the dynamic section

DT_NULL	Equ	0
DT_NEEDED	Equ	1
DT_PLTRELSZ	Equ	2
DT_PLTGOT	Equ	3
DT_HASH	Equ	4
DT_STRTAB	Equ	5
DT_SYMTAB	Equ	6
DT_RELA	Equ	7
DT_RELASZ	Equ	8
DT_RELAENT	Equ	9
DT_STRSZ	Equ	10
DT_SYMENT	Equ	11
DT_INIT	Equ	12
DT_FINI	Equ	13
DT_SONAME	Equ	14
DT_RPATH 	Equ	15
DT_SYMBOLIC	Equ	16
DT_REL	Equ	17
DT_RELSZ	Equ	18
DT_RELENT	Equ	19
DT_PLTREL	Equ	20
DT_DEBUG	Equ	21
DT_TEXTREL	Equ	22
DT_JMPREL	Equ	23
DT_LOPROC	Equ	0x70000000
DT_HIPROC	Equ	0x7fffffff

RHF_NONE	Equ	0
RHF_HARDWAY	Equ	1
RHF_NOTPOT	Equ	2

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; This info is needed when parsing the symbol table
;

STB_LOCAL	Equ	0
STB_GLOBAL	Equ	1
STB_WEAK	Equ	2

STT_NOTYPE	Equ	0
STT_OBJECT	Equ	1
STT_FUNC	Equ	2
STT_SECTION	Equ	3
STT_FILE	Equ	4


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Symbolic values for the entries in the auxiliary table put on the initial stack
;

AT_NULL	Equ	0	; End of vector
AT_IGNORE	Equ	1	; Entry should be ignored
AT_EXECFD	Equ	2	; File descriptor of program
AT_PHDR	Equ	3	; Program headers for program
AT_PHENT	Equ	4	; Size of program header entry
AT_PHNUM	Equ	5	; Number of program headers
AT_PAGESZ	Equ	6	; System page size
AT_BASE	Equ	7	; Base address of interpreter
AT_FLAGS	Equ	8	; Flags
AT_ENTRY	Equ	9	; Entry point of program
AT_NOTELF	Equ	10	; Program is not ELF
AT_UID	Equ	11	; Real UID
AT_EUID	Equ	12	; Effective UID
AT_GID	Equ	13	; Real GID
AT_EGID	Equ	14	; Effective GID
AT_PLATFORM	Equ	15	; String identifying CPU for optimizations
AT_HWCAP	Equ	16	; Arch dependent hints at CPU capabilities

;typedef struct dynamic{
;  Elf32_Sword d_tag;
;  union{
;    Elf32_Sword	d_val;
;    Elf32_Addr	d_ptr;
;  } d_un;
;} Elf32_Dyn;
;
;

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; ELF relocations equates
;


R_386_NONE	Equ	0
R_386_32	Equ	1	; Ordinary absolute relocation
R_386_PC32	Equ	2	; PC-relative relocation
R_386_GOT32	Equ	3	; Offset into GOT
R_386_PLT32	Equ	4	; PC-relative offset into PLT
R_386_COPY	Equ	5
R_386_GLOB_DAT	Equ	6
R_386_JMP_SLOT	Equ	7
R_386_RELATIVE	Equ	8
R_386_GOTOFF	Equ	9	; Offset from GOT base
R_386_GOTPC	Equ	10	; PC-relative offset _to_ GOT
R_386_NUM	Equ	11




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; ELF32_Rel

	Struc ELFREL
ELF_RELOffset	ResD	1	; Location at which to apply the action
ELF_RELInfo	ResD	1	; Index and type of relocation         
ELF_RELSIZE	EndStruc                                                         


	Struc ELFRELA
ELF_RELAOffset	ResD	1	; Location at which to apply the action
ELF_RELAInfo	ResD	1	; Index and type of relocation         
ELF_RELAAddend	ResD	1	; Constant added used to compute value 
ELF_RELASIZE	EndStruc


	Struc ELFSYM
ELF_STName	ResD	1	; Symbol name, index in string tabel
ELF_STValue	ResD	1	; Type and binding attributes
ELF_STSize	ResD	1	; No defined meaning, null
ELF_STInfo	ResB	1	; Associated section index
ELF_STOther	ResB	1	; Value of the symbol
ELF_STShndx	ResW	1	; Associated symbol size
ELF_STSIZE	EndStruc


EI_NIDENT	Equ	16

	Struc ELFHDR
ELF_HDRIdent	ResB	EI_NIDENT	; ELF magic number
ELF_HDRType	ResW	1
ELF_HDRMachine	ResW	1
ELF_HDRVersion	ResD	1
ELF_HDREntry	ResD	1	; Entry point
ELF_HDRPhoff	ResD	1	; Program header table file offset
ELF_HDRShoff	ResD	1	; Section header table file offset
ELF_HDRFlags	ResD	1
ELF_HDREhsize	ResW	1
ELF_HDRPhentsize	ResW	1
ELF_HDRPhnum	ResW	1
ELF_HDRShentsize	ResW	1
ELF_HDRShnum	ResW	1
ELF_HDRShstrndx	ResW	1
ELF_HDRSIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; These constants define the permissions on sections in the program  header, pflags
;

PF_R	Equ	0x4
PF_W	Equ	0x2
PF_X	Equ	0x1


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Struc ELFPHDR
ELF_PHType	ResD	1
ELF_PHOffset	ResD	1	; Segment file offset             
ELF_PHVaddr	ResD	1	; Segment virtual address         
ELF_PHPaddr	ResD	1	; Segment physical address        
ELF_PHFilesz	ResD	1	; Segment size in file            
ELF_PHMemsz	ResD	1	; Segment size in memory          
ELF_PHFlags	ResD	1
ELF_PHAlign	ResD	1	; Segment alignment, file & memory
ELF_PHSIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; sh_type

SHT_NULL	Equ	0
SHT_PROGBITS	Equ	1
SHT_SYMTAB	Equ	2
SHT_STRTAB	Equ	3
SHT_RELA	Equ	4
SHT_HASH	Equ	5
SHT_DYNAMIC	Equ	6
SHT_NOTE	Equ	7
SHT_NOBITS	Equ	8
SHT_REL	Equ	9
SHT_SHLIB	Equ	10
SHT_DYNSYM	Equ	11
SHT_NUM	Equ	12
SHT_LOPROC	Equ	0x70000000
SHT_HIPROC	Equ	0x7fffffff
SHT_LOUSER	Equ	0x80000000
SHT_HIUSER	Equ	0xffffffff

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; sh_flags
;

SHF_WRITE	Equ	0x1
SHF_ALLOC	Equ	0x2
SHF_EXECINSTR	Equ	0x4
SHF_MASKPROC	Equ	0xf0000000

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Special section indexes
;

SHN_UNDEF	Equ	0
SHN_LORESERVE	Equ	0xff00
SHN_LOPROC	Equ	0xff00
SHN_HIPROC	Equ	0xff1f
SHN_ABS	Equ	0xfff1
SHN_COMMON	Equ	0xfff2
SHN_HIRESERVE	Equ	0xffff
 

	Struc ELFSHDR
ELF_SHDRName	ResD	1	; Section name, index in string tabel
ELF_SHDRType	ResD	1	; Type of section
ELF_SHDRFlags	ResD	1	; Miscellaneous section attributes
ELF_SHDRAddr	ResD	1	; Section virtual address at execution
ELF_SHDROffset	ResD	1	; Section file offset
ELF_SHDRSizez	ResD	1	; Size of section in bytes
ELF_SHDRLink	ResD	1	; Index of another section
ELF_SHDRInfo	ResD	1	; Additional section information
ELF_SHDRAddrAlign	ResD	1	; Section alignment
ELF_SHDREntSize	ResD	1	; Entry size if section holds table
ELF_SHDRSIZE	EndStruc


EI_MAG0	Equ	0	; e_ident indexes
EI_MAG1	Equ	1
EI_MAG2	Equ	2
EI_MAG3	Equ	3
EI_CLASS	Equ	4
EI_DATA	Equ	5
EI_VERSION	Equ	6
EI_PAD	Equ	7

ELFMAG0	Equ	0x7f	; EI_MAG
ELFMAG1	Equ	"E"
ELFMAG2	Equ	"L"
ELFMAG3	Equ	"F"
ELFMAG	Equ	0x7f454c46	; "\177ELF"
SELFMAG	Equ	4

ELFCLASSNONE	Equ	0	; EI_CLASS
ELFCLASS32	Equ	1
ELFCLASS64	Equ	2
ELFCLASSNUM	Equ	3

ELFDATANONE	Equ	0	; e_ident[EI_DATA]
ELFDATA2LSB	Equ	1
ELFDATA2MSB	Equ	2

EV_NONE	Equ	0	; e_version, EI_VERSION
EV_CURRENT	Equ	1
EV_NUM	Equ	2

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Notes used in ET_CORE
;

NT_PRSTATUS	Equ	1
NT_PRFPREG	Equ	2
NT_PRPSINFO	Equ	3
NT_TASKSTRUCT	Equ	4
NT_PRFPXREG	Equ	20

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Note header in a PT_NOTE section
;

	Struc ELFNT
ELF_NTNamesz	ResD	1	; Name size
ELF_NTDescsz	ResD	1	; Content size
ELF_NTType	ResD	1	; Content type
ELF_NTSIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
