

	%Include	"Includes\Taglist.I"
	%Include	"Includes\TypeDef.I"
	%Include	"Includes\Nodes.I"
	%Include	"Includes\Lists.I"
	%Include	"Includes\Libraries.I"
	%Include	"includes\UserInterface\Classes.I"
	%Include	"Includes\Classes\Group.I"
	%Include	"Includes\Classes\Button.I"

	Org	0x0

Config	Dd	CCD_GROUP,GroupCFG
	Dd	CCD_BUTTON,ButtonCFG
	Dd	TAG_DONE

GroupCFG	Dd	GCTP_HORIZONTALSPACING,2
	Dd	GCTP_VERTICALSPACING,2
	Dd	GCTP_TITLEPOSITION,0
	Dd	GCTP_TITLEFONT,MindkillerFont
	Dd	GCTP_TITLEFONTSIZE,8
	Dd	GCTP_TITLERENDERMODE,0
	Dd	GCTP_FRAMETYPE,0
	Dd	GCTP_BACKGROUND,0x00ff00
	Dd	TAG_DONE

ButtonCFG	Dd	BCTP_FRAME,0
	Dd	BCTP_BACKGROUND,0xffff00
	Dd	BCTP_BACKGROUNDPRESSED,0xff00ff
	Dd	BCTP_FONT,MindkillerFont
	Dd	BCTP_FONTSIZE,8
	Dd	TAG_DONE

MindkillerFont	Db	"p0t-noodle.font",0

