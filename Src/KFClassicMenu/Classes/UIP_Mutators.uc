Class UIP_Mutators extends KFGUI_Page;

var UIR_MutatorList MutatorFrame;
var UIR_EnabledMutatorList EMutatorFrame;
var UI_StartGame StartGame;
var KFGUI_Frame TextBackground;
var KFGUI_TextScroll DescriptionText;

function InitMenu()
{
    Super.InitMenu();
    
    MutatorFrame = UIR_MutatorList(FindComponentID('MutatorFrame'));
    EMutatorFrame = UIR_EnabledMutatorList(FindComponentID('EMutatorFrame'));
    
    TextBackground = KFGUI_Frame(FindComponentID('TextBackground'));
    TextBackground.FrameTex = Owner.CurrentStyle.BorderTextures[`BOX_SMALL_SLIGHTTRANSPARENT];
    
    DescriptionText = KFGUI_TextScroll(FindComponentID('DescriptionText'));
    
    EMutatorFrame.MainMutatorsFrame = MutatorFrame;
    MutatorFrame.EnabledMutatorsFrame = EMutatorFrame;
}

function ButtonClicked( KFGUI_Button Sender )
{
	switch( Sender.ID )
	{
	case 'AddMut':
        if( MutatorFrame.SelectedIndex != -1 )
            MutatorFrame.DoubleClickedItem(MutatorFrame.SelectedIndex, false, 0, 0);
		break;
	case 'RemoveMut':
        if( EMutatorFrame.SelectedIndex != -1 )
            EMutatorFrame.DoubleClickedItem(EMutatorFrame.SelectedIndex, false, 0, 0);
		break;
	}
}

defaultproperties
{
    Begin Object class=KFGUI_Frame Name=TextBackground
        ID="TextBackground"
        XPosition=0.3
        YPosition=0.075
        XSize=0.4
        YSize=0.25
    End Object
    Components.Add(TextBackground)  
    
    Begin Object Class=KFGUI_TextScroll Name=DescriptionText
        ID="DescriptionText"
        XPosition=0.31
        YPosition=0.085
        XSize=0.39
        YSize=0.24
        Text=""
    End Object
    Components.Add(DescriptionText)
    
	Begin Object Class=KFGUI_Button Name=AddMutatorButton
		ID="AddMut"
		ButtonText=">>>"
		XPosition=0.425
		YPosition=0.375
		XSize=0.15
		YSize=0.05
		OnClickLeft=ButtonClicked
		OnClickRight=ButtonClicked
	End Object
    Components.Add(AddMutatorButton)
    
	Begin Object Class=KFGUI_Button Name=RemoveMutatorButton
		ID="RemoveMut"
		ButtonText="<<<"
		XPosition=0.425
		YPosition=0.425
		XSize=0.15
		YSize=0.05
		OnClickLeft=ButtonClicked
		OnClickRight=ButtonClicked
	End Object
    Components.Add(RemoveMutatorButton)
    
    Begin Object Class=UIR_MutatorList Name=MutatorFrame
        XPosition=0.025
        YPosition=0.05
		YSize=0.75
        XSize=0.25
        EdgeSize(2)=-20
        WindowTitle="Avaliable Mutators"
        bHeaderCenter=true
        ID="MutatorFrame"
    End Object    
    Components.Add(MutatorFrame)
    
    Begin Object Class=UIR_EnabledMutatorList Name=EMutatorFrame
        XPosition=0.725
        YPosition=0.05
		YSize=0.75
        XSize=0.25
        EdgeSize(2)=-20
        WindowTitle="Enabled Mutators"
        bHeaderCenter=true
        ID="EMutatorFrame"
    End Object    
    Components.Add(EMutatorFrame)
}