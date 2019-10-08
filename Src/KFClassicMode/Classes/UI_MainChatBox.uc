Class UI_MainChatBox extends UIR_ChatBox;

var ETextChatChannel CurrentTextChatChannel;
var ClassicPlayerController PC;

function InitMenu()
{
    Super.InitMenu();
    PC = ClassicPlayerController(GetPlayer());
    PC.CurrentChatBox = self;
    
    SetTimer(0.5, true, nameOf(CheckForLobbyClose));
}

function CheckForLobbyClose()
{
    if( PC.LobbyMenu == None )
    {
        if( !ChatBoxText.bVisible )
        {
            ChatBoxText.SetVisibility(true);
        }
    }
    else
    {
        if( ChatBoxText.bVisible )
        {
            ChatBoxText.SetVisibility(false);
        }
    }
}

function SetVisible(bool B)
{
    bDrawBackground = B;
    ChatBoxText.bUseOutlineText = !B;
    bNoLookInputs = B;
    
    if( B )
    {
        SetTimer(0.01, false, nameOf(SetChatOpen));
        ChatBoxText.MessageFadeInTime = WindowFadeInTime;
    }
    else
    {
        HUDOwner.bChatOpen = false;
        ChatBoxText.MessageFadeInTime = 0.f;
    }
    
    ChatBoxEdit.SetText("");
    ChatBoxEdit.SetVisibility(B);
    ChatBoxEdit.bDisabled = !B;
    ChatBoxEdit.bCanFocus = B;
    
    if( ChatBoxText.ScrollBar != None )
        ChatBoxText.ScrollBar.bHideScrollbar = !B;
    
    ChatBoxText.InitSize();
    ChatBoxText.FadeStartTime = PC.WorldInfo.TimeSeconds;
    ChatBoxText.bFadeInOut = !B;
}

function SetChatOpen()
{
    HUDOwner.bChatOpen = true;
}

function AddText(string S)
{
    if( ChatBoxText.bFadeInOut )
        ChatBoxText.FadeStartTime = PC.WorldInfo.TimeSeconds;
    
    Super.AddText(S);
}

function PlayerHitEnter(KFGUI_EditBox Sender, string S)
{
    switch(CurrentTextChatChannel)
    {
        case ETCC_ALL:
            PC.Say(S);
            break;
        case ETCC_TEAM:
            PC.TeamSay(S);
            break;
    }

    PC.CloseChatBox();
}

function bool NotifyInputChar(int Key, string Unicode)
{
    if( !HUDOwner.bChatOpen )
        return false;
        
    return ChatBoxEdit.NotifyInputChar(Key, Unicode);
}

function bool NotifyInputKey(int ControllerId, name Key, EInputEvent Event, float AmountDepressed, bool bGamepad)
{
    if( !HUDOwner.bChatOpen )
        return false;
    else if( Super.NotifyInputKey(ControllerId, Key, Event, AmountDepressed, bGamepad) )
        return true;
    
    return ChatBoxEdit.NotifyInputKey(ControllerId, Key, Event, AmountDepressed, bGamepad);
}

function UserPressedEsc()
{
    PC.CloseChatBox();
}

function ScrollMouseWheel( bool bUp )
{
    ChatBoxText.ScrollMouseWheel(bUp);
}

defaultproperties
{
    bUseAnimation=true
    bEnableInputs=true
    
    XPosition=0.025
    YPosition=0.525
    XSize=0.275
    YSize=0.275
    
    FrameOpacity=195
    
    Begin Object Name=ChatBoxTextBox
        MessageDisplayTime=8.f
        MessageFadeOutTime=3.f
    End Object
    
    Begin Object Name=ChatBoxField
        bForceShowCaret=true
    End Object
}