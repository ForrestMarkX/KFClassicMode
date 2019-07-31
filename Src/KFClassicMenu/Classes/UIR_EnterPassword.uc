Class UIR_EnterPassword extends KFGUI_FloatingWindow;

var transient bool JoinAsSpectator;
var transient int SearchIndex;

var UIP_ServerList ServerListOwner;
var KFGUI_EditBox PasswordField;

function InitMenu()
{
    Super.InitMenu();
    
    PasswordField = KFGUI_EditBox(FindComponentID('PasswordField'));
    PasswordField.OnTextFinished = PlayerEnteredPassword;
}

function ShowMenu()
{
    Super.ShowMenu();
    PasswordField.GrabKeyFocus();
}

function ButtonClicked( KFGUI_Button Sender )
{
    switch( Sender.ID )
    {
    case 'Okay':
        ServerListOwner.JoinServer(SearchIndex, PasswordField.GetText(), JoinAsSpectator);
        DoClose();
        break;
    case 'Cancel':
        DoClose();
        break;
    }
}

function PlayerEnteredPassword(KFGUI_EditBox Sender, string S)
{
    ServerListOwner.JoinServer(SearchIndex, S, JoinAsSpectator);
    DoClose();
}

defaultproperties
{
    XPosition=0.35
    YPosition=0.4
    XSize=0.3
    YSize=0.2
    WindowTitle="Password"
    bPersistant=false
    bAlwaysTop=true
    bOnlyThisFocus=true
    
    Begin Object Class=KFGUI_EditBox Name=PasswordField
        ID="PasswordField"
        XPosition=0.125
        YPosition=0.45
        XSize=0.75
        YSize=0.1
        bDrawBackground=true
        bMaskText=true
        MaxWidth=128
    End Object

    Begin Object Class=KFGUI_TextLable Name=InfoLabel
        ID="Info"
        YPosition=0.25
        YSize=0.25
        AlignX=1
        Text="Enter the password for this server!"
        TextColor=(R=255,G=255,B=64,A=255)
    End Object

    Begin Object Class=KFGUI_Button Name=AcceptButton
        ID="Okay"
        ButtonText="Accept"
        ToolTip="Accepts the entered password."
        XPosition=0.3
        YPosition=0.75
        XSize=0.2
        YSize=0.15
        ExtravDir=1
        TextColor=(R=0,G=195,B=0,A=255)
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object

    Begin Object Class=KFGUI_Button Name=CancelButton
        ID="Cancel"
        ButtonText="Cancel"
        ToolTip="Cancels the connection."
        XPosition=0.5
        YPosition=0.75
        XSize=0.2
        YSize=0.15
        TextColor=(R=195,G=0,B=0,A=255)
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object

    Components.Add(InfoLabel)
    Components.Add(AcceptButton)
    Components.Add(CancelButton)
    Components.Add(PasswordField)
}