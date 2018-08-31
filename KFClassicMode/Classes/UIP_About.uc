Class UIP_About extends KFGUI_MultiComponent;

var const string ForumURL;

private final function UniqueNetId GetAuthID()
{
	local UniqueNetId Res;

	class'OnlineSubsystem'.Static.StringToUniqueNetId("0x0110000100E8984E",Res);
	return Res;
}
function ButtonClicked( KFGUI_Button Sender )
{
	switch( Sender.ID )
	{
	case 'Forum':
		class'GameEngine'.static.GetOnlineSubsystem().OpenURL(ForumURL);
		break;
	case 'Author':
		OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem()).ShowProfileUI(0,,GetAuthID());
		break;
	}
}

defaultproperties
{
	ForumURL="forums.tripwireinteractive.com/showthread.php?t=106926"

	Begin Object Class=KFGUI_TextField Name=AboutText
		XPosition=0.025
		YPosition=0.025
		XSize=0.95
		YSize=0.8
		Text="REPLACE ME|"
	End Object
	Begin Object Class=KFGUI_Button Name=AboutButton
		ID="Author"
		ButtonText="Author Profile"
		Tooltip="Visit this mod authors steam profile"
		XPosition=0.7
		YPosition=0.92
		XSize=0.27
		YSize=0.06
		TextColor=(R=0,G=0,B=0,A=255)
		OnClickLeft=ButtonClicked
		OnClickRight=ButtonClicked
	End Object
	Begin Object Class=KFGUI_Button Name=ForumButton
		ID="Forum"
		ButtonText="Visit Forums"
		Tooltip="Visit this mods discussion forum"
		XPosition=0.7
		YPosition=0.84
		XSize=0.27
		YSize=0.06
		TextColor=(R=0,G=0,B=0,A=255)
		OnClickLeft=ButtonClicked
		OnClickRight=ButtonClicked
	End Object
	
	Components.Add(AboutText)
	Components.Add(AboutButton)
	Components.Add(ForumButton)
}