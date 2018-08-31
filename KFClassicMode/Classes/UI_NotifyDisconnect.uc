class UI_NotifyDisconnect extends KFGUI_FloatingWindow;

var KFGUI_TextLable InfoLabel;

function InitMenu()
{
	InfoLabel = KFGUI_TextLable(FindComponentID('Info'));
	Super.InitMenu();
}

function SetupTo( ClassicPerk_Base P )
{
	WindowTitle = "Disconnect";
}

function MessageTo()
{
	InfoLabel.SetText("Are you sure you want to disconnect from the server?");  
}

function ButtonClicked( KFGUI_Button Sender )
{
	switch(Sender.ID)
	{
		case 'Yes':
			GetPlayer().ConsoleCommand("DISCONNECT");
			break;
		case 'No':
			DoClose();
			break;
	}
}

function CloseMenu()
{
	Super.CloseMenu();
	Owner.OpenMenu(ClassicPlayerController(GetPlayer()).MidGameMenuClass);
}

defaultproperties
{
	XPosition=0.35
	YPosition=0.40
	XSize=0.3
	YSize=0.1250
	WindowTitle="Disconnect"
	bAlwaysTop=true
	bOnlyThisFocus=true
	
	Begin Object Class=KFGUI_TextLable Name=WarningLabel
		ID="Info"
		YPosition=0.3
		YSize=0.25
		AlignX=1
		Text="Are you sure you want to disconnect from the server?"
	End Object
	Begin Object Class=KFGUI_Button Name=YesButten
		ID="Yes"
		ButtonText="Yes "
		ToolTip="You can not undo this action!"
		XPosition=0.2
		YPosition=0.70
		XSize=0.29
		YSize=0.180
		OnClickLeft=ButtonClicked
		OnClickRight=ButtonClicked
	End Object
	Begin Object Class=KFGUI_Button Name=NoButten
		ID="No"
		ButtonText="No "
		XPosition=0.5
		YPosition=0.70
		XSize=0.29
		YSize=0.180
		OnClickLeft=ButtonClicked
		OnClickRight=ButtonClicked
	End Object
	
	Components.Add(WarningLabel)
	Components.Add(YesButten)
	Components.Add(NoButten)
}