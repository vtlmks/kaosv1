
CheckUART	Mov	dx,UART0_BASE+UART_FCR
	Mov	al,UARTFCR_EFIFO
	Out	dx,al
	Mov	dx,UART0_BASE+UART_IIR
	In	al,dx
	And	al,11000000b
	Shr	al,6
	Cmp	al,3
	Je	.16550A
	Cmp	al,1
	Je	.16550
.16450	Ret
.16550	Ret
.16550A	Ret



