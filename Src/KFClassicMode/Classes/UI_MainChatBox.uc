Class UI_MainChatBox extends UIR_ChatBox;

var ETextChatChannel CurrentTextChatChannel;
var float ChatBoxFadeInTime, OpenTime;
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
    if( PC.LobbyMenu == None || PC.LobbyMenu.bClosed )
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
    
    PC.PlayerInput.ResetInput();
    
    if( B )
    {
        SetTimer(0.01, false, nameOf(SetChatOpen));
        ChatBoxText.MessageFadeInTime = ChatBoxFadeInTime;
        OpenTime = PC.WorldInfo.TimeSeconds;
    }
    else
    {
        KFHUDInterface(PC.myHUD).bChatOpen = false;
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
    KFHUDInterface(PC.myHUD).bChatOpen = true;
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

function DrawMenu()
{
    local float TempSize;
    
    TempSize = PC.WorldInfo.TimeSeconds - OpenTime;
    if ( ChatBoxFadeInTime - TempSize > 0 )
    {
        FrameOpacity = (1.f - ((ChatBoxFadeInTime - TempSize) / ChatBoxFadeInTime)) * default.FrameOpacity;
    }
    
    Super.DrawMenu();
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
        
    switch(Key)
    {
        case 'Escape':
            if( Event==IE_Pressed )
                PC.CloseChatBox();
            return true;
        case 'MouseScrollDown':
        case 'MouseScrollUp':
            if( Event==IE_Pressed )
                ChatBoxText.ScrollMouseWheel(Key=='MouseScrollUp');
            return true;
    }
    
    return ChatBoxEdit.NotifyInputKey(ControllerId, Key, Event, AmountDepressed, bGamepad);
}

defaultproperties
{
    XPosition=0.025
    YPosition=0.525
    XSize=0.275
    YSize=0.275
    
    ChatBoxFadeInTime=0.2
    FrameOpacity=195
    
    Begin Object Name=ChatBoxTextBox
        MessageDisplayTime=4.f
        MessageFadeOutTime=3.f
    End Object
    
    Begin Object Name=ChatBoxField
        bForceShowCaret=true
    End Object
}