class UI_ConsoleMenu extends UI_MainChatBox;

var transient UI_Console MainConsole;
var editinline export UIR_ConsoleAutoCompleteList ConsoleAutoComplete;
var transient bool bAutoCompleteOpen, bForceUpdateRows;
var int MaxAutoCompletes;

function InitMenu()
{
    Super(UIR_ChatBox).InitMenu();
    
    PC = ClassicPlayerController(GetPlayer());
    
    MainConsole = UI_Console(LocalPlayer(PC.Player).ViewportClient.ViewportConsole);
    MainConsole.ConsoleMenu = self;
    
    ChatBoxEdit.OnChange = CheckAutoCompletes;
}

function ShowMenu()
{
    Super.ShowMenu();
    SetTimer(0.1, false, nameOf(SetChatOpen));
}

function SetChatOpen()
{
    ChatBoxEdit.GrabKeyFocus();
    Owner.HUDOwner.bChatOpen = true;
}

function PlayerHitEnter(KFGUI_EditBox Sender, string S)
{
    MainConsole.ConsoleCommand(S);
}

function UserPressedEsc()
{
    Super(KFGUI_Frame).UserPressedEsc();
}

function CloseMenu()
{
    Owner.HUDOwner.bChatOpen = false;
    MainConsole.bCaptureKeyInput = false;
    bAutoCompleteOpen = false;
    bForceUpdateRows = false;
}

function bool NotifyInputChar(int Key, string Unicode)
{
    if( Unicode ~= string(MainConsole.ConsoleKey) )
        return false;
        
    return Super.NotifyInputChar(Key, Unicode);
}

function CheckAutoCompletes(KFGUI_EditBox Sender)
{
    local int i;
    local string S, ToolTip;
    
    MainConsole.TypedStr = Sender.GetText();
    MainConsole.UpdateCompleteIndices();
    
    ConsoleAutoComplete.ItemRows.Length = 0;
    if( MainConsole.AutoCompleteIndices.Length > 0 )
    {
        if( !bAutoCompleteOpen )
        {
            bAutoCompleteOpen = true;
            ConsoleAutoComplete.OpenMenu(Self);
        }
        else bForceUpdateRows = true;
        
        for(i=0; i<MainConsole.AutoCompleteIndices.Length; i++)
        {
            if( (ConsoleAutoComplete.ItemRows.Length-1) == MaxAutoCompletes )
                break;
                
            S = MainConsole.AutoCompleteList[MainConsole.AutoCompleteIndices[i]].Command;
            if( S != "" )
            {
                ToolTip = MainConsole.AutoCompleteList[MainConsole.AutoCompleteIndices[i]].Desc;
                if( ToolTip ~= S )
                    ToolTip = "";
                    
                ConsoleAutoComplete.AddRow(S, false, ToolTip);
            }
        }
    }
    else if( bAutoCompleteOpen )
    {
        ConsoleAutoComplete.DropInputFocus();
        bAutoCompleteOpen = false;
    }
}

function PreDraw()
{
    Super.PreDraw();
    if( bAutoCompleteOpen && bForceUpdateRows )
    {
        bForceUpdateRows = false;
        ConsoleAutoComplete.Canvas = Canvas;
        ConsoleAutoComplete.OldSizeX = 0;
        ConsoleAutoComplete.PreDraw();
    }
}

function SelectedAutoComplete( int Index )
{
    ChatBoxEdit.SetText(ConsoleAutoComplete.ItemRows[Index].Text);
    ChatBoxEdit.bAllSelected = false;
    ChatBoxEdit.GrabKeyFocus();
}

defaultproperties
{
    XPosition=0.54
    YPosition=0.025
    XSize=0.45
    YSize=0.525
    
    WindowTitle="Console"
    FrameOpacity=240
    
    bUseAnimation=true
    bAlwaysTop=true
    bOnlyThisFocus=true
    MaxAutoCompletes=16
    
    Begin Object Name=ChatBoxTextBox
        FontScale=0.9
    End Object
    
    Begin Object Name=ChatBoxField
        YPosition=0.95
        YSize=0.05
    End Object
    
    Begin Object Class=UIR_ConsoleAutoCompleteList Name=ConsoleAutoCompleteMenu
        OnSelectedItem=SelectedAutoComplete
    End Object
    ConsoleAutoComplete=ConsoleAutoCompleteMenu
}