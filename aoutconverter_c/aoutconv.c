/*
** AOut2MFS Converter Copyright (c)2000 Mindkiller Systems Inc.
**
** started 00-10-15 18:08
** finished 00-10-15 00:00
**
** NOTE(2017-12-02): compile with cygwin gcc -O2 -xc -o aoutconv.exe aoutconv.c
**                   remember for copy cygwin1.dll to the same directory as the aoutconv.
**                   make sure the cmd.exe has the path set to reach acoutconv.exe
*/

/******************************************************************************/
#include	<sys/types.h>
#include	<sys/stat.h>
#include <stdint.h>
#include	<fcntl.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<unistd.h>

/******************************************************************************/
void				ConvertCodeseg();
void				FreeAOut();
void				PrintInfo();
void				ReadAOut();
void				WriteMex();

/******************************************************************************/
#define		reloc_8		0
#define		reloc_16		1
#define		reloc_32		2

#define		chunk_code		8002
#define		chunk_data		8003
#define		chunk_bss		8004
#define		chunk_reloc		8005

/******************************************************************************/
struct exec {
	uint32_t	Magic;
	uint32_t	CodeSize;
	uint32_t	DataSize;
	uint32_t	BSSSize;
	uint32_t	SymbolsSize;
	uint32_t	Entrypoint;
	uint32_t	CodeRelocSize;
	uint32_t	DataRelocSize;
};

#define	SECT_ABS		2
#define	SECT_TEXT		4
#define	SECT_DATA		6
#define	SECT_BSS		8

struct	relocation_info {
	int	r_address;
	unsigned int	r_symbolnum : 24,
								r_pcrel			: 1,
								r_length		: 2,
								r_extern		: 1,
								r_baserel		: 1,
								r_jmptable	: 1,
								r_relative	: 1,
								r_copy			: 1;
};

struct	relocation_info2 {
	int						r_address;
	unsigned int	r_type			: 8,
								r_symbolnum : 24;
};

struct	mex_relo32{
	uint16_t	sourcechunk;
	uint16_t	destchunk;
	uint32_t		offset;
};

struct	mex_relo16{
	uint16_t	sourcechunk;
	uint16_t	destchunk;
	uint32_t		offset;
};

struct	mex_relo8{
	uint16_t	sourcechunk;
	uint16_t	destchunk;
	uint32_t		offset;
};

/******************************************************************************/
struct	exec	aoutfile;
long		codesize,datasize,bsssize,relosize;
int			*codechunk,*datachunk,*bsschunk,*coderelochunk,*datarelochunk, *relochunk;
int			relocsize, aoutrelocentrys;

/******************************************************************************/
int	main(int argc, char **argv){
	printf("\nAOut -> MFS0 Converter V1.0.0 Copyright (c)2000 Mindkiller Systems Inc.\n\n");
	if(argc == 3){
		ReadAOut(argv[1]);
		if(aoutrelocentrys = aoutfile.CodeRelocSize/8){
			relocsize = aoutrelocentrys*sizeof(struct mex_relo32);
			relochunk = calloc(1, relocsize);
		}

		WriteMex(argv[2]);
	}
	return 0;
}

/******************************************************************************/
void	WriteMex(char *filename){
	int			fh;
	int			i=0,chunktype;

	struct		relocation_info		*CodeRelocChunk		=	(struct relocation_info *)		coderelochunk;
	struct		relocation_info2		*CodeRelocChunk2		=	(struct relocation_info2 *)	coderelochunk;
	struct		mex_relo32				*relocchunk				=	(struct mex_relo32 *)			relochunk;

	fh = open(filename,O_CREAT|O_WRONLY|O_TRUNC|O_BINARY, S_IRWXU|S_IRWXG|S_IRWXO);	// open new file, or truncate old file....  mode 777 = read/write/execute all...

	write(fh,"MFS0",4);

	for(i=0;i<aoutrelocentrys;i++){

		switch(CodeRelocChunk[i].r_length){
			case	reloc_32:

				switch(CodeRelocChunk2[i].r_type) {

					case	SECT_ABS:
						printf("SECT_ABS - Do nothing about this...\n");
					break;

					case	SECT_TEXT:
						relocchunk[i].sourcechunk = 0;
						relocchunk[i].destchunk = 0;
						relocchunk[i].offset = CodeRelocChunk[i].r_address;
					break;

					case	SECT_DATA:
						relocchunk[i].sourcechunk = 0;
						relocchunk[i].destchunk = 1;
						relocchunk[i].offset = CodeRelocChunk[i].r_address;
					break;

					case	SECT_BSS:
						printf("SECT_BSS - This... Is a future implementation...\n");
					break;
				}
			break;

			case	reloc_16:
				printf("Warning: 16 bit relocation information\n");
			break;

			case	reloc_8:
				printf("Warning: 8 bit relocation information\n");
			break;

			default:
				printf("Warning: This one should not be here.. BEGONE THOU EVIL SHIT!@$#%\n");
			break;
		}
	}

	printf("\nWriting file");

	chunktype = chunk_code;						// Write header
	write(fh,(char *) &chunktype,4);
	write(fh,(char *) &aoutfile.CodeSize,4);
	write(fh,codechunk,aoutfile.CodeSize);	// Write Code-segment

	printf(".");

	if(aoutfile.DataSize) {
		chunktype = chunk_data;
		write(fh,(char *) &chunktype,4);
		write(fh,(char *) &aoutfile.DataSize,4);
		write(fh,datachunk,aoutfile.DataSize);
	}

	printf(".");

	if(relocsize) {
		chunktype = chunk_reloc;					// Write reloc32 header...
		write(fh,(char *) &chunktype, 4);
		write(fh,(char *) &relocsize, 4);
		write(fh,relocchunk, relocsize);			// Write reloc32 data
	}

	printf(".");

	close(fh);		// Close output file...

	printf(" Done...\n");
}

/******************************************************************************
** Read the entire AOut file, at the moment there are no restrictions on the
** size of the AOut file, this routine will load it even if there are no
** free available memory.
*/
void	ReadAOut(char *filename){
	int		fh;
	long		aoutfilesize;

	fh = open(filename, O_RDONLY|O_BINARY);
	aoutfilesize = lseek(fh,0,SEEK_END);
	lseek(fh,0,SEEK_SET);
	read(fh, &aoutfile, sizeof(aoutfile));

	codechunk = calloc(1,aoutfile.CodeSize);
	datachunk = calloc(1,aoutfile.DataSize);
	coderelochunk = calloc(1,aoutfile.CodeRelocSize);
 	datarelochunk = calloc(1,aoutfile.DataRelocSize);

	printf("      Reading code chunk...");
	read(fh,codechunk, aoutfile.CodeSize);
	printf(" Done.      Codesize = 0x%x\n      Reading Data chunk...", aoutfile.CodeSize);
	read(fh,datachunk, aoutfile.DataSize);
	printf(" Done.      Datasize = 0x%x\nReading Code Reloc chunk...", aoutfile.DataSize);
	read(fh,coderelochunk, aoutfile.CodeRelocSize);
	printf(" Done. Coderelocsize = 0x%x\nReading Data Reloc chunk...", aoutfile.CodeRelocSize);
	read(fh,datarelochunk, aoutfile.DataRelocSize);
	printf(" Done. DataRelocsize = 0x%x\n", aoutfile.DataRelocSize);
	close(fh);
}

