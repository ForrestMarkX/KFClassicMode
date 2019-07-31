Class xUI_MapRank extends KFGUI_FloatingWindow;

var xVotingReplication RepInfo;

function CloseMenu()
{
    Super.CloseMenu();
    RepInfo = None;
}

function ButtonClicked( KFGUI_Button Sender )
{
    switch( Sender.ID )
    {
    case 'Yes':
        RepInfo.ServerRankMap(true);
        DoClose();
        break;
    case 'No':
        RepInfo.ServerRankMap(false);
        DoClose();
        break;
    }
}

defaultproperties
{
    XPosition=0.35
    YPosition=0.4
    XSize=0.3
    YSize=0.2
    WindowTitle="Map Review"
    bPersistant=false
    bAlwaysTop=true
    bOnlyThisFocus=true

    Begin Object Class=KFGUI_TextLable Name=InfoLabel
        ID="Info"
        YPosition=0.3
        YSize=0.25
        AlignX=1
        Text="Did you like this map?"
        TextColor=(R=255,G=255,B=64,A=255)
    End Object

    Begin Object Class=KFGUI_Button Name=LikeButton
        ID="Yes"
        ButtonText="Like"
        ToolTip="Press this if you liked this map."
        XPosition=0.3
        YPosition=0.5
        XSize=0.2
        YSize=0.3
        ExtravDir=1
        TextColor=(R=128,G=255,B=128,A=255)
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object

    Begin Object Class=KFGUI_Button Name=DislikeButton
        ID="No"
        ButtonText="Dislike"
        ToolTip="Press this if you disliked this map."
        XPosition=0.5
        YPosition=0.5
        XSize=0.2
        YSize=0.3
        TextColor=(R=255,G=128,B=128,A=255)
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object

    Components.Add(InfoLabel)
    Components.Add(LikeButton)
    Components.Add(DislikeButton)
}