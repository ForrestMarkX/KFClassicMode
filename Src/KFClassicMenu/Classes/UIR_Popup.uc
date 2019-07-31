Class UIR_Popup extends KFGUI_FloatingWindow;

var KFGUI_TextLable InfoLabel;
var KFGUI_Button AcceptButton;

function InitMenu()
{
    Super.InitMenu();
    
    InfoLabel = KFGUI_TextLable(FindComponentID('Info'));
    AcceptButton = KFGUI_Button(FindComponentID('Okay'));
    AcceptButton.ButtonText = class'KFCommon_LocalizedStrings'.default.OKString;
}

function ButtonClicked( KFGUI_Button Sender )
{
    switch( Sender.ID )
    {
    case 'Okay':
        DoClose();
        break;
    }
}

defaultproperties
{
    XPosition=0.25
    YPosition=0.4
    XSize=0.5
    YSize=0.2
    bPersistant=false
    bAlwaysTop=true
    bOnlyThisFocus=true

    Begin Object Class=KFGUI_TextLable Name=InfoLabel
        ID="Info"
        YPosition=0.25
        YSize=0.5
        AlignX=1
        FontScale=2
        TextColor=(R=255,G=255,B=255,A=255)
    End Object

    Begin Object Class=KFGUI_Button Name=AcceptButton
        ID="Okay"
        XPosition=0.3
        YPosition=0.75
        XSize=0.4
        YSize=0.15
        ExtravDir=1
        TextColor=(R=0,G=0,B=0,A=255)
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object

    Components.Add(InfoLabel)
    Components.Add(AcceptButton)
}