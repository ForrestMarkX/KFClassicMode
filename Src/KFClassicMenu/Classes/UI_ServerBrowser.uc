Class UI_ServerBrowser extends UI_BaseMenuBackgrounds;

var KFGUI_TextLable NumServers;
var transient int NumLabels;
var array<UIP_ServerList> ServerPages;

function InitMenu()
{
    Pages[0].Caption = class'KFGFxMenu_ServerBrowser'.default.TabStrings[0];
    Pages[1].Caption = class'KFGFxMenu_ServerBrowser'.default.TabStrings[3];
    Pages[2].Caption = class'KFGFxMenu_ServerBrowser'.default.TabStrings[1];
    Pages[3].Caption = class'KFGFxMenu_ServerBrowser'.default.TabStrings[2];
    Pages[4].Caption = class'KFGFxMenu_ServerBrowser'.default.TabStrings[4];
    
    Super.InitMenu();
    
    AddMenuButton('Back',class'KFGFxWidget_ButtonPrompt'.default.CancelString,"Takes you back to the main menu.");
    AddMenuButton('Join',class'KFGFxMenu_ServerBrowser'.default.JoinString,"Join the selected server.");
    AddMenuButton('Refresh',class'KFGFxMenu_ServerBrowser'.default.RefreshString,"Refresh the server list.");
    
    NumServers = AddMenuLabel('NumServers', "Servers Recieved: 0");
}

function SetupPageItem(KFGUI_Base P)
{
    Super.SetupPageItem(P);
    if( UIP_ServerList(P) != None )
        ServerPages.AddItem(UIP_ServerList(P));
}

final function KFGUI_TextLable AddMenuLabel( name LabelID, string Text )
{
    local KFGUI_TextLable L;
    
    L = new (Self) class'KFGUI_TextLable';
    L.SetText(Text);
    L.ID = LabelID;
    L.XPosition = 0.025+(NumLabels*0.165);
    L.XSize = 0.15;
    L.YSize = 1;
    L.AlignY = 1;
    
    ++NumLabels;
    
    MenuBar.AddComponent(L);
    return L;
}

function ButtonClicked( KFGUI_Button Sender )
{
    switch( Sender.ID )
    {
    case 'Back':
        PC.OpenLobbyMenu();
        DoClose();
        break;
    case 'Refresh':
        ServerPages[PageSwitcher.CurrentPageNum].SetTimer(0.25f, false, 'RefreshList');
        break;
    case 'Join':
        ServerPages[PageSwitcher.CurrentPageNum].JoinServer(ServerPages[PageSwitcher.CurrentPageNum].SelectedServerIndex);
        break;
    }
}

defaultproperties
{
    Begin Object Name=MultiPager
        YSize=0.875
    End Object
    
    Pages.Add((PageClass=Class'UIP_ServerList',Hint="Browser for Internet games."))
    Pages.Add((PageClass=Class'UIP_ServerHistory',Hint="Browser for recently played games."))
    Pages.Add((PageClass=Class'UIP_ServerFavorites',Hint="Browser favorited servers."))
    Pages.Add((PageClass=Class'UIP_ServerFriends',Hint="See what server your friends are player on."))
    Pages.Add((PageClass=Class'UIP_ServerLAN',Hint="Browser for LAN games."))
}