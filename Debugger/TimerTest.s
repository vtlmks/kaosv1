;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     TimerTest.s V1.0.0
;
;     -
;

TimerTest	Lea	ecx,[TimerTestProcTags]
	LIBCALL	AddProcess,ExecBase
	Ret

TimerTestProcTags	Dd	AP_PROCESSPOINTER,TimerTestProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,TimerTestProcN
	Dd	TAG_DONE

TimerTestProcN	Db	'timertest',0



TimerTestProc	Mov	eax,2048
	LIBCALL	Delay,TimerBase
	Lea	eax,[TimerTestTxt]
	Int	0xff
	Jmp	TimerTestProc

TimerTestTxt	Db	"Timer test every 2048 ticks..",0xa,0
