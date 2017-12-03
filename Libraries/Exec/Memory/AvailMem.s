
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; AvailMem -- Return amount of free bytes in memory
;
; Inputs : -
; Output : eax - Number of free bytes
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AvailMem	Mov	eax,[SysBase+SB_MemoryFree]
	Ret

