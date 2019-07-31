Class xUI_PostGameReport extends KFGUI_FloatingWindow;

var KFGUI_SwitchMenuBar PageSwitcher;
var() array<FPageInfo> Pages;

var UIP_MapVote VotePage;
var KFGUI_Button AwardsButton;

function InitMenu()
{
    local int i;
    local KFGUI_Base PageItem;
    local KFGUI_Button B;
    
    PageSwitcher = KFGUI_SwitchMenuBar(FindComponentID('Pager'));
    
    Super(KFGUI_Page).InitMenu();
    
    WindowTitle = class'KFGFxMenu_PostGameReport'.default.PostGameReportString;
    for( i=0; i<Pages.Length; ++i )
    {
        PageItem = PageSwitcher.AddPage(Pages[i].PageClass,Pages[i].Caption,Pages[i].Hint,B);
        PageItem.InitMenu();
        
        if( UIP_MapVote(PageItem) != None )
        {
            VotePage = UIP_MapVote(PageItem);
        }
        else if( UIP_TeamAwards(PageItem) != None )
        {
            AwardsButton = B;
        }
    }
}

function ShowMenu()
{
    local bool bGameEnded;
    
    Super.ShowMenu();
    
    bGameEnded = KFGameReplicationInfo(GetPlayer().WorldInfo.GRI).bMatchIsOver;
    AwardsButton.SetDisabled(!bGameEnded);
    
    if( bGameEnded )
    {
        PageSwitcher.SelectPage(0);
    }
    else
    {
        PageSwitcher.SelectPage(1);
    }
}

function ButtonClicked( KFGUI_Button Sender )
{
    local KFGUI_Page T;
    
    switch( Sender.ID )
    {
    case 'Close':
        DoClose();
        break;
    case 'Disconnect':
        T = Owner.OpenMenu(class'UI_NotifyDisconnect');
        UI_NotifyDisconnect(T).MessageTo();
        break;
    }
}

defaultproperties
{
    XPosition=0.2
    YPosition=0.1
    XSize=0.6
    YSize=0.8
    
    // bAlwaysTop=true
    // bOnlyThisFocus=true
    
    Pages.Add((PageClass=Class'UIP_TeamAwards',Caption="Team Awards",Hint="Show team awards!"))
    Pages.Add((PageClass=Class'UIP_MapVote',Caption="Map Vote",Hint="Vote for the next map!"))
    
    Begin Object Class=KFGUI_SwitchMenuBar Name=MultiPager
        ID="Pager"
        XPosition=0.015
        YPosition=0.04
        XSize=0.97
        YSize=0.89
        BorderWidth=0.05
        ButtonAxisSize=0.125
    End Object
    Begin Object Class=KFGUI_Button Name=CloseButton
        XPosition=0.85
        YPosition=0.94
        XSize=0.0990
        YSize=0.03990
        ID="Close"
        ButtonText="Close"
        ToolTip="Close the report menu."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object
    Begin Object Class=KFGUI_Button Name=DisconnectButton
        XPosition=0.7450
        YPosition=0.940
        XSize=0.0990
        YSize=0.03990
        ID="Disconnect"
        ButtonText="Disconnect"
        ToolTip="Disconnect from this server."
        OnClickLeft=ButtonClicked
        OnClickRight=ButtonClicked
    End Object
    
    Components.Add(MultiPager)
    Components.Add(CloseButton)
    Components.Add(DisconnectButton)
}