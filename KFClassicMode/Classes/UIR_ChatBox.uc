class UIR_ChatBox extends KFGUI_Frame;

var KFGUI_TextField ChatBoxText;
var KFGUI_EditBox ChatBoxEdit;

function InitMenu()
{
	Super.InitMenu();
	
	ChatBoxText = KFGUI_TextField(FindComponentID('ChatBoxTextBox'));
	
	ChatBoxEdit = KFGUI_EditBox(FindComponentID('ChatBoxField'));
	ChatBoxEdit.OnTextFinished = PlayerHitEnter;
}

function AddText(string S)
{
	ChatBoxText.AddText(S);
}

function PlayerHitEnter(KFGUI_EditBox Sender, string S)
{
	GetPlayer().Say(S);
}

function DrawMenu()
{
	if( !bTextureInit )
	{
		GetStyleTextures();
		return;
	}
	
	Super.DrawMenu();
}

function GetStyleTextures()
{
	if( !Owner.bFinishedReplication )
	{
		return;
	}
	
	FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_MEDIUM];
	if( FrameTex == None )
		return;
	
	bTextureInit = true;
}

defaultproperties
{
	bHeaderCenter=true
	WindowTitle="Chat Box"
	
	Begin Object Class=KFGUI_TextField Name=ChatBoxTextBox
		ID="ChatBoxTextBox"
		XPosition=0
		YPosition=0
		XSize=1
		YSize=0.875
		Text=""
		LineSplitter="<LINEBREAK>"
		MaxHistory=32
		bNoReset=true
	End Object
	
	Begin Object Class=KFGUI_EditBox Name=ChatBoxField
		ID="ChatBoxField"
		XPosition=0
		YPosition=0.9
		XSize=1
		YSize=0.1
		bDrawBackground=true
		MaxWidth=128
	End Object
	
	Components.Add(ChatBoxTextBox)	
	Components.Add(ChatBoxField)
}