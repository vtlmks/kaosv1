%ifndef Includes_Hardware_Keyboard_I
%define Includes_Hardware_Keyboard_I

;
; (C) Copyright 1999 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Keyboard.I V1.0.0
;
;     Keyboard hardware includes.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Keyboard 8041/8042 ports and commands.

KEYBP_DATA	Equ	0x60	; Keyboard dataport (input)
KEYBP_STAT	Equ	0x61	; Keyboard status
KEYBP_CTRL	Equ	0x64	; Keyboard controller


KCMD_RemMP	Equ	0xa7	; Disable mouse port
KCMD_SetMP	Equ	0xa8	; Enable mouse port
KCMD_DisableKeyb	Equ	0xad	; Disable keyboard
KCMD_EnableKeyb	Equ	0xae	; Enable keyboard
KCMD_SetWPort	Equ	0xd1	; Set write mode to 804x output port for the next byte.
KCMD_SetMCmd	Equ	0xd4	; Enhanched command, write to the auxiliary device
KCMD_SetA20	Equ	0xdf	; Enable address line A20
KCMD_SetMI	Equ	0xed	; Set mode indicators (leds)
KCMD_WaitAck	Equ	0xfa	; Wait for acknowledge
KCMD_Error	Equ	0xfc
KCMD_Resend	Equ	0xfe
KCMD_Reset	Equ	0xff

	; Status responses from 8042 controller

KSTA_IBF8042	Equ	00000010b
KSTA_OBF8042	Equ	00000001b
KSTA_OBFAUX	Equ	00100000b
KSTA_OBFMS	Equ	00100001b
KSTA_MOBF	Equ	00100001b
KSTA_ID101_1	Equ	0xab
KSTA_ID101_2	Equ	0x41
KSTA_OVER	Equ	0xff

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PS/2 auxiliary commands. All commands except 0xEC and 0xFF are acknowledged by 0xFA or 0xFE.
; All auxiliary commands must issue KCMD_SetMCmd to the KEYBP_CTRL port first (for each command).
;
PS2_Scale1	Equ	0xe6	; Set mouse scaling to 1:1
PS2_Scale2	Equ	0xe7	; Set mouse scaling to 2:1
PS2_SetRes	Equ	0xe8	; Set mouse resolution, 0x0=1/mm, 0x1=2/mm, 0x2=4/mm etc.
PS2_GetInfo	Equ	0xe9	; Get mouse information, byte 0=flags, 1=resolution
PS2_SetStream	Equ	0xea	; Set mouse to stream mode (sends data on any changes)
PS2_GetMData	Equ	0xeb	; Get mouse data
PS2_ResetWrap	Equ	0xec	; Reset mouse wrap mode (to normal mode)
PS2_SetWrap	Equ	0xee	; Set wrap mode
PS2_SetRMode	Equ	0xf0	; Set remote mode (instead of stream mode). Will only send data when issueing command 0xEB.
PS2_ReadMID	Equ	0xf2	; Read mouse ID, returns 1(-2) bytes.
PS2_SetMSR	Equ	0xf3	; Set mouse sample rate (rps), min=0x0, max=0xff
PS2_EnableSM	Equ	0xf4	; Enable mouse (in stream mode)
PS2_DisableSM	Equ	0xf5	; Disable mouse (in stream mode), set default parameters
PS2_SetDefs	Equ	0xf6	; Reset to defaults, 100/s, scaling 1:1, streaming, 4/mm
PS2_Resend	Equ	0xfe	; Resend last mouse data (8 bytes, see below)
PS2_Reset	Equ	0xff	; Reset mouse

	BITDEF	PS2,LEFTBUTTON,0
	BITDEF	PS2,RIGHTBUTTON,1
	BITDEF	PS2,MIDDLEBUTTON,2

;
; The auxiliary resend packet contains 8 bytes with the following data:
;
; Byte 0  - Status
;	Bit 0 - Left button pressed
;	Bit 1 - Right button pressed
;	Bit 2 - Middle button pressed
;                 Bit 3 - Reserved (Always set!?)
;	Bit 4 - X-data negative
;	Bit 5 - Y-data negative
;	Bit 6 - X-data overrun
;	Bit 7 - Y-data overrun
; Byte 1  - Reserved
; Byte 2  - X-data
; Byte 3  - Reserved
; Byte 4  - Y-data
; Byte 5  - Reserved
; Byte 6  - Z-data
; Byte 7  - Reserved
;
;
;
; 3 bytes are returned for each event
; Byte 0 - Button status
; Byte 1 - X position
; Byte 2 - Y position

; Mouse status byte looks like this (Byte 0).
; Bit 0 - Right button pressed
; Bit 1 - unused
; Bit 2 - Left button pressed
; Bit 3 - unused
; Bit 4 - Scaling set to 2:1
; Bit 5 - Mouse enabled
; Bit 6 - Remote mode (not streaming)
; Bit 7 - unused
;
; middle mouse button is probably at Bit 1,3 or 7..
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

%endif
